/// Turkish-aware text helpers. Dart's `toLowerCase()` is locale-blind:
/// `I`→`i` (should be `ı`) and `İ`→`i̇` (i + combining dot).
library;

/// Lowercase using Turkish rules.
String trLower(String s) {
  final mapped = s.replaceAll('I', 'ı').replaceAll('İ', 'i');
  return mapped.toLowerCase().replaceAll('̇', '');
}

final _edgePunct = RegExp(
  r'''^[.,!?;:…"'«»“”‘’()\[\]\-–—\s]+|[.,!?;:…"'«»“”‘’()\[\]\-–—\s]+$''',
);

/// Lowercase, trim, collapse whitespace and strip leading/trailing
/// punctuation. Inner apostrophes are kept.
String trNormalize(String s) {
  final lower = trLower(s).replaceAll(RegExp(r'\s+'), ' ');
  return lower.replaceAll(_edgePunct, '');
}

const _diacriticMap = {
  'ı': 'i',
  'ş': 's',
  'ğ': 'g',
  'ç': 'c',
  'ö': 'o',
  'ü': 'u',
  'â': 'a',
  'î': 'i',
  'û': 'u',
};

/// Replace Turkish letters with their ASCII look-alikes.
String stripDiacritics(String s) =>
    s.split('').map((c) => _diacriticMap[c] ?? c).join();

/// `word`, `phrase` or `sentence`, from the shape of the Turkish text.
String inferKind(String turkish) {
  final text = turkish.trim();
  final tokens =
      text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;
  if (tokens <= 1) return 'word';
  if (tokens >= 5 || RegExp(r'[.!?…]$').hasMatch(text)) return 'sentence';
  return 'phrase';
}
