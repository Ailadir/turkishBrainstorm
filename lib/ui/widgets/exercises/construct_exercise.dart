import 'package:flutter/material.dart';

import '../../../domain/exercise.dart';

/// Build the Turkish word by tapping its shuffled letters in order.
/// More than 2 wrong taps counts as a wrong answer.
class ConstructExercise extends StatefulWidget {
  final Exercise exercise;
  final VocabItem word;
  final ValueChanged<AnswerResult> onAnswered;

  const ConstructExercise({
    super.key,
    required this.exercise,
    required this.word,
    required this.onAnswered,
  });

  @override
  State<ConstructExercise> createState() => _ConstructExerciseState();
}

class _ConstructExerciseState extends State<ConstructExercise> {
  final _clock = Stopwatch()..start();
  late final List<bool> _used =
      List.filled(widget.exercise.options.length, false);
  int _placed = 0;
  int _wrongTaps = 0;
  int? _flashWrong;
  bool _finished = false;

  String get _answer => widget.exercise.answer;

  void _tap(int i) {
    if (_finished || _used[i]) return;
    if (widget.exercise.options[i] == _answer[_placed]) {
      setState(() {
        _used[i] = true;
        _placed++;
        _flashWrong = null;
      });
      if (_placed == _answer.length) _finish(true);
    } else {
      setState(() {
        _wrongTaps++;
        _flashWrong = i;
      });
      if (_wrongTaps > 2) _finish(false);
    }
  }

  void _finish(bool correct) {
    _finished = true;
    widget.onAnswered(AnswerResult(
        correct: correct, took: _clock.elapsed, wrongTaps: _wrongTaps));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Spelling', style: tt.labelLarge?.copyWith(color: Colors.grey)),
        Text('Tap the letters in order',
            style: tt.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 20),
        Text(widget.word.english,
            textAlign: TextAlign.center, style: tt.headlineMedium),
        const SizedBox(height: 20),
        Text(
          _answer.substring(0, _placed).padRight(_answer.length, '_'),
          style: tt.headlineMedium?.copyWith(letterSpacing: 4),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < widget.exercise.options.length; i++)
              SizedBox(
                width: 48,
                height: 48,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: _flashWrong == i
                        ? Colors.red.withValues(alpha: 0.3)
                        : null,
                    foregroundColor: _used[i] ? cs.outline : null,
                  ),
                  onPressed: _used[i] || _finished ? null : () => _tap(i),
                  child: Text(widget.exercise.options[i],
                      style: tt.titleLarge),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Wrong taps: $_wrongTaps / 2',
            style: tt.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
