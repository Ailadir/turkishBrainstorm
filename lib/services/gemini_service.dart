import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

/// Gemini-Flash translation for Turkish word parts.
/// Free tier: 1 500 req/day, 1M tokens/day — more than enough for a vocab app.
class GeminiService {
  static const _model =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent';

  final SettingsService _settings;
  GeminiService(this._settings);

  bool get isConfigured => _settings.geminiApiKey?.isNotEmpty == true;

  /// Translate a single Turkish word to English.
  /// Returns null when key is missing or the call fails.
  Future<String?> translateWord(String text) async {
    if (!isConfigured || text.trim().isEmpty) return null;
    final prompt = 'Translate this Turkish word/phrase to English concisely.\n'
        'Word: "${text.trim()}"\n'
        'Reply with JSON only: {"translation": "..."}';
    final raw = await _call(prompt);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map)['translation'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Translate the morphological root and each suffix in a SINGLE API call.
  /// Returns a record ({root meaning, list of suffix meanings}) or null on failure.
  Future<({String root, List<String> suffixes})?> translateParts({
    required String root,
    required List<String> suffixes,
  }) async {
    if (!isConfigured) return null;

    final suffixList = jsonEncode(suffixes);
    final prompt =
        'You are a Turkish-to-English dictionary module for a language learning app.\n'
        'Translate the morphological parts below:\n'
        '  root: "$root"\n'
        '  suffixes: $suffixList\n\n'
        'For the root provide a short English dictionary meaning (e.g. "to go").\n'
        'For each suffix provide its grammatical name + function in plain English '
        '(e.g. "present continuous (-ing)").\n\n'
        'Reply with JSON only, matching this exact structure:\n'
        '{"root": "...", "suffixes": ["...", "..."]}';

    final raw = await _call(prompt);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final rootMeaning = json['root'] as String? ?? '';
      final sfx = (json['suffixes'] as List?)?.cast<String>() ?? [];
      return (root: rootMeaning, suffixes: sfx);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _call(String prompt) async {
    final apiKey = _settings.geminiApiKey!;
    try {
      final uri = Uri.parse('$_model?key=$apiKey');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {'responseMimeType': 'application/json'},
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) return null;
        final content = candidates[0]['content'] as Map?;
        final parts = content?['parts'] as List?;
        return parts?.isNotEmpty == true
            ? parts![0]['text'] as String?
            : null;
      }
    } catch (_) {}
    return null;
  }
}
