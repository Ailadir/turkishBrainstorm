import 'package:flutter/material.dart';
import '../../data/word_repository.dart';
import '../../domain/practice_mode.dart';
import '../../services/tts_service.dart';
import 'grade_buttons.dart';

class ListeningCard extends StatefulWidget {
  final ReviewCard card;
  final TtsService tts;
  final Future<List<String>> Function(int wordId, int n) fetchDistractors;
  final void Function(ReviewGrade) onGrade;

  const ListeningCard({
    super.key,
    required this.card,
    required this.tts,
    required this.fetchDistractors,
    required this.onGrade,
  });

  @override
  State<ListeningCard> createState() => _ListeningCardState();
}

class _ListeningCardState extends State<ListeningCard> {
  List<String>? _options;
  String? _selected;
  bool _answered = false;
  bool _ttsPlayed = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void didUpdateWidget(ListeningCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.word.id != widget.card.word.id) {
      _options = null;
      _selected = null;
      _answered = false;
      _ttsPlayed = false;
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    final distractors =
        await widget.fetchDistractors(widget.card.word.id, 3);
    final all = [widget.card.word.english, ...distractors];
    all.shuffle();
    if (mounted) setState(() => _options = all);
  }

  void _select(String option) {
    if (_answered) return;
    setState(() {
      _selected = option;
      _answered = true;
    });
  }

  ReviewGrade get _grade =>
      _selected == widget.card.word.english
          ? ReviewGrade.good
          : ReviewGrade.again;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Text('Listening', style: tt.labelLarge?.copyWith(color: Colors.grey)),
        const SizedBox(height: 24),
        IconButton(
          icon: const Icon(Icons.hearing, size: 64),
          onPressed: () {
            widget.tts.speak(widget.card.word.turkish);
            setState(() => _ttsPlayed = true);
          },
        ),
        Text('Tap to hear', style: tt.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 32),
        if (_options == null)
          const CircularProgressIndicator()
        else ...[
          ..._options!.map((opt) => _OptionTile(
                option: opt,
                selected: _selected == opt,
                correct: _answered && opt == widget.card.word.english,
                wrong: _answered && _selected == opt &&
                    opt != widget.card.word.english,
                onTap: _answered ? null : () => _select(opt),
              )),
          const SizedBox(height: 24),
          if (_answered) ...[
            Text(
              _grade == ReviewGrade.good ? 'Correct!' : 'Incorrect',
              style: TextStyle(
                color: _grade == ReviewGrade.good ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            if (_grade == ReviewGrade.good)
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
          ] else if (!_ttsPlayed)
            const Text('Listen first, then pick'),
        ],
      ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    if (correct) bg = Colors.green.shade100;
    if (wrong) bg = Colors.red.shade100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        tileColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        title: Text(option),
        onTap: onTap,
      ),
    );
  }
}
