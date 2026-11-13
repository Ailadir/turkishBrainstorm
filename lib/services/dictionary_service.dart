import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../domain/turkish_text.dart';

class DictEntry {
  final String word;
  final String pos;
  final List<String> glosses;
  final String? exampleTr;
  final String? exampleEn;
  const DictEntry({
    required this.word,
    required this.pos,
    required this.glosses,
    this.exampleTr,
    this.exampleEn,
  });

  /// Short English for a card: the first gloss up to the first comma/semicolon.
  String get shortGloss {
    var s = glosses.first.replaceFirst(RegExp(r'^\([^)]*\)\s*'), '');
    final cut = s.indexOf(RegExp(r'[,;]'));
    if (cut > 0) s = s.substring(0, cut);
    return s.trim().replaceFirst(RegExp(r'\.$'), '');
  }
}

/// Read-only Turkish→English dictionary built from Wiktionary (kaikki.org,
/// CC BY-SA 4.0) by `tool/build_dictionary.dart`.
class DictionaryService {
  static const assetPath = 'assets/dict/tr_en.db';

  Database? _db;
  final Database Function()? _opener;

  /// [_opener] lets tests supply an in-memory database.
  DictionaryService([this._opener]);

  Future<Database> _open() async {
    final existing = _db;
    if (existing != null) return existing;
    if (_opener != null) return _db = _opener();
    final data = await rootBundle.load(assetPath);
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'tr_en.db'));
    // Re-copy when the bundled file changes (size check is enough here).
    if (!file.existsSync() || file.lengthSync() != data.lengthInBytes) {
      await file.create(recursive: true);
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    return _db = sqlite3.open(file.path, mode: OpenMode.readOnly);
  }

  /// Looks up [lemma]; verbs also match with/without the `-mek/-mak` ending
  /// (`git` finds `gitmek`). [pos] (Wiktionary names: noun, verb, adj...) is a
  /// preference, not a filter.
  Future<DictEntry?> lookup(String lemma, {String? pos}) async {
    final db = await _open();
    final n = trNormalize(lemma);
    if (n.isEmpty) return null;
    final keys = <String>[n];
    if (n.endsWith('mek') || n.endsWith('mak')) {
      keys.add(n.substring(0, n.length - 3));
    } else {
      keys.addAll(['${n}mek', '${n}mak']);
    }
    for (final k in keys) {
      final rows = db.select(
        'SELECT word, pos, glosses, ex_tr, ex_en FROM entries WHERE lemma = ?',
        [k],
      );
      if (rows.isEmpty) continue;
      // A bare stem like "git" should only match verbs via the -mek form.
      final usable = k == n
          ? rows.toList()
          : rows.where((r) => r['pos'] == 'verb').toList();
      if (usable.isEmpty) continue;
      final row = usable.firstWhere(
        (r) => r['pos'] == pos,
        orElse: () => usable.firstWhere(
          (r) => r['pos'] != 'name',
          orElse: () => usable.first,
        ),
      );
      return DictEntry(
        word: row['word'] as String,
        pos: row['pos'] as String,
        glosses: (jsonDecode(row['glosses'] as String) as List).cast<String>(),
        exampleTr: row['ex_tr'] as String?,
        exampleEn: row['ex_en'] as String?,
      );
    }
    return null;
  }

  void close() => _db?.close();
}
