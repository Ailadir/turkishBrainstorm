import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turkish_vocab/services/update_service.dart';

void main() {
  final apkBytes = utf8.encode('pretend this is an apk');
  final apkSha = sha256.convert(apkBytes).toString();
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('upd'));
  tearDown(() => dir.delete(recursive: true));

  UpdateService service({
    required int build,
    int latestBuild = 8,
    String sha = '',
    bool withVersionJson = true,
  }) {
    final client = MockClient((req) async {
      final url = req.url.toString();
      if (url.endsWith('/releases/latest') || url.contains('/releases/tags/')) {
        return http.Response(
          jsonEncode({
            'assets': [
              if (withVersionJson)
                {
                  'name': 'version.json',
                  'browser_download_url': 'https://dl.test/version.json',
                },
              {
                'name': 'app-arm64-v8a-release.apk',
                'browser_download_url': 'https://dl.test/app.apk',
              },
            ],
          }),
          200,
        );
      }
      if (url.endsWith('version.json')) {
        return http.Response(
          jsonEncode({
            'version': '1.3.0',
            'build': latestBuild,
            'apk': 'app-arm64-v8a-release.apk',
            'sha256': sha.isEmpty ? apkSha : sha,
            'notes': '- Brainstorm skips words\n- New A2 pack',
            'published': '2026-11-20',
          }),
          200,
        );
      }
      if (url.endsWith('app.apk')) return http.Response.bytes(apkBytes, 200);
      return http.Response('nope', 404);
    });
    return UpdateService(
      repo: 'me/app',
      client: client,
      currentBuild: () async => build,
      cacheDir: () async => dir,
    );
  }

  test('newer build gives UpdateInfo; same or older gives null', () async {
    final info = await service(build: 7).checkLatest();
    expect(info!.version, '1.3.0');
    expect(info.build, 8);
    expect(info.notes, contains('New A2 pack'));
    expect(await service(build: 8).checkLatest(), isNull);
    expect(await service(build: 9).checkLatest(), isNull);
  });

  test('a release without version.json is ignored', () async {
    expect(
      await service(build: 1, withVersionJson: false).checkLatest(),
      isNull,
    );
  });

  test('download verifies the checksum', () async {
    final s = service(build: 7);
    final info = (await s.checkLatest())!;
    final path = await s.download(info);
    expect(File(path).readAsBytesSync(), apkBytes);
  });

  test('checksum mismatch deletes the file and throws', () async {
    final s = service(build: 7, sha: 'f' * 64);
    final info = (await s.checkLatest())!;
    await expectLater(s.download(info), throwsA(isA<UpdateException>()));
    expect(File('${dir.path}/update.apk').existsSync(), isFalse);
  });

  test("what's-new notes come from the tagged release", () async {
    expect(
      await service(build: 8).notesForTag('v1.3.0+8'),
      contains('Brainstorm'),
    );
  });

  group('decisions', () {
    const info = UpdateInfo(
      version: '1.3.0',
      build: 8,
      apkUrl: '',
      sha256: '',
      notes: '',
    );

    test('alert shown once, hidden after dismissal, shown again for newer', () {
      expect(shouldShowUpdateAlert(info, 7, 0), isTrue);
      expect(shouldShowUpdateAlert(info, 7, 8), isFalse);
      const newer = UpdateInfo(
        version: '1.4.0',
        build: 9,
        apkUrl: '',
        sha256: '',
        notes: '',
      );
      expect(shouldShowUpdateAlert(newer, 7, 8), isTrue);
      expect(shouldShowUpdateAlert(info, 8, 0), isFalse, reason: 'not newer');
      expect(shouldShowUpdateAlert(null, 7, 0), isFalse);
    });

    test("what's new only after an update, never on a fresh install", () {
      expect(shouldShowWhatsNew(8, 7), isTrue);
      expect(shouldShowWhatsNew(8, 8), isFalse);
      expect(shouldShowWhatsNew(8, 0), isFalse);
    });
  });

  test('appBuild strips the per-ABI offset', () {
    expect(appBuild('2002'), 2);
    expect(appBuild('1003'), 3);
    expect(appBuild('4010'), 10);
    expect(appBuild('7'), 7);
  });
}
