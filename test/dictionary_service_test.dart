import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:turkish_vocab/services/dictionary_service.dart';

Database _db() {
  final db = sqlite3.openInMemory();
  db.execute('CREATE TABLE entries(lemma, word, pos, glosses, ex_tr, ex_en)');
  void add(String l, String w, String pos, String g) => db.execute(
    'INSERT INTO entries VALUES (?,?,?,?,NULL,NULL)',
    [l, w, pos, g],
  );
  add('gitmek', 'gitmek', 'verb', '["to go"]');
  add('ev', 'ev', 'noun', '["house", "home"]');
  add('ali', 'Ali', 'name', '["a male given name"]');
  return db;
}

void main() {
  final svc = DictionaryService(_db);

  test('exact match, case/diacritic-safe via trNormalize', () async {
    expect((await svc.lookup('EV'))?.shortGloss, 'house');
  });

  test('verb stem falls back to the -mek form', () async {
    final e = await svc.lookup('git');
    expect(e?.word, 'gitmek');
    expect(e?.shortGloss, 'to go');
  });

  test('unknown words return null', () async {
    expect(await svc.lookup('zzzz'), isNull);
  });
}
