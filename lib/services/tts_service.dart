import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around `flutter_tts` for Turkish playback (build plan §1).
/// Uses Android's built-in TTS engine — on-device, free, no API.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.45);
    _initialized = true;
  }

  Future<void> speak(String turkishWord) async {
    await _ensureInit();
    await _tts.stop();
    await _tts.speak(turkishWord);
  }

  Future<void> stop() => _tts.stop();
}
