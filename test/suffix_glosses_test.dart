import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/morpheme_ref.dart';
import 'package:turkish_vocab/domain/suffix_glosses.dart';

void main() {
  test('every entry has a gloss, valid category and level', () {
    for (final e in suffixGlosses.entries) {
      expect(e.value.label, isNotEmpty, reason: e.key);
      expect(e.value.gloss, isNotEmpty, reason: e.key);
      expect(suffixCategories, contains(e.value.category), reason: e.key);
      expect(cefrLevels, contains(e.value.level), reason: e.key);
    }
  });

  test('unknown id falls back to the id at level B2', () {
    final i = suffixInfo('NoSuchMorpheme');
    expect(i.gloss, 'NoSuchMorpheme');
    expect(i.level, 'B2');
  });

  test('core A1 ids are present', () {
    for (final id in [
      'A3pl',
      'P1pl',
      'Loc',
      'Dat',
      'Abl',
      'Prog1',
      'Past',
      'Neg',
    ]) {
      expect(suffixGlosses[id]?.level, 'A1', reason: id);
    }
  });

  test('MorphemeRef JSON round-trips and tolerates garbage', () {
    const list = [MorphemeRef('ler', 'A3pl'), MorphemeRef('de', 'Loc')];
    expect(MorphemeRef.decodeList(MorphemeRef.encodeList(list)), list);
    expect(MorphemeRef.decodeList('not json'), isEmpty);
    expect(MorphemeRef.decodeList('[]'), isEmpty);
  });
}
