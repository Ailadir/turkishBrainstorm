import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../data/word_repository.dart';
import '../services/morphology_service.dart';
import '../services/settings_service.dart';
import '../services/translation_service.dart';
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

// ── Services ──────────────────────────────────────────────────────────────────
final morphologyServiceProvider = Provider<MorphologyService>((_) {
  return MorphologyService();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(ref.watch(settingsServiceProvider));
});

final translationServiceProvider = Provider<TranslationService>((_) {
  return TranslationService();
});

// ── Data providers ────────────────────────────────────────────────────────────
final dueQueueProvider = FutureProvider<List<ReviewCard>>((ref) {
  return ref.watch(wordRepositoryProvider).dueQueue();
});

final statsProvider = FutureProvider<VocabStats>((ref) {
  return ref.watch(wordRepositoryProvider).stats();
});

final wordSearchProvider =
    FutureProvider.family<List<Word>, String>((ref, query) {
  return ref.watch(wordRepositoryProvider).searchWords(query);
});
