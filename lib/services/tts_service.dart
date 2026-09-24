import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'settings_service.dart';

/// Plays Turkish audio. Strategy:
///   1. If ElevenLabs key+voice are set → cache-first TTS
///      (local mp3 if exists, else fetch from API → save → play)
///   2. Otherwise (no key, offline, API error) → device flutter_tts fallback.
///
/// The public interface is identical to the original: `speak(word)` / `stop()`.
/// All call sites (recognition_card, writing_card, listening_card, review_screen)
/// work without change.
class TtsService {
  final SettingsService _settings;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _ttsInitialized = false;

  static const String _model = 'eleven_multilingual_v2';

  TtsService(this._settings);

  Future<void> speak(String turkishWord) async {
    final word = turkishWord.trim();
    if (word.isEmpty) return;

    if (!_settings.hasElevenLabs) {
      await _speakWithPhoneTts(word);
      return;
    }

    final cacheFile = await _cacheFileFor(word);
    if (await cacheFile.exists()) {
      await _playFile(cacheFile.path);
      return;
    }

    await _fetchAndPlay(word, cacheFile);
  }

  // ── ElevenLabs fetch + cache ──────────────────────────────────────────────

  Future<void> _fetchAndPlay(String text, File targetFile) async {
    try {
      final apiKey = _settings.elevenLabsApiKey!;
      final voiceId = _settings.elevenLabsVoiceId!;
      final uri = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$voiceId?output_format=mp3_44100_128',
      );
      final response = await http.post(
        uri,
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({'text': text, 'model_id': _model}),
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await targetFile.writeAsBytes(response.bodyBytes);
        await _playFile(targetFile.path);
      } else {
        // 401 bad key, 422 voice not found, 429 quota, etc.
        await _speakWithPhoneTts(text);
      }
    } catch (_) {
      // Network unavailable or any unexpected error.
      await _speakWithPhoneTts(text);
    }
  }

  /// Cache path: `<docs>/tts_cache/<voiceId>_<sha1(model|text)>.mp3`
  /// SHA-1 of the model+text avoids Turkish characters in filenames.
  Future<File> _cacheFileFor(String text) async {
    final docs = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(docs.path, 'tts_cache'));
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    final voiceId = _settings.elevenLabsVoiceId ?? 'v';
    final hash = sha1.convert(utf8.encode('$_model|$text')).toString();
    return File(p.join(cacheDir.path, '${voiceId}_$hash.mp3'));
  }

  Future<void> _playFile(String path) async {
    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  // ── Phone TTS fallback ────────────────────────────────────────────────────

  Future<void> _speakWithPhoneTts(String text) async {
    if (!_ttsInitialized) {
      await _tts.setLanguage('tr-TR');
      await _tts.setSpeechRate(0.45);
      _ttsInitialized = true;
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
  }
}
