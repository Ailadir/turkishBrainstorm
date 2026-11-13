import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

const piperVoices = {
  'fahrettin': 'fahrettin (male)',
  'fettah': 'fettah (male)',
  'dfki': 'dfki (female)',
};

const _vowels = 'aeıioöuüâîû';

/// Spoken before every word, then cut off (see [finishPiperAudio]).
const _carrier = 'evet,';

/// Cuts the "evet," lead-in off [full] at the quietest 10 ms near where the
/// lead-in alone ended ([leadLength] samples), fades the edges so nothing
/// clicks, and adds 0.15 s of silence on both sides.
Float32List finishPiperAudio(Float32List full, int leadLength, int sampleRate) {
  final win = sampleRate ~/ 100;
  final from = (leadLength - sampleRate * 0.12).round().clamp(0, full.length);
  final to = (leadLength + sampleRate * 0.12).round().clamp(
    0,
    full.length - win,
  );
  var cut = 0;
  var best = double.infinity;
  for (var i = from; i < to; i += win ~/ 2) {
    var e = 0.0;
    for (var j = i; j < i + win; j++) {
      e += full[j] * full[j];
    }
    if (e < best) {
      best = e;
      cut = i;
    }
  }
  final word = Float32List.fromList(full.sublist(cut));
  final fadeIn = (sampleRate * 0.015).round().clamp(0, word.length);
  final fadeOut = (sampleRate * 0.04).round().clamp(0, word.length);
  for (var i = 0; i < fadeIn; i++) {
    word[i] *= i / fadeIn;
  }
  for (var i = 0; i < fadeOut; i++) {
    word[word.length - 1 - i] *= i / fadeOut;
  }
  final pad = (sampleRate * 0.15).round();
  return Float32List(word.length + 2 * pad)
    ..setRange(pad, pad + word.length, word);
}

/// Text and speed actually sent to Piper. Piper swallows short words said
/// alone: "ve" lasts 0.09 s and "altı" starts with a made-up "f". Tested by
/// ear with fahrettin: an exclamation mark fixes short words, and a held
/// vowel ("veee") fixes two-letter ones.
({String text, double speed}) piperInput(String raw, double speed) {
  final t = raw.trim();
  if (t.contains(' ') || t.length > 5) {
    return (text: RegExp(r'[.!?…]$').hasMatch(t) ? t : '$t.', speed: speed);
  }
  var word = t.replaceFirst(RegExp(r'[.!?…,]+$'), '');
  if (word.length <= 2) {
    final i = word
        .split('')
        .lastIndexWhere((c) => _vowels.contains(c.toLowerCase()));
    if (i >= 0) {
      word = word.substring(0, i + 1) + word[i] * 2 + word.substring(i + 1);
    }
  }
  return (text: '$word!', speed: speed * 0.875);
}

String piperArchiveUrl(String voice) =>
    'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/'
    'vits-piper-tr_TR-$voice-medium.tar.bz2';

/// Offline Turkish voice: the Piper `tr_TR` VITS model run by sherpa-onnx.
/// The ~65 MB model is downloaded once from the sherpa-onnx GitHub release.
class PiperEngine {
  Isolate? _isolate;
  SendPort? _send;
  String? _loadedVoice;

  /// Why the last [synthesize] failed (shown in Settings), or null.
  String? lastError;

  Future<Directory> _modelDir(String voice) async {
    final base = await getApplicationSupportDirectory();
    return Directory(
      p.join(base.path, 'piper', 'vits-piper-tr_TR-$voice-medium'),
    );
  }

  Future<bool> isInstalled(String voice) async {
    final d = await _modelDir(voice);
    return File(p.join(d.path, 'tr_TR-$voice-medium.onnx')).existsSync() &&
        File(p.join(d.path, 'tokens.txt')).existsSync() &&
        Directory(p.join(d.path, 'espeak-ng-data')).existsSync();
  }

  Future<void> download(
    String voice, {
    void Function(double fraction)? onProgress,
  }) async {
    final base = await getApplicationSupportDirectory();
    final root = Directory(p.join(base.path, 'piper'))
      ..createSync(recursive: true);
    final tmp = File(p.join(root.path, 'download-$voice.tar.bz2'));
    final client = http.Client();
    try {
      final resp = await client.send(
        http.Request('GET', Uri.parse(piperArchiveUrl(voice))),
      );
      if (resp.statusCode != 200) {
        throw HttpException('Voice download failed: HTTP ${resp.statusCode}');
      }
      final total = resp.contentLength ?? 0;
      var got = 0;
      var lastTick = DateTime.now();
      final sink = tmp.openWrite();
      await for (final chunk in resp.stream) {
        sink.add(chunk);
        got += chunk.length;
        // Update the UI a few times per second, not once per chunk.
        final now = DateTime.now();
        if (total > 0 && now.difference(lastTick).inMilliseconds > 250) {
          lastTick = now;
          onProgress?.call(got / total * 0.8); // last 20% is unpacking
        }
      }
      await sink.close();
      onProgress?.call(0.8);
      // Unpacking a .tar.bz2 is CPU-heavy: do it off the UI thread.
      final archivePath = tmp.path;
      final outPath = root.path;
      await Isolate.run(() => extractFileToDisk(archivePath, outPath));
      onProgress?.call(1);
    } finally {
      client.close();
      if (tmp.existsSync()) tmp.deleteSync();
    }
    if (!await isInstalled(voice)) {
      throw const FormatException('Voice archive had unexpected contents');
    }
  }

  Future<void> delete(String voice) async {
    await _stop();
    final d = await _modelDir(voice);
    if (d.existsSync()) await d.delete(recursive: true);
  }

  /// Writes a WAV for [text] to [outPath]. Runs in a long-lived isolate so the
  /// UI never stalls; returns false if synthesis failed.
  /// [speed] < 1 speaks slower (natural, not stretched).
  Future<bool> synthesize(
    String voice,
    String text,
    String outPath, {
    double speed = 1.0,
  }) async {
    if (!await isInstalled(voice)) return false;
    if (_loadedVoice != voice) await _stop();
    final dir = (await _modelDir(voice)).path;
    _send ??= await _spawn(voice, dir);
    _loadedVoice = voice;
    final reply = ReceivePort();
    _send!.send([text, outPath, speed, reply.sendPort]);
    final answer = await reply.first.timeout(
      const Duration(seconds: 90), // the first call also loads the model
      onTimeout: () => 'Timed out while loading the voice',
    );
    reply.close();
    if (answer == true) {
      lastError = null;
      return true;
    }
    lastError = answer is String ? answer : 'Synthesis failed';
    await _stop(); // start fresh next time
    return false;
  }

  Future<SendPort> _spawn(String voice, String dir) async {
    final ready = ReceivePort();
    _isolate = await Isolate.spawn(_worker, [ready.sendPort, voice, dir]);
    final port = await ready.first as SendPort;
    ready.close();
    return port;
  }

  Future<void> _stop() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _send = null;
    _loadedVoice = null;
  }

  Future<void> dispose() => _stop();
}

/// Isolate body: owns the one OfflineTts instance.
void _worker(List<Object> args) {
  final toMain = args[0] as SendPort;
  final voice = args[1] as String;
  final dir = args[2] as String;
  final inbox = ReceivePort();
  toMain.send(inbox.sendPort);

  sherpa.OfflineTts? tts;
  final carrierLength = <double, int>{};
  inbox.listen((msg) {
    final m = msg as List;
    final reply = m[3] as SendPort;
    try {
      sherpa.initBindings();
      tts ??= sherpa.OfflineTts(
        sherpa.OfflineTtsConfig(
          model: sherpa.OfflineTtsModelConfig(
            vits: sherpa.OfflineTtsVitsModelConfig(
              model: p.join(dir, 'tr_TR-$voice-medium.onnx'),
              tokens: p.join(dir, 'tokens.txt'),
              dataDir: p.join(dir, 'espeak-ng-data'),
              // Less slurring than the defaults (0.667 / 0.8).
              noiseScale: 0.333,
              noiseScaleW: 0.4,
            ),
            numThreads: 2,
          ),
        ),
      );
      final input = piperInput(m[0] as String, m[2] as double);
      // Said alone, a word starts mid-attack and short ones get garbled
      // ("altı" -> "artı"). Said after "evet," it comes out right, so we
      // generate both and cut the lead-in off at the pause between them.
      final lead = carrierLength[input.speed] ??= tts!
          .generate(text: _carrier, speed: input.speed)
          .samples
          .length;
      final audio = tts!.generate(
        text: '$_carrier ${input.text}',
        speed: input.speed,
      );
      if (audio.samples.isEmpty) {
        reply.send('The voice produced no audio for "${m[0]}"');
        return;
      }
      final samples = finishPiperAudio(audio.samples, lead, audio.sampleRate);
      final ok = sherpa.writeWave(
        filename: m[1] as String,
        samples: samples,
        sampleRate: audio.sampleRate,
      );
      reply.send(ok ? true : 'Could not write the audio file');
    } catch (e) {
      reply.send('Voice error: $e');
    }
  });
}
