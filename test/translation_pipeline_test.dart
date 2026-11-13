import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/morpheme_ref.dart';
import 'package:turkish_vocab/services/llm_service.dart';
import 'package:turkish_vocab/services/morphology_service.dart';
import 'package:turkish_vocab/services/translation_pipeline.dart';

class _Ai implements LlmProvider {
  @override
  final String name;
  final List<LlmReply> replies;
  int calls = 0;
  _Ai(this.name, this.replies);
  @override
  bool get isConfigured => true;
  @override
  Future<LlmReply> complete(String system, String prompt) async =>
      replies[calls++ % replies.length];
}

LlmReply _json(String en, String who) => LlmReply(
  text: '{"translation": "$en", "alternatives": ["x"]}',
  provider: who,
);
const _limited = LlmReply(error: '429', retryElsewhere: true);

void main() {
  late Map<String, String> cache;
  late int aiCalls;
  late String? myMemory;

  TranslationPipeline make(List<LlmProvider> providers) {
    cache = {};
    aiCalls = 0;
    myMemory = null;
    return TranslationPipeline(
      TranslationDeps(
        analyze: (w) async => switch (w) {
          'ev' => const MorphologyResult(lemma: 'ev'),
          'evde' => const MorphologyResult(
            lemma: 'ev',
            morphemes: [MorphemeRef('de', 'Loc')],
          ),
          'evlerimizde' => const MorphologyResult(
            lemma: 'ev',
            morphemes: [
              MorphemeRef('ler', 'A3pl'),
              MorphemeRef('imiz', 'P1pl'),
              MorphemeRef('de', 'Loc'),
            ],
          ),
          _ => MorphologyResult.fallback(w),
        },
        dictionary: (l) async =>
            l == 'ev' ? (gloss: 'house', glosses: ['house', 'home']) : null,
        savedEnglish: (n) async => n == 'su' ? 'water' : null,
        cacheGet: (k) async => cache[k],
        cachePut: (k, p, _) async => cache[k] = p,
        myMemory: (_) async => myMemory,
        countAiCall: () => aiCalls++,
      ),
      LlmService(providers),
    );
  }

  test('a dictionary word costs 0 AI calls', () async {
    final ai = _Ai('A', [_json('nope', 'A')]);
    final p = make([ai]);
    final r = (await p.translate('ev'))!;
    expect(r.english, 'house');
    expect(r.source, TranslationSource.dictionary);
    expect(ai.calls, 0);
    expect((await p.translate('evde'))!.english, 'house + in/at');
    expect(ai.calls, 0);
  });

  test('a word already in your list uses it', () async {
    final p = make([
      _Ai('A', [_json('nope', 'A')]),
    ]);
    expect((await p.translate('su'))!.source, TranslationSource.saved);
  });

  test('a phrase calls AI once, then hits the cache', () async {
    final ai = _Ai('A', [_json('I am going home', 'A')]);
    final p = make([ai]);
    final r1 = (await p.translate('eve gidiyorum'))!;
    expect(r1.english, 'I am going home');
    expect(r1.sourceLabel, 'AI: A');
    final r2 = (await p.translate('eve gidiyorum'))!;
    expect(r2.source, TranslationSource.cache);
    expect(ai.calls, 1);
    expect(aiCalls, 1);
  });

  test('a long word (2+ suffixes) goes to AI with the breakdown', () async {
    final ai = _Ai('A', [_json('in our houses', 'A')]);
    final p = make([ai]);
    expect((await p.translate('evlerimizde'))!.english, 'in our houses');
    expect(ai.calls, 1);
  });

  test('429 moves to the next provider', () async {
    final a = _Ai('A', [_limited]);
    final b = _Ai('B', [_json('ok', 'B')]);
    final p = make([a, b]);
    final r = (await p.translate('eve gidiyorum'))!;
    expect(r.provider, 'B');
  });

  test('all AI fail -> MyMemory -> literal', () async {
    final p = make([
      _Ai('A', [_limited]),
    ]);
    myMemory = 'from memory';
    var r = (await p.translate('eve gidiyorum'))!;
    expect(r.source, TranslationSource.myMemory);
    expect(r.warning, isNotNull);

    final p2 = make([
      _Ai('A', [_limited]),
    ]);
    r = (await p2.translate('evlerimizde'))!;
    expect(r.source, TranslationSource.literal);
    expect(r.english, 'house + plural + our + in/at');
  });

  test('bad JSON falls through', () async {
    final p = make([
      _Ai('A', [const LlmReply(text: 'sorry, cannot', provider: 'A')]),
    ]);
    myMemory = 'mm';
    expect(
      (await p.translate('eve gidiyorum'))!.source,
      TranslationSource.myMemory,
    );
  });

  test('forceAi skips cache and local shortcuts', () async {
    final ai = _Ai('A', [_json('home', 'A')]);
    final p = make([ai]);
    await p.translate('ev');
    final r = (await p.translate('ev', forceAi: true))!;
    expect(r.source, TranslationSource.ai);
    expect(ai.calls, 1);
  });
}
