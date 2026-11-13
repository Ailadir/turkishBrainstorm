/// Word-level mastery indicator, derived on the fly (never stored).
class Mastery {
  /// 0 for a word not yet learned in Brainstorm; otherwise consecutive
  /// successful reviews / 5, clamped to [0, 1].
  static double ofWord({required String status, required int repetitions}) {
    if (status == 'new') return 0;
    return (repetitions / 5.0).clamp(0.0, 1.0);
  }
}
