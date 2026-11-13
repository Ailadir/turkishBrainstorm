import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/word_repository.dart';
import '../../domain/brainstorm_session.dart';
import '../../domain/exercise.dart';
import '../../domain/review_session.dart';
import '../../providers/providers.dart';
import '../widgets/exercises/choice_exercise.dart';
import '../widgets/exercises/construct_exercise.dart';
import '../widgets/exercises/reveal_exercise.dart';
import '../widgets/exercises/typing_exercise.dart';
import '../widgets/result_panel.dart';

enum SessionKind { brainstorm, review }

/// Runs a Brainstorm round (new words) or a Review (due words). Every answer
/// is persisted immediately and followed by a result panel.
class SessionScreen extends ConsumerStatefulWidget {
  final SessionKind kind;
  const SessionScreen({super.key, required this.kind});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  bool _loading = true;
  bool _finished = false;
  final Map<int, Word> _words = {};
  BrainstormSession? _brain;
  ReviewSession? _review;
  Exercise? _exercise;
  AnswerResult? _result;
  Timer? _timer;
  int _counter = 0;
  final _scroll = ScrollController();

  /// Brainstorm: the current word is shown as a card before its first
  /// exercise.
  bool _intro = false;
  final Set<int> _introduced = {};

  int _learned = 0;
  int _answers = 0;
  int _correctAnswers = 0;
  DateTime _startedAt = DateTime.now();

  bool get _isBrain => widget.kind == SessionKind.brainstorm;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _finished = false;
      _result = null;
      _learned = 0;
      _intro = false;
      _answers = 0;
      _correctAnswers = 0;
      _startedAt = DateTime.now();
    });
    final repo = ref.read(wordRepositoryProvider);
    final settings = ref.read(settingsServiceProvider);
    final List<Word> words = _isBrain
        ? await repo.pickNewWords(
            settings.wordsPerBrainstorm,
            usePackWords: settings.usePackWords,
          )
        : await repo.dueWords(limit: settings.maxReviewsPerSession);
    // Audio for this round and the next two is generated in the background.
    ref.read(ttsServiceProvider).resetNotice();
    if (_isBrain) {
      final ahead = await repo.pickNewWords(
        settings.wordsPerBrainstorm * 3,
        usePackWords: settings.usePackWords,
      );
      ref.read(audioPrefetchProvider).enqueue(ahead.map((w) => w.turkish));
    }
    final pool = await repo.distractorPool(
      exceptIds: {for (final w in words) w.id},
    );
    _introduced.clear();
    _words
      ..clear()
      ..addEntries(words.map((w) => MapEntry(w.id, w)));
    if (_isBrain) {
      _brain = BrainstormSession(
        words: words.map((w) => w.toItem()).toList(),
        pool: pool,
        typingEnabled: settings.typingEnabled,
      );
    } else {
      _review = ReviewSession(
        due: words.map((w) => w.toItem()).toList(),
        pool: pool,
        typingEnabled: settings.typingEnabled,
      );
    }
    if (!mounted) return;
    _advance(initial: true);
  }

  void _advance({bool initial = false}) {
    _timer?.cancel();
    final next = _isBrain ? _brain!.next() : _review!.next();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = null;
      _exercise = next;
      _finished = next == null;
      _intro = _isBrain && next != null && _introduced.add(next.wordId);
      _counter++;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    if (next == null) ref.invalidate(statsProvider);
  }

  Future<void> _onAnswered(AnswerResult r) async {
    final ex = _exercise!;
    final repo = ref.read(wordRepositoryProvider);
    final outcome = _isBrain ? _brain!.answer(r) : _review!.answer(r);
    setState(() {
      _result = r;
      _answers++;
      if (r.correct) _correctAnswers++;
    });
    // Bring the explanation and its Continue button into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Persist after every answer.
    if (_isBrain) {
      await repo.logBrainstorm(ex.wordId, ex.type, r.correct);
      if (outcome.wordCompleted) {
        await repo.finishBrainstorm(ex.wordId, outcome.mistakes);
        _learned++;
      }
    } else if (outcome.grade != null) {
      await repo.applyWordReview(ex.wordId, outcome.grade!, ex.type);
    }

    final settings = ref.read(settingsServiceProvider);
    if (r.correct && settings.autoAdvanceOnCorrect && mounted) {
      _timer = Timer(const Duration(milliseconds: 900), _advance);
    }
  }

  Widget _exerciseView(Exercise ex) {
    final word = _words[ex.wordId]!.toItem();
    final tts = ref.read(ttsServiceProvider);
    return switch (ex.type) {
      ExerciseType.chooseMeaning ||
      ExerciseType.chooseTurkish ||
      ExerciseType.listenChoose => ChoiceExercise(
        exercise: ex,
        word: word,
        tts: tts,
        onAnswered: _onAnswered,
      ),
      ExerciseType.construct => ConstructExercise(
        exercise: ex,
        word: word,
        onAnswered: _onAnswered,
      ),
      ExerciseType.typing => TypingExercise(
        exercise: ex,
        word: word,
        onAnswered: _onAnswered,
      ),
      ExerciseType.reveal => RevealExercise(
        exercise: ex,
        word: word,
        tts: tts,
        onAnswered: _onAnswered,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _isBrain ? 'Brainstorm' : 'Review';
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_finished) return _endScreen(title);

    final ex = _exercise!;
    final progress = _isBrain ? _brain!.progress : _review!.progress;
    final settings = ref.read(settingsServiceProvider);
    final result = _result;
    final advancesAlone =
        result != null && result.correct && settings.autoAdvanceOnCorrect;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            if (_intro)
              ResultPanel(
                key: ValueKey('i$_counter'),
                word: _words[ex.wordId]!,
                correct: true,
                intro: true,
                tts: ref.read(ttsServiceProvider),
                onContinue: () => setState(() {
                  _intro = false;
                  _counter++;
                }),
              )
            else ...[
              if (ex.isReask)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'One more try',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: Colors.orange),
                  ),
                ),
              // Keyed so each exercise starts with fresh state.
              KeyedSubtree(key: ValueKey(_counter), child: _exerciseView(ex)),
              if (result != null) ...[
                const SizedBox(height: 20),
                ResultPanel(
                  key: ValueKey('r$_counter'),
                  word: _words[ex.wordId]!,
                  correct: result.correct,
                  tts: ref.read(ttsServiceProvider),
                  autoplay: ex.type != ExerciseType.listenChoose,
                  onContinue: advancesAlone ? null : _advance,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _endScreen(String title) {
    final theme = Theme.of(context);
    final empty = _answers == 0;
    final accuracy = _answers == 0
        ? 0
        : (_correctAnswers * 100 / _answers).round();
    final mins = DateTime.now().difference(_startedAt).inSeconds;
    return Scaffold(
      appBar: AppBar(title: Text('$title complete')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                empty ? Icons.inbox_outlined : Icons.check_circle_outline,
                size: 80,
                color: empty ? Colors.grey : Colors.green,
              ),
              const SizedBox(height: 16),
              if (empty)
                Text(
                  _isBrain ? 'No new words to learn.' : 'Nothing due.',
                  style: theme.textTheme.headlineSmall,
                )
              else ...[
                Text(
                  _isBrain
                      ? 'Learned $_learned word${_learned == 1 ? '' : 's'}'
                      : 'Reviewed $_answers',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Accuracy $accuracy% · ${mins ~/ 60}m ${mins % 60}s'),
              ],
              const SizedBox(height: 24),
              if (!empty)
                FilledButton(
                  onPressed: _start,
                  child: const Text('Another round'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
