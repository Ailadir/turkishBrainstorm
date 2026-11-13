// Builds word packs + grammar packs + index.json.
//   dart run tool/build_packs.dart ~/turkish-data/lemmas.tsv ~/turkish-data/forms.tsv \
//       assets/dict/tr_en.db packs/ [reviewDir]
// Inputs come from tool/LemmaCounter.java and tool/GrammarMiner.java.
// Manual fixes live in tool/overrides.tsv (lemma<TAB>en, or "-" to drop).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:turkish_vocab/domain/suffix_glosses.dart';
import 'package:turkish_vocab/domain/turkish_text.dart';

const attribution =
    'Wiktionary via kaikki.org (CC BY-SA 4.0); word frequencies from '
    'FrequencyWords / OpenSubtitles';

// (level, first rank, last rank)
const bands = [
  ('A1', 1, 600),
  ('A2', 601, 1500),
  ('B1', 1501, 3000),
  ('B2', 3001, 5000),
];

const posMap = {
  'Noun': ['noun'],
  'Verb': ['verb'],
  'Adj': ['adj'],
  'Adv': ['adv'],
  'Pron': ['pron'],
  'Det': ['det'],
  'Conj': ['conj'],
  'Postp': ['postp', 'prep'],
};

String shortGloss(List<String> glosses) {
  bool poor(String g) =>
      g.length > 40 ||
      RegExp(r'^(Used |The name of|Alternative|Equal in|The first)').hasMatch(g);
  final g = glosses.firstWhere((x) => !poor(x), orElse: () => glosses.first);
  var s = g.replaceFirst(RegExp(r'^\([^)]*\)\s*'), '').trim();
  if (s.isEmpty) s = g;
  final cut = s.indexOf(RegExp(r'[,;]'));
  if (cut > 0) s = s.substring(0, cut);
  s = s.trim().replaceFirst(RegExp(r'\.$'), '');
  if (s.startsWith('To ')) s = 't${s.substring(1)}';
  return s.length <= 40 ? s : '${s.substring(0, 39).trimRight()}…';
}

Map<String, dynamic> pack({
  required String id,
  required String kind,
  required String title,
  required String level,
  required String key,
  required List<Map<String, dynamic>> items,
}) => {
  'format': 1,
  'id': id,
  'version': 1,
  'kind': kind,
  'title': title,
  'level': level,
  'license': 'CC BY-SA 4.0',
  'attribution': attribution,
  key: items,
};

typedef Hit = ({String word, List<String> glosses, String? exTr, String? exEn});

void main(List<String> args) {
  if (args.length < 4) {
    stderr.writeln(
      'usage: build_packs lemmas.tsv forms.tsv dict.db outDir [reviewDir]',
    );
    exit(64);
  }
  final outDir = Directory(args[3])..createSync(recursive: true);
  final reviewDir = Directory(
    args.length > 4 ? args[4] : '${args[3]}/../review',
  )..createSync(recursive: true);
  final db = sqlite3.open(args[2], mode: OpenMode.readOnly);

  final overrides = <String, String>{};
  for (final l in File('tool/overrides.tsv').readAsLinesSync()) {
    final p = l.split('\t');
    if (p.length == 2 && !l.startsWith('#')) {
      overrides[trNormalize(p[0])] = p[1];
    }
  }

  Hit? lookup(String lemma, String pos) {
    final wanted = posMap[pos] ?? const <String>[];
    final n = trNormalize(lemma);
    final keys = <String>{n};
    if (pos == 'Verb') {
      if (n.endsWith('mek') || n.endsWith('mak')) {
        keys.add(n.substring(0, n.length - 3));
      } else {
        keys.addAll(['${n}mek', '${n}mak']);
      }
    }
    for (final k in keys) {
      final rows = db.select(
        'SELECT word, pos, glosses, ex_tr, ex_en FROM entries WHERE lemma = ?',
        [k],
      );
      for (final r in rows) {
        if (wanted.contains(r['pos'])) {
          return (
            word: r['word'] as String,
            glosses: (jsonDecode(r['glosses'] as String) as List)
                .cast<String>(),
            exTr: r['ex_tr'] as String?,
            exEn: r['ex_en'] as String?,
          );
        }
      }
    }
    return null;
  }

  // Hand-made essentials first, so the core packs can skip them.
  final essentials = <Map<String, dynamic>>[];
  final essentialKeys = <String>{};
  for (final l in File('tool/essentials.tsv').readAsLinesSync()) {
    final p = l.split('\t');
    if (p.length != 3) continue;
    if (!essentialKeys.add(trNormalize(p[0]))) continue;
    essentials.add({
      'tr': p[0],
      'en': p[1],
      'pos': p[2],
      'rank': essentials.length + 1,
    });
  }

  // Ranked lemmas that have a dictionary gloss.
  final ranked = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final l in File(args[0]).readAsLinesSync()) {
    final p = l.split('\t');
    if (p.length != 3) continue;
    final lemma = p[0], pos = p[1];
    // Capitalised lemmas are letter names / proper nouns; question particles
    // are not vocabulary.
    if (lemma != lemma.toLowerCase() && lemma != trLower(lemma)) continue;
    if (const {'mi', 'mı', 'mu', 'mü'}.contains(lemma)) continue;
    if (!posMap.containsKey(pos)) continue;
    final key = trNormalize(lemma);
    if (key.length < 2 && key != 'o') continue;
    if (!seen.add(key)) continue;
    final override = overrides[key];
    if (override == '-') continue;
    final hit = lookup(lemma, pos);
    if (hit == null && override == null) continue;
    final en = override ?? shortGloss(hit!.glosses);
    ranked.add({
      'tr': lemma,
      'en': en,
      'pos': pos,
      'rank': ranked.length + 1,
      if (hit?.exTr != null) 'example': hit!.exTr,
      if (hit?.exEn != null) 'example_en': hit!.exEn,
    });
  }

  final index = <Map<String, dynamic>>[];
  void write(Map<String, dynamic> pk, List<Map<String, dynamic>> rows) {
    final id = pk['id'] as String;
    final file = File('${outDir.path}/$id.json');
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(pk)}\n',
    );
    final bytes = file.readAsBytesSync();
    index.add({
      'id': id,
      'title': pk['title'],
      'kind': pk['kind'],
      'level': pk['level'],
      'version': pk['version'],
      'count': rows.length,
      'file': '$id.json',
      'sha256': sha256.convert(bytes).toString(),
      'size': bytes.length,
    });
    final csv = StringBuffer('tr,en,pos,rank\n');
    for (final r in rows) {
      final en = (r['en'] as String).replaceAll('"', "'");
      csv.writeln('${r['tr']},"$en",${r['pos'] ?? ''},${r['rank'] ?? ''}');
    }
    File('${reviewDir.path}/$id.csv').writeAsStringSync(csv.toString());
    stdout.writeln(
      '$id: ${rows.length} entries, ${(bytes.length / 1024).toStringAsFixed(0)} KB',
    );
  }

  write(
    pack(
      id: 'tr-a1-essentials',
      kind: 'words',
      title: 'A1 essentials',
      level: 'A1',
      key: 'words',
      items: essentials,
    ),
    essentials,
  );

  final levelOfRank = <int, String>{};
  for (final (lvl, from, to) in bands) {
    final rows = <Map<String, dynamic>>[];
    for (final w in ranked) {
      final r = w['rank'] as int;
      if (r < from || r > to) continue;
      levelOfRank[r] = lvl;
      if (!essentialKeys.contains(trNormalize(w['tr'] as String))) {
        rows.add(w);
      }
    }
    write(
      pack(
        id: 'tr-${lvl.toLowerCase()}-core',
        kind: 'words',
        title: '$lvl core words',
        level: lvl,
        key: 'words',
        items: rows,
      ),
      rows,
    );
  }

  // ── grammar packs from attested forms ────────────────────────────────────
  final lemmaLevel = <String, String>{};
  for (final w in ranked) {
    final lvl = levelOfRank[w['rank'] as int];
    if (lvl != null) lemmaLevel[trNormalize(w['tr'] as String)] = lvl;
  }
  for (final w in essentials) {
    lemmaLevel.putIfAbsent(trNormalize(w['tr'] as String), () => 'A1');
  }
  final bySuffix = <String, List<({String word, String lemma, int count})>>{};
  for (final l in File(args[1]).readAsLinesSync()) {
    final p = l.split('\t');
    if (p.length != 4) continue;
    final id = p[0];
    if (id == 'A3sg' || !suffixGlosses.containsKey(id)) continue;
    bySuffix
        .putIfAbsent(id, () => [])
        .add((word: p[1], lemma: p[2], count: int.tryParse(p[3]) ?? 0));
  }
  for (final lvl in cefrLevels) {
    final rank = cefrLevels.indexOf(lvl);
    final suffixes = <Map<String, dynamic>>[];
    for (final e in suffixGlosses.entries.where((e) => e.value.level == lvl)) {
      final cands = (bySuffix[e.key] ?? const [])
          .where((c) => c.word != c.lemma && c.word.length <= 14)
          .toList();
      int bandOf(String lemma) {
        final b = lemmaLevel[trNormalize(lemma)];
        return b == null ? 9 : cefrLevels.indexOf(b);
      }

      // Prefer lemmas in the same-or-lower level, then frequency.
      cands.sort((a, b) {
        final ba = bandOf(a.lemma) <= rank ? 0 : 1;
        final bb = bandOf(b.lemma) <= rank ? 0 : 1;
        return ba != bb ? ba - bb : b.count - a.count;
      });
      final usedLemmas = <String>{};
      final examples = <Map<String, String>>[];
      for (final c in cands) {
        if (examples.length >= 10) break;
        // Only real, frequent lemmas: Zemberek's first analysis of a rare
        // form is often a weird lemma (buna -> bunamak).
        if (!lemmaLevel.containsKey(trNormalize(c.lemma))) continue;
        if (const {'mi', 'mı', 'mu', 'mü'}.contains(c.lemma)) continue;
        if (!usedLemmas.add(c.lemma)) continue;
        final hit =
            lookup(c.lemma, 'Noun') ??
            lookup(c.lemma, 'Verb') ??
            lookup(c.lemma, 'Adj');
        final gloss =
            overrides[trNormalize(c.lemma)] ??
            (hit == null ? null : shortGloss(hit.glosses));
        if (gloss == null || gloss == '-') continue;
        examples.add({'tr': c.word, 'en': '$gloss (+ ${e.value.label})'});
      }
      if (examples.length >= 4) {
        suffixes.add({'id': e.key, 'examples': examples});
      } else {
        stdout.writeln(
          '  ! ${e.key} ($lvl): only ${examples.length} examples, skipped',
        );
      }
    }
    write(
      pack(
        id: 'tr-grammar-${lvl.toLowerCase()}',
        kind: 'grammar',
        title: '$lvl suffixes',
        level: lvl,
        key: 'suffixes',
        items: suffixes,
      ),
      suffixes
          .map(
            (s) => {
              'tr': s['id'],
              'en': '${(s['examples'] as List).length} examples',
            },
          )
          .toList(),
    );
  }

  File('${outDir.path}/index.json').writeAsStringSync(
    '${const JsonEncoder.withIndent(' ').convert({'format': 1, 'packs': index})}\n',
  );
  db.close();
}
