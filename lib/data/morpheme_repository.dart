import 'package:drift/drift.dart';

import '../domain/morpheme_ref.dart';
import '../domain/srs.dart';
import '../domain/suffix_drill_session.dart';
import '../domain/suffix_glosses.dart';
import 'database.dart';

/// Suffix-level data: examples, SRS state, and per-level progress.
class MorphemeRepository {
  final AppDatabase db;
  MorphemeRepository(this.db);

  static int _levelIndex(String level) => cefrLevels.indexOf(level);

  SrsState _srs(Morpheme m) => SrsState(
    intervalDays: m.intervalDays,
    easeFactor: m.easeFactor,
    repetitions: m.repetitions,
    lapses: m.lapses,
    dueAt: m.dueAt,
    lastReviewedAt: m.lastReviewedAt,
  );

  /// Suffixes up to [maxLevel] that have at least one example.
  /// Pack examples and the user's own words are both used.
  Future<List<DrillCandidate>> candidates(String maxLevel) async {
    final limit = _levelIndex(maxLevel);
    final ids = [
      for (final e in suffixGlosses.entries)
        if (_levelIndex(e.value.level) <= limit) e.key,
    ];

    final rows = {for (final m in await db.select(db.morphemes).get()) m.id: m};

    final packEx = <String, List<DrillExample>>{};
    for (final e in await db.select(db.morphemeExamples).get()) {
      packEx
          .putIfAbsent(e.morphemeId, () => [])
          .add(DrillExample(word: e.turkish, english: e.english));
    }

    // Own words: newest first, at most 20 per suffix.
    final own = <String, List<DrillExample>>{};
    final q = db.select(db.wordMorphemes).join([
      innerJoin(db.words, db.words.id.equalsExp(db.wordMorphemes.wordId)),
    ])..orderBy([OrderingTerm.desc(db.words.id)]);
    for (final r in await q.get()) {
      final w = r.readTable(db.words);
      if (w.kind != 'word' || w.english.trim().isEmpty) continue;
      final id = r.readTable(db.wordMorphemes).morphemeId;
      final list = own.putIfAbsent(id, () => []);
      if (list.length >= 20 || list.any((e) => e.word == w.turkish)) continue;
      list.add(
        DrillExample(
          word: w.turkish,
          english: w.english,
          own: true,
          lemma: w.lemma,
          parts: MorphemeRef.decodeList(w.morphemes),
        ),
      );
    }

    return [
      for (final id in ids)
        if ((packEx[id]?.length ?? 0) + (own[id]?.length ?? 0) > 0)
          DrillCandidate(
            id: id,
            examples: [...?own[id], ...?packEx[id]],
            repetitions: rows[id]?.repetitions ?? 0,
            dueAt: rows[id]?.dueAt,
            isNew: rows[id] == null || rows[id]!.status == 'new',
          ),
    ];
  }

  Future<int> dueCount(String maxLevel, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final list = await candidates(maxLevel);
    return list.where((c) => c.isDue(at)).length;
  }

  /// How many suffixes could be started right now (new, with examples).
  Future<int> drillableCount(String maxLevel, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final list = await candidates(maxLevel);
    return list.where((c) => c.isDue(at) || c.isNew).length;
  }

  Future<void> applyReview(
    String morphemeId,
    ReviewGrade grade, {
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.morphemes)
          .insert(
            MorphemesCompanion.insert(id: morphemeId),
            mode: InsertMode.insertOrIgnore,
          );
      final row = await (db.select(
        db.morphemes,
      )..where((m) => m.id.equals(morphemeId))).getSingle();
      final next = SrsScheduler.reviewWord(_srs(row), grade, now: at);
      await (db.update(
        db.morphemes,
      )..where((m) => m.id.equals(morphemeId))).write(
        MorphemesCompanion(
          status: const Value('review'),
          intervalDays: Value(next.intervalDays),
          easeFactor: Value(next.easeFactor),
          repetitions: Value(next.repetitions),
          lapses: Value(next.lapses),
          dueAt: Value(next.dueAt),
          lastReviewedAt: Value(next.lastReviewedAt),
        ),
      );
      await db
          .into(db.reviewLog)
          .insert(
            ReviewLogCompanion.insert(
              exercise: 'suffixDrill',
              result: grade.dbValue,
              morphemeId: Value(morphemeId),
              reviewedAt: Value(at),
            ),
          );
    });
  }

  /// Share of the suffixes of [level] (that have examples) answered
  /// correctly at least twice. 0..1; 0 when there are none.
  Future<double> levelProgress(String level) async {
    final list = (await candidates(level)).where((c) => c.info.level == level);
    if (list.isEmpty) return 0;
    return list.where((c) => !c.isNew && c.repetitions >= 2).length /
        list.length;
  }
}
