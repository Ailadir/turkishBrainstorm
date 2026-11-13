/// Result of one scored answer. Brainstorm/Review derive it automatically
/// from correctness and speed; nothing is self-graded.
enum ReviewGrade {
  again,
  hard,
  good,
  easy;

  String get dbValue => name;

  static ReviewGrade fromDb(String value) =>
      ReviewGrade.values.firstWhere((g) => g.name == value);

  /// SM-2 quality value in the 0–5 range. `again` is a lapse (< 3).
  int get quality => switch (this) {
    again => 2,
    hard => 3,
    good => 4,
    easy => 5,
  };

  bool get isPass => quality >= 3;
}

/// Immutable snapshot of a word's (or suffix's) scheduling state.
class SrsState {
  final double intervalDays;
  final double easeFactor;
  final int repetitions;
  final int lapses;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  const SrsState({
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    this.lapses = 0,
    this.dueAt,
    this.lastReviewedAt,
  });

  /// A brand-new item: due immediately, default ease.
  factory SrsState.fresh({DateTime? now}) => SrsState(
    intervalDays: 0,
    easeFactor: SrsScheduler.defaultEaseFactor,
    repetitions: 0,
    dueAt: now ?? DateTime.now(),
  );
}

/// SM-2, one state per word. Intervals: 1 day → 3 days → interval × ease.
class SrsScheduler {
  static const double defaultEaseFactor = 2.5;
  static const double minEaseFactor = 1.3;

  /// A lapsed word is due again after 10 minutes.
  static const double lapseIntervalDays = 10 / (24 * 60);

  static const double firstIntervalDays = 1;
  static const double secondIntervalDays = 3;

  /// Growth multiplier for a `hard` pass (slower than `good`).
  static const double hardGrowth = 1.2;

  /// Extra multiplier for an `easy` pass.
  static const double easyBonus = 1.3;

  static SrsState reviewWord(
    SrsState state,
    ReviewGrade grade, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();

    // Standard SM-2 ease update: EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
    final q = grade.quality;
    final delta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    var ease = state.easeFactor + delta;
    if (ease < minEaseFactor) ease = minEaseFactor;

    if (!grade.isPass) {
      return SrsState(
        intervalDays: lapseIntervalDays,
        easeFactor: ease,
        repetitions: 0,
        lapses: state.lapses + 1,
        dueAt: _addDays(at, lapseIntervalDays),
        lastReviewedAt: at,
      );
    }

    double interval;
    if (state.repetitions == 0) {
      interval = firstIntervalDays;
    } else if (state.repetitions == 1) {
      interval = secondIntervalDays;
    } else {
      interval = state.intervalDays * ease;
    }
    if (grade == ReviewGrade.hard) {
      interval = state.repetitions == 0
          ? firstIntervalDays
          : (state.intervalDays * hardGrowth).clamp(
              firstIntervalDays,
              double.infinity,
            );
    } else if (grade == ReviewGrade.easy) {
      interval *= easyBonus;
    }

    return SrsState(
      intervalDays: interval,
      easeFactor: ease,
      repetitions: state.repetitions + 1,
      lapses: state.lapses,
      dueAt: _addDays(at, interval),
      lastReviewedAt: at,
    );
  }

  static DateTime _addDays(DateTime from, double days) =>
      from.add(Duration(milliseconds: (days * 86400000).round()));
}
