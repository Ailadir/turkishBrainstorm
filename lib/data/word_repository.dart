import 'package:drift/drift.dart';

import '../domain/exercise.dart';
import '../domain/mastery.dart';
import '../domain/morpheme_ref.dart';
import '../domain/srs.dart';
import '../domain/turkish_text.dart';
import 'database.dart';

extension WordX on Word {
  List<MorphemeRef> get morphemeRefs => MorphemeRef.decodeList(morphemes);
  double get mastery => Mastery.ofWord(status: status, repetitions: repetitions);

  VocabItem toItem() => VocabItem(
        id: id,
        turkish: turkish,
        english: english,
        kind: kind,
        repetitions: repetitions,
      );

  SrsState get srs => SrsState(
        intervalDays: intervalDays,
        easeFactor: easeFactor,
        repetitions: repetitions,
        lapses: lapses,
        dueAt: dueAt,
        lastReviewedAt: lastReviewedAt,
      );
}

/// All reads/writes against the DB. Ties the drift schema to the SRS domain
/// logic so the UI never touches SM-2 details directly.
class WordRepository {
  final AppDatabase db;
  WordRepository(this.db);

  static const _levelOrder = {'A1': 0, 'A2': 1, 'B1': 2, 'B2': 3};

  // ---- Adding & editing ----

  /// Add a word. Dedupes on the Turkish-normalised text; a duplicate returns
  /// the existing id with `existed: true`. Pass [lemma]/[morphemes] when the
  /// analysis is already known, otherwise the background job fills them in.
  Future<({int id, bool existed})> addWord({
    required String turkish,
    required String english,
    String? lemma,
    String? pos,
    List<MorphemeRef> morphemes = const [],
    String? note,
    String? noteEn,
    String? source,
    String? level,
    bool englishEdited = false,
    bool? needsAnalysis,
  }) async {
    final normalized = trNormalize(turkish);
    final existing = await (db.select(db.words)
          ..where((w) => w.normalized.equals(normalized)))
        .getSingleOrNull();
    if (existing != null) return (id: existing.id, existed: true);

    final kind = inferKind(turkish);
    final analysed = lemma != null && lemma.isNotEmpty;
    final id = await db.transaction(() async {
      final wordId = await db.into(db.words).insert(
            WordsCompanion.insert(
              turkish: turkish.trim(),
              normalized: normalized,
              english: english,
              englishEdited: Value(englishEdited),
              kind: Value(kind),
              lemma: Value(lemma),
              pos: Value(pos),
              morphemes: Value(MorphemeRef.encodeList(morphemes)),
              note: Value(note),
              noteEn: Value(noteEn),
              source: Value(source),
              level: Value(level),
              needsAnalysis: Value(needsAnalysis ?? !analysed),
            ),
          );
      if (analysed) await _writeMorphemes(wordId, morphemes);
      return wordId;
    });
    return (id: id, existed: false);
  }

  Future<void> updateWordFields({
    required int wordId,
    String? turkish,
    String? english,
    String? lemma,
    String? note,
    String? source,
  }) async {
    final current = await wordById(wordId);
    if (current == null) return;
    final turkishChanged = turkish != null && turkish != current.turkish;
    final englishChanged = english != null && english != current.english;
    await (db.update(db.words)..where((w) => w.id.equals(wordId))).write(
      WordsCompanion(
        turkish: turkish == null ? const Value.absent() : Value(turkish),
        normalized: turkishChanged
            ? Value(trNormalize(turkish))
            : const Value.absent(),
        kind: turkishChanged ? Value(inferKind(turkish)) : const Value.absent(),
        needsAnalysis:
            turkishChanged ? const Value(true) : const Value.absent(),
        english: english == null ? const Value.absent() : Value(english),
        englishEdited:
            englishChanged ? const Value(true) : const Value.absent(),
        lemma: lemma == null ? const Value.absent() : Value(lemma),
        note: note == null ? const Value.absent() : Value(note),
        source: source == null ? const Value.absent() : Value(source),
      ),
    );
  }

  Future<void> deleteWord(int wordId) async {
    await (db.delete(db.words)..where((w) => w.id.equals(wordId))).go();
  }

  /// Delete every word (cascades to morphemes, pack links and the log).
  Future<void> deleteAllWords() => db.delete(db.words).go();

  // ---- Morphology analysis job ----

  Future<List<Word>> wordsNeedingAnalysis(int limit) =>
      (db.select(db.words)
            ..where((w) => w.needsAnalysis.equals(true))
            ..orderBy([(w) => OrderingTerm.asc(w.id)])
            ..limit(limit))
          .get();

  /// Store an analysis: lemma/pos/morphemes on the word, one `WordMorphemes`
  /// row per suffix, and a `Morphemes` row for every id seen for the first time.
  Future<void> applyAnalysis(
    int wordId, {
    required String lemma,
    String? pos,
    required List<MorphemeRef> morphemes,
  }) async {
    await db.transaction(() async {
      await (db.update(db.words)..where((w) => w.id.equals(wordId))).write(
        WordsCompanion(
          lemma: Value(lemma),
          pos: Value(pos),
          morphemes: Value(MorphemeRef.encodeList(morphemes)),
          needsAnalysis: const Value(false),
        ),
      );
      await _writeMorphemes(wordId, morphemes);
    });
  }

  Future<void> _writeMorphemes(int wordId, List<MorphemeRef> list) async {
    await (db.delete(db.wordMorphemes)..where((m) => m.wordId.equals(wordId)))
        .go();
    for (var i = 0; i < list.length; i++) {
      await db.into(db.wordMorphemes).insert(WordMorphemesCompanion.insert(
            wordId: wordId,
            morphemeId: list[i].id,
            surface: list[i].surface,
            position: i,
          ));
      await db
          .into(db.morphemes)
          .insert(MorphemesCompanion.insert(id: list[i].id),
              mode: InsertMode.insertOrIgnore);
    }
  }

  // ---- Brainstorm / Review ----

  /// New words for a Brainstorm round: own words (not from any pack) newest
  /// first, then — if [usePackWords] — pack words by CEFR level and rank.
  Future<List<Word>> pickNewWords(int n, {bool usePackWords = true}) async {
    final fresh = await (db.select(db.words)
          ..where((w) => w.status.equals('new')))
        .get();
    final packRows = await db.select(db.wordPacks).get();
    final rankByWord = <int, int>{};
    for (final r in packRows) {
      final cur = rankByWord[r.wordId];
      if (cur == null || r.rank < cur) rankByWord[r.wordId] = r.rank;
    }
    final own = fresh.where((w) => !rankByWord.containsKey(w.id)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt) != 0
          ? b.createdAt.compareTo(a.createdAt)
          : b.id.compareTo(a.id));
    final result = <Word>[...own];
    if (usePackWords) {
      final pack = fresh.where((w) => rankByWord.containsKey(w.id)).toList()
        ..sort((a, b) {
          final la = _levelOrder[a.level] ?? 9;
          final lb = _levelOrder[b.level] ?? 9;
          if (la != lb) return la.compareTo(lb);
          return rankByWord[a.id]!.compareTo(rankByWord[b.id]!);
        });
      result.addAll(pack);
    }
    return result.take(n).toList();
  }

  /// Number of words a Brainstorm could serve (own words, plus pack words
  /// when [usePackWords]).
  Future<int> newCount({bool usePackWords = true}) async =>
      (await pickNewWords(1 << 30, usePackWords: usePackWords)).length;

  /// A word passed every Brainstorm step: schedule its first review for
  /// tomorrow; more [mistakes] lower the starting ease (2.5 − 0.15×min(m,3)).
  Future<void> finishBrainstorm(int wordId, int mistakes, {DateTime? now}) {
    final at = now ?? DateTime.now();
    return (db.update(db.words)..where((w) => w.id.equals(wordId))).write(
      WordsCompanion(
        status: const Value('review'),
        repetitions: const Value(1),
        intervalDays: const Value(1),
        easeFactor: Value(2.5 - 0.15 * (mistakes > 3 ? 3 : mistakes)),
        dueAt: Value(at.add(const Duration(days: 1))),
        lastReviewedAt: Value(at),
      ),
    );
  }

  /// Words due for review (`status = review`, `dueAt <= now`), most overdue
  /// first, capped at [limit].
  Future<List<Word>> dueWords({DateTime? now, int? limit}) async {
    final at = now ?? DateTime.now();
    final q = db.select(db.words)
      ..where((w) => w.status.equals('review') & w.dueAt.isSmallerOrEqualValue(at))
      ..orderBy([(w) => OrderingTerm.asc(w.dueAt), (w) => OrderingTerm.asc(w.id)]);
    if (limit != null) q.limit(limit);
    return q.get();
  }

  Future<int> dueCount({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final c = db.words.id.count();
    final row = await (db.selectOnly(db.words)
          ..addColumns([c])
          ..where(db.words.status.equals('review') &
              db.words.dueAt.isSmallerOrEqualValue(at)))
        .getSingle();
    return row.read(c) ?? 0;
  }

  /// Apply an auto-graded review to the word's SRS state and log it.
  Future<void> applyWordReview(
    int wordId,
    ReviewGrade grade,
    ExerciseType exercise, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final word = await wordById(wordId);
    if (word == null) return;
    final next = SrsScheduler.reviewWord(word.srs, grade, now: at);
    await db.transaction(() async {
      await (db.update(db.words)..where((w) => w.id.equals(wordId))).write(
        WordsCompanion(
          intervalDays: Value(next.intervalDays),
          easeFactor: Value(next.easeFactor),
          repetitions: Value(next.repetitions),
          lapses: Value(next.lapses),
          dueAt: Value(next.dueAt),
          lastReviewedAt: Value(next.lastReviewedAt),
        ),
      );
      await _log(wordId, exercise, grade.dbValue, at);
    });
  }

  /// Log one Brainstorm answer (`pass` / `fail`).
  Future<void> logBrainstorm(int wordId, ExerciseType exercise, bool correct,
      {DateTime? now}) {
    return _log(wordId, exercise, correct ? 'pass' : 'fail',
        now ?? DateTime.now());
  }

  Future<void> _log(
      int wordId, ExerciseType exercise, String result, DateTime at) {
    return db.into(db.reviewLog).insert(ReviewLogCompanion.insert(
          wordId: Value(wordId),
          exercise: exercise.name,
          result: result,
          reviewedAt: Value(at),
        ));
  }

  /// Words used as multiple-choice distractors (everything but [exceptIds]).
  Future<List<VocabItem>> distractorPool({Set<int> exceptIds = const {}}) async {
    final rows = await db.select(db.words).get();
    return [
      for (final w in rows)
        if (!exceptIds.contains(w.id)) w.toItem(),
    ];
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

  Future<Word?> wordById(int id) =>
      (db.select(db.words)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Aggregate stats for the dashboard.
  Future<VocabStats> stats({DateTime? now, bool usePackWords = true}) async {
    final at = now ?? DateTime.now();
    final words = await db.select(db.words).get();
    final reviewsToday =
        await _reviewsSince(DateTime(at.year, at.month, at.day));
    final avg = words.isEmpty
        ? 0.0
        : words.map((w) => w.mastery).reduce((a, b) => a + b) / words.length;
    return VocabStats(
      totalWords: words.length,
      dueNow: await dueCount(now: at),
      newCount: await newCount(usePackWords: usePackWords),
      reviewsToday: reviewsToday,
      averageMastery: avg,
      byStatus: {
        for (final s in ['new', 'learning', 'review', 'suspended'])
          s: words.where((w) => w.status == s).length,
      },
    );
  }

  Future<int> _reviewsSince(DateTime since) async {
    final count = db.reviewLog.id.count();
    final row = await (db.selectOnly(db.reviewLog)
          ..addColumns([count])
          ..where(db.reviewLog.reviewedAt.isBiggerOrEqualValue(since)))
        .getSingle();
    return row.read(count) ?? 0;
  }
}

class VocabStats {
  final int totalWords;
  final int dueNow;
  final int newCount;
  final int reviewsToday;
  final double averageMastery;
  final Map<String, int> byStatus;

  const VocabStats({
    required this.totalWords,
    required this.dueNow,
    required this.newCount,
    required this.reviewsToday,
    required this.averageMastery,
    this.byStatus = const {},
  });
}
