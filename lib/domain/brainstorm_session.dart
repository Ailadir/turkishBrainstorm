import 'dart:math';

import 'exercise.dart';
import 'srs.dart';
import 'turkish_text.dart';

/// Shared by Brainstorm and Review: what happened after an answer.
class AnswerOutcome {
  /// Review only: the grade to persist (null for re-asks).
  final ReviewGrade? grade;

  /// Brainstorm only: the word just passed its last step.
  final bool wordCompleted;
  final int mistakes;
  const AnswerOutcome({this.grade, this.wordCompleted = false, this.mistakes = 0});
}

/// Builds multiple-choice options: 1 correct + up to 4 distractors, drawn
/// from [pool] (same kind, similar length, no duplicates). Returns fewer than
/// 2 entries when the pool is too small; callers then fall back to `reveal`.
List<String> buildChoiceOptions({
  required VocabItem word,
  required List<VocabItem> pool,
  required String Function(VocabItem) pick,
  required Random rng,
}) {
  final correct = pick(word);
  final seen = <String>{trNormalize(correct)};

  List<String> collect(bool strict) {
    final out = <String>[];
    final candidates = pool.where((p) => p.id != word.id).toList()
      ..shuffle(rng);
    for (final p in candidates) {
      final text = pick(p);
      final key = trNormalize(text);
      if (key.isEmpty || seen.contains(key)) continue;
      if (strict &&
          (p.kind != word.kind ||
              (text.length - correct.length).abs() > 3)) {
        continue;
      }
      seen.add(key);
      out.add(text);
      if (out.length == 4) break;
    }
    return out;
  }

  var distractors = collect(true);
  if (distractors.isEmpty) distractors = collect(false);
  return [correct, ...distractors]..shuffle(rng);
}

/// Shuffled letters of `trLower(turkish)`; reshuffled if left unchanged.
List<String> constructLetters(String turkish, Random rng) {
  final letters = trLower(turkish).split('');
  final original = List<String>.from(letters);
  if (letters.toSet().length < 2) return letters;
  for (var i = 0; i < 10; i++) {
    letters.shuffle(rng);
    if (letters.join() != original.join()) break;
  }
  return letters;
}

class _Entry {
  final VocabItem word;
  final List<ExerciseType> steps;
  int stepIndex = 0;
  int mistakes = 0;
  int blockedUntil = 0;
  int lastServed = -1;
  _Entry(this.word, this.steps);
  bool get done => stepIndex >= steps.length;
}

/// Lingualeo-style learning round for new words (pure Dart, no I/O).
///
/// Every word passes `[chooseMeaning, chooseTurkish, listenChoose,
/// construct]` (+ `typing` when enabled). Exercises are interleaved so the
/// same word never comes twice in a row, and a missed word is blocked for the
/// next 2 exercises before it is retried.
class BrainstormSession {
  final List<VocabItem> pool;
  final Random _rng;
  final List<_Entry> _entries;
  int _served = 0;
  int? _lastWordId;
  _Entry? _current;

  BrainstormSession({
    required List<VocabItem> words,
    List<VocabItem> pool = const [],
    bool typingEnabled = false,
    Random? rng,
  })  : pool = [...pool, ...words],
        _rng = rng ?? Random(),
        _entries = [
          for (final w in words)
            _Entry(w, [
              if (w.isSimple) ...[
                ExerciseType.chooseMeaning,
                ExerciseType.chooseTurkish,
                ExerciseType.listenChoose,
                ExerciseType.construct,
                if (typingEnabled) ExerciseType.typing,
              ] else ...[
                ExerciseType.reveal,
                ExerciseType.listenChoose,
              ],
            ]),
        ];

  int get totalSteps => _entries.fold(0, (s, e) => s + e.steps.length);
  int get doneSteps => _entries.fold(0, (s, e) => s + e.stepIndex);
  double get progress => totalSteps == 0 ? 1 : doneSteps / totalSteps;
  bool get isFinished => _entries.every((e) => e.done);
  int get totalMistakes => _entries.fold(0, (s, e) => s + e.mistakes);

  /// The next exercise, or null when every word has passed every step.
  Exercise? next() {
    final pending = _entries.where((e) => !e.done).toList();
    if (pending.isEmpty) {
      _current = null;
      return null;
    }
    // Never the same word twice in a row (unless it is the only one left);
    // among the rest prefer words that are not blocked after a mistake.
    bool unblocked(_Entry e) => e.blockedUntil < _served + 1;
    final others = pending.where((e) => e.word.id != _lastWordId).toList();
    var candidates = others.where(unblocked).toList();
    if (candidates.isEmpty) candidates = others;
    if (candidates.isEmpty) candidates = pending;

    // Lowest pending step first, then the least recently served (round-robin).
    candidates.sort((a, b) {
      final c = a.stepIndex.compareTo(b.stepIndex);
      return c != 0 ? c : a.lastServed.compareTo(b.lastServed);
    });
    final entry = candidates.first;
    _current = entry;
    _served++;
    entry.lastServed = _served;
    _lastWordId = entry.word.id;
    return _build(entry);
  }

  Exercise _build(_Entry e) {
    final w = e.word;
    var type = e.steps[e.stepIndex];
    switch (type) {
      case ExerciseType.chooseMeaning:
      case ExerciseType.listenChoose:
        final opts = buildChoiceOptions(
            word: w, pool: pool, pick: (x) => x.english, rng: _rng);
        if (opts.length < 2) return _reveal(w);
        return Exercise(
            wordId: w.id, type: type, options: opts, answer: w.english);
      case ExerciseType.chooseTurkish:
        final opts = buildChoiceOptions(
            word: w, pool: pool, pick: (x) => x.turkish, rng: _rng);
        if (opts.length < 2) return _reveal(w);
        return Exercise(
            wordId: w.id, type: type, options: opts, answer: w.turkish);
      case ExerciseType.construct:
        return Exercise(
            wordId: w.id,
            type: type,
            options: constructLetters(w.turkish, _rng),
            answer: trLower(w.turkish));
      case ExerciseType.typing:
        return Exercise(wordId: w.id, type: type, answer: w.turkish);
      case ExerciseType.reveal:
        return _reveal(w);
    }
  }

  Exercise _reveal(VocabItem w) =>
      Exercise(wordId: w.id, type: ExerciseType.reveal, answer: w.english);

  /// Report the answer to the exercise last returned by [next].
  AnswerOutcome answer(AnswerResult result) {
    final e = _current;
    if (e == null) return const AnswerOutcome();
    if (result.correct) {
      e.stepIndex++;
    } else {
      e.mistakes++;
      e.blockedUntil = _served + 2;
    }
    return AnswerOutcome(wordCompleted: e.done, mistakes: e.mistakes);
  }

  /// Mistakes so far for [wordId] (used when persisting the word).
  int mistakesFor(int wordId) =>
      _entries.firstWhere((e) => e.word.id == wordId).mistakes;
}
