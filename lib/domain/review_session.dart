import 'dart:math';

import 'brainstorm_session.dart';
import 'exercise.dart';
import 'srs.dart';
import 'turkish_text.dart';

/// Auto-grade from correctness and response time:
/// correct in < 8 s with no wrong taps → good; slower, 1–2 wrong taps or a
/// diacritic-only typo → hard; wrong → again.
ReviewGrade gradeAnswer(AnswerResult r) {
  if (!r.correct) return ReviewGrade.again;
  if (r.diacriticOnly) return ReviewGrade.hard;
  if (r.wrongTaps > 0) return ReviewGrade.hard;
  if (r.took >= const Duration(seconds: 8)) return ReviewGrade.hard;
  return ReviewGrade.good;
}

/// Exercise for a due word, chosen by its repetition count.
ExerciseType exerciseFor(VocabItem w, {required bool typingEnabled}) {
  if (!w.isSimple) {
    return w.repetitions.isEven ? ExerciseType.reveal : ExerciseType.listenChoose;
  }
  final r = w.repetitions;
  if (r <= 1) return ExerciseType.chooseMeaning;
  if (r == 2) return ExerciseType.chooseTurkish;
  if (r == 3) return ExerciseType.listenChoose;
  if (r == 4) return ExerciseType.construct;
  if (typingEnabled) return ExerciseType.typing;
  return r.isEven ? ExerciseType.construct : ExerciseType.chooseTurkish;
}

class _Reask {
  final VocabItem word;
  final int notBefore;
  _Reask(this.word, this.notBefore);
}

/// One exercise per due word, auto-graded. A lapsed word is asked once more
/// with `chooseMeaning`, at least 3 exercises later (not scheduled again).
class ReviewSession {
  final List<VocabItem> pool;
  final bool typingEnabled;
  final Random _rng;
  final List<VocabItem> _queue;
  final List<_Reask> _reasks = [];
  final int total;
  int _served = 0;
  int _answered = 0;
  VocabItem? _currentWord;
  bool _currentIsReask = false;

  ReviewSession({
    required List<VocabItem> due,
    List<VocabItem> pool = const [],
    this.typingEnabled = false,
    Random? rng,
  })  : pool = [...pool, ...due],
        _rng = rng ?? Random(),
        _queue = List.of(due),
        total = due.length;

  double get progress => total == 0 ? 1 : (_answered / total).clamp(0, 1);
  bool get isFinished => _queue.isEmpty && _reasks.isEmpty;

  Exercise? next() {
    if (isFinished) {
      _currentWord = null;
      return null;
    }
    // A re-ask whose delay has passed goes first; when the main queue is
    // empty, any pending re-ask is served.
    _Reask? reask;
    for (final r in _reasks) {
      if (r.notBefore <= _served + 1 || _queue.isEmpty) {
        reask = r;
        break;
      }
    }
    _served++;
    if (reask != null) {
      _reasks.remove(reask);
      _currentWord = reask.word;
      _currentIsReask = true;
      return _build(reask.word, ExerciseType.chooseMeaning, isReask: true);
    }
    final w = _queue.removeAt(0);
    _currentWord = w;
    _currentIsReask = false;
    return _build(w, exerciseFor(w, typingEnabled: typingEnabled));
  }

  Exercise _build(VocabItem w, ExerciseType type, {bool isReask = false}) {
    Exercise reveal() => Exercise(
        wordId: w.id,
        type: ExerciseType.reveal,
        answer: w.english,
        isReask: isReask);
    switch (type) {
      case ExerciseType.chooseMeaning:
      case ExerciseType.listenChoose:
        final opts = buildChoiceOptions(
            word: w, pool: pool, pick: (x) => x.english, rng: _rng);
        if (opts.length < 2) return reveal();
        return Exercise(
            wordId: w.id,
            type: type,
            options: opts,
            answer: w.english,
            isReask: isReask);
      case ExerciseType.chooseTurkish:
        final opts = buildChoiceOptions(
            word: w, pool: pool, pick: (x) => x.turkish, rng: _rng);
        if (opts.length < 2) return reveal();
        return Exercise(
            wordId: w.id,
            type: type,
            options: opts,
            answer: w.turkish,
            isReask: isReask);
      case ExerciseType.construct:
        return Exercise(
            wordId: w.id,
            type: type,
            options: constructLetters(w.turkish, _rng),
            answer: trLower(w.turkish),
            isReask: isReask);
      case ExerciseType.typing:
        return Exercise(
            wordId: w.id, type: type, answer: w.turkish, isReask: isReask);
      case ExerciseType.reveal:
        return reveal();
    }
  }

  /// Report the answer to the exercise last returned by [next]. The outcome's
  /// `grade` is what to persist; it is null for re-asks.
  AnswerOutcome answer(AnswerResult result) {
    final w = _currentWord;
    if (w == null) return const AnswerOutcome();
    final grade = gradeAnswer(result);
    if (_currentIsReask) return const AnswerOutcome();
    _answered++;
    if (grade == ReviewGrade.again) {
      _reasks.add(_Reask(w, _served + 3));
    }
    return AnswerOutcome(grade: grade);
  }
}
