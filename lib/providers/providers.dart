import 'package:flutter/material.dart' show SnackBar, Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../domain/turkish_text.dart';
import '../ui/messenger.dart';
import '../data/morpheme_repository.dart';
import '../data/pack_repository.dart';
import '../data/word_repository.dart';
import '../services/analysis_job.dart';
import '../services/dictionary_service.dart';
import '../services/llm_service.dart';
import '../services/morphology_service.dart';
import '../services/pack_service.dart';
import '../services/settings_service.dart';
import '../services/translation_service.dart';
import '../services/audio_prefetch_queue.dart';
import '../services/piper_engine.dart';
import '../services/translation_pipeline.dart';
import '../services/update_service.dart';
import '../services/tts_service.dart';

// ── Shared Preferences ────────────────────────────────────────────────────────
// Overridden in main() after SharedPreferences.getInstance() resolves.
final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(sharedPreferencesProvider));
});

// ── Database / Repo ───────────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.watch(databaseProvider));
});

final morphemeRepositoryProvider = Provider<MorphemeRepository>((ref) {
  return MorphemeRepository(ref.watch(databaseProvider));
});

/// Suffixes due for the drill (at the current grammar level) + new ones.
final suffixDueProvider = FutureProvider<({int due, int fresh})>((ref) async {
  final level = ref.watch(settingsServiceProvider).grammarLevel;
  final list = await ref.watch(morphemeRepositoryProvider).candidates(level);
  final now = DateTime.now();
  return (
    due: list.where((c) => c.isDue(now)).length,
    fresh: list.where((c) => c.isNew).length,
  );
});

final packRepositoryProvider = Provider<PackRepository>((ref) {
  return PackRepository(ref.watch(databaseProvider));
});

// ── Services ──────────────────────────────────────────────────────────────────
final morphologyServiceProvider = Provider<MorphologyService>((_) {
  return MorphologyService();
});

final piperEngineProvider = Provider<PiperEngine>((ref) {
  final e = PiperEngine();
  ref.onDispose(e.dispose);
  return e;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  final repo = ref.watch(wordRepositoryProvider);
  return TtsService(
    settings,
    cloud: ElevenLabsVoice(settings),
    offline: PiperVoice(ref.watch(piperEngineProvider), settings),
    isPackWord: (t) => repo.isPackWordText(trNormalize(t)),
    onProblem: (m) =>
        messengerKey.currentState?.showSnackBar(SnackBar(content: Text(m))),
  );
});

final audioPrefetchProvider = Provider<AudioPrefetchQueue>((ref) {
  return AudioPrefetchQueue(ref.watch(ttsServiceProvider));
});

final translationServiceProvider = Provider<TranslationService>((_) {
  return TranslationService();
});

// Gemini → Groq → OpenRouter; moves on when one hits its free limit.
final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmService.fromSettings(ref.watch(settingsServiceProvider));
});

final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  final d = DictionaryService();
  ref.onDispose(d.close);
  return d;
});

final packServiceProvider = Provider<PackService>((ref) {
  return PackService(
    ref.watch(packRepositoryProvider),
    ref.watch(settingsServiceProvider),
  );
});

final translationPipelineProvider = Provider<TranslationPipeline>((ref) {
  final repo = ref.watch(wordRepositoryProvider);
  final dict = ref.watch(dictionaryServiceProvider);
  final morph = ref.watch(morphologyServiceProvider);
  final settings = ref.watch(settingsServiceProvider);
  final mymemory = ref.watch(translationServiceProvider);
  return TranslationPipeline(
    TranslationDeps(
      analyze: morph.analyze,
      dictionary: (lemma) async {
        try {
          final e = await dict.lookup(lemma);
          return e == null ? null : (gloss: e.shortGloss, glosses: e.glosses);
        } catch (_) {
          return null;
        }
      },
      savedEnglish: repo.englishFor,
      cacheGet: repo.cacheGet,
      cachePut: repo.cachePut,
      myMemory: mymemory.translate,
      countAiCall: settings.countAiCall,
    ),
    ref.watch(llmServiceProvider),
  );
});

final updateServiceProvider = Provider<UpdateService>((_) => UpdateService());
final appInstallerProvider = Provider<AppInstaller>((_) => AppInstaller());

final analysisJobProvider = Provider<AnalysisJob>((ref) {
  return AnalysisJob(
    ref.watch(wordRepositoryProvider),
    ref.watch(morphologyServiceProvider),
  );
});

// ── Data providers ────────────────────────────────────────────────────────────
final statsProvider = FutureProvider<VocabStats>((ref) {
  return ref
      .watch(wordRepositoryProvider)
      .stats(usePackWords: ref.watch(settingsServiceProvider).usePackWords);
});

// Reactive — emits automatically when the words table changes.
final wordSearchProvider = StreamProvider.family<List<Word>, String>((
  ref,
  query,
) {
  return ref.watch(wordRepositoryProvider).watchWords(query);
});

/// Short English meaning of a root, from the bundled dictionary (null if none).
final rootGlossProvider = FutureProvider.family<String?, String>((
  ref,
  lemma,
) async {
  try {
    return (await ref.watch(dictionaryServiceProvider).lookup(lemma))
        ?.shortGloss;
  } catch (_) {
    return null;
  }
});
