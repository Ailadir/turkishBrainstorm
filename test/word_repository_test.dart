import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/word_repository.dart';
import 'package:turkish_vocab/domain/exercise.dart';
import 'package:turkish_vocab/domain/morpheme_ref.dart';
import 'package:turkish_vocab/domain/srs.dart';

WordRepository _makeRepo() =>
    WordRepository(AppDatabase(NativeDatabase.memory()));

void main() {
  final now = DateTime(2026, 1, 1, 12);

  test('addWord stores one new row with kind inferred', () async {
    final repo = _makeRepo();
    final r = await repo.addWord(
      turkish: 'evlerimizde',
      english: 'in our houses',
    );
    expect(r.existed, isFalse);
    final w = (await repo.wordById(r.id))!;
    expect(w.status, 'new');
    expect(w.kind, 'word');
    expect(w.needsAnalysis, isTrue);
    expect((await repo.db.select(repo.db.words).get()).length, 1);

    final p = await repo.addWord(
      turkish: 'eve gidiyorum',
      english: 'I am going home',
    );
    expect((await repo.wordById(p.id))!.kind, 'phrase');
    final s = await repo.addWord(
      turkish: 'Bugün hava çok güzel.',
      english: 'The weather is nice today.',
    );
    expect((await repo.wordById(s.id))!.kind, 'sentence');
  });

  test('addWord dedupes case- and Turkish-aware', () async {
    final repo = _makeRepo();
    final first = await repo.addWord(turkish: 'ev', english: 'house');
    final dup = await repo.addWord(turkish: 'EV', english: 'home');
    expect(dup.existed, isTrue);
    expect(dup.id, first.id);
    await repo.addWord(turkish: 'ışık', english: 'light');
    expect(
      (await repo.addWord(turkish: 'IŞIK', english: 'light')).existed,
      isTrue,
    );
  });

  test('applyAnalysis fills morphemes and creates Morphemes rows', () async {
    final repo = _makeRepo();
    final id = (await repo.addWord(turkish: 'evlerimizde', english: 'x')).id;
    expect((await repo.wordsNeedingAnalysis(10)).length, 1);
    await repo.applyAnalysis(
      id,
      lemma: 'ev',
      pos: 'Noun',
      morphemes: const [
        MorphemeRef('ler', 'A3pl'),
        MorphemeRef('imiz', 'P1pl'),
        MorphemeRef('de', 'Loc'),
      ],
    );
    final w = (await repo.wordById(id))!;
    expect(w.lemma, 'ev');
    expect(w.needsAnalysis, isFalse);
    expect(w.morphemeRefs.map((m) => m.id), ['A3pl', 'P1pl', 'Loc']);
    expect((await repo.db.select(repo.db.wordMorphemes).get()).length, 3);
    expect((await repo.db.select(repo.db.morphemes).get()).length, 3);
    expect(await repo.wordsNeedingAnalysis(10), isEmpty);
  });

  test('deleteWord cascades to WordMorphemes and dueCount drops', () async {
    final repo = _makeRepo();
    final id = (await repo.addWord(
      turkish: 'evde',
      english: 'at home',
      lemma: 'ev',
      morphemes: const [MorphemeRef('de', 'Loc')],
    )).id;
    await repo.finishBrainstorm(id, 0, now: now);
    expect(await repo.dueCount(now: now.add(const Duration(days: 2))), 1);
    await repo.deleteWord(id);
    expect(await repo.dueCount(now: now.add(const Duration(days: 2))), 0);
    expect(await repo.db.select(repo.db.wordMorphemes).get(), isEmpty);
  });

  test(
    'finishBrainstorm schedules tomorrow and lowers ease with mistakes',
    () async {
      final repo = _makeRepo();
      final a = (await repo.addWord(turkish: 'ev', english: 'house')).id;
      final b = (await repo.addWord(turkish: 'su', english: 'water')).id;
      await repo.finishBrainstorm(a, 0, now: now);
      await repo.finishBrainstorm(b, 9, now: now);
      final wa = (await repo.wordById(a))!;
      final wb = (await repo.wordById(b))!;
      expect(wa.status, 'review');
      expect(wa.repetitions, 1);
      expect(wa.dueAt, now.add(const Duration(days: 1)));
      expect(wa.easeFactor, 2.5);
      expect(wb.easeFactor, closeTo(2.05, 1e-9)); // capped at 3 mistakes
      expect(await repo.dueCount(now: now), 0);
      expect(await repo.dueCount(now: now.add(const Duration(days: 1))), 2);
    },
  );

  test(
    'pickNewWords: own words (newest first) before pack words by level/rank',
    () async {
      final repo = _makeRepo();
      final db = repo.db;
      await db
          .into(db.packs)
          .insert(
            PacksCompanion.insert(
              id: 'p',
              title: 'P',
              kind: 'words',
              version: 1,
            ),
          );
      Future<int> pack(String tr, String level, int rank) async {
        final id = (await repo.addWord(
          turkish: tr,
          english: tr,
          level: level,
        )).id;
        await db
            .into(db.wordPacks)
            .insert(
              WordPacksCompanion.insert(wordId: id, packId: 'p', rank: rank),
            );
        return id;
      }

      final b1 = await pack('b1word', 'B1', 1);
      final a1r2 = await pack('a1two', 'A1', 2);
      final a1r1 = await pack('a1one', 'A1', 1);
      final own1 = (await repo.addWord(turkish: 'benim1', english: 'mine1')).id;
      final own2 = (await repo.addWord(turkish: 'benim2', english: 'mine2')).id;

      final all = await repo.pickNewWords(10);
      expect(all.map((w) => w.id), [own2, own1, a1r1, a1r2, b1]);
      final own = await repo.pickNewWords(10, usePackWords: false);
      expect(own.map((w) => w.id), [own2, own1]);
      expect(await repo.newCount(usePackWords: false), 2);
    },
  );

  test('applyWordReview updates SRS state and logs', () async {
    final repo = _makeRepo();
    final id = (await repo.addWord(turkish: 'ev', english: 'house')).id;
    await repo.finishBrainstorm(id, 0, now: now);
    final due = now.add(const Duration(days: 1));
    await repo.applyWordReview(
      id,
      ReviewGrade.good,
      ExerciseType.chooseMeaning,
      now: due,
    );
    var w = (await repo.wordById(id))!;
    expect(w.repetitions, 2);
    expect(w.intervalDays, closeTo(3, 1e-9));
    await repo.applyWordReview(
      id,
      ReviewGrade.again,
      ExerciseType.construct,
      now: due,
    );
    w = (await repo.wordById(id))!;
    expect(w.repetitions, 0);
    expect(w.lapses, 1);
    expect((await repo.db.select(repo.db.reviewLog).get()).length, 2);
  });

  test('dueWords: only review status, most overdue first, limited', () async {
    final repo = _makeRepo();
    final a = (await repo.addWord(turkish: 'bir', english: 'one')).id;
    final b = (await repo.addWord(turkish: 'iki', english: 'two')).id;
    await repo.addWord(turkish: 'üç', english: 'three'); // still new
    await repo.finishBrainstorm(a, 0, now: now);
    await repo.finishBrainstorm(
      b,
      0,
      now: now.subtract(const Duration(days: 2)),
    );
    final later = now.add(const Duration(days: 5));
    final due = await repo.dueWords(now: later);
    expect(due.map((w) => w.id), [b, a]);
    expect((await repo.dueWords(now: later, limit: 1)).length, 1);
  });

  test('stats counts words, new, due', () async {
    final repo = _makeRepo();
    final a = (await repo.addWord(turkish: 'araba', english: 'car')).id;
    await repo.addWord(turkish: 'köpek', english: 'dog');
    await repo.finishBrainstorm(a, 0, now: now);
    final s = await repo.stats(now: now.add(const Duration(days: 2)));
    expect(s.totalWords, 2);
    expect(s.newCount, 1);
    expect(s.dueNow, 1);
    expect(s.byStatus['review'], 1);
  });

  test('updateWordFields marks englishEdited and re-normalizes', () async {
    final repo = _makeRepo();
    final id = (await repo.addWord(turkish: 'Ev', english: 'house')).id;
    await repo.updateWordFields(wordId: id, english: 'home', turkish: 'Evim');
    final w = (await repo.wordById(id))!;
    expect(w.englishEdited, isTrue);
    expect(w.normalized, 'evim');
    expect(w.needsAnalysis, isTrue);
  });
}
