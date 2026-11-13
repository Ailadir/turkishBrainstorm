import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/services/llm_service.dart';

class _Fake implements LlmProvider {
  @override
  final String name;
  @override
  final bool isConfigured;
  final LlmReply reply;
  int calls = 0;
  _Fake(this.name, this.reply, {this.isConfigured = true});

  @override
  Future<LlmReply> complete(String system, String prompt) async {
    calls++;
    return reply;
  }
}

const _limited = LlmReply(error: 'HTTP 429', retryElsewhere: true);
LlmReply _ok(String who) =>
    LlmReply(text: '{"translation": "go"}', provider: who);

void main() {
  test('falls through to the next provider on a rate limit', () async {
    final a = _Fake('A', _limited);
    final b = _Fake('B', _ok('B'));
    final c = _Fake('C', _ok('C'));
    final svc = LlmService([a, b, c]);
    expect(await svc.translate('gitmek'), 'go');
    expect(a.calls, 1);
    expect(b.calls, 1);
    expect(c.calls, 0);
  });

  test('a limited provider is skipped until the cooldown ends', () async {
    var t = DateTime(2026);
    final a = _Fake('A', _limited);
    final b = _Fake('B', _ok('B'));
    final svc = LlmService([a, b], now: () => t);
    await svc.translate('x');
    await svc.translate('y');
    expect(a.calls, 1, reason: 'skipped while cooling down');
    t = t.add(const Duration(minutes: 3));
    await svc.translate('z');
    expect(a.calls, 2);
  });

  test(
    'unconfigured providers are ignored; all failing returns null',
    () async {
      final a = _Fake('A', _ok('A'), isConfigured: false);
      final b = _Fake('B', _limited);
      final svc = LlmService([a, b]);
      expect(await svc.translate('x'), isNull);
      expect(a.calls, 0);
    },
  );

  test('a bad key on one provider does not stop the others', () async {
    final a = _Fake('A', const LlmReply(error: 'HTTP 401'));
    final b = _Fake('B', _ok('B'));
    expect(await LlmService([a, b]).translate('x'), 'go');
  });

  test('extractJsonObject handles fenced replies', () {
    expect(extractJsonObject('```json\n{"translation": "house"}\n```'), {
      'translation': 'house',
    });
    expect(extractJsonObject('no json here'), isNull);
  });
}
