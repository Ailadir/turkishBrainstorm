import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/exercise.dart';
import 'package:turkish_vocab/domain/review_session.dart';
import 'package:turkish_vocab/domain/srs.dart';

VocabItem w(
  int id,
  String tr,
  String en, {
  int reps = 1,
  String kind = 'word',
}) =>
    VocabItem(id: id, turkish: tr, english: en, kind: kind, repetitions: reps);

void main() {
  test('exercise by repetitions', () {
    ExerciseType f(int r, {bool typing = false, String kind = 'word'}) =>
        exerciseFor(
          w(1, 'kitap', 'book', reps: r, kind: kind),
          typingEnabled: typing,
        );
    expect(f(0), ExerciseType.chooseMeaning);
    expect(f(1), ExerciseType.chooseMeaning);
    expect(f(2), ExerciseType.chooseTurkish);
    expect(f(3), ExerciseType.listenChoose);
    expect(f(4), ExerciseType.construct);
    expect(f(5, typing: true), ExerciseType.typing);
    expect(f(5), ExerciseType.chooseTurkish);
    expect(f(6), ExerciseType.construct);
    expect(
      {f(1, kind: 'sentence'), f(2, kind: 'sentence')},
      {ExerciseType.reveal, ExerciseType.listenChoose},
    );
  });

  test('grading thresholds', () {
    ReviewGrade g(AnswerResult r) => gradeAnswer(r);
    expect(
      g(const AnswerResult(correct: true, took: Duration(seconds: 3))),
      ReviewGrade.good,
    );
    expect(
      g(const AnswerResult(correct: true, took: Duration(seconds: 8))),
      ReviewGrade.hard,
    );
    expect(
      g(
        const AnswerResult(
          correct: true,
          took: Duration(seconds: 2),
          wrongTaps: 1,
        ),
      ),
      ReviewGrade.hard,
    );
    expect(
      g(
        const AnswerResult(
          correct: true,
          took: Duration(seconds: 2),
          diacriticOnly: true,
        ),
      ),
      ReviewGrade.hard,
    );
    expect(g(const AnswerResult(correct: false)), ReviewGrade.again);
  });

  final pool = [
    w(10, 'masa', 'table'),
    w(11, 'sandalye', 'chair'),
    w(12, 'kapı', 'door'),
  ];

  test('one exercise per due word, grades reported', () {
    final s = ReviewSession(
      due: [w(1, 'kitap', 'book'), w(2, 'kalem', 'pencil')],
      pool: pool,
      rng: Random(1),
    );
    final grades = <ReviewGrade?>[];
    var n = 0;
    while (s.next() != null) {
      n++;
      grades.add(
        s
            .answer(
              const AnswerResult(correct: true, took: Duration(seconds: 1)),
            )
            .grade,
      );
    }
    expect(n, 2);
    expect(grades, everyElement(ReviewGrade.good));
    expect(s.isFinished, isTrue);
  });

  test('a lapse is re-asked once with chooseMeaning, 3+ exercises later, unscheduled', () {
    final due = [for (var i = 1; i <= 6; i++) w(i, 'kelime$i', 'word$i')];
    final s = ReviewSession(due: due, pool: pool, rng: Random(2));
    final order = <int>[];
    final reasks = <int>[];
    var idx = 0;
    while (true) {
      final ex = s.next();
      if (ex == null) break;
      order.add(ex.wordId);
      final miss = idx == 0; // miss the very first card
      final o = s.answer(
        AnswerResult(correct: !miss, took: const Duration(seconds: 1)),
      );
      if (ex.isReask) {
        reasks.add(idx);
        expect(ex.type, ExerciseType.chooseMeaning);
        expect(o.grade, isNull); // not scheduled again
      }
      idx++;
    }
    expect(order.first, 1);
    expect(reasks.length, 1);
    expect(reasks.single, greaterThanOrEqualTo(3));
    expect(order[reasks.single], 1);
  });
}
