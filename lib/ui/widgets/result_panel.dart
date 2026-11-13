import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/word_repository.dart';
import '../../services/tts_service.dart';
import 'breakdown_view.dart';

/// Shown after every answer: Turkish + audio + English + suffix breakdown +
/// example/note, with a green or red header.
class ResultPanel extends StatefulWidget {
  final Word word;
  final bool correct;
  final TtsService tts;

  /// Play the word on show (skipped for listening, which already played it).
  final bool autoplay;

  /// Null when the screen advances by itself.
  final VoidCallback? onContinue;

  /// Brainstorm shows the panel once before a new word's first exercise.
  final bool intro;

  const ResultPanel({
    super.key,
    required this.word,
    required this.correct,
    required this.tts,
    this.autoplay = true,
    this.onContinue,
    this.intro = false,
  });

  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel> {
  @override
  void initState() {
    super.initState();
    if (widget.autoplay) _play();
  }

  void _play() {
    widget.tts.speak(widget.word.turkish).ignore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = widget.word;
    final color = widget.intro
        ? theme.colorScheme.primary
        : widget.correct
        ? Colors.green
        : Colors.red;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.intro
                ? 'New word'
                : widget.correct
                ? '✓ Correct'
                : '✗ Not quite',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  w.turkish,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.volume_up), onPressed: _play),
            ],
          ),
          Text(
            w.english,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          BreakdownView(lemma: w.lemma, morphemes: w.morphemeRefs),
          if (w.note != null && w.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              w.note!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            if (w.noteEn != null && w.noteEn!.isNotEmpty)
              Text(
                w.noteEn!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
          ],
          if (widget.onContinue != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.onContinue,
              child: Text(widget.intro ? 'Got it' : 'Continue'),
            ),
          ],
        ],
      ),
    );
  }
}
