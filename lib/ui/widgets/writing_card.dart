import 'package:flutter/material.dart';
import '../../data/word_repository.dart';
import '../../domain/edit_distance.dart';
import '../../domain/practice_mode.dart';
import '../../services/tts_service.dart';
import 'grade_buttons.dart';

class WritingCard extends StatefulWidget {
  final ReviewCard card;
  final TtsService tts;
  final void Function(ReviewGrade) onGrade;

  const WritingCard({
    super.key,
    required this.card,
    required this.tts,
    required this.onGrade,
  });

  @override
  State<WritingCard> createState() => _WritingCardState();
}

class _WritingCardState extends State<WritingCard> {
  final _controller = TextEditingController();
  bool _checked = false;
  ReviewGrade? _autoGrade;
  bool _ttsPlayed = false;

  @override
  void didUpdateWidget(WritingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.word.id != widget.card.word.id) {
      _controller.clear();
      _checked = false;
      _autoGrade = null;
      _ttsPlayed = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final input = _controller.text;
    final expected = widget.card.word.turkish;
    ReviewGrade grade;
    if (input.trim().toLowerCase() == expected.trim().toLowerCase()) {
      grade = ReviewGrade.good;
    } else if (EditDistance.isCloseEnough(input, expected)) {
      grade = ReviewGrade.hard;
    } else {
      grade = ReviewGrade.again;
    }
    setState(() {
      _checked = true;
      _autoGrade = grade;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final word = widget.card.word;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Writing', style: tt.labelLarge?.copyWith(color: Colors.grey)),
        const SizedBox(height: 24),
        Text(word.english, style: tt.displaySmall),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.volume_up),
          label: const Text('Hear it once'),
          onPressed: _ttsPlayed
              ? null
              : () {
                  widget.tts.speak(word.turkish);
                  setState(() => _ttsPlayed = true);
                },
        ),
        const SizedBox(height: 24),
        if (!_checked) ...[
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _check(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Type the Turkish word',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _check, child: const Text('Check')),
        ] else ...[
          _ResultBanner(grade: _autoGrade!, correct: word.turkish),
          const SizedBox(height: 24),
          if (_autoGrade == ReviewGrade.good)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => widget.onGrade(ReviewGrade.good),
                  child: const Text('Good'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => widget.onGrade(ReviewGrade.hard),
                  child: const Text('Was hard'),
                ),
              ],
            )
          else
            GradeButtons(onGrade: widget.onGrade),
        ],
      ],
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final ReviewGrade grade;
  final String correct;
  const _ResultBanner({required this.grade, required this.correct});

  @override
  Widget build(BuildContext context) {
    final isPass = grade != ReviewGrade.again;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPass ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPass ? Colors.green : Colors.red,
        ),
      ),
      child: Column(
        children: [
          Text(
            isPass ? '✓ Correct!' : '✗ Incorrect',
            style: TextStyle(
              color: isPass ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (!isPass) ...[
            const SizedBox(height: 8),
            Text('Correct: $correct',
                style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
    );
  }
}
