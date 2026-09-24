import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/word_repository.dart';
import 'package:turkish_vocab/domain/practice_mode.dart';

WordRepository _makeRepo() =>
    WordRepository(AppDatabase(NativeDatabase.memory()));

void main() {
  group('WordRepository', () {
    test('addWord creates word + 2 recognition states due immediately', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id = await repo.addWord(
        turkish: 'gelmek',
        english: 'to come',
        now: now,
      );
      expect(id, greaterThan(0));

      final queue = await repo.dueQueue(now: now);
      expect(queue.length, 2);
      final modes = queue.map((c) => c.mode).toSet();
      expect(modes, {PracticeMode.recognitionTrEn, PracticeMode.recognitionEnTr});
      for (final card in queue) {
        expect(card.word.id, id);
        expect(card.state.repetitions, 0);
      }
    });

    test('applyReview(good) moves card out of due queue', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'ev', english: 'house', now: now);

      var queue = await repo.dueQueue(now: now);
      expect(queue.length, 2);

      await repo.applyReview(queue.first, ReviewGrade.good, now: now);

      // Move time forward 10 minutes — still same moment for new cards.
      queue = await repo.dueQueue(now: now);
      // The reviewed card is due in ~1 day, so only 1 card remains.
      expect(queue.length, 1);
    });

    test('ensureModeState(writing) adds a 3rd state and is idempotent', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id =
          await repo.addWord(turkish: 'kitap', english: 'book', now: now);

      await repo.ensureModeState(id, PracticeMode.writing, now: now);
      var queue = await repo.dueQueue(now: now);
      expect(queue.length, 3);

      // Second call is a no-op.
      await repo.ensureModeState(id, PracticeMode.writing, now: now);
      queue = await repo.dueQueue(now: now);
      expect(queue.length, 3);
    });

    test('withMastery reflects repetitions', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'su', english: 'water', now: now);

      final words = await repo.searchWords('su');
      expect(words.length, 1);

      final wm = await repo.withMastery(words.first);
      expect(wm.mastery, 0.0); // no reps yet
      expect(wm.activeModes.length, 2);
    });

    test('stats counts words, due, reviewsToday', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      await repo.addWord(turkish: 'araba', english: 'car', now: now);
      await repo.addWord(turkish: 'köpek', english: 'dog', now: now);

      final s = await repo.stats(now: now);
      expect(s.totalWords, 2);
      expect(s.dueNow, 4); // 2 words × 2 recognition modes
      expect(s.reviewsToday, 0);
    });

    test('randomEnglishDistractors excludes the given word', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id =
          await repo.addWord(turkish: 'kedi', english: 'cat', now: now);
      await repo.addWord(turkish: 'köpek', english: 'dog', now: now);
      await repo.addWord(turkish: 'kuş', english: 'bird', now: now);
      await repo.addWord(turkish: 'balık', english: 'fish', now: now);

      final distractors =
          await repo.randomEnglishDistractors(id, 3);
      expect(distractors.length, 3);
      expect(distractors, isNot(contains('cat')));
    });

    test('dueCountByMode splits counts by mode', () async {
      final repo = _makeRepo();
      final now = DateTime(2026, 1, 1, 12);
      final id =
          await repo.addWord(turkish: 'gitmek', english: 'to go', now: now);
      await repo.ensureModeState(id, PracticeMode.writing, now: now);

      final counts = await repo.dueCountByMode(now: now);
      expect(counts[PracticeMode.recognitionTrEn], 1);
      expect(counts[PracticeMode.recognitionEnTr], 1);
      expect(counts[PracticeMode.writing], 1);
      expect(counts[PracticeMode.listening], isNull);
    });
  });
}
