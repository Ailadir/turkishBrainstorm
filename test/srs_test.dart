import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/srs.dart';

void main() {
  final now = DateTime(2026, 1, 1, 12);
  SrsState review(SrsState s, ReviewGrade g) =>
      SrsScheduler.reviewWord(s, g, now: now);

  test('fresh state is due immediately with default ease', () {
    final s = SrsState.fresh(now: now);
    expect(s.repetitions, 0);
    expect(s.easeFactor, SrsScheduler.defaultEaseFactor);
    expect(s.dueAt, now);
  });

  test('good: 1 day, then 3 days, then 3 x ease', () {
    var s = review(SrsState.fresh(now: now), ReviewGrade.good);
    expect(s.repetitions, 1);
    expect(s.intervalDays, closeTo(1, 1e-9));
    expect(s.dueAt, now.add(const Duration(days: 1)));

    s = review(s, ReviewGrade.good);
    expect(s.repetitions, 2);
    expect(s.intervalDays, closeTo(3, 1e-9));

    final before = s.intervalDays;
    s = review(s, ReviewGrade.good);
    expect(s.intervalDays, closeTo(before * s.easeFactor, 1e-9));
  });

  test('again lapses: reps reset, lapses++, due in 10 minutes', () {
    var s = review(SrsState.fresh(now: now), ReviewGrade.good);
    s = review(s, ReviewGrade.good);
    s = review(s, ReviewGrade.again);
    expect(s.repetitions, 0);
    expect(s.lapses, 1);
    expect(s.dueAt, now.add(const Duration(minutes: 10)));
    expect(s.easeFactor, lessThan(2.5));
  });

  test('ease never drops below the minimum', () {
    var s = SrsState.fresh(now: now);
    for (var i = 0; i < 20; i++) {
      s = review(s, ReviewGrade.again);
    }
    expect(s.easeFactor, SrsScheduler.minEaseFactor);
  });

  test('hard grows slower than good, easy faster', () {
    var base = review(SrsState.fresh(now: now), ReviewGrade.good);
    base = review(base, ReviewGrade.good);
    final hard = review(base, ReviewGrade.hard);
    final good = review(base, ReviewGrade.good);
    final easy = review(base, ReviewGrade.easy);
    expect(hard.intervalDays, lessThan(good.intervalDays));
    expect(easy.intervalDays, greaterThan(good.intervalDays));
  });
}
