import 'dart:convert';

/// One suffix of an analysed word: its surface form and Zemberek morpheme id.
class MorphemeRef {
  final String surface;
  final String id;
  const MorphemeRef(this.surface, this.id);

  Map<String, String> toJson() => {'s': surface, 'id': id};

  @override
  bool operator ==(Object other) =>
      other is MorphemeRef && other.surface == surface && other.id == id;

  @override
  int get hashCode => Object.hash(surface, id);

  /// Encode as the JSON stored in `words.morphemes`: `[{"s":"ler","id":"A3pl"}]`.
  static String encodeList(List<MorphemeRef> list) =>
      jsonEncode(list.map((m) => m.toJson()).toList());

  static List<MorphemeRef> decodeList(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final raw = jsonDecode(json) as List<dynamic>;
      return [
        for (final e in raw)
          MorphemeRef((e as Map)['s'] as String, e['id'] as String),
      ];
    } catch (_) {
      return const [];
    }
  }
}
