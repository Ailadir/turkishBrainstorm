import 'package:flutter/material.dart';

import '../../../domain/exercise.dart';
import '../../../services/tts_service.dart';

/// Flip card for phrases and sentences: read/hear the Turkish, reveal the
/// English, then say whether you knew it.
class RevealExercise extends StatefulWidget {
  final Exercise exercise;
  final VocabItem word;
  final TtsService tts;
  final ValueChanged<AnswerResult> onAnswered;

  const RevealExercise({
    super.key,
    required this.exercise,
    required this.word,
    required this.tts,
    required this.onAnswered,
  });

  @override
  State<RevealExercise> createState() => _RevealExerciseState();
}

class _RevealExerciseState extends State<RevealExercise> {
  final _clock = Stopwatch()..start();
  bool _revealed = false;
  bool _answered = false;

  void _play() => widget.tts.speak(widget.word.turkish).catchError((_) {});

  void _answer(bool knew) {
    if (_answered) return;
    setState(() => _answered = true);
    widget.onAnswered(AnswerResult(correct: knew, took: _clock.elapsed));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Phrase', style: tt.labelLarge?.copyWith(color: Colors.grey)),
        Text('Do you know what this means?',
            style: tt.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 20),
        Text(widget.word.turkish,
            textAlign: TextAlign.center, style: tt.headlineMedium),
        IconButton(icon: const Icon(Icons.volume_up), onPressed: _play),
        const SizedBox(height: 16),
        if (!_revealed)
          FilledButton(
              onPressed: () => setState(() => _revealed = true),
              child: const Text('Show meaning'))
        else ...[
          Text(widget.word.english,
              textAlign: TextAlign.center, style: tt.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: _answered ? null : () => _answer(true),
                  child: const Text('Knew it')),
              const SizedBox(width: 12),
              OutlinedButton(
                  onPressed: _answered ? null : () => _answer(false),
                  child: const Text("Didn't")),
            ],
          ),
        ],
      ],
    );
  }
}
