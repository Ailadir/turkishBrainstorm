import 'dart:convert';

import '../domain/suffix_glosses.dart';
import '../domain/turkish_text.dart';
import 'llm_service.dart';
import 'morphology_service.dart';

/// Where a translation came from; shown as a chip on the Add screen.
enum TranslationSource { cache, saved, dictionary, ai, myMemory, literal }

class TranslationResult {
  final String english;
  final List<String> alternatives;
  final String? note;
  final TranslationSource source;

  /// e.g. "Gemini" when [source] is [TranslationSource.ai].
  final String? provider;
  final String? warning;

  /// Word-by-word gloss: "house + plural + our + in".
  final String? literal;

  const TranslationResult({
    required this.english,
    required this.source,
    this.alternatives = const [],
    this.note,
    this.provider,
    this.warning,
    this.literal,
  });

  Map<String, dynamic> toJson() => {
    'en': english,
    'alt': alternatives,
    'note': note,
    'provider': provider,
    'literal': literal,
    'source': source.name,
  };

  factory TranslationResult.fromJson(
    Map<String, dynamic> j, {
    TranslationSource? source,
  }) => TranslationResult(
    english: j['en'] as String,
    alternatives: (j['alt'] as List? ?? const []).cast<String>(),
    note: j['note'] as String?,
    provider: j['provider'] as String?,
    literal: j['literal'] as String?,
    source: source ?? TranslationSource.cache,
  );

  String get sourceLabel => switch (source) {
    TranslationSource.cache => 'cached',
    TranslationSource.saved => 'your list',
    TranslationSource.dictionary => 'dictionary',
    TranslationSource.ai => 'AI: ${provider ?? ''}'.trim(),
    TranslationSource.myMemory => 'MyMemory',
    TranslationSource.literal => 'word-by-word',
  };
}

/// What the pipeline needs from the outside; every piece is a function so
/// tests can fake it without a phone, a database or a network.
class TranslationDeps {
  final Future<MorphologyResult> Function(String word) analyze;
  final Future<({String gloss, List<String> glosses})?> Function(String lemma)
  dictionary;
  final Future<String?> Function(String normalized) savedEnglish;
  final Future<String?> Function(String key) cacheGet;
  final Future<void> Function(String key, String payload, String provider)
  cachePut;
  final Future<String?> Function(String text) myMemory;
  final void Function() countAiCall;

  const TranslationDeps({
    required this.analyze,
    required this.dictionary,
    required this.savedEnglish,
    required this.cacheGet,
    required this.cachePut,
    required this.myMemory,
    required this.countAiCall,
  });
}

class TranslationPipeline {
  final TranslationDeps deps;
  final LlmService llm;
  TranslationPipeline(this.deps, this.llm);

  /// Order: cache → your list → local dictionary → AI (once) → MyMemory →
  /// word-by-word. Never throws; always returns something when [text] is
  /// non-empty.
  Future<TranslationResult?> translate(
    String text, {
    String? context,
    bool forceAi = false,

    /// Typing-time lookups: never call AI or MyMemory.
    bool localOnly = false,
  }) async {
    final normalized = trNormalize(text);
    if (normalized.isEmpty) return null;
    final kind = inferKind(text);
    final key = '$kind|$normalized';

    if (!forceAi) {
      final cached = await deps.cacheGet(key);
      if (cached != null) {
        try {
          return TranslationResult.fromJson(
            jsonDecode(cached) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
    }

    String? literal;
    String? gloss;
    MorphologyResult? morph;
    if (kind == 'word') {
      if (!forceAi) {
        final saved = await deps.savedEnglish(normalized);
        if (saved != null && saved.trim().isNotEmpty) {
          return TranslationResult(
            english: saved,
            source: TranslationSource.saved,
          );
        }
      }
      morph = await deps.analyze(text.trim());
      final entry = await deps.dictionary(morph.lemma);
      gloss = entry?.gloss;
      if (gloss != null) {
        literal = [
          gloss,
          for (final m in morph.morphemes) suffixInfo(m.id).label,
        ].join(' + ');
        if (!forceAi && morph.morphemes.length <= 1) {
          final r = TranslationResult(
            english: morph.morphemes.isEmpty ? gloss : literal,
            alternatives: entry!.glosses.skip(1).toList(),
            source: TranslationSource.dictionary,
            literal: literal,
          );
          await _store(key, r);
          return r;
        }
      }
    }

    if (localOnly) {
      return literal == null
          ? null
          : TranslationResult(
              english: literal,
              source: TranslationSource.literal,
              literal: literal,
            );
    }

    String? warning;
    if (llm.isConfigured) {
      deps.countAiCall();
      final reply = await llm.complete(
        _prompt(text.trim(), context, morph, gloss),
      );
      final parsed = reply.text == null ? null : extractJsonObject(reply.text!);
      final en = parsed?['translation'];
      if (en is String && en.trim().isNotEmpty) {
        final r = TranslationResult(
          english: en.trim(),
          alternatives: [
            for (final a in (parsed!['alternatives'] as List? ?? const []))
              if (a is String && a.trim().isNotEmpty) a.trim(),
          ],
          note: parsed['note'] is String ? parsed['note'] as String : null,
          source: TranslationSource.ai,
          provider: reply.provider,
          literal: literal,
        );
        await _store(key, r);
        return r;
      }
      warning = 'AI unavailable right now';
    }

    final mm = await deps.myMemory(text.trim());
    if (mm != null && mm.trim().isNotEmpty) {
      final r = TranslationResult(
        english: mm.trim(),
        source: TranslationSource.myMemory,
        warning: warning,
        literal: literal,
      );
      await _store(key, r);
      return r;
    }
    if (literal != null) {
      return TranslationResult(
        english: literal,
        source: TranslationSource.literal,
        warning: warning ?? 'Offline: showing a word-by-word gloss',
        literal: literal,
      );
    }
    return null;
  }

  String _prompt(
    String text,
    String? context,
    MorphologyResult? morph,
    String? gloss,
  ) {
    final b = StringBuffer(
      'Translate this Turkish ${inferKind(text)} to natural English.\n'
      'Text: "$text"\n',
    );
    if (context != null && context.trim().isNotEmpty) {
      b.writeln('Context sentence: "${context.trim()}"');
    }
    if (morph != null && morph.analyzed) {
      b.writeln(
        'Morphology: root "${morph.lemma}"'
        '${gloss != null ? ' (dictionary: $gloss)' : ''}, suffixes: '
        '${morph.morphemes.map((m) => '${m.surface}=${suffixInfo(m.id).gloss}').join('; ')}',
      );
    }
    b.write(
      'Reply with JSON only: {"translation": "...", '
      '"alternatives": ["..."], "note": "short usage note or empty"}',
    );
    return b.toString();
  }

  Future<void> _store(String key, TranslationResult r) =>
      deps.cachePut(key, jsonEncode(r.toJson()), r.provider ?? r.source.name);
}
