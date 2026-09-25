import 'package:drift/drift.dart';

import '../domain/mastery.dart';
import '../domain/practice_mode.dart';
import '../domain/srs.dart';
import 'database.dart';

/// A due card: the word plus one of its practice states, ready to review.
class ReviewCard {
  final Word word;
  final PracticeState state;
  PracticeMode get mode => PracticeMode.fromDb(state.mode);

  const ReviewCard(this.word, this.state);
}

/// A word plus a derived mastery indicator and its active modes, for browse.
class WordWithMastery {
  final Word word;
  final double mastery;
  final List<PracticeMode> activeModes;

  const WordWithMastery(this.word, this.mastery, this.activeModes);
}

/// All reads/writes against the DB. Ties the drift schema to the SRS domain
/// logic so the UI never touches SM-2 details directly.
class WordRepository {
  final AppDatabase db;
  WordRepository(this.db);

  // ---- Adding & editing ----

  /// Add a word and immediately create its two recognition practice states
  /// (plan §2: writing/listening are created lazily later).
  Future<int> addWord({
    required String turkish,
    required String english,
    String root = '',
    List<String> suffixes = const [],
    String? note,
    String? source,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    return db.transaction(() async {
      final wordId = await db.into(db.words).insert(
            WordsCompanion.insert(
              turkish: turkish,
              english: english,
              root: Value(root),
              suffixes: Value(_encodeSuffixes(suffixes)),
              note: Value(note),
              source: Value(source),
            ),
          );
      for (final mode in PracticeMode.initialModes) {
        await _insertState(wordId, mode, at);
      }
      return wordId;
    });
  }

  Future<void> updateWordFields({
    required int wordId,
    String? turkish,
    String? english,
    String? root,
    List<String>? suffixes,
    String? note,
    String? source,
  }) async {
    await (db.update(db.words)..where((w) => w.id.equals(wordId))).write(
      WordsCompanion(
        turkish: turkish == null ? const Value.absent() : Value(turkish),
        english: english == null ? const Value.absent() : Value(english),
        root: root == null ? const Value.absent() : Value(root),
        suffixes: suffixes == null
            ? const Value.absent()
            : Value(_encodeSuffixes(suffixes)),
        note: note == null ? const Value.absent() : Value(note),
        source: source == null ? const Value.absent() : Value(source),
      ),
    );
  }

  Future<void> deleteWord(int wordId) async {
    await (db.delete(db.words)..where((w) => w.id.equals(wordId))).go();
  }

  /// Lazily create a writing/listening state the first time the user opts in.
  Future<void> ensureModeState(int wordId, PracticeMode mode,
      {DateTime? now}) async {
    final existing = await (db.select(db.practiceStates)
          ..where((s) => s.wordId.equals(wordId) & s.mode.equals(mode.dbValue)))
        .getSingleOrNull();
    if (existing == null) {
      await _insertState(wordId, mode, now ?? DateTime.now());
    }
  }

  Future<void> _insertState(int wordId, PracticeMode mode, DateTime at) async {
    final fresh = SrsState.fresh(now: at);
    await db.into(db.practiceStates).insert(
          PracticeStatesCompanion.insert(
            wordId: wordId,
            mode: mode.dbValue,
            intervalDays: Value(fresh.intervalDays),
            easeFactor: Value(fresh.easeFactor),
            repetitions: Value(fresh.repetitions),
            dueAt: fresh.dueAt!,
          ),
        );
  }

  // ---- Review queue ----

  /// All practice states due now, interleaved across modes and words
  /// (plan §4: mixed queue beats blocking by mode). Ordered by due date.
  Future<List<ReviewCard>> dueQueue({DateTime? now, int? limit}) async {
    final at = now ?? DateTime.now();
    final query = db.select(db.practiceStates).join([
      innerJoin(db.words, db.words.id.equalsExp(db.practiceStates.wordId)),
    ])
      ..where(db.practiceStates.dueAt.isSmallerOrEqualValue(at))
      ..orderBy([OrderingTerm.asc(db.practiceStates.dueAt)]);
    if (limit != null) query.limit(limit);

    final rows = await query.get();
    return rows
        .map((r) => ReviewCard(
              r.readTable(db.words),
              r.readTable(db.practiceStates),
            ))
        .toList();
  }

  Future<int> dueCount({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final count = db.practiceStates.id.count();
    final query = db.selectOnly(db.practiceStates)
      ..addColumns([count])
      ..where(db.practiceStates.dueAt.isSmallerOrEqualValue(at));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Apply a grade to a card: recompute SM-2 state, persist, and log it.
  Future<void> applyReview(
    ReviewCard card,
    ReviewGrade grade, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final current = SrsState(
      intervalDays: card.state.intervalDays,
      easeFactor: card.state.easeFactor,
      repetitions: card.state.repetitions,
      dueAt: card.state.dueAt,
      lastReviewedAt: card.state.lastReviewedAt,
    );
    final next = SrsScheduler.review(current, grade, card.mode, now: at);

    await db.transaction(() async {
      await (db.update(db.practiceStates)
            ..where((s) => s.id.equals(card.state.id)))
          .write(PracticeStatesCompanion(
        intervalDays: Value(next.intervalDays),
        easeFactor: Value(next.easeFactor),
        repetitions: Value(next.repetitions),
        dueAt: Value(next.dueAt!),
        lastReviewedAt: Value(next.lastReviewedAt),
      ));
      await db.into(db.reviewLog).insert(ReviewLogCompanion.insert(
            wordId: card.word.id,
            mode: card.mode.dbValue,
            result: grade.dbValue,
          ));
    });
  }

  // ---- Browse & stats ----

  Future<List<Word>> searchWords(String query) async {
    final sel = db.select(db.words)
      ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]);
    if (query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      sel.where((w) => w.turkish.like(q) | w.english.like(q));
    }
    return sel.get();
  }

  /// Reactive version — emits a new list whenever the words table changes.
  Stream<List<Word>> watchWords(String query) {
    final sel = db.select(db.words)
      ..orderBy([(w) => OrderingTerm.desc(w.createdAt)]);
    if (query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      sel.where((w) => w.turkish.like(q) | w.english.like(q));
    }
    return sel.watch();
  }

  /// Delete every word (cascades to practice states and review log).
  Future<void> deleteAllWords() => db.delete(db.words).go();

  /// A word with its derived mastery indicator (plan §3).
  Future<WordWithMastery> withMastery(Word word) async {
    final states = await (db.select(db.practiceStates)
          ..where((s) => s.wordId.equals(word.id)))
        .get();
    final byMode = <PracticeMode, int>{
      for (final s in states) PracticeMode.fromDb(s.mode): s.repetitions,
    };
    return WordWithMastery(
      word,
      Mastery.overall(byMode),
      byMode.keys.toList(),
    );
  }

  /// Aggregate stats for the dashboard.
  Future<VocabStats> stats({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final totalWords = await db.words.count().getSingle();
    final due = await dueCount(now: at);
    final states = await db.select(db.practiceStates).get();
    final reviewsToday = await _reviewsSince(
        DateTime(at.year, at.month, at.day));

    // Group repetitions by word to compute an average mastery.
    final byWord = <int, Map<PracticeMode, int>>{};
    for (final s in states) {
      byWord
          .putIfAbsent(s.wordId, () => {})[PracticeMode.fromDb(s.mode)] =
          s.repetitions;
    }
    final masteries = byWord.values.map(Mastery.overall).toList();
    final avgMastery = masteries.isEmpty
        ? 0.0
        : masteries.reduce((a, b) => a + b) / masteries.length;

    return VocabStats(
      totalWords: totalWords,
      dueNow: due,
      reviewsToday: reviewsToday,
      averageMastery: avgMastery,
    );
  }

  Future<Word?> wordById(int id) =>
      (db.select(db.words)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Three random English translations from words other than [exceptWordId],
  /// used as distractors in listening multiple-choice (plan §4.4).
  Future<List<String>> randomEnglishDistractors(
      int exceptWordId, int n) async {
    final rows = await (db.select(db.words)
          ..where((w) => w.id.equals(exceptWordId).not())
          ..orderBy([(w) => OrderingTerm(
                expression: FunctionCallExpression('random', []),
              )])
          ..limit(n))
        .get();
    return rows.map((w) => w.english).toList();
  }

  /// Per-mode due counts for the stats screen.
  Future<Map<PracticeMode, int>> dueCountByMode({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final states = await (db.select(db.practiceStates)
          ..where((s) => s.dueAt.isSmallerOrEqualValue(at)))
        .get();
    final result = <PracticeMode, int>{};
    for (final s in states) {
      final mode = PracticeMode.fromDb(s.mode);
      result[mode] = (result[mode] ?? 0) + 1;
    }
    return result;
  }

  Future<int> _reviewsSince(DateTime since) async {
    final count = db.reviewLog.id.count();
    final query = db.selectOnly(db.reviewLog)
      ..addColumns([count])
      ..where(db.reviewLog.reviewedAt.isBiggerOrEqualValue(since));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  static String _encodeSuffixes(List<String> suffixes) {
    // Simple JSON array of strings.
    final escaped =
        suffixes.map((s) => '"${s.replaceAll('"', '\\"')}"').join(',');
    return '[$escaped]';
  }
}

class VocabStats {
  final int totalWords;
  final int dueNow;
  final int reviewsToday;
  final double averageMastery;

  const VocabStats({
    required this.totalWords,
    required this.dueNow,
    required this.reviewsToday,
    required this.averageMastery,
  });
}
