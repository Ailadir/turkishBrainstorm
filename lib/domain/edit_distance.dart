/// Levenshtein edit distance and a "close enough" helper used by Writing mode
/// to distinguish minor typos from real mistakes (build plan §4.3).
class EditDistance {
  /// Standard Levenshtein distance between two strings.
  static int compute(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final rows = a.length + 1;
    final cols = b.length + 1;
    final dp = List.generate(rows, (i) => List<int>.filled(cols, 0));

    for (var i = 0; i < rows; i++) { dp[i][0] = i; }
    for (var j = 0; j < cols; j++) { dp[0][j] = j; }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,     // deletion
          dp[i][j - 1] + 1,     // insertion
          dp[i - 1][j - 1] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[a.length][b.length];
  }

  /// Whether [input] is "close enough" to [expected] (minor typo vs. real
  /// mistake). Normalises both strings to lowercase and trims whitespace.
  ///
  /// Tolerance rule (plan §4.3):
  ///   - words ≤ 4 chars → tolerance 0 (exact match only — too short to forgive)
  ///   - words  > 4 chars → tolerance 1 (one-character transposition/typo OK)
  static bool isCloseEnough(String input, String expected,
      {int? tolerance}) {
    final a = input.trim().toLowerCase();
    final b = expected.trim().toLowerCase();
    if (a == b) return true;
    final tol = tolerance ?? (b.length <= 4 ? 0 : 1);
    return compute(a, b) <= tol;
  }
}
