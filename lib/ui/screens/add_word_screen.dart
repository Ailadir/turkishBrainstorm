import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/morpheme_ref.dart';
import '../../domain/turkish_text.dart';
import '../../providers/providers.dart';
import '../../services/translation_pipeline.dart';
import '../widgets/breakdown_view.dart';

class AddWordScreen extends ConsumerStatefulWidget {
  /// Pre-filled text, e.g. from "Add to Turkish Vocab" in another app.
  final String? initialText;
  const AddWordScreen({super.key, this.initialText});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _turkishCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  final _englishCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;
  int _generation = 0; // drops results of superseded lookups

  // Single-word analysis.
  String? _lemma;
  String? _pos;
  List<MorphemeRef> _morphemes = [];

  TranslationResult? _result;
  bool _englishEdited = false;
  bool _busy = false; // network lookup or save in progress
  final Set<String> _alsoSave = {};

  List<String> get _tokens => _turkishCtrl.text
      .split(RegExp(r'\s+'))
      .map(trNormalize)
      .where((t) => t.isNotEmpty)
      .toSet()
      .toList();
  bool get _isWord => inferKind(_turkishCtrl.text) == 'word';

  @override
  void initState() {
    super.initState();
    _sourceCtrl.text = ref.read(settingsServiceProvider).lastSource;
    final initial = widget.initialText?.trim();
    if (initial != null && initial.isNotEmpty) {
      _turkishCtrl.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) => _localLookup());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _turkishCtrl.dispose();
    _contextCtrl.dispose();
    _englishCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  // ── Lookups ───────────────────────────────────────────────────────────────

  void _onTurkishChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _localLookup);
  }

  /// Offline only: breakdown + dictionary gloss. Never touches the network.
  Future<void> _localLookup() async {
    final text = _turkishCtrl.text.trim();
    final gen = ++_generation;
    if (text.isEmpty) {
      setState(() {
        _lemma = null;
        _morphemes = [];
        _result = null;
        _alsoSave.clear();
      });
      return;
    }
    MorphologyResult0? morph;
    if (_isWord) {
      final r = await ref.read(morphologyServiceProvider).analyze(text);
      morph = (lemma: r.lemma, pos: r.pos, morphemes: r.morphemes);
    }
    final result = await ref
        .read(translationPipelineProvider)
        .translate(text, localOnly: true);
    if (!mounted || gen != _generation) return;
    setState(() {
      _lemma = morph?.lemma;
      _pos = morph?.pos;
      _morphemes = morph?.morphemes ?? [];
      _result = result;
      _alsoSave.removeWhere((t) => !_tokens.contains(t));
      // A word-by-word gloss is a hint, not a translation: don't fill it in,
      // so Save with an empty English still asks the AI.
      if (!_englishEdited &&
          result != null &&
          result.source != TranslationSource.literal) {
        _englishCtrl.text = result.english;
      }
    });
  }

  /// May use the network (AI, then MyMemory).
  Future<void> _translateOnline({bool forceAi = false}) async {
    final text = _turkishCtrl.text.trim();
    if (text.isEmpty) return;
    final gen = ++_generation;
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(translationPipelineProvider)
          .translate(text, context: _contextCtrl.text, forceAi: forceAi);
      if (!mounted || gen != _generation) return;
      if (r == null) {
        _snack('No translation found. Type the English meaning.');
        return;
      }
      setState(() {
        _result = r;
        if (forceAi || !_englishEdited) {
          _englishCtrl.text = r.english;
          _englishEdited = false;
        }
      });
      if (r.warning != null) _snack(r.warning!);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save({required bool addAnother}) async {
    if (_turkishCtrl.text.trim().isEmpty) {
      _formKey.currentState?.validate();
      return;
    }
    // Save only waits for the network when English is still empty.
    if (_englishCtrl.text.trim().isEmpty) await _translateOnline();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(wordRepositoryProvider);
      final settings = ref.read(settingsServiceProvider);
      final source = _sourceCtrl.text.trim();
      await settings.setLastSource(source);

      final r = await repo.addWord(
        turkish: _turkishCtrl.text.trim(),
        english: _englishCtrl.text.trim(),
        lemma: _isWord && _lemma != null && _morphemes.isNotEmpty
            ? _lemma
            : null,
        pos: _isWord ? _pos : null,
        morphemes: _isWord ? _morphemes : const [],
        englishEdited: _englishEdited,
        note: _contextCtrl.text.trim().isEmpty
            ? null
            : _contextCtrl.text.trim(),
        source: source.isEmpty ? null : source,
      );

      var skipped = 0;
      for (final token in _alsoSave) {
        final t = await ref
            .read(translationPipelineProvider)
            .translate(token, localOnly: true);
        if (t == null) {
          skipped++;
          continue;
        }
        await repo.addWord(
          turkish: token,
          english: t.english,
          source: source.isEmpty ? null : source,
        );
      }
      ref.read(analysisJobProvider).run().ignore();
      // Generate the audio now so it plays offline later.
      ref.read(audioPrefetchProvider).enqueue([_turkishCtrl.text]);
      ref.invalidate(statsProvider);
      if (!mounted) return;
      _snack(
        r.existed
            ? 'Already in your list'
            : skipped > 0
            ? 'Saved ($skipped words had no known meaning and were skipped)'
            : 'Saved',
      );
      if (addAnother) {
        setState(() {
          _turkishCtrl.clear();
          _contextCtrl.clear();
          _englishCtrl.clear();
          _englishEdited = false;
          _lemma = null;
          _morphemes = [];
          _result = null;
          _alsoSave.clear();
        });
      } else {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = _tokens;
    final hasAi = ref.read(llmServiceProvider).isConfigured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add word'),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => _save(addAnother: false),
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _turkishCtrl,
              autofocus: widget.initialText == null,
              decoration: const InputDecoration(
                labelText: 'Turkish word or phrase *',
                hintText: 'e.g. gitmek  or  eve gidiyorum',
                border: OutlineInputBorder(),
              ),
              onChanged: _onTurkishChanged,
              onFieldSubmitted: (_) {
                _debounce?.cancel();
                // Done on a phrase asks for a full translation.
                if (!_isWord) {
                  _translateOnline();
                } else {
                  _localLookup();
                }
              },
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            if (_isWord) BreakdownView(lemma: _lemma, morphemes: _morphemes),
            if (_isWord && _morphemes.isNotEmpty) const SizedBox(height: 12),

            if (!_isWord && tokens.length > 1) ...[
              Text(
                'Also save as separate cards:',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in tokens)
                    FilterChip(
                      label: Text(t),
                      selected: _alsoSave.contains(t),
                      onSelected: (on) => setState(
                        () => on ? _alsoSave.add(t) : _alsoSave.remove(t),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            TextFormField(
              controller: _contextCtrl,
              decoration: const InputDecoration(
                labelText: 'Context sentence (optional)',
                helperText: 'Where you saw it. Helps the AI and your memory.',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _englishCtrl,
              onChanged: (_) => _englishEdited = true,
              decoration: InputDecoration(
                labelText: 'English *',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: hasAi ? 'Ask AI' : 'Translate online',
                  onPressed: _busy
                      ? null
                      : () => _translateOnline(forceAi: hasAi),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            if (_result != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(_result!.sourceLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  for (final alt in _result!.alternatives.take(3))
                    ActionChip(
                      label: Text(alt),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() {
                        _englishCtrl.text = alt;
                        _englishEdited = true;
                      }),
                    ),
                ],
              ),
              if (_result!.source == TranslationSource.literal)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Word by word: ${_result!.english}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              if (_result!.note != null && _result!.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_result!.note!, style: theme.textTheme.bodySmall),
                ),
            ],
            const SizedBox(height: 16),

            TextFormField(
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Source (manhwa, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: const Text('Save & add another'),
              onPressed: _busy ? null : () => _save(addAnother: true),
            ),
          ],
        ),
      ),
    );
  }
}

typedef MorphologyResult0 = ({
  String lemma,
  String? pos,
  List<MorphemeRef> morphemes,
});
