import 'practice_mode.dart';

/// Word-level mastery indicator (build plan §3). Derived on the fly for the
/// browse/stats UI — never stored. Weighted average of per-mode scores across
/// the word's *active* practice states, where harder modes count for more.
class Mastery {
  /// Per-mode weight in the mastery average.
  static double modeWeight(PracticeMode mode) => switch (mode) {
        PracticeMode.recognitionTrEn => 1.0,
        PracticeMode.recognitionEnTr => 1.0,
        PracticeMode.listening => 1.5,
        PracticeMode.writing => 2.0,
      };

  /// A single mode's score in [0, 1], based on consecutive-correct count.
  static double modeScore(int repetitions) {
    final s = repetitions / 5.0;
    return s.clamp(0.0, 1.0);
  }

  /// Weighted average across active modes. Returns 0 when there are no
  /// active states. [statesByMode] maps each active mode to its repetitions.
  static double overall(Map<PracticeMode, int> statesByMode) {
    if (statesByMode.isEmpty) return 0;
    double weightedSum = 0;
    double weightTotal = 0;
    statesByMode.forEach((mode, reps) {
      final w = modeWeight(mode);
      weightedSum += modeScore(reps) * w;
      weightTotal += w;
    });
    if (weightTotal == 0) return 0;
    return weightedSum / weightTotal;
  }
}
