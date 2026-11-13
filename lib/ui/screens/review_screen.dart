import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/word_repository.dart';
import '../../domain/practice_mode.dart';
import '../../providers/providers.dart';
import '../widgets/listening_card.dart';
import '../widgets/recognition_card.dart';
import '../widgets/writing_card.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<ReviewCard>? _queue;
  int _index = 0;
  int _reviewed = 0;
  bool _loading = true;
  final Set<int> _requeued = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final queue = await ref.read(wordRepositoryProvider).dueQueue();
    if (mounted) {
      setState(() {
        _queue = queue;
        _loading = false;
      });
    }
  }

  Future<void> _grade(ReviewGrade grade) async {
    final card = _queue![_index];
    await ref.read(wordRepositoryProvider).applyReview(card, grade);
    // A missed card comes back once more at the end of this session.
    if (grade == ReviewGrade.again && !_requeued.contains(card.word.id)) {
      _requeued.add(card.word.id);
      _queue!.add(card);
    }
    setState(() {
      _reviewed++;
      _index++;
    });
    if (_index >= _queue!.length) {
      ref.invalidate(dueQueueProvider);
      ref.invalidate(statsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final queue = _queue!;

    if (_index >= queue.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Done! Reviewed $_reviewed cards.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      );
    }

    final card = queue[_index];
    final tts = ref.read(ttsServiceProvider);
    final repo = ref.read(wordRepositoryProvider);
    final progress = (_index + 1) / queue.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${queue.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildCard(card, tts, repo),
        ),
      ),
    );
  }

  Widget _buildCard(ReviewCard card, dynamic tts, WordRepository repo) {
    return switch (card.mode) {
      PracticeMode.recognitionTrEn || PracticeMode.recognitionEnTr =>
        RecognitionCard(card: card, tts: tts, onGrade: _grade),
      PracticeMode.writing => WritingCard(
        card: card,
        tts: tts,
        onGrade: _grade,
      ),
      PracticeMode.listening => ListeningCard(
        card: card,
        tts: tts,
        fetchDistractors: (id, n) => repo.randomEnglishDistractors(id, n),
        onGrade: _grade,
      ),
    };
  }
}
