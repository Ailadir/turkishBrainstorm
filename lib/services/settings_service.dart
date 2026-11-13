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

  // ── Gemini ────────────────────────────────────────────────────────────────

  String? get geminiApiKey => _prefs.getString('gemini_api_key');
  bool get hasGemini => geminiApiKey?.isNotEmpty == true;

  Future<void> setGeminiApiKey(String key) =>
      _prefs.setString('gemini_api_key', key);

  String get geminiModel =>
      _prefs.getString('gemini_model') ?? 'gemini-3.8-flash';
  Future<void> setGeminiModel(String v) => _prefs.setString('gemini_model', v);

  // ── Groq (free, OpenAI-compatible) ──────────────────────────────────────

  String? get groqApiKey => _prefs.getString('groq_api_key');
  Future<void> setGroqApiKey(String v) => _prefs.setString('groq_api_key', v);

  String get groqModel =>
      _prefs.getString('groq_model') ?? 'llama-3.3-70b-versatile';
  Future<void> setGroqModel(String v) => _prefs.setString('groq_model', v);

  // ── OpenRouter (free models) ────────────────────────────────────────────

  String? get openRouterApiKey => _prefs.getString('openrouter_api_key');
  Future<void> setOpenRouterApiKey(String v) =>
      _prefs.setString('openrouter_api_key', v);

  // `openrouter/free` lets OpenRouter pick any currently-free model.
  String get openRouterModel =>
      _prefs.getString('openrouter_model') ?? 'openrouter/free';
  Future<void> setOpenRouterModel(String v) =>
      _prefs.setString('openrouter_model', v);

  // ── Practice ──────────────────────────────────────────────────────────────

  int get wordsPerBrainstorm =>
      (_prefs.getInt('words_per_brainstorm') ?? 5).clamp(3, 10);
  Future<void> setWordsPerBrainstorm(int v) =>
      _prefs.setInt('words_per_brainstorm', v.clamp(3, 10));

  int get maxReviewsPerSession => _prefs.getInt('max_reviews') ?? 50;
  Future<void> setMaxReviewsPerSession(int v) =>
      _prefs.setInt('max_reviews', v);

  bool get typingEnabled => _prefs.getBool('typing_enabled') ?? false;
  Future<void> setTypingEnabled(bool v) => _prefs.setBool('typing_enabled', v);

  bool get autoAdvanceOnCorrect => _prefs.getBool('auto_advance') ?? true;
  Future<void> setAutoAdvanceOnCorrect(bool v) =>
      _prefs.setBool('auto_advance', v);

  bool get usePackWords => _prefs.getBool('use_pack_words') ?? true;
  Future<void> setUsePackWords(bool v) => _prefs.setBool('use_pack_words', v);
}
