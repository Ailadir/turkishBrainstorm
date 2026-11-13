/// Presentation of one question. The SRS state lives on the word, not on the
/// exercise, so exercises never multiply the number of cards.
enum ExerciseType {
  chooseMeaning, // Turkish shown, pick the English
  chooseTurkish, // English shown, pick the Turkish
  listenChoose, // audio played, pick the English
  construct, // English shown, tap the letters in order
  typing, // English shown, type the Turkish
  reveal, // flip card: "Knew it" / "Didn't"
}

/// Minimal view of a word for the pure-Dart sessions (no database types).
class VocabItem {
  final int id;
  final String turkish;
  final String english;

  /// `word`, `phrase` or `sentence`.
  final String kind;
  final int repetitions;

  const VocabItem({
    required this.id,
    required this.turkish,
    required this.english,
    this.kind = 'word',
    this.repetitions = 0,
  });

  /// Single short words get the full exercise ladder; the rest only
  /// reveal / listen.
  bool get isSimple => kind == 'word' && turkish.length <= 14;
}

class Exercise {
  final int wordId;
  final ExerciseType type;

  /// Choice options (choose*/listen) or shuffled letters (construct).
  final List<String> options;

  /// Correct option, or the expected Turkish text for construct/typing.
  final String answer;

  /// True when a lapsed word is asked once more; it is not scheduled again.
  final bool isReask;

  const Exercise({
    required this.wordId,
    required this.type,
    this.options = const [],
    this.answer = '',
    this.isReask = false,
  });
}

/// What the UI reports after the user answers.
class AnswerResult {
  final bool correct;
  final Duration took;

  /// Wrong taps before the final answer (choice/construct).
  final int wrongTaps;

  /// Typing only: correct apart from Turkish diacritics.
  final bool diacriticOnly;

  const AnswerResult({
    required this.correct,
    this.took = Duration.zero,
    this.wrongTaps = 0,
    this.diacriticOnly = false,
  });
}
