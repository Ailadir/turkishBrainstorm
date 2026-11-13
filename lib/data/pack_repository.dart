import 'package:drift/drift.dart';

import '../domain/pack.dart';
import '../domain/turkish_text.dart';
import 'database.dart';

class InstalledPack {
  final PackRow pack;
  final int wordCount;
  final int learned;
  const InstalledPack(this.pack, this.wordCount, this.learned);
}

/// Installing, updating and removing packs. Pack words are plain `Words` rows
/// with `source = 'pack:<id>'` and a `WordPacks` link carrying the rank.
class PackRepository {
  final AppDatabase db;
  PackRepository(this.db);

  Future<List<InstalledPack>> installed() async {
    final rows =
        await (db.select(db.packs)..orderBy([
              (p) => OrderingTerm.asc(p.level),
              (p) => OrderingTerm.asc(p.id),
            ]))
            .get();
    final result = <InstalledPack>[];
    for (final p in rows) {
      var total = 0, learned = 0;
      if (p.kind == 'words') {
        final q = db.select(db.wordPacks).join([
          innerJoin(db.words, db.words.id.equalsExp(db.wordPacks.wordId)),
        ])..where(db.wordPacks.packId.equals(p.id));
        final linked = await q.get();
        total = linked.length;
        learned = linked
            .where((r) => r.readTable(db.words).status != 'new')
            .length;
      } else {
        total =
            await (db.selectOnly(db.morphemeExamples)
                  ..addColumns([db.morphemeExamples.id.count()])
                  ..where(db.morphemeExamples.packId.equals(p.id)))
                .map((r) => r.read(db.morphemeExamples.id.count()) ?? 0)
                .getSingle();
      }
      result.add(InstalledPack(p, total, learned));
    }
    return result;
  }

  Future<int?> installedVersion(String id) async => (await (db.select(
    db.packs,
  )..where((p) => p.id.equals(id))).getSingleOrNull())?.version;

  /// Imports (or updates) one pack in a single transaction.
  Future<({int added, int updated})> import(Pack pack) async {
    return db.transaction(() async {
      var added = 0, updated = 0;
      await db
          .into(db.packs)
          .insertOnConflictUpdate(
            PacksCompanion.insert(
              id: pack.id,
              title: pack.title,
              kind: pack.kind,
              version: pack.version,
              level: Value(pack.level),
            ),
          );

      if (pack.isGrammar) {
        await (db.delete(
          db.morphemeExamples,
        )..where((e) => e.packId.equals(pack.id))).go();
        for (final s in pack.suffixes) {
          await db
              .into(db.morphemes)
              .insert(
                MorphemesCompanion.insert(id: s.id),
                mode: InsertMode.insertOrIgnore,
              );
          for (final e in s.examples) {
            await db
                .into(db.morphemeExamples)
                .insert(
                  MorphemeExamplesCompanion.insert(
                    morphemeId: s.id,
                    turkish: e.tr,
                    english: e.en,
                    packId: pack.id,
                  ),
                );
          }
        }
        return (added: pack.suffixes.length, updated: 0);
      }

      final existing = {
        for (final w in await db.select(db.words).get()) w.normalized: w,
      };
      final keep = <int>{};
      for (final w in pack.words) {
        final key = trNormalize(w.tr);
        final have = existing[key];
        int wordId;
        if (have == null) {
          wordId = await db
              .into(db.words)
              .insert(
                WordsCompanion.insert(
                  turkish: w.tr,
                  normalized: key,
                  english: w.en,
                  kind: Value(inferKind(w.tr)),
                  pos: Value(w.pos),
                  note: Value(w.example),
                  noteEn: Value(w.exampleEn),
                  source: Value('pack:${pack.id}'),
                  level: Value(pack.level),
                ),
              );
          added++;
        } else {
          wordId = have.id;
          await (db.update(db.words)..where((x) => x.id.equals(have.id))).write(
            WordsCompanion(
              english: have.englishEdited ? const Value.absent() : Value(w.en),
              level: have.level == null
                  ? Value(pack.level)
                  : const Value.absent(),
              note: have.note == null && w.example != null
                  ? Value(w.example)
                  : const Value.absent(),
              noteEn: have.noteEn == null && w.exampleEn != null
                  ? Value(w.exampleEn)
                  : const Value.absent(),
            ),
          );
          updated++;
        }
        keep.add(wordId);
        await db
            .into(db.wordPacks)
            .insertOnConflictUpdate(
              WordPacksCompanion.insert(
                wordId: wordId,
                packId: pack.id,
                rank: w.rank,
              ),
            );
      }
      // Words that left the pack keep their progress; only the link goes.
      await (db.delete(
        db.wordPacks,
      )..where((l) => l.packId.equals(pack.id) & l.wordId.isNotIn(keep))).go();
      return (added: added, updated: updated);
    });
  }

  /// Removes a pack. Words never studied that belong only to it are deleted;
  /// everything else stays with just the link removed.
  Future<int> remove(String packId) async {
    return db.transaction(() async {
      final links = await (db.select(
        db.wordPacks,
      )..where((l) => l.packId.equals(packId))).get();
      final others = await (db.select(
        db.wordPacks,
      )..where((l) => l.packId.equals(packId).not())).get();
      final inOthers = others.map((l) => l.wordId).toSet();
      var deleted = 0;
      for (final l in links) {
        if (inOthers.contains(l.wordId)) continue;
        final w = await (db.select(
          db.words,
        )..where((x) => x.id.equals(l.wordId))).getSingleOrNull();
        if (w != null &&
            w.status == 'new' &&
            w.repetitions == 0 &&
            w.source?.startsWith('pack:') == true) {
          await (db.delete(db.words)..where((x) => x.id.equals(w.id))).go();
          deleted++;
        }
      }
      await (db.delete(db.packs)..where((p) => p.id.equals(packId))).go();
      return deleted;
    });
  }
}
