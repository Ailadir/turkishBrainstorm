import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class WordBreakdown {
  final String wordMeaning;    // inflected form translation, e.g. "to the house"
  final String rootMeaning;    // lemma translation, e.g. "house"
  final List<String> suffixMeanings; // one per suffix in the same order
  const WordBreakdown({
    required this.wordMeaning,
    required this.rootMeaning,
    required this.suffixMeanings,
  });
}

class PhraseBreakdown {
  final String phraseMeaning;
  final List<WordBreakdown> words;
  const PhraseBreakdown(this.phraseMeaning, this.words);
}

/// Gemini-Flash translation for Turkish word parts.
/// Free tier: 1 500 req/day, 1M tokens/day — more than enough for a vocab app.
class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';
  // Primary: 3.8-flash. Fallback: 3.5-flash-lite (budget, always available).
  static const _models = [
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
  ];

  final SettingsService _settings;
  GeminiService(this._settings);

  bool get isConfigured => _settings.geminiApiKey?.isNotEmpty == true;

  /// Translate a single Turkish word/phrase to English.
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
  Future<({String root, List<String> suffixes})?> translateParts({
    required String root,
    required List<String> suffixes,
  }) async {
    if (!isConfigured) return null;

    final prompt =
        'You are a Turkish-to-English dictionary module for a language learning app.\n'
        'Translate the morphological parts below:\n'
        '  root: "$root"\n'
        '  suffixes: ${jsonEncode(suffixes)}\n\n'
        'For the root provide a short English dictionary meaning (e.g. "to go").\n'
        'For each suffix provide its grammatical name + function in plain English '
        '(e.g. "present continuous (-ing)").\n\n'
        'Reply with JSON only:\n'
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

  /// One API call that translates a multi-word phrase AND all its morphological
  /// parts (each word's inflected form, root, and suffixes).
  ///
  /// [wordParts] comes from Zemberek analysis — one entry per word in the phrase.
  Future<PhraseBreakdown?> translatePhraseBreakdown({
    required String phrase,
    required List<({String word, String root, List<String> suffixes})> wordParts,
  }) async {
    if (!isConfigured) return null;

    final breakdown = wordParts
        .map((p) => {'word': p.word, 'root': p.root, 'suffixes': p.suffixes})
        .toList();

    final prompt =
        'You are a Turkish-to-English dictionary module for a language learning app.\n'
        'Translate this Turkish phrase and each word\'s morphological parts.\n\n'
        'Phrase: "$phrase"\n'
        'Morphological breakdown (from Zemberek NLP): ${jsonEncode(breakdown)}\n\n'
        'For each word provide:\n'
        '  "word_meaning": translation of the inflected form as it appears\n'
        '  "root_meaning": short dictionary meaning of the root lemma\n'
        '  "suffix_meanings": list with one entry per suffix (same order), '
        'each describing the grammatical function in plain English\n\n'
        'Reply with JSON only:\n'
        '{\n'
        '  "phrase": "...",\n'
        '  "words": [\n'
        '    {"word_meaning": "...", "root_meaning": "...", "suffix_meanings": ["..."]},\n'
        '    ...\n'
        '  ]\n'
        '}';

    final raw = await _call(prompt);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final phraseMeaning = json['phrase'] as String? ?? '';
      final words = (json['words'] as List? ?? []).map((w) {
        final m = w as Map<String, dynamic>;
        return WordBreakdown(
          wordMeaning: m['word_meaning'] as String? ?? '',
          rootMeaning: m['root_meaning'] as String? ?? '',
          suffixMeanings: (m['suffix_meanings'] as List?)?.cast<String>() ?? [],
        );
      }).toList();
      return PhraseBreakdown(phraseMeaning, words);
    } catch (_) {
      return null;
    }
  }

  /// Test call used by the Settings screen — returns the raw text or an error.
  Future<String> testTranslation(String word) async {
    if (!isConfigured) return 'Error: Gemini API key not set';
    final prompt = 'Translate this Turkish word to English concisely.\n'
        'Word: "$word"\n'
        'Reply with JSON only: {"translation": "..."}';
    final (result, error) = await _callWithError(prompt);
    if (error != null) return 'Error: $error';
    return result ?? 'Error: null result';
  }

  // ── HTTP ──────────────────────────────────────────────────────────────────

  /// Tries each model in [_models] order; returns first success or last error.
  Future<(String?, String?)> _callWithError(String prompt) async {
    final apiKey = _settings.geminiApiKey!;
    String lastError = 'Unknown error';

    for (final model in _models) {
      try {
        final uri = Uri.parse('$_baseUrl$model:generateContent?key=$apiKey');
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
        ).timeout(const Duration(seconds: 20));

        debugPrint('[Gemini] $model → ${response.statusCode}');
        if (response.statusCode == 503 || response.statusCode == 404) {
          lastError = 'HTTP ${response.statusCode} ($model): ${response.body}';
          debugPrint('[Gemini] trying next model...');
          continue;
        }
        if (response.statusCode != 200) {
          debugPrint('[Gemini] error body: ${response.body}');
          return (null, 'HTTP ${response.statusCode}: ${response.body}');
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          return (null, 'Empty candidates in response: ${response.body}');
        }
        final content = candidates[0]['content'] as Map?;
        final parts = content?['parts'] as List?;
        final text =
            parts?.isNotEmpty == true ? parts![0]['text'] as String? : null;
        if (text == null) return (null, 'No text in response: ${response.body}');
        debugPrint('[Gemini] ok via $model');
        return (text, null);
      } catch (e) {
        debugPrint('[Gemini] $model exception: $e');
        lastError = e.toString();
      }
    }
    return (null, lastError);
  }

  Future<String?> _call(String prompt) async {
    final (result, _) = await _callWithError(prompt);
    return result;
  }
}
