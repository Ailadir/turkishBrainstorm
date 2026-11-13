import 'package:flutter/material.dart';

import '../../../domain/exercise.dart';
import '../../../services/tts_service.dart';

/// chooseMeaning (Turkish → English), chooseTurkish (English → Turkish) and
/// listenChoose (audio → English). One tap is the final answer.
class ChoiceExercise extends StatefulWidget {
  final Exercise exercise;
  final VocabItem word;
  final TtsService tts;
  final ValueChanged<AnswerResult> onAnswered;

  const ChoiceExercise({
    super.key,
    required this.exercise,
    required this.word,
    required this.tts,
    required this.onAnswered,
  });

  @override
  State<ChoiceExercise> createState() => _ChoiceExerciseState();
}

class _ChoiceExerciseState extends State<ChoiceExercise> {
  final _clock = Stopwatch()..start();
  String? _selected;
  bool _showText = false;

  ExerciseType get _type => widget.exercise.type;

  @override
  void initState() {
    super.initState();
    if (_type == ExerciseType.listenChoose) _play();
  }

  void _play() => widget.tts.speak(widget.word.turkish).ignore();

  void _pick(String option) {
    if (_selected != null) return;
    setState(() => _selected = option);
    widget.onAnswered(
      AnswerResult(
        correct: option == widget.exercise.answer,
        took: _clock.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (label, hint) = switch (_type) {
      ExerciseType.chooseMeaning => ('Meaning', 'Pick the English meaning'),
      ExerciseType.chooseTurkish => ('Turkish', 'Pick the Turkish word'),
      _ => ('Listening', 'Listen, then pick the English meaning'),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: tt.labelLarge?.copyWith(color: Colors.grey)),
        Text(hint, style: tt.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 20),
        if (_type == ExerciseType.chooseMeaning)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.word.turkish,
                  textAlign: TextAlign.center,
                  style: tt.displaySmall,
                ),
              ),
              IconButton(icon: const Icon(Icons.volume_up), onPressed: _play),
            ],
          )
        else if (_type == ExerciseType.chooseTurkish)
          Text(
            widget.word.english,
            textAlign: TextAlign.center,
            style: tt.displaySmall,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.hearing),
            iconSize: 64,
            onPressed: _play,
          ),
          // No Turkish voice on the device? Let the user read the word.
          if (_showText)
            Text(widget.word.turkish, style: tt.headlineSmall)
          else
            TextButton(
              onPressed: () => setState(() => _showText = true),
              child: const Text("Can't hear? Show text"),
            ),
        ],
        const SizedBox(height: 24),
        for (final opt in widget.exercise.options)
          _OptionTile(
            text: opt,
            correct: _selected != null && opt == widget.exercise.answer,
            wrong: _selected == opt && opt != widget.exercise.answer,
            onTap: _selected == null ? () => _pick(opt) : null,
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;
  const _OptionTile({
    required this.text,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? Colors.green
        : wrong
        ? Colors.red
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        tileColor: color?.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color ?? Colors.grey.shade400),
        ),
        title: Text(text, textAlign: TextAlign.center),
        onTap: onTap,
      ),
    );
  }
}
