import '../data/word_repository.dart';
import 'morphology_service.dart';

/// Fills lemma / pos / morphemes for words saved with `needsAnalysis = true`,
/// in batches so a big pack import never blocks the UI.
class AnalysisJob {
  final WordRepository repo;
  final MorphologyService morphology;
  final int batchSize;
  bool _running = false;

  AnalysisJob(this.repo, this.morphology, {this.batchSize = 20});

  /// Process every pending word. Safe to call repeatedly; concurrent calls
  /// are ignored while one run is active.
  Future<void> run() async {
    if (_running) return;
    _running = true;
    try {
      while (true) {
        final batch = await repo.wordsNeedingAnalysis(batchSize);
        if (batch.isEmpty) break;
        for (final word in batch) {
          if (word.kind == 'word') {
            final r = await morphology.analyze(word.turkish);
            await repo.applyAnalysis(
              word.id,
              lemma: r.lemma,
              pos: r.pos,
              morphemes: r.morphemes,
            );
          } else {
            // Phrases/sentences: store the lemmas only; per-word suffix
            // breakdowns would be confusing on a multi-word card.
            final parts = await morphology.analyzeSentence(word.turkish);
            final lemma = parts.isEmpty
                ? word.turkish
                : parts.map((p) => p.lemma).join(' ');
            await repo.applyAnalysis(
              word.id,
              lemma: lemma,
              morphemes: const [],
            );
          }
        }
        // Yield to the event loop between batches.
        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      _running = false;
    }
  }
}
