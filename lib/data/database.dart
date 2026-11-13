import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A Turkish word, phrase or sentence. Holds its own SRS state: there is one
/// card per word; exercises are presentation only.
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The text as entered.
  TextColumn get turkish => text()();

  /// `trNormalize(turkish)`; unique, used for de-duplication.
  TextColumn get normalized => text().unique()();

  TextColumn get english => text()();

  /// True once the user typed/edited the English (packs must not overwrite it).
  BoolColumn get englishEdited =>
      boolean().withDefault(const Constant(false))();

  /// `word` | `phrase` | `sentence`.
  TextColumn get kind => text().withDefault(const Constant('word'))();

  TextColumn get lemma => text().nullable()();
  TextColumn get pos => text().nullable()();

  /// JSON `[{"s":"ler","id":"A3pl"}]` from Zemberek.
  TextColumn get morphemes => text().withDefault(const Constant('[]'))();

  TextColumn get note => text().nullable()();
  TextColumn get noteEn => text().nullable()();
  TextColumn get source => text().nullable()();

  /// CEFR level `A1..B2`, set for pack words.
  TextColumn get level => text().nullable()();

  /// `new` | `learning` | `review` | `suspended`.
  TextColumn get status => text().withDefault(const Constant('new'))();

  RealColumn get intervalDays => real().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  /// True until the background analysis job has filled lemma/pos/morphemes.
  BoolColumn get needsAnalysis => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Suffixes of a word, one row per morpheme (queried by the suffix drill).
class WordMorphemes extends Table {
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get morphemeId => text()();
  TextColumn get surface => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {wordId, position};
}

/// One row per Zemberek morpheme id, with its own SRS state (suffix drill).
class Morphemes extends Table {
  TextColumn get id => text()();
  TextColumn get status => text().withDefault(const Constant('new'))();
  RealColumn get intervalDays => real().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PackRow')
class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get level => text().nullable()();

  /// `words` | `grammar`.
  TextColumn get kind => text()();
  IntColumn get version => integer()();
  DateTimeColumn get installedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Grammar examples that come from packs.
class MorphemeExamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get morphemeId => text()();
  TextColumn get turkish => text()();
  TextColumn get english => text()();
  TextColumn get packId =>
      text().references(Packs, #id, onDelete: KeyAction.cascade)();
}

class WordPacks extends Table {
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get packId =>
      text().references(Packs, #id, onDelete: KeyAction.cascade)();
  IntColumn get rank => integer()();

  @override
  Set<Column> get primaryKey => {wordId, packId};
}

class TranslationCache extends Table {
  TextColumn get key => text()();
  TextColumn get payload => text()();
  TextColumn get provider => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}

/// Append-only log of answers, for stats.
class ReviewLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().nullable().references(
    Words,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get morphemeId => text().nullable()();

  /// [ExerciseType] name.
  TextColumn get exercise => text()();

  /// [ReviewGrade] name, or `pass` / `fail` for Brainstorm.
  TextColumn get result => text()();
  DateTimeColumn get reviewedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Words,
    WordMorphemes,
    Morphemes,
    MorphemeExamples,
    Packs,
    WordPacks,
    TranslationCache,
    ReviewLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Owner approved wiping v1 data: drop everything, start clean.
        for (final t in ['practice_states', 'review_log', 'words']) {
          await customStatement('DROP TABLE IF EXISTS $t');
        }
        await m.createAll();
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless asked; without this, cascades
      // never fire and deleted words leave orphan rows behind.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _open() {
    // Offline-first local SQLite in the app's documents dir.
    return driftDatabase(name: 'turkish_vocab');
  }
}
