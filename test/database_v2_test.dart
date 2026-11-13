import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/word_repository.dart';

void main() {
  test('v1 database is wiped and upgraded to the v2 schema', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
        CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, turkish TEXT NOT NULL,
          root TEXT NOT NULL DEFAULT '', suffixes TEXT NOT NULL DEFAULT '[]',
          english TEXT NOT NULL, note TEXT, source TEXT, created_at INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE practice_states (id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id INTEGER NOT NULL, mode TEXT NOT NULL);
        CREATE TABLE review_log (id INTEGER PRIMARY KEY AUTOINCREMENT,
          word_id INTEGER NOT NULL, mode TEXT NOT NULL, result TEXT NOT NULL,
          reviewed_at INTEGER NOT NULL DEFAULT 0);
        INSERT INTO words (turkish, english) VALUES ('ev', 'house');
        INSERT INTO practice_states (word_id, mode) VALUES (1, 'writing');
        PRAGMA user_version = 1;
      ''');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    // Old data is gone.
    expect(await db.select(db.words).get(), isEmpty);

    // All v2 tables exist.
    final names =
        (await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type='table'",
                )
                .get())
            .map((r) => r.read<String>('name'))
            .toSet();
    for (final t in [
      'words',
      'word_morphemes',
      'morphemes',
      'morpheme_examples',
      'packs',
      'word_packs',
      'translation_cache',
      'review_log',
    ]) {
      expect(names, contains(t));
    }
    expect(names, isNot(contains('practice_states')));

    // Foreign keys are enforced: deleting a word cascades.
    final repo = WordRepository(db);
    final id = (await repo.addWord(turkish: 'evde', english: 'at home')).id;
    await db
        .into(db.wordMorphemes)
        .insert(
          WordMorphemesCompanion.insert(
            wordId: id,
            morphemeId: 'Loc',
            surface: 'de',
            position: 0,
          ),
        );
    await db
        .into(db.packs)
        .insert(
          PacksCompanion.insert(id: 'p', title: 'P', kind: 'words', version: 1),
        );
    await db
        .into(db.wordPacks)
        .insert(WordPacksCompanion.insert(wordId: id, packId: 'p', rank: 1));
    await repo.deleteWord(id);
    expect(await db.select(db.wordMorphemes).get(), isEmpty);
    expect(await db.select(db.wordPacks).get(), isEmpty);
  });
}
