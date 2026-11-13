import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'settings_service.dart';

/// Result of one provider attempt.
class LlmReply {
  final String? text;
  final String? error;
  final String? provider;

  /// True when the provider is rate-limited or down, so the next one should be
  /// tried (and this one skipped for a while).
  final bool retryElsewhere;
  const LlmReply({
    this.text,
    this.error,
    this.provider,
    this.retryElsewhere = false,
  });
}

/// One free LLM backend. Keys and model names come from Settings.
abstract class LlmProvider {
  String get name;
  bool get isConfigured;
  Future<LlmReply> complete(String system, String prompt);
}

const _systemPrompt =
    'You are an expert Turkish linguist and translator. Provide accurate, '
    'natural translations. Never add conversational filler or unsolicited '
    'explanations. Always reply with valid JSON exactly matching the '
    'requested structure.';

bool _shouldSkip(int status) =>
    status == 429 || status == 404 || status == 408 || status >= 500;

class GeminiProvider implements LlmProvider {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';
  final SettingsService _s;
  GeminiProvider(this._s);

  @override
  String get name => 'Gemini';
  @override
  bool get isConfigured => _s.geminiApiKey?.isNotEmpty == true;

  @override
  Future<LlmReply> complete(String system, String prompt) async {
    final models = [_s.geminiModel, 'gemini-3.5-flash-lite'];
    var last = const LlmReply(error: 'Gemini: no model answered');
    for (final model in models.toSet()) {
      try {
        // Key goes in a header, not the URL, so it never lands in logs.
        final response = await http
            .post(
              Uri.parse('$_baseUrl$model:generateContent'),
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': _s.geminiApiKey!,
              },
              body: jsonEncode({
                'system_instruction': {
                  'parts': [
                    {'text': system},
                  ],
                },
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'responseMimeType': 'application/json',
                  'temperature': 0.3,
                },
              }),
            )
            .timeout(const Duration(seconds: 20));
        debugPrint('[LLM] Gemini $model → ${response.statusCode}');
        if (_shouldSkip(response.statusCode)) {
          last = LlmReply(
            error: 'Gemini $model: HTTP ${response.statusCode}',
            retryElsewhere: true,
          );
          continue;
        }
        if (response.statusCode != 200) {
          return LlmReply(
            error: 'Gemini: HTTP ${response.statusCode} ${response.body}',
          );
        }
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final parts =
            ((json['candidates'] as List?)?.firstOrNull?['content']?['parts'])
                as List?;
        final text = parts?.firstOrNull?['text'] as String?;
        if (text == null) return const LlmReply(error: 'Gemini: empty reply');
        return LlmReply(text: text, provider: 'Gemini');
      } catch (e) {
        last = LlmReply(error: 'Gemini $model: $e', retryElsewhere: true);
      }
    }
    return last;
  }
}

/// Any OpenAI-compatible chat endpoint (Groq, OpenRouter, Mistral, ...).
class OpenAiCompatibleProvider implements LlmProvider {
  @override
  final String name;
  final String baseUrl;
  final String? Function() apiKey;
  final String Function() model;
  final bool jsonMode;
  final Map<String, String> extraHeaders;

  OpenAiCompatibleProvider({
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.jsonMode = false,
    this.extraHeaders = const {},
  });

  @override
  bool get isConfigured => apiKey()?.isNotEmpty == true;

  @override
  Future<LlmReply> complete(String system, String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${apiKey()}',
              ...extraHeaders,
            },
            body: jsonEncode({
              'model': model(),
              'temperature': 0.3,
              'messages': [
                {'role': 'system', 'content': system},
                {'role': 'user', 'content': prompt},
              ],
              if (jsonMode) 'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 25));
      debugPrint('[LLM] $name ${model()} → ${response.statusCode}');
      if (_shouldSkip(response.statusCode)) {
        return LlmReply(
          error: '$name: HTTP ${response.statusCode}',
          retryElsewhere: true,
        );
      }
      if (response.statusCode != 200) {
        return LlmReply(
          error: '$name: HTTP ${response.statusCode} ${response.body}',
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final text = json['choices']?[0]?['message']?['content'] as String?;
      if (text == null || text.trim().isEmpty) {
        // Free models sometimes return nothing; treat as "try the next one".
        return LlmReply(error: '$name: empty reply', retryElsewhere: true);
      }
      return LlmReply(text: text, provider: name);
    } catch (e) {
      return LlmReply(error: '$name: $e', retryElsewhere: true);
    }
  }
}

/// Pulls the first JSON object out of a model reply. Free models often wrap
/// JSON in ```json fences or add a sentence around it.
Map<String, dynamic>? extractJsonObject(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final v = jsonDecode(raw.substring(start, end + 1));
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}

/// Tries each configured provider in order. A provider that hits its limit
/// (429/5xx/timeout) is skipped for [cooldown] so the next call doesn't wait
/// for it again.
class LlmService {
  final List<LlmProvider> providers;
  final Duration cooldown;
  final DateTime Function() _now;
  final Map<String, DateTime> _blockedUntil = {};

  LlmService(
    this.providers, {
    this.cooldown = const Duration(minutes: 10),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  factory LlmService.fromSettings(SettingsService s) => LlmService([
    GeminiProvider(s),
    OpenAiCompatibleProvider(
      name: 'Groq',
      baseUrl: 'https://api.groq.com/openai/v1',
      apiKey: () => s.groqApiKey,
      model: () => s.groqModel,
      jsonMode: true,
    ),
    OpenAiCompatibleProvider(
      name: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      apiKey: () => s.openRouterApiKey,
      model: () => s.openRouterModel,
    ),
  ]);

  bool get isConfigured => providers.any((p) => p.isConfigured);

  Future<LlmReply> complete(
    String prompt, {
    String system = _systemPrompt,
  }) async {
    final errors = <String>[];
    final now = _now();
    final usable = providers.where((p) => p.isConfigured).toList();
    if (usable.isEmpty) return const LlmReply(error: 'No AI key set');

    // Providers not on cooldown first; cooled-down ones only as a last resort.
    final ready = usable
        .where((p) => (_blockedUntil[p.name] ?? now).compareTo(now) <= 0)
        .toList();
    final cooling = usable.where((p) => !ready.contains(p));

    for (final p in [...ready, ...cooling]) {
      final reply = await p.complete(system, prompt);
      if (reply.text != null) {
        _blockedUntil.remove(p.name);
        return reply;
      }
      errors.add(reply.error ?? '${p.name}: failed');
      // Limits/outages cool the provider down; a bad key just moves on, and
      // its error still shows up in the combined message.
      if (reply.retryElsewhere) _blockedUntil[p.name] = now.add(cooldown);
    }
    return LlmReply(error: errors.join('\n'));
  }

  /// Turkish → English. Returns null if every provider failed.
  Future<String?> translate(String text) async {
    if (text.trim().isEmpty) return null;
    final reply = await complete(
      'Translate this Turkish word/phrase to English concisely.\n'
      'Text: "${text.trim()}"\n'
      'Reply with JSON only: {"translation": "..."}',
    );
    if (reply.text == null) return null;
    final t = extractJsonObject(reply.text!)?['translation'];
    return t is String && t.trim().isNotEmpty ? t.trim() : null;
  }

  /// Used by Settings: which provider answered, or the errors.
  Future<String> test(String word) async {
    final reply = await complete(
      'Translate this Turkish word to English concisely.\n'
      'Word: "$word"\n'
      'Reply with JSON only: {"translation": "..."}',
    );
    if (reply.text == null) return 'Error:\n${reply.error}';
    return 'Answered by ${reply.provider}:\n${reply.text}';
  }
}
