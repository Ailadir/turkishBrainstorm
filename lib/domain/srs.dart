import 'practice_mode.dart';

/// Immutable snapshot of a card's scheduling state for one `(word, mode)`.
class SrsState {
  final double intervalDays;
  final double easeFactor;
  final int repetitions;
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  const SrsState({
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    this.dueAt,
    this.lastReviewedAt,
  });

  /// A brand-new card: due immediately, default ease.
  factory SrsState.fresh({DateTime? now}) {
    final at = now ?? DateTime.now();
    return SrsState(
      intervalDays: 0,
      easeFactor: SrsScheduler.defaultEaseFactor,
      repetitions: 0,
      dueAt: at,
      lastReviewedAt: null,
    );
  }

  SrsState copyWith({
    double? intervalDays,
    double? easeFactor,
    int? repetitions,
    DateTime? dueAt,
    DateTime? lastReviewedAt,
  }) {
    return SrsState(
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }
}

/// SM-2 with per-mode interval weighting (build plan §3).
///
/// Base algorithm is standard SM-2, applied per `(word, mode)` independently.
/// On top of SM-2 we apply per-mode factors so that harder modes (writing,
/// listening) grow intervals faster on success and — for writing — penalise
/// the ease factor harder on failure. All tunables live here so they're easy
/// to adjust after a few weeks of real use.
class SrsScheduler {
  // ---- SM-2 base constants ----
  static const double defaultEaseFactor = 2.5;
  static const double minEaseFactor = 1.3;

  /// Learning/lapse step: how long until a lapsed card is due again.
  static const double lapseIntervalDays = 10 / (24 * 60); // 10 minutes

  /// Interval (days) granted the first time a card graduates from learning.
  static const double firstIntervalDays = 1;

  /// Interval (days) granted on the second successful review.
  static const double secondIntervalDays = 6;

  /// Growth multiplier applied for a `hard` pass (slower than `good`).
  static const double hardGrowth = 1.2;

  /// Extra multiplier for an `easy` pass on top of the ease factor.
  static const double easyBonus = 1.3;

  // ---- Per-mode weighting ----

  /// Multiplier applied to the successful-review interval per mode.
  /// Recognition = baseline; listening a little more; writing the most.
  static double intervalFactor(PracticeMode mode) => switch (mode) {
        PracticeMode.recognitionTrEn => 1.0,
        PracticeMode.recognitionEnTr => 1.0,
        PracticeMode.listening => 1.15,
        PracticeMode.writing => 1.4,
      };

  /// Multiplier applied to the ease penalty on an incorrect (`again`) review.
  /// Production failures (writing) matter more than recognition failures.
  static double easePenaltyFactor(PracticeMode mode) => switch (mode) {
        PracticeMode.writing => 1.5,
        _ => 1.0,
      };

  /// Compute the next state for a card given a grade.
  static SrsState review(
    SrsState state,
    ReviewGrade grade,
    PracticeMode mode, {
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();

    // --- Ease factor update (standard SM-2 formula) ---
    // EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
    final q = grade.quality;
    final delta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    double newEase;
    if (grade == ReviewGrade.again) {
      // Failures drop ease; writing failures drop it harder.
      newEase = state.easeFactor + delta * easePenaltyFactor(mode);
    } else {
      newEase = state.easeFactor + delta;
    }
    if (newEase < minEaseFactor) newEase = minEaseFactor;

    // --- Repetitions + interval ---
    int newReps;
    double newInterval;

    if (!grade.isPass) {
      // Lapse: reset repetitions, short relearning step. No mode factor.
      newReps = 0;
      newInterval = lapseIntervalDays;
    } else {
      newReps = state.repetitions + 1;
      double base;
      if (state.repetitions == 0) {
        base = firstIntervalDays;
      } else if (state.repetitions == 1) {
        base = secondIntervalDays;
      } else {
        base = state.intervalDays * newEase;
      }

      // Grade-specific shaping.
      switch (grade) {
        case ReviewGrade.hard:
          // Hard grows slowly regardless of ease.
          base = state.repetitions == 0
              ? firstIntervalDays
              : state.intervalDays * hardGrowth;
          break;
        case ReviewGrade.easy:
          base = base * easyBonus;
          break;
        case ReviewGrade.good:
          break;
        case ReviewGrade.again:
          break; // unreachable (handled above)
      }

      // Apply the per-mode interval factor to the successful interval.
      newInterval = base * intervalFactor(mode);
    }

    return SrsState(
      intervalDays: newInterval,
      easeFactor: newEase,
      repetitions: newReps,
      dueAt: _addDays(at, newInterval),
      lastReviewedAt: at,
    );
  }

  static DateTime _addDays(DateTime from, double days) {
    final ms = (days * 24 * 60 * 60 * 1000).round();
    return from.add(Duration(milliseconds: ms));
  }
}
