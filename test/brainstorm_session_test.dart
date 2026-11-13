import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/brainstorm_session.dart';
import 'package:turkish_vocab/domain/exercise.dart';

VocabItem w(int id, String tr, String en, {String kind = 'word'}) =>
    VocabItem(id: id, turkish: tr, english: en, kind: kind);

final words = [
  w(1, 'kitap', 'book'),
  w(2, 'kalem', 'pencil'),
  w(3, 'masa', 'table'),
  w(4, 'kapı', 'door'),
  w(5, 'araba', 'car'),
];

/// Answer everything correctly; returns the exercise sequence.
List<Exercise> runPerfect(BrainstormSession s) {
  final seq = <Exercise>[];
  for (var i = 0; i < 200; i++) {
    final ex = s.next();
    if (ex == null) return seq;
    seq.add(ex);
    s.answer(const AnswerResult(correct: true));
  }
  fail('session did not finish');
}

void main() {
  test(
    'never serves the same word twice in a row; ends when all steps pass',
    () {
      final s = BrainstormSession(words: words, rng: Random(1));
      final seq = runPerfect(s);
      expect(s.isFinished, isTrue);
      expect(seq.length, 5 * 4); // 4 steps per word, typing off
      for (var i = 1; i < seq.length; i++) {
        expect(seq[i].wordId, isNot(seq[i - 1].wordId), reason: 'at $i');
      }
    },
  );

  test('every word completes exactly once', () {
    final s = BrainstormSession(words: words, rng: Random(2));
    final done = <int>[];
    while (true) {
      final ex = s.next();
      if (ex == null) break;
      final o = s.answer(const AnswerResult(correct: true));
      if (o.wordCompleted) done.add(ex.wordId);
    }
    expect(done.toSet(), {1, 2, 3, 4, 5});
    expect(done.length, 5);
  });

  test('a wrong answer blocks that word for the next 2 exercises and repeats the step', () {
    final s = BrainstormSession(words: words, rng: Random(3));
    final first = s.next()!;
    s.answer(const AnswerResult(correct: false));
    final second = s.next()!;
    s.answer(const AnswerResult(correct: true));
    final third = s.next()!;
    s.answer(const AnswerResult(correct: true));
    expect(second.wordId, isNot(first.wordId));
    expect(third.wordId, isNot(first.wordId));
    // Eventually the same step comes back for the missed word.
    var seenAgain = false;
    for (var i = 0; i < 50 && !seenAgain; i++) {
      final ex = s.next();
      if (ex == null) break;
      if (ex.wordId == first.wordId && ex.type == first.type) seenAgain = true;
      s.answer(const AnswerResult(correct: true));
    }
    expect(seenAgain, isTrue);
  });

  test(
    'choice options are valid: correct once, no duplicates, 2-5 options',
    () {
      final s = BrainstormSession(words: words, rng: Random(4));
      for (var i = 0; i < 20; i++) {
        final ex = s.next()!;
        if (ex.options.isNotEmpty && ex.type != ExerciseType.construct) {
          expect(ex.options.length, inInclusiveRange(2, 5));
          expect(ex.options.toSet().length, ex.options.length);
          expect(ex.options.where((o) => o == ex.answer).length, 1);
        }
        s.answer(const AnswerResult(correct: true));
      }
    },
  );

  test('construct letters are a shuffle of the lowercase word', () {
    final s = BrainstormSession(words: [w(1, 'IŞIK', 'light')], rng: Random(5));
    ExerciseType? t;
    Exercise? construct;
    while ((construct = s.next()) != null) {
      if (construct!.type == ExerciseType.construct) break;
      s.answer(const AnswerResult(correct: true));
    }
    t = construct?.type;
    expect(t, ExerciseType.construct);
    expect(construct!.answer, 'ışık');
    expect([...construct.options]..sort(), [...'ışık'.split('')]..sort());
  });

  test('phrases/sentences and long words get only reveal + listen', () {
    final s = BrainstormSession(
      words: [
        w(1, 'eve gidiyorum', 'I am going home', kind: 'phrase'),
        w(2, 'sorumluluklarımızdan', 'from our responsibilities'),
      ],
      rng: Random(6),
    );
    final types = runPerfect(s).map((e) => e.type).toSet();
    expect(
      types.difference({ExerciseType.reveal, ExerciseType.listenChoose}),
      isEmpty,
    );
  });

  test('a lone word with no distractors degrades to reveal, never a 1-option choice', () {
    final s = BrainstormSession(words: [w(1, 'ev', 'house')], rng: Random(7));
    final ex = s.next()!;
    expect(ex.type, ExerciseType.reveal);
  });

  test('typing step is added when enabled', () {
    final s = BrainstormSession(
      words: words,
      typingEnabled: true,
      rng: Random(8),
    );
    final seq = runPerfect(s);
    expect(seq.length, 5 * 5);
    expect(seq.any((e) => e.type == ExerciseType.typing), isTrue);
  });
}
