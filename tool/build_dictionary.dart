// Builds assets/dict/tr_en.db from a kaikki.org Turkish JSONL dump.
//   dart run tool/build_dictionary.dart kaikki.org-dictionary-Turkish.jsonl assets/dict/tr_en.db
// Data: Wiktionary via kaikki.org, CC BY-SA 4.0.
import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';
import 'package:turkish_vocab/domain/turkish_text.dart';

const _skipTags = {'form-of', 'alt-of', 'misspelling', 'obsolete', 'dated'};

String _clip(String s, int max) {
  final t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.length <= max ? t : '${t.substring(0, max - 1).trimRight()}…';
}

void main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('usage: build_dictionary <kaikki.jsonl> <out.db>');
    exit(64);
  }
  final out = File(args[1]);
  if (out.existsSync()) out.deleteSync();
  out.parent.createSync(recursive: true);
  final db = sqlite3.open(out.path);
  db.execute('''
    CREATE TABLE entries(
      lemma TEXT NOT NULL,   -- trNormalize(headword)
      word TEXT NOT NULL,    -- headword as written
      pos TEXT NOT NULL,
      glosses TEXT NOT NULL, -- JSON list, up to 3 x 80 chars
      ex_tr TEXT, ex_en TEXT -- one short example, if the dump has one
    );
  ''');
  final insert = db.prepare(
    'INSERT INTO entries(lemma, word, pos, glosses, ex_tr, ex_en) '
    'VALUES (?,?,?,?,?,?)',
  );

  var read = 0, kept = 0;
  db.execute('BEGIN');
  final lines = File(args[0])
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  await for (final line in lines) {
    read++;
    if (line.isEmpty) continue;
    final d = jsonDecode(line) as Map<String, dynamic>;
    if (d['lang_code'] != 'tr') continue;
    final word = d['word'] as String?;
    final pos = d['pos'] as String?;
    if (word == null || pos == null) continue;
    if (pos == 'suffix' || pos == 'prefix' || pos == 'interfix') continue;
    if (pos == 'character' || pos == 'symbol') continue;

    final glosses = <String>[];
    String? exTr, exEn;
    for (final s in (d['senses'] as List? ?? const [])) {
      final sense = s as Map<String, dynamic>;
      final tags = (sense['tags'] as List? ?? const []).cast<String>();
      if (tags.any(_skipTags.contains)) continue;
      if (sense['form_of'] != null || sense['alt_of'] != null) continue;
      for (final g in (sense['glosses'] as List? ?? const [])) {
        final text = _clip(g as String, 80);
        if (text.isNotEmpty && !glosses.contains(text) && glosses.length < 3) {
          glosses.add(text);
        }
      }
      if (exTr == null) {
        for (final e in (sense['examples'] as List? ?? const [])) {
          final m = e as Map<String, dynamic>;
          final tr = m['text'] as String?;
          final en = (m['english'] ?? m['translation']) as String?;
          if (tr != null && en != null && tr.length <= 70 && en.length <= 90) {
            exTr = tr;
            exEn = en;
            break;
          }
        }
      }
    }
    if (glosses.isEmpty) continue;
    insert.execute([trNormalize(word), word, pos, jsonEncode(glosses), exTr, exEn]);
    kept++;
  }
  db.execute('COMMIT');
  db.execute('CREATE INDEX idx_entries_lemma ON entries(lemma)');
  insert.close();
  db.execute('VACUUM');
  db.close();
  final mb = out.lengthSync() / (1024 * 1024);
  stdout.writeln('read $read lines, kept $kept entries, ${mb.toStringAsFixed(1)} MB');
}
