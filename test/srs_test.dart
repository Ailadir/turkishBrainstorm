import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/practice_mode.dart';
import 'package:turkish_vocab/domain/srs.dart';

void main() {
  final now = DateTime(2026, 1, 1, 12, 0, 0);

  group('SM-2 base behaviour', () {
    test('fresh card is due immediately with default ease', () {
      final s = SrsState.fresh(now: now);
      expect(s.repetitions, 0);
      expect(s.easeFactor, SrsScheduler.defaultEaseFactor);
      expect(s.dueAt, now);
    });

    test('first good review graduates to ~1 day', () {
      final s = SrsScheduler.review(
        SrsState.fresh(now: now),
        ReviewGrade.good,
        PracticeMode.recognitionTrEn,
        now: now,
      );
      expect(s.repetitions, 1);
      expect(s.intervalDays, closeTo(1, 0.001));
      expect(s.lastReviewedAt, now);
    });

    test('second good review graduates to ~6 days', () {
      var s = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.good,
          PracticeMode.recognitionTrEn, now: now);
      s = SrsScheduler.review(
          s, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      expect(s.repetitions, 2);
      expect(s.intervalDays, closeTo(6, 0.001));
    });

    test('third good review multiplies by ease factor', () {
      var s = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.good,
          PracticeMode.recognitionTrEn, now: now);
      s = SrsScheduler.review(
          s, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      final beforeInterval = s.intervalDays;
      final ease = s.easeFactor;
      s = SrsScheduler.review(
          s, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      expect(s.intervalDays, closeTo(beforeInterval * ease, 0.001));
    });

    test('again resets repetitions and shortens to the lapse step', () {
      var s = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.good,
          PracticeMode.recognitionTrEn, now: now);
      s = SrsScheduler.review(
          s, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      final s2 = SrsScheduler.review(
          s, ReviewGrade.again, PracticeMode.recognitionTrEn, now: now);
      expect(s2.repetitions, 0);
      expect(s2.intervalDays, SrsScheduler.lapseIntervalDays);
      expect(s2.easeFactor, lessThan(s.easeFactor));
    });

    test('ease never drops below the floor', () {
      var s = SrsState.fresh(now: now);
      for (var i = 0; i < 20; i++) {
        s = SrsScheduler.review(
            s, ReviewGrade.again, PracticeMode.recognitionTrEn, now: now);
      }
      expect(s.easeFactor, greaterThanOrEqualTo(SrsScheduler.minEaseFactor));
    });

    test('easy grows faster than good', () {
      final base = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.good,
          PracticeMode.recognitionTrEn, now: now);
      final good = SrsScheduler.review(
          base, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      final easy = SrsScheduler.review(
          base, ReviewGrade.easy, PracticeMode.recognitionTrEn, now: now);
      expect(easy.intervalDays, greaterThan(good.intervalDays));
    });

    test('hard grows slower than good', () {
      final base = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.good,
          PracticeMode.recognitionTrEn, now: now);
      final good = SrsScheduler.review(
          base, ReviewGrade.good, PracticeMode.recognitionTrEn, now: now);
      final hard = SrsScheduler.review(
          base, ReviewGrade.hard, PracticeMode.recognitionTrEn, now: now);
      expect(hard.intervalDays, lessThan(good.intervalDays));
    });
  });

  group('per-mode weighting', () {
    test('writing grows the interval more than recognition on success', () {
      // Advance both to rep 2 so the ease-based step applies.
      SrsState advance(PracticeMode mode) {
        var s = SrsScheduler.review(
            SrsState.fresh(now: now), ReviewGrade.good, mode, now: now);
        s = SrsScheduler.review(s, ReviewGrade.good, mode, now: now);
        return SrsScheduler.review(s, ReviewGrade.good, mode, now: now);
      }

      final rec = advance(PracticeMode.recognitionTrEn);
      final listen = advance(PracticeMode.listening);
      final write = advance(PracticeMode.writing);
      expect(listen.intervalDays, greaterThan(rec.intervalDays));
      expect(write.intervalDays, greaterThan(listen.intervalDays));
    });

    test('writing penalises ease harder on failure', () {
      final recFail = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.again,
          PracticeMode.recognitionTrEn, now: now);
      final writeFail = SrsScheduler.review(
          SrsState.fresh(now: now), ReviewGrade.again,
          PracticeMode.writing, now: now);
      expect(writeFail.easeFactor, lessThan(recFail.easeFactor));
    });
  });
}
