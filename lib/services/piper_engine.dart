import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

const piperVoices = {
  'dfki': 'dfki (female)',
  'fahrettin': 'fahrettin (male)',
  'fettah': 'fettah (male)',
};

String piperArchiveUrl(String voice) =>
    'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/'
    'vits-piper-tr_TR-$voice-medium.tar.bz2';

/// Offline Turkish voice: the Piper `tr_TR` VITS model run by sherpa-onnx.
/// The ~65 MB model is downloaded once from the sherpa-onnx GitHub release.
class PiperEngine {
  Isolate? _isolate;
  SendPort? _send;
  String? _loadedVoice;

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
      final sink = tmp.openWrite();
      await for (final chunk in resp.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) onProgress?.call(got / total);
      }
      await sink.close();
      await extractFileToDisk(tmp.path, root.path);
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
  Future<bool> synthesize(String voice, String text, String outPath) async {
    if (!await isInstalled(voice)) return false;
    if (_loadedVoice != voice) await _stop();
    final dir = (await _modelDir(voice)).path;
    _send ??= await _spawn(voice, dir);
    _loadedVoice = voice;
    final reply = ReceivePort();
    _send!.send([text, outPath, reply.sendPort]);
    final ok = await reply.first.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );
    reply.close();
    return ok == true;
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
  inbox.listen((msg) {
    final m = msg as List;
    final reply = m[2] as SendPort;
    try {
      sherpa.initBindings();
      tts ??= sherpa.OfflineTts(
        sherpa.OfflineTtsConfig(
          model: sherpa.OfflineTtsModelConfig(
            vits: sherpa.OfflineTtsVitsModelConfig(
              model: p.join(dir, 'tr_TR-$voice-medium.onnx'),
              tokens: p.join(dir, 'tokens.txt'),
              dataDir: p.join(dir, 'espeak-ng-data'),
            ),
            numThreads: 2,
          ),
        ),
      );
      final audio = tts!.generate(text: m[0] as String, speed: 0.95);
      if (audio.samples.isEmpty) {
        reply.send(false);
        return;
      }
      final ok = sherpa.writeWave(
        filename: m[1] as String,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );
      reply.send(ok);
    } catch (_) {
      reply.send(false);
    }
  });
}
