import 'package:flutter/services.dart';

import '../domain/morpheme_ref.dart';

/// Result of a morphological analysis of one word.
class MorphologyResult {
  final String lemma;
  final String? pos;
  final String stem;
  final List<MorphemeRef> morphemes;

  /// True when Zemberek really analysed the word (false for the fallback).
  final bool analyzed;
  final String? token;

  const MorphologyResult({
    required this.lemma,
    this.pos,
    String? stem,
    this.morphemes = const [],
    this.analyzed = true,
    this.token,
  }) : stem = stem ?? lemma;

  /// Back-compat names used by older UI code.
  String get root => lemma;
  List<String> get suffixes => [for (final m in morphemes) m.surface];

  factory MorphologyResult.fallback(String word) => MorphologyResult(
        lemma: word,
        analyzed: false,
      );

  factory MorphologyResult.fromMap(Map<dynamic, dynamic> map, String word) {
    final lemma = (map['lemma'] as String?)?.trim();
    final pos = (map['pos'] as String?)?.trim();
    return MorphologyResult(
      lemma: (lemma == null || lemma.isEmpty) ? word : lemma,
      pos: (pos == null || pos.isEmpty) ? null : pos,
      stem: map['stem'] as String?,
      token: map['token'] as String?,
      morphemes: [
        for (final m in (map['morphemes'] as List<dynamic>? ?? []))
          MorphemeRef((m as Map)['surface'] as String, m['id'] as String),
      ],
    );
  }
}

/// Bridge to the Kotlin/Zemberek side over `MethodChannel("turkish_morphology")`.
///
/// If the native side is missing or throws, every method falls back to
/// "lemma = the word, no suffixes" so the app keeps working.
class MorphologyService {
  static const MethodChannel _channel = MethodChannel('turkish_morphology');

  Future<MorphologyResult> analyze(String word) async {
    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('analyze', {'word': word});
      if (result == null) return MorphologyResult.fallback(word);
      return MorphologyResult.fromMap(result, word);
    } on PlatformException {
      return MorphologyResult.fallback(word);
    } on MissingPluginException {
      return MorphologyResult.fallback(word);
    }
  }

  /// Disambiguated analysis of a multi-word text; one result per token.
  /// Slower than [analyze]; use only for phrases and sentences.
  Future<List<MorphologyResult>> analyzeSentence(String text) async {
    try {
      final result =
          await _channel.invokeListMethod<Map<dynamic, dynamic>>(
              'analyzeSentence', {'text': text});
      if (result == null) return const [];
      return [for (final m in result) MorphologyResult.fromMap(m, text)];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// One result per input word, in order (fallback where unknown).
  Future<List<MorphologyResult>> analyzeBatch(List<String> words) async {
    try {
      final result = await _channel
          .invokeListMethod<Map<dynamic, dynamic>?>(
              'analyzeBatch', {'words': words});
      if (result == null || result.length != words.length) {
        return [for (final w in words) MorphologyResult.fallback(w)];
      }
      return [
        for (var i = 0; i < words.length; i++)
          result[i] == null
              ? MorphologyResult.fallback(words[i])
              : MorphologyResult.fromMap(result[i]!, words[i]),
      ];
    } on PlatformException {
      return [for (final w in words) MorphologyResult.fallback(w)];
    } on MissingPluginException {
      return [for (final w in words) MorphologyResult.fallback(w)];
    }
  }
}
