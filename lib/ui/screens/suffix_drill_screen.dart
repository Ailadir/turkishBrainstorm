import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/srs.dart';
import '../../domain/suffix_drill_session.dart';
import '../../domain/suffix_glosses.dart';
import '../../providers/providers.dart';

/// Ten short questions: "what does the highlighted part mean?"
class SuffixDrillScreen extends ConsumerStatefulWidget {
  const SuffixDrillScreen({super.key});

  @override
  ConsumerState<SuffixDrillScreen> createState() => _SuffixDrillScreenState();
}

class _SuffixDrillScreenState extends ConsumerState<SuffixDrillScreen> {
  SuffixDrillSession? _session;
  DrillQuestion? _question;
  List<DrillSegment> _segments = const [];
  List<DrillExample> _moreExamples = const [];
  String? _picked;
  final _clock = Stopwatch();
  bool _loading = true;
  int _answered = 0;
  int _correct = 0;
  Timer? _advance;
  double _levelProgress = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    final settings = ref.read(settingsServiceProvider);
    final repo = ref.read(morphemeRepositoryProvider);
    final candidates = await repo.candidates(settings.grammarLevel);
    _levelProgress = await repo.levelProgress(settings.grammarLevel);
    _session = SuffixDrillSession(candidates: candidates);
    _answered = 0;
    _correct = 0;
    await _next();
  }

  Future<void> _next() async {
    final q = _session!.next();
    if (q == null) {
      setState(() {
        _question = null;
        _loading = false;
      });
      return;
    }
    // Pack examples carry no analysis: ask Zemberek where the suffix is.
    var parts = q.example.parts;
    var lemma = q.example.lemma;
    if (parts.isEmpty) {
      final r = await ref
          .read(morphologyServiceProvider)
          .analyze(q.example.word);
      parts = r.morphemes;
      lemma = r.lemma;
    }
    if (!mounted) return;
    final candidate = _session!.candidates.firstWhere(
      (c) => c.id == q.morphemeId,
    );
    setState(() {
      _question = q;
      _segments = segmentsFor(q.example.word, lemma, parts, q.morphemeId);
      _moreExamples = candidate.examples
          .where((e) => e.word != q.example.word)
          .take(3)
          .toList();
      _picked = null;
      _loading = false;
    });
    _clock
      ..reset()
      ..start();
  }

  Future<void> _answer(String option) async {
    final q = _question!;
    if (_picked != null) return;
    final correct = option == q.answer;
    final took = _clock.elapsed;
    setState(() => _picked = option);
    final scheduled = _session!.answer(correct: correct);
    if (scheduled) {
      _answered++;
      if (correct) _correct++;
      final grade = !correct
          ? ReviewGrade.again
          : took >= const Duration(seconds: 8)
          ? ReviewGrade.hard
          : ReviewGrade.good;
      await ref
          .read(morphemeRepositoryProvider)
          .applyReview(q.morphemeId, grade);
    }
    if (correct && ref.read(settingsServiceProvider).autoAdvanceOnCorrect) {
      _advance = Timer(const Duration(milliseconds: 1400), () {
        if (mounted && _picked != null) _next();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Suffix drill')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _question == null
          ? _summary(theme)
          : _questionView(theme, _question!),
    );
  }

  Widget _questionView(ThemeData theme, DrillQuestion q) {
    final info = suffixInfo(q.morphemeId);
    final answered = _picked != null;
    final cs = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (q.isReask) Text('One more try', style: theme.textTheme.labelMedium),
        const SizedBox(height: 12),
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                for (var i = 0; i < _segments.length; i++) ...[
                  if (i > 0) const TextSpan(text: '·'),
                  TextSpan(
                    text: _segments[i].text,
                    style: _segments[i].highlighted
                        ? TextStyle(
                            color: cs.primary,
                            decoration: TextDecoration.underline,
                          )
                        : null,
                  ),
                ],
              ],
            ),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(q.example.english, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 20),
        Text(
          'What does the highlighted part mean?',
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        for (final o in q.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: !answered
                    ? null
                    : o == q.answer
                    ? Colors.green.withValues(alpha: 0.2)
                    : o == _picked
                    ? Colors.red.withValues(alpha: 0.2)
                    : null,
              ),
              onPressed: answered ? null : () => _answer(o),
              child: Text(o, textAlign: TextAlign.center),
            ),
          ),
        if (answered) ...[
          const Divider(height: 28),
          Text(info.gloss, style: theme.textTheme.titleMedium),
          Text(
            '${info.category} · ${info.level}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final e in _moreExamples)
            Text(
              '${e.word}  –  ${e.english}',
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              _advance?.cancel();
              _next();
            },
            child: const Text('Next'),
          ),
        ],
      ],
    );
  }

  Widget _summary(ThemeData theme) {
    final settings = ref.read(settingsServiceProvider);
    final level = settings.grammarLevel;
    final next = cefrLevels.indexOf(level) + 1;
    final canUnlock = _levelProgress >= 0.8 && next < cefrLevels.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _answered == 0 ? 'Nothing to drill right now' : 'Done!',
              style: theme.textTheme.headlineSmall,
            ),
            if (_answered > 0) Text('$_correct / $_answered correct first try'),
            const SizedBox(height: 8),
            Text(
              '$level suffixes: ${(_levelProgress * 100).round()}% learned',
              style: theme.textTheme.bodyMedium,
            ),
            if (_answered == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Install the A1 starter on Home to get suffix examples, or add words.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            if (canUnlock)
              FilledButton.tonal(
                onPressed: () async {
                  await settings.setGrammarLevel(cefrLevels[next]);
                  ref.invalidate(suffixDueProvider);
                  await _start();
                },
                child: Text('Unlock ${cefrLevels[next]} suffixes'),
              ),
            if (_answered > 0) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _start,
                child: const Text('Another round'),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
