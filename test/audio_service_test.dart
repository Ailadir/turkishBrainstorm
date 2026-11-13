import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turkish_vocab/services/piper_engine.dart';
import 'package:turkish_vocab/services/settings_service.dart';
import 'package:turkish_vocab/services/tts_service.dart';

class _Cloud implements CloudVoice {
  @override
  bool configured;
  List<int>? reply;
  int calls = 0;
  _Cloud({this.configured = true, this.reply = const [1, 2, 3]});
  @override
  String get voiceId => 'voiceX';
  @override
  String get model => 'm1';
  @override
  Future<List<int>?> synth(String text) async {
    calls++;
    return reply;
  }
}

class _Offline implements OfflineVoice {
  bool installed;
  int calls = 0;
  _Offline({this.installed = true});
  @override
  String get voice => 'dfki';
  @override
  Future<bool> isInstalled() async => installed;
  @override
  Future<bool> synth(String text, String outPath) async {
    calls++;
    await File(outPath).writeAsBytes([9, 9]);
    return true;
  }
}

void main() {
  late Directory dir;
  late SettingsService settings;
  late List<String> played;
  late List<String> problems;
  var phoneHasTurkish = false;
  var packWord = false;

  TtsService make({CloudVoice? cloud, OfflineVoice? offline}) => TtsService(
    settings,
    cloud: cloud,
    offline: offline,
    isPackWord: (_) async => packWord,
    playFile: (path) async => played.add(path),
    phoneSpeak: (_) async => phoneHasTurkish,
    cacheDir: () async => dir,
    onProblem: problems.add,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(await SharedPreferences.getInstance());
    dir = await Directory.systemTemp.createTemp('tts_test');
    played = [];
    problems = [];
    phoneHasTurkish = false;
    packWord = false;
  });
  tearDown(() => dir.delete(recursive: true));

  test('ElevenLabs first, then the file is served from cache', () async {
    final cloud = _Cloud();
    final tts = make(cloud: cloud, offline: _Offline());
    expect((await tts.speak('ev')).via, 'elevenlabs');
    expect((await tts.speak('ev')).via, 'cache');
    expect(cloud.calls, 1);
    expect(played.length, 2);
  });

  test('ElevenLabs failure (429/quota) falls through to Piper', () async {
    final cloud = _Cloud(reply: null);
    final off = _Offline();
    final tts = make(cloud: cloud, offline: off);
    expect((await tts.speak('ev')).via, 'piper');
    expect(off.calls, 1);
    expect((await tts.speak('ev')).via, 'cache');
  });

  test('no keys: Piper plays offline', () async {
    final tts = make(cloud: _Cloud(configured: false), offline: _Offline());
    expect((await tts.speak('ev')).via, 'piper');
  });

  test('pack words go to Piper by default, ElevenLabs if enabled', () async {
    packWord = true;
    final cloud = _Cloud();
    final off = _Offline();
    var tts = make(cloud: cloud, offline: off);
    expect((await tts.speak('su')).via, 'piper');
    expect(cloud.calls, 0);

    await settings.setElevenLabsForPackWords(true);
    tts = make(cloud: cloud, offline: off);
    expect((await tts.speak('göz')).via, 'elevenlabs');
  });

  test(
    'phone TTS only when it has Turkish; otherwise a clear message once',
    () async {
      final tts = make(offline: _Offline(installed: false));
      final r = await tts.speak('ev');
      expect(r.ok, isFalse);
      expect(r.problem, contains('offline voice'));
      await tts.speak('ev');
      expect(problems.length, 1, reason: 'shown once per session');

      phoneHasTurkish = true;
      expect((await tts.speak('ev')).via, 'phone');
    },
  );

  test('cache file names are stable and keep the old ElevenLabs scheme', () {
    final tts = make(cloud: _Cloud(), offline: _Offline());
    expect(tts.cloudFileName('ev'), tts.cloudFileName('ev'));
    expect(tts.cloudFileName('ev'), startsWith('voiceX_'));
    expect(tts.cloudFileName('ev'), endsWith('.mp3'));
    expect(tts.cloudFileName('ev'), isNot(tts.cloudFileName('su')));
    expect(tts.offlineFileName('ev'), startsWith('piper_dfki_'));
  });

  test('prefetch caches without playing', () async {
    final tts = make(offline: _Offline());
    expect(await tts.prefetch('ev'), isTrue);
    expect(played, isEmpty);
    expect(await tts.isCached('ev'), isTrue);
  });

  test('piperInput: short words get help, phrases are left alone', () {
    expect(piperInput('ve', 0.8).text, 'veee!');
    expect(piperInput('ev', 0.8).text, 'eeev!');
    expect(piperInput('altı', 0.8).text, 'altı!');
    expect(piperInput('altı', 0.8).speed, closeTo(0.7, 1e-9));
    expect(piperInput('merhaba', 0.8).text, 'merhaba.');
    expect(piperInput('merhaba', 0.8).speed, 0.8);
    expect(piperInput('iyi günler', 0.8).text, 'iyi günler.');
    expect(piperInput('Nasılsın?', 0.8).text, 'Nasılsın?');
  });
}
