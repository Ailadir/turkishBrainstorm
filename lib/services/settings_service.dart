import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

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

  String get elevenLabsModel =>
      _prefs.getString('el_model') ?? 'eleven_multilingual_v2';
  Future<void> setElevenLabsModel(String v) => _prefs.setString('el_model', v);

  /// Spend ElevenLabs characters on pack words too (default: only your own).
  bool get elevenLabsForPackWords => _prefs.getBool('el_pack_words') ?? false;
  Future<void> setElevenLabsForPackWords(bool v) =>
      _prefs.setBool('el_pack_words', v);

  /// Playback speed for every voice (1.0 = as generated).
  double get speechSpeed => _prefs.getDouble('speech_speed') ?? 0.8;
  Future<void> setSpeechSpeed(double v) => _prefs.setDouble('speech_speed', v);

  // ── Offline voice (Piper) ───────────────────────────────────────────────

  /// `fahrettin` or `fettah` (male), `dfki` (female).
  String get piperVoice => _prefs.getString('piper_voice') ?? 'fahrettin';
  Future<void> setPiperVoice(String v) => _prefs.setString('piper_voice', v);

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

  // ── AI call counter (for the Settings display) ──────────────────────────

  int get aiCallsToday {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _prefs.getString('ai_calls_day') == today
        ? (_prefs.getInt('ai_calls') ?? 0)
        : 0;
  }

  void countAiCall() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final n = aiCallsToday + 1;
    _prefs.setString('ai_calls_day', today);
    _prefs.setInt('ai_calls', n);
  }

  String get lastSource => _prefs.getString('last_source') ?? '';
  Future<void> setLastSource(String v) => _prefs.setString('last_source', v);

  // ── Suffix drill ────────────────────────────────────────────────────────

  /// Highest CEFR level whose suffixes the drill may ask (A1..B2).
  String get grammarLevel => _prefs.getString('grammar_level') ?? 'A1';
  Future<void> setGrammarLevel(String v) =>
      _prefs.setString('grammar_level', v);

  // ── App updates ─────────────────────────────────────────────────────────

  bool get autoCheckUpdates => _prefs.getBool('auto_update_check') ?? true;
  Future<void> setAutoCheckUpdates(bool v) =>
      _prefs.setBool('auto_update_check', v);

  int get lastUpdateCheckMs => _prefs.getInt('last_update_check') ?? 0;
  Future<void> setLastUpdateCheckMs(int v) =>
      _prefs.setInt('last_update_check', v);

  /// Build number of the release whose alert the user already closed.
  int get dismissedUpdateBuild => _prefs.getInt('dismissed_update_build') ?? 0;
  Future<void> setDismissedUpdateBuild(int v) =>
      _prefs.setInt('dismissed_update_build', v);

  /// Highest build the user has opened (0 = fresh install).
  int get lastSeenBuild => _prefs.getInt('last_seen_build') ?? 0;
  Future<void> setLastSeenBuild(int v) => _prefs.setInt('last_seen_build', v);

  // ── Packs ───────────────────────────────────────────────────────────────

  String get packIndexUrl =>
      _prefs.getString('pack_index_url') ?? defaultPackIndexUrl();
  Future<void> setPackIndexUrl(String v) =>
      _prefs.setString('pack_index_url', v);

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

  bool get autoAdvanceOnCorrect => _prefs.getBool('auto_advance_v2') ?? false;
  Future<void> setAutoAdvanceOnCorrect(bool v) =>
      _prefs.setBool('auto_advance_v2', v);

  bool get usePackWords => _prefs.getBool('use_pack_words') ?? true;
  Future<void> setUsePackWords(bool v) => _prefs.setBool('use_pack_words', v);
}
