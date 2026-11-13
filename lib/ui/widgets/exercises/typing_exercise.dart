import 'package:flutter/material.dart';

import '../../../domain/exercise.dart';
import '../../../domain/turkish_text.dart';

/// Type the Turkish word. A diacritic-only miss (`gitti` vs `gıtti`) counts
/// as correct but "hard".
class TypingExercise extends StatefulWidget {
  final Exercise exercise;
  final VocabItem word;
  final ValueChanged<AnswerResult> onAnswered;

  const TypingExercise({
    super.key,
    required this.exercise,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<TypingExercise> createState() => _TypingExerciseState();
}

class _TypingExerciseState extends State<TypingExercise> {
  final _clock = Stopwatch()..start();
  final _ctrl = TextEditingController();
  bool _checked = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _check() {
    if (_checked || _ctrl.text.trim().isEmpty) return;
    final a = trNormalize(_ctrl.text);
    final b = trNormalize(widget.exercise.answer);
    final exact = a == b;
    final diacriticOnly = !exact && stripDiacritics(a) == stripDiacritics(b);
    setState(() => _checked = true);
    widget.onAnswered(
      AnswerResult(
        correct: exact || diacriticOnly,
        took: _clock.elapsed,
        diacriticOnly: diacriticOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Writing', style: tt.labelLarge?.copyWith(color: Colors.grey)),
        Text(
          'Type the Turkish for this meaning',
          style: tt.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Text(
          widget.word.english,
          textAlign: TextAlign.center,
          style: tt.displaySmall,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _ctrl,
          autofocus: true,
          enabled: !_checked,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _check(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Turkish',
          ),
        ),
        const SizedBox(height: 12),
        if (!_checked)
          FilledButton(onPressed: _check, child: const Text('Check')),
      ],
    );
  }
}
