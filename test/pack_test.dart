import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/data/pack_repository.dart';
import 'package:turkish_vocab/data/word_repository.dart';
import 'package:turkish_vocab/domain/pack.dart';
import 'package:turkish_vocab/services/pack_service.dart';
import 'package:turkish_vocab/services/settings_service.dart';

String _words(String id, int version, List<List<String>> words) => jsonEncode({
  'format': 1,
  'id': id,
  'version': version,
  'kind': 'words',
  'title': id,
  'level': 'A1',
  'words': [
    for (var i = 0; i < words.length; i++)
      {'tr': words[i][0], 'en': words[i][1], 'rank': i + 1},
  ],
});

String _grammar() => jsonEncode({
  'format': 1,
  'id': 'g1',
  'version': 1,
  'kind': 'grammar',
  'title': 'g1',
  'level': 'A1',
  'suffixes': [
    {
      'id': 'Loc',
      'examples': [
        {'tr': 'evde', 'en': 'at home'},
      ],
    },
  ],
});

void main() {
  late AppDatabase db;
  late WordRepository words;
  late PackRepository packs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    words = WordRepository(db);
    packs = PackRepository(db);
  });

  group('parsePack', () {
    test('valid words and grammar packs', () {
      expect(
        parsePack(
          _words('a', 1, [
            ['ev', 'house'],
          ]),
        ).words.single.tr,
        'ev',
      );
      expect(parsePack(_grammar()).suffixes.single.id, 'Loc');
    });

    test('rejects bad input', () {
      expect(() => parsePack('nope'), throwsA(isA<PackFormatException>()));
      expect(
        () => parsePack(jsonEncode({'format': 2})),
        throwsA(isA<PackFormatException>()),
      );
      expect(
        () => parsePack(
          _words('a', 1, [
            ['ev', ''],
          ]),
        ),
        throwsA(isA<PackFormatException>()),
      );
      // duplicates are detected after Turkish normalisation
      expect(
        () => parsePack(
          _words('a', 1, [
            ['Isı', 'heat'],
            ['ısı', 'heat'],
          ]),
        ),
        throwsA(isA<PackFormatException>()),
      );
    });
  });

  test(
    'import keeps SRS of an existing own word and respects englishEdited',
    () async {
      final own = await words.addWord(
        turkish: 'ev',
        english: 'my own meaning',
        englishEdited: true,
      );
      await words.finishBrainstorm(own.id, 0);
      final other = await words.addWord(turkish: 'su', english: 'ai guess');

      final r = await packs.import(
        parsePack(
          _words('p1', 1, [
            ['ev', 'house'],
            ['su', 'water'],
            ['at', 'horse'],
          ]),
        ),
      );
      expect(r.added, 1);
      expect(r.updated, 2);

      final ev = (await words.wordById(own.id))!;
      expect(ev.english, 'my own meaning');
      expect(ev.status, 'review'); // progress untouched
      expect((await words.wordById(other.id))!.english, 'water');
      expect(await words.newCount(), 2); // su + at
    },
  );

  test(
    'own words are served before pack words, even if a pack has them',
    () async {
      await packs.import(
        parsePack(
          _words('p1', 1, [
            ['ev', 'house'],
            ['at', 'horse'],
          ]),
        ),
      );
      await words.addWord(turkish: 'araba', english: 'car');
      final picked = await words.pickNewWords(3);
      expect(picked.first.turkish, 'araba');
    },
  );

  test('remove deletes only never-studied pack-only words', () async {
    await packs.import(
      parsePack(
        _words('p1', 1, [
          ['ev', 'house'],
          ['at', 'horse'],
        ]),
      ),
    );
    final ev = (await words.searchWords('ev')).single;
    await words.finishBrainstorm(ev.id, 0);
    final own = await words.addWord(turkish: 'su', english: 'water');
    await packs.import(
      parsePack(
        _words('p2', 1, [
          ['su', 'water'],
          ['göz', 'eye'],
        ]),
      ),
    );

    final deleted = await packs.remove('p1');
    expect(deleted, 1); // "at" only
    final left = (await db.select(db.words).get())
        .map((w) => w.turkish)
        .toSet();
    expect(left, {'ev', 'su', 'göz'});
    expect(await packs.installedVersion('p1'), isNull);
    expect((await words.wordById(own.id)), isNotNull);
  });

  test('update adds new words and drops links of removed ones', () async {
    await packs.import(
      parsePack(
        _words('p1', 1, [
          ['ev', 'house'],
          ['at', 'horse'],
        ]),
      ),
    );
    final r = await packs.import(
      parsePack(
        _words('p1', 2, [
          ['ev', 'house'],
          ['göz', 'eye'],
        ]),
      ),
    );
    expect(r.added, 1);
    expect(await packs.installedVersion('p1'), 2);
    final links = await db.select(db.wordPacks).get();
    expect(links.length, 2);
    // "at" keeps its row (and progress); only the link is gone.
    expect((await words.searchWords('at')).length, 1);
  });

  test('grammar import replaces examples and creates morphemes', () async {
    await packs.import(parsePack(_grammar()));
    await packs.import(parsePack(_grammar()));
    expect((await db.select(db.morphemeExamples).get()).length, 1);
    expect((await db.select(db.morphemes).get()).single.id, 'Loc');
  });

  group('PackService', () {
    late SettingsService settings;
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'pack_index_url': 'https://example.test/packs/index.json',
      });
      settings = SettingsService(await SharedPreferences.getInstance());
    });

    String index(String sha) => jsonEncode({
      'format': 1,
      'packs': [
        {
          'id': 'p1',
          'title': 'P1',
          'kind': 'words',
          'level': 'A1',
          'version': 1,
          'count': 1,
          'file': 'p1.json',
          'sha256': sha,
          'size': 10,
        },
      ],
    });

    test('rejects a checksum mismatch, accepts a match', () async {
      final body = _words('p1', 1, [
        ['ev', 'house'],
      ]);
      final good = sha256.convert(utf8.encode(body)).toString();
      http.Client client(String sha) => MockClient((req) async {
        return req.url.path.endsWith('index.json')
            ? http.Response(index(sha), 200)
            : http.Response.bytes(utf8.encode(body), 200);
      });

      var svc = PackService(packs, settings, client: client('0' * 64));
      final entry = (await svc.fetchIndex()).single;
      expect(() => svc.download(entry), throwsA(isA<PackFormatException>()));
      expect(await words.newCount(), 0);

      svc = PackService(packs, settings, client: client(good));
      await svc.download((await svc.fetchIndex()).single);
      expect(await words.newCount(), 1);
    });

    test('installStarter loads the bundled packs', () async {
      final svc = PackService(
        packs,
        settings,
        loadAsset: (path) async => path.contains('grammar')
            ? _grammar()
            : _words(path.contains('core') ? 'tr-a1-core' : 'ess', 1, [
                [path, 'x'],
              ]),
      );
      expect(await svc.starterInstalled(), isFalse);
      await svc.installStarter();
      expect(await svc.starterInstalled(), isTrue);
    });
  });
}
