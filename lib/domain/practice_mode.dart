/// The independent practice modes. Each `(word, mode)` pair is scheduled
/// separately so "I recognize it", "I can spell it" and "I can hear it" are
/// tracked as distinct skills. See build plan §2 / §4.
enum PracticeMode {
  recognitionTrEn,
  recognitionEnTr,
  writing,
  listening;

  /// The two modes created immediately when a word is added. Writing and
  /// listening are created lazily the first time the user opts into them,
  /// so new words don't produce 4x the reviews on day one (plan §2).
  static const List<PracticeMode> initialModes = [
    recognitionTrEn,
    recognitionEnTr,
  ];

  bool get isRecognition => this == recognitionTrEn || this == recognitionEnTr;

  String get label => switch (this) {
    recognitionTrEn => 'Recognition TR→EN',
    recognitionEnTr => 'Recognition EN→TR',
    writing => 'Writing',
    listening => 'Listening',
  };

  /// Stable string used to persist the enum in the DB.
  String get dbValue => name;

  static PracticeMode fromDb(String value) =>
      PracticeMode.values.firstWhere((m) => m.name == value);
}

/// Grading buttons shown after each review (standard SM-2 4-button grading).
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
