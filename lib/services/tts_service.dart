import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'piper_engine.dart';
import 'settings_service.dart';

/// What happened when asked to speak.
class AudioOutcome {
  /// `cache`, `elevenlabs`, `piper`, `phone` or `none`.
  final String via;
  final String? problem;
  const AudioOutcome(this.via, {this.problem});
  bool get ok => via != 'none';
}

/// A cloud voice (ElevenLabs). Returns audio bytes, or null on ANY failure
/// (bad key, quota, network) so the caller falls through to the next voice.
abstract class CloudVoice {
  bool get configured;
  String get voiceId;
  String get model;
  Future<List<int>?> synth(String text);
}

/// An on-device voice (Piper).
abstract class OfflineVoice {
  String get voice;
  Future<bool> isInstalled();
  Future<bool> synth(String text, String outPath);
}

class ElevenLabsVoice implements CloudVoice {
  final SettingsService _s;
  ElevenLabsVoice(this._s);

  @override
  bool get configured => _s.hasElevenLabs;
  @override
  String get voiceId => _s.elevenLabsVoiceId ?? 'v';
  @override
  String get model => _s.elevenLabsModel;

  @override
  Future<List<int>?> synth(String text) async {
    try {
      final r = await http
          .post(
            Uri.parse(
              'https://api.elevenlabs.io/v1/text-to-speech/${_s.elevenLabsVoiceId}'
              '?output_format=mp3_44100_128',
            ),
            headers: {
              'xi-api-key': _s.elevenLabsApiKey!,
              'Content-Type': 'application/json',
              'Accept': 'audio/mpeg',
            },
            body: jsonEncode({'text': text, 'model_id': model}),
          )
          .timeout(const Duration(seconds: 15));
      // 401 bad key, 422 bad voice, 429/quota: all mean "use the next voice".
      return r.statusCode == 200 && r.bodyBytes.isNotEmpty ? r.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  /// Characters left this billing period, or null if unknown.
  Future<({int used, int limit})?> quota() async {
    if (!configured) return null;
    try {
      final r = await http
          .get(
            Uri.parse('https://api.elevenlabs.io/v1/user/subscription'),
            headers: {'xi-api-key': _s.elevenLabsApiKey!},
          )
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      return (
        used: (j['character_count'] as num).toInt(),
        limit: (j['character_limit'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}

class PiperVoice implements OfflineVoice {
  final PiperEngine engine;
  final SettingsService _s;
  PiperVoice(this.engine, this._s);

  @override
  String get voice => _s.piperVoice;
  @override
  Future<bool> isInstalled() => engine.isInstalled(voice);
  @override
  Future<bool> synth(String text, String outPath) =>
      engine.synthesize(voice, text, outPath, speed: _s.speechSpeed);
}

/// Plays Turkish audio, always trying to produce *something*:
///   cached file → ElevenLabs → Piper (offline) → phone TTS (only if it has
///   Turkish) → `none` with a reason.
/// Everything produced is cached, so a word is generated once.
class TtsService {
  final SettingsService _settings;
  final CloudVoice? cloud;
  final OfflineVoice? offline;
  final Future<bool> Function(String text) isPackWord;
  final Future<void> Function(String path) playFile;
  final Future<bool> Function(String text) phoneSpeak;
  final Future<Directory> Function() cacheDir;
  final void Function(String message)? onProblem;
  bool _problemShown = false;

  TtsService(
    this._settings, {
    this.cloud,
    this.offline,
    Future<bool> Function(String)? isPackWord,
    Future<void> Function(String)? playFile,
    Future<bool> Function(String)? phoneSpeak,
    Future<Directory> Function()? cacheDir,
    this.onProblem,
  }) : isPackWord = isPackWord ?? ((_) async => false),
       playFile = playFile ?? _Player(() => _settings.speechSpeed).play,
       phoneSpeak = phoneSpeak ?? _PhoneTts(() => _settings.speechSpeed).speak,
       cacheDir = cacheDir ?? _defaultCacheDir;

  static Future<Directory> _defaultCacheDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, 'tts_cache'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  // ── Cache keys (stable: tests rely on them) ───────────────────────────────

  static String _sha(String s) => sha1.convert(utf8.encode(s)).toString();

  /// Same scheme as before, so audio cached by older versions still plays.
  String cloudFileName(String text) =>
      '${cloud?.voiceId ?? 'v'}_${_sha('${cloud?.model}|$text')}.mp3';

  /// Includes the speed, because Piper bakes it into the audio.
  String offlineFileName(String text) =>
      'piper_${offline?.voice ?? 'x'}_${_sha(text)}'
      '_s${(_settings.speechSpeed * 100).round()}_2.wav';

  Future<File?> _cached(String text) async {
    final dir = await cacheDir();
    if (cloud?.configured == true) {
      final f = File(p.join(dir.path, cloudFileName(text)));
      if (await f.exists()) return f;
    }
    if (offline != null) {
      final f = File(p.join(dir.path, offlineFileName(text)));
      if (await f.exists()) return f;
    }
    return null;
  }

  Future<bool> isCached(String text) async =>
      await _cached(text.trim()) != null;

  Future<bool> _useCloud(String text) async =>
      cloud?.configured == true &&
      (_settings.elevenLabsForPackWords || !await isPackWord(text));

  // ── Public API ────────────────────────────────────────────────────────────

  Future<AudioOutcome> speak(String turkishWord) async {
    final text = turkishWord.trim();
    if (text.isEmpty) return const AudioOutcome('none');

    final hit = await _cached(text);
    if (hit != null) {
      await playFile(hit.path);
      return const AudioOutcome('cache');
    }

    final made = await _generate(text);
    if (made != null) {
      await playFile(made.file.path);
      return AudioOutcome(made.via);
    }

    if (await phoneSpeak(text)) return const AudioOutcome('phone');

    const reason =
        'No Turkish voice available. Download the offline voice in Settings.';
    if (!_problemShown) {
      _problemShown = true;
      onProblem?.call(reason);
    }
    return const AudioOutcome('none', problem: reason);
  }

  /// Make sure [text] is cached without playing it. Used by the prefetch
  /// queue. Quiet on failure; returns true when a file exists afterwards.
  Future<bool> prefetch(String text, {bool allowOffline = true}) async {
    final t = text.trim();
    if (t.isEmpty) return false;
    if (await _cached(t) != null) return true;
    return await _generate(t, allowOffline: allowOffline) != null;
  }

  void resetNotice() => _problemShown = false;

  Future<({File file, String via})?> _generate(
    String text, {
    bool allowOffline = true,
  }) async {
    final dir = await cacheDir();
    if (await _useCloud(text)) {
      final bytes = await cloud!.synth(text);
      if (bytes != null) {
        final f = File(p.join(dir.path, cloudFileName(text)));
        await f.writeAsBytes(bytes);
        return (file: f, via: 'elevenlabs');
      }
    }
    if (allowOffline && offline != null && await offline!.isInstalled()) {
      final f = File(p.join(dir.path, offlineFileName(text)));
      if (await offline!.synth(text, f.path) && await f.exists()) {
        return (file: f, via: 'piper');
      }
    }
    return null;
  }
}

class _Player {
  final double Function() speed;
  _Player(this.speed);
  final AudioPlayer _player = AudioPlayer();
  Future<void> play(String path) async {
    await _player.stop();
    // Piper audio is already generated at the chosen speed; other audio is
    // slowed on playback (Android keeps the pitch).
    final piper = p.basename(path).startsWith('piper_');
    await _player.setPlaybackRate(piper ? 1.0 : speed());
    await _player.play(DeviceFileSource(path));
  }
}

/// Phone TTS, used only when the phone really has a Turkish voice.
class _PhoneTts {
  final double Function() speed;
  _PhoneTts(this.speed);
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<bool> speak(String text) async {
    try {
      if (!_ready) {
        final available = await _tts.isLanguageAvailable('tr-TR');
        if (available != true && available != 1) return false;
        await _tts.setLanguage('tr-TR');
        _ready = true;
      }
      await _tts.setSpeechRate(0.5 * speed());
      await _tts.stop();
      await _tts.speak(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}
