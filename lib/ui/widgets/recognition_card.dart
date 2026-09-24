import 'package:flutter/material.dart';
import '../../data/word_repository.dart';
import '../../domain/practice_mode.dart';
import '../../services/tts_service.dart';
import 'grade_buttons.dart';

class RecognitionCard extends StatefulWidget {
  final ReviewCard card;
  final TtsService tts;
  final void Function(ReviewGrade) onGrade;

  const RecognitionCard({
    super.key,
    required this.card,
    required this.tts,
    required this.onGrade,
  });

  @override
  State<RecognitionCard> createState() => _RecognitionCardState();
}

class _RecognitionCardState extends State<RecognitionCard> {
  bool _revealed = false;

  @override
  void didUpdateWidget(RecognitionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.word.id != widget.card.word.id ||
        oldWidget.card.mode != widget.card.mode) {
      _revealed = false;
    }
  }

  bool get _isTrEn => widget.card.mode == PracticeMode.recognitionTrEn;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final word = widget.card.word;
    final prompt = _isTrEn ? word.turkish : word.english;
    final answer = _isTrEn ? word.english : word.turkish;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Text(
          widget.card.mode.label,
          style: tt.labelLarge?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Text(prompt, style: tt.displaySmall),
        if (_isTrEn) ...[
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.volume_up),
            iconSize: 32,
            onPressed: () => widget.tts.speak(word.turkish),
          ),
        ],
        if (word.note != null && _revealed) ...[
          const SizedBox(height: 12),
          Text(
            word.note!,
            style: tt.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        if (!_revealed)
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: const Text('Show answer'),
          )
        else ...[
          Text(answer, style: tt.headlineMedium),
          if (!_isTrEn) ...[
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: 28,
              onPressed: () => widget.tts.speak(word.turkish),
            ),
          ],
          const SizedBox(height: 24),
          GradeButtons(onGrade: widget.onGrade),
        ],
      ],
        ),
      ),
    );
  }
}
