import 'package:shared_preferences/shared_preferences.dart';

/// Persists user configuration on-device. Loaded once at startup and passed
/// through the provider graph so all services read the same live instance.
class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // ── ElevenLabs ────────────────────────────────────────────────────────────

  String? get elevenLabsApiKey => _prefs.getString('el_api_key');
  String? get elevenLabsVoiceId => _prefs.getString('el_voice_id');

  /// True when both API key and voice ID are non-empty.
  bool get hasElevenLabs =>
      elevenLabsApiKey?.isNotEmpty == true &&
      elevenLabsVoiceId?.isNotEmpty == true;

  Future<void> setElevenLabsApiKey(String key) =>
      _prefs.setString('el_api_key', key);

  Future<void> setElevenLabsVoiceId(String id) =>
      _prefs.setString('el_voice_id', id);
}
