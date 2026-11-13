import 'dart:convert';

import 'suffix_glosses.dart';
import 'turkish_text.dart';

class PackFormatException implements Exception {
  final String message;
  PackFormatException(this.message);
  @override
  String toString() => 'PackFormatException: $message';
}

class PackWord {
  final String tr;
  final String en;
  final String? pos;
  final int rank;
  final String? example;
  final String? exampleEn;
  const PackWord({
    required this.tr,
    required this.en,
    required this.rank,
    this.pos,
    this.example,
    this.exampleEn,
  });
}

class PackExample {
  final String tr;
  final String en;
  const PackExample(this.tr, this.en);
}

class PackSuffix {
  final String id;
  final List<PackExample> examples;
  const PackSuffix(this.id, this.examples);
}

class Pack {
  final String id;
  final int version;
  final String kind; // words | grammar
  final String title;
  final String? level;
  final List<PackWord> words;
  final List<PackSuffix> suffixes;
  const Pack({
    required this.id,
    required this.version,
    required this.kind,
    required this.title,
    this.level,
    this.words = const [],
    this.suffixes = const [],
  });

  bool get isGrammar => kind == 'grammar';
  int get count => isGrammar ? suffixes.length : words.length;
}

/// Parses and validates a pack file. Mirrors `tool/validate_pack.dart`.
Pack parsePack(String source) {
  final Object? raw;
  try {
    raw = jsonDecode(source);
  } catch (e) {
    throw PackFormatException('Not valid JSON');
  }
  if (raw is! Map<String, dynamic>) {
    throw PackFormatException('Top level must be an object');
  }
  final Map<String, dynamic> obj = raw;
  if (obj['format'] != 1) {
    throw PackFormatException('Unsupported pack format: ${obj['format']}');
  }
  String need(String key) {
    final v = obj[key];
    if (v is! String || v.trim().isEmpty) {
      throw PackFormatException('Missing "$key"');
    }
    return v;
  }

  final id = need('id');
  final title = need('title');
  final kind = need('kind');
  final version = obj['version'];
  if (version is! int || version < 1) {
    throw PackFormatException('Missing or bad "version"');
  }
  if (kind != 'words' && kind != 'grammar') {
    throw PackFormatException('Unknown kind "$kind"');
  }
  final level = obj['level'];
  if (level != null && !cefrLevels.contains(level)) {
    throw PackFormatException('Bad level "$level"');
  }

  if (kind == 'words') {
    final list = obj['words'];
    if (list is! List) throw PackFormatException('Missing "words"');
    final seen = <String>{};
    final words = <PackWord>[];
    for (final w in list) {
      if (w is! Map) throw PackFormatException('Bad word entry');
      final tr = w['tr'];
      final en = w['en'];
      if (tr is! String || tr.trim().isEmpty) {
        throw PackFormatException('Word without "tr"');
      }
      if (en is! String || en.trim().isEmpty) {
        throw PackFormatException('"$tr" has no "en"');
      }
      if (!seen.add(trNormalize(tr))) {
        throw PackFormatException('Duplicate word "$tr"');
      }
      words.add(
        PackWord(
          tr: tr.trim(),
          en: en.trim(),
          pos: w['pos'] as String?,
          rank: (w['rank'] as num?)?.toInt() ?? words.length + 1,
          example: w['example'] as String?,
          exampleEn: w['example_en'] as String?,
        ),
      );
    }
    return Pack(
      id: id,
      version: version,
      kind: kind,
      title: title,
      level: level as String?,
      words: words,
    );
  }

  final list = obj['suffixes'];
  if (list is! List) throw PackFormatException('Missing "suffixes"');
  final suffixes = <PackSuffix>[];
  final seenIds = <String>{};
  for (final s in list) {
    if (s is! Map) throw PackFormatException('Bad suffix entry');
    final sid = s['id'];
    if (sid is! String || sid.isEmpty) {
      throw PackFormatException('Suffix without "id"');
    }
    if (!seenIds.add(sid)) throw PackFormatException('Duplicate suffix "$sid"');
    final ex = s['examples'];
    if (ex is! List || ex.isEmpty) {
      throw PackFormatException('Suffix "$sid" has no examples');
    }
    suffixes.add(
      PackSuffix(sid, [
        for (final e in ex)
          if (e is Map && e['tr'] is String && e['en'] is String)
            PackExample(e['tr'] as String, e['en'] as String)
          else
            throw PackFormatException('Bad example in "$sid"'),
      ]),
    );
  }
  return Pack(
    id: id,
    version: version,
    kind: kind,
    title: title,
    level: level as String?,
    suffixes: suffixes,
  );
}

class PackIndexEntry {
  final String id;
  final String title;
  final String kind;
  final String? level;
  final int version;
  final int count;
  final String file;
  final String sha256;
  final int size;
  const PackIndexEntry({
    required this.id,
    required this.title,
    required this.kind,
    required this.version,
    required this.count,
    required this.file,
    required this.sha256,
    required this.size,
    this.level,
  });
}

List<PackIndexEntry> parsePackIndex(String source) {
  final Object? raw;
  try {
    raw = jsonDecode(source);
  } catch (_) {
    throw PackFormatException('Index is not valid JSON');
  }
  if (raw is! Map || raw['format'] != 1 || raw['packs'] is! List) {
    throw PackFormatException('Bad index');
  }
  return [
    for (final p in raw['packs'] as List)
      PackIndexEntry(
        id: p['id'] as String,
        title: p['title'] as String,
        kind: p['kind'] as String,
        level: p['level'] as String?,
        version: p['version'] as int,
        count: p['count'] as int,
        file: p['file'] as String,
        sha256: p['sha256'] as String,
        size: p['size'] as int,
      ),
  ];
}
