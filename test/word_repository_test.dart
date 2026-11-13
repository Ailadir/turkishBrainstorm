import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/word_repository.dart';
import 'package:turkish_vocab/domain/practice_mode.dart';

WordRepository _makeRepo() =>
    WordRepository(AppDatabase(NativeDatabase.memory()));

void main() {
  group('WordRepository', () {
    test('addWord creates word + 2 initial states (recognition×2)', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id = (await repo.addWord(
        turkish: 'gelmek',
        english: 'to come',
        now: now,
      )).id;
      expect(id, greaterThan(0));

      final queue = await repo.dueQueue(now: now);
      // One card per word in the queue, even though 2 states exist.
      expect(queue.length, 1);
      expect(queue.single.mode, PracticeMode.recognitionTrEn);
      expect(queue.single.word.id, id);
      expect(queue.single.state.repetitions, 0);
      final states = await repo.db.select(repo.db.practiceStates).get();
      expect(states.length, 2);
    });

    test('applyReview(good) moves card out of due queue', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'ev', english: 'house', now: now);

      var queue = await repo.dueQueue(now: now);
      expect(queue.length, 1);

      await repo.applyReview(queue.first, ReviewGrade.good, now: now);

      queue = await repo.dueQueue(now: now);
      // TR→EN is rescheduled; the sibling EN→TR is now the one card due.
      expect(queue.length, 1);
      expect(queue.single.mode, PracticeMode.recognitionEnTr);
    });

    test(
      'ensureModeState(listening) adds a 3rd state and is idempotent',
      () async {
        final repo = _makeRepo();
        final now = DateTime(2026, 1, 1, 12);
        final id = (await repo.addWord(
          turkish: 'kitap',
          english: 'book',
          now: now,
        )).id;

        // Listening is NOT in initialModes — this call should add it.
        Future<int> stateCount() async =>
            (await repo.db.select(repo.db.practiceStates).get()).length;
        await repo.ensureModeState(id, PracticeMode.listening, now: now);
        expect(await stateCount(), 3);

        // Second call is a no-op.
        await repo.ensureModeState(id, PracticeMode.listening, now: now);
        expect(await stateCount(), 3);
      },
    );

    test('withMastery reflects repetitions', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'su', english: 'water', now: now);

      final words = await repo.searchWords('su');
      expect(words.length, 1);

      final wm = await repo.withMastery(words.first);
      expect(wm.mastery, 0.0); // no reps yet
      expect(wm.activeModes.length, 2); // recognition×2
    });

    test('stats counts words, due, reviewsToday', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'araba', english: 'car', now: now);
      await repo.addWord(turkish: 'köpek', english: 'dog', now: now);

      final s = await repo.stats(now: now);
      expect(s.totalWords, 2);
      expect(s.dueNow, 2); // one due card per word
      expect(s.reviewsToday, 0);
    });

    test('randomEnglishDistractors excludes the given word', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id = (await repo.addWord(
        turkish: 'kedi',
        english: 'cat',
        now: now,
      )).id;
      await repo.addWord(turkish: 'köpek', english: 'dog', now: now);
      await repo.addWord(turkish: 'kuş', english: 'bird', now: now);
      await repo.addWord(turkish: 'balık', english: 'fish', now: now);

      final distractors = await repo.randomEnglishDistractors(id, 3);
      expect(distractors.length, 3);
      expect(distractors, isNot(contains('cat')));
    });

    test('dueCountByMode splits counts by mode', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id = (await repo.addWord(
        turkish: 'gitmek',
        english: 'to go',
        now: now,
      )).id;
      await repo.ensureModeState(id, PracticeMode.listening, now: now);
      await repo.addWord(turkish: 'ev', english: 'house', now: now);

      // One card per word → both words count under TR→EN only.
      final counts = await repo.dueCountByMode(now: now);
      expect(counts[PracticeMode.recognitionTrEn], 2);
      expect(counts[PracticeMode.recognitionEnTr], isNull);
      expect(counts[PracticeMode.listening], isNull);
    });

    test('addWord dedupes case- and Turkish-aware', () async {
      final repo = _makeRepo();
      final first = await repo.addWord(turkish: 'ev', english: 'house');
      expect(first.existed, isFalse);
      final dup = await repo.addWord(turkish: 'EV', english: 'home');
      expect(dup.existed, isTrue);
      expect(dup.id, first.id);

      await repo.addWord(turkish: 'ışık', english: 'light');
      final dup2 = await repo.addWord(turkish: 'IŞIK', english: 'light');
      expect(dup2.existed, isTrue);
    });

    test('deleteWord removes states so dueCount is 0', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id = (await repo.addWord(
        turkish: 'ev',
        english: 'house',
        now: now,
      )).id;
      expect(await repo.dueCount(now: now), 1);
      await repo.deleteWord(id);
      expect(await repo.dueCount(now: now), 0);
      expect(await repo.db.select(repo.db.practiceStates).get(), isEmpty);
    });
  });
}
