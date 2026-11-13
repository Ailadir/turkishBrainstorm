import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/morpheme_repository.dart';
import 'package:turkish_vocab/data/pack_repository.dart';
import 'package:turkish_vocab/data/word_repository.dart';
import 'package:turkish_vocab/domain/morpheme_ref.dart';
import 'package:turkish_vocab/domain/pack.dart';
import 'package:turkish_vocab/domain/srs.dart';
import 'package:turkish_vocab/domain/suffix_drill_session.dart';
import 'package:turkish_vocab/domain/suffix_glosses.dart';

DrillExample _ex(String w, {bool own = false}) =>
    DrillExample(word: w, english: w, own: own);

DrillCandidate _c(
  String id, {
  bool isNew = true,
  DateTime? dueAt,
  List<DrillExample>? examples,
}) => DrillCandidate(
  id: id,
  isNew: isNew,
  dueAt: dueAt,
  examples: examples ?? [_ex('x$id')],
);

void main() {
  final now = DateTime(2026, 1, 1);

  test(
    'at most 10 questions: due first, then up to 3 new, lowest level first',
    () {
      final ids = suffixGlosses.keys.toList();
      final due = [
        for (final id in ids.take(8))
          _c(id, isNew: false, dueAt: now.subtract(const Duration(days: 1))),
      ];
      final fresh = [for (final id in ids.skip(8).take(10)) _c(id)];
      final s = SuffixDrillSession(candidates: [...fresh, ...due], now: now);
      expect(s.total, 10);
      final asked = <String>[];
      while (true) {
        final q = s.next();
        if (q == null) break;
        asked.add(q.morphemeId);
        s.answer(correct: true);
      }
      expect(asked.take(8).toSet(), ids.take(8).toSet(), reason: 'due first');
      expect(asked.length, 10);

      final onlyNew = SuffixDrillSession(
        candidates: [for (final id in ids.take(10)) _c(id)],
        now: now,
      );
      expect(onlyNew.total, 3);
    },
  );

  test('new suffixes come lowest level first', () {
    final s = SuffixDrillSession(
      candidates: [_c('Unable'), _c('Fut'), _c('Loc'), _c('Cond')],
      now: now,
      maxNew: 2,
    );
    final ids = [s.next()!.morphemeId, s.next()!.morphemeId];
    expect(ids.toSet(), {'Loc', 'Fut'}.intersection(ids.toSet()));
    expect(suffixInfo(ids[0]).level, 'A1');
  });

  test(
    'the right answer appears exactly once; distractors prefer the category',
    () {
      for (var seed = 0; seed < 30; seed++) {
        final s = SuffixDrillSession(
          candidates: [_c('Loc')],
          now: now,
          rng: Random(seed),
        );
        final q = s.next()!;
        expect(q.options.length, 4);
        expect(q.options.where((o) => o == q.answer).length, 1);
        expect(q.options.toSet().length, 4);
        final sameCategory = q.options
            .where((o) => o != q.answer)
            .where(
              (o) => suffixGlosses.values.any(
                (i) => i.gloss == o && i.category == 'case',
              ),
            )
            .length;
        // "case" has 7 suffixes, so all three distractors can be cases.
        expect(sameCategory, 3);
      }
    },
  );

  test('prefers own words over pack examples', () {
    final s = SuffixDrillSession(
      candidates: [
        _c(
          'Loc',
          examples: [_ex('pack1'), _ex('mine', own: true), _ex('pack2')],
        ),
      ],
      now: now,
    );
    expect(s.next()!.example.word, 'mine');
  });

  test('a wrong answer is asked once more at the end, and not scheduled', () {
    final s = SuffixDrillSession(candidates: [_c('Loc'), _c('Dat')], now: now);
    final first = s.next()!;
    expect(s.answer(correct: false), isTrue); // scheduled (again)
    s.next();
    s.answer(correct: true);
    final reask = s.next()!;
    expect(reask.isReask, isTrue);
    expect(reask.morphemeId, first.morphemeId);
    expect(s.answer(correct: false), isFalse, reason: 'practice only');
    expect(s.next(), isNull);
    expect(s.isDone, isTrue);
  });

  test('segments highlight only the target suffix', () {
    final seg = segmentsFor('evlerimizde', 'ev', const [
      MorphemeRef('ler', 'A3pl'),
      MorphemeRef('imiz', 'P1pl'),
      MorphemeRef('de', 'Loc'),
    ], 'P1pl');
    expect(seg.map((s) => s.text), ['ev', 'ler', 'imiz', 'de']);
    expect(seg.where((s) => s.highlighted).single.text, 'imiz');
    expect(
      segmentsFor('ev', 'ev', const [], 'Loc').single.highlighted,
      isFalse,
    );
  });

  group('MorphemeRepository', () {
    late AppDatabase db;
    late MorphemeRepository repo;
    late WordRepository words;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = MorphemeRepository(db);
      words = WordRepository(db);
    });

    Pack grammar(String id, List<String> suffixIds) => parsePack(
      '{"format":1,"id":"$id","version":1,"kind":"grammar","title":"t",'
      '"level":"A1","suffixes":[${[for (final s in suffixIds) '{"id":"$s","examples":[{"tr":"evde","en":"at home"}]}'].join(',')}]}',
    );

    test(
      'level gate: only suffixes at or below the level, with examples',
      () async {
        await PackRepository(db).import(grammar('g', ['Loc', 'Fut', 'Cond']));
        final a1 = (await repo.candidates('A1')).map((c) => c.id);
        expect(a1, ['Loc']);
        final b1 = (await repo.candidates('B1')).map((c) => c.id).toSet();
        expect(b1, {'Loc', 'Fut', 'Cond'});
      },
    );

    test('own words become examples, and A3pl is one suffix', () async {
      final r = await words.addWord(
        turkish: 'evlerimizde',
        english: 'in our houses',
      );
      await words.applyAnalysis(
        r.id,
        lemma: 'ev',
        morphemes: const [
          MorphemeRef('ler', 'A3pl'),
          MorphemeRef('imiz', 'P1pl'),
          MorphemeRef('de', 'Loc'),
        ],
      );
      final r2 = await words.addWord(turkish: 'kitaplar', english: 'books');
      await words.applyAnalysis(
        r2.id,
        lemma: 'kitap',
        morphemes: const [MorphemeRef('lar', 'A3pl')],
      );
      final list = await repo.candidates('A1');
      final plural = list.singleWhere((c) => c.id == 'A3pl');
      expect(plural.examples.map((e) => e.word).toSet(), {
        'evlerimizde',
        'kitaplar',
      });
      expect(plural.examples.every((e) => e.own), isTrue);
      expect(list.map((c) => c.id), containsAll(['A3pl', 'P1pl', 'Loc']));
    });

    test('review schedules the suffix and level progress follows', () async {
      await PackRepository(db).import(grammar('g', ['Loc']));
      expect((await repo.candidates('A1')).single.isNew, isTrue);
      await repo.applyReview(
        'Loc',
        ReviewGrade.good,
        now: DateTime(2026, 1, 1),
      );
      await repo.applyReview(
        'Loc',
        ReviewGrade.good,
        now: DateTime(2026, 1, 2),
      );
      final c = (await repo.candidates('A1')).single;
      expect(c.isNew, isFalse);
      expect(c.repetitions, 2);
      expect(await repo.levelProgress('A1'), 1.0);
      expect(await repo.dueCount('A1', now: DateTime(2026, 1, 2)), 0);
      expect(await repo.dueCount('A1', now: DateTime(2026, 2, 1)), 1);
    });
  });
}
