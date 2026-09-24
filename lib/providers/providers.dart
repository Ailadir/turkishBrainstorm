import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/word_repository.dart';
import '../services/morphology_service.dart';
import '../services/tts_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.watch(databaseProvider));
});

final morphologyServiceProvider = Provider<MorphologyService>((_) {
  return MorphologyService();
});

final ttsServiceProvider = Provider<TtsService>((_) {
  return TtsService();
});

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
