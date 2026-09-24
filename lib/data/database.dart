import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A Turkish word encountered in the wild, with its morphological breakdown
/// and translation (build plan §2).
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The full word as encountered.
  TextColumn get turkish => text()();

  /// Root/lemma from Zemberek analysis.
  TextColumn get root => text().withDefault(const Constant(''))();

  /// Suffix morpheme ids as a JSON array string (editable if ambiguous).
  TextColumn get suffixes => text().withDefault(const Constant('[]'))();

  /// Primary English translation.
  TextColumn get english => text()();

  /// Example sentence / context from the source, optional.
  TextColumn get note => text().nullable()();

  /// Where the word was found (e.g. manhwa title), optional.
  TextColumn get source => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// One row per `(word, mode)` — the core of the "separate skill per mode"
/// design. Stores SM-2 scheduling state (build plan §2 / §3).
class PracticeStates extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  /// Persisted as the [PracticeMode] enum name.
  TextColumn get mode => text()();

  RealColumn get intervalDays => real().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();

  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {wordId, mode},
      ];
}

/// Append-only log of reviews, used for stats and recomputing mastery.
/// Not required for scheduling itself (build plan §2).
class ReviewLog extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  /// Persisted as the [PracticeMode] enum name.
  TextColumn get mode => text()();

  /// Persisted as the [ReviewGrade] enum name.
  TextColumn get result => text()();

  DateTimeColumn get reviewedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Words, PracticeStates, ReviewLog])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    // Offline-first local SQLite in the app's documents dir.
    return driftDatabase(name: 'turkish_vocab');
  }
}
