import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

// One Zemberek result per word in the phrase.
typedef _WordPart = ({String word, String root, List<String> suffixes});

class AddWordScreen extends ConsumerStatefulWidget {
  const AddWordScreen({super.key});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _turkishCtrl = TextEditingController();
  final _englishCtrl = TextEditingController();
  final _rootCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Single-word state.
  List<String> _suffixes = [];

  // Multi-word / phrase state (non-empty means phrase mode).
  List<_WordPart> _wordParts = [];
  bool get _isPhrase => _wordParts.isNotEmpty;

  bool _analyzing = false;
  bool _translating = false;
  bool _saving = false;

  @override
  void dispose() {
    _turkishCtrl.dispose();
    _englishCtrl.dispose();
    _rootCtrl.dispose();
    _noteCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  // ── Analyse ──────────────────────────────────────────────────────────────

  Future<void> _analyze() async {
    final input = _turkishCtrl.text.trim();
    if (input.isEmpty) return;

    final words =
        input.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    setState(() => _analyzing = true);
    try {
      final morphService = ref.read(morphologyServiceProvider);
      if (words.length == 1) {
        final result = await morphService.analyze(input);
        _rootCtrl.text = result.root;
        setState(() {
          _suffixes = result.suffixes;
          _wordParts = [];
        });
      } else {
        // Analyse all words in parallel.
        final results =
            await Future.wait(words.map((w) => morphService.analyze(w)));
        setState(() {
          _wordParts = [
            for (var i = 0; i < words.length; i++)
              (word: words[i], root: results[i].root, suffixes: results[i].suffixes)
          ];
          _suffixes = [];
          _rootCtrl.clear();
        });
      }
    } finally {
      setState(() => _analyzing = false);
    }

    if (_englishCtrl.text.trim().isEmpty) {
      await _translateEnglish();
    }
  }

  // ── Translate ─────────────────────────────────────────────────────────────

  /// Translates the full Turkish field (single word or whole phrase).
  Future<void> _translateEnglish() async {
    final word = _turkishCtrl.text.trim();
    if (word.isEmpty) return;
    setState(() => _translating = true);
    try {
      String? translation;
      final gemini = ref.read(geminiServiceProvider);
      if (gemini.isConfigured) {
        translation = await gemini.translateWord(word);
      }
      translation ??=
          await ref.read(translationServiceProvider).translate(word);
      if (translation != null && mounted) {
        _englishCtrl.text = translation;
      }
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      if (_isPhrase) {
        await _savePhrase();
      } else {
        await _saveSingleWord();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveSingleWord() async {
    final repo = ref.read(wordRepositoryProvider);
    final gemini = ref.read(geminiServiceProvider);
    final translator = ref.read(translationServiceProvider);

    await repo.addWord(
      turkish: _turkishCtrl.text.trim(),
      english: _englishCtrl.text.trim(),
      root: _rootCtrl.text.trim(),
      suffixes: _suffixes,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      source:
          _sourceCtrl.text.trim().isEmpty ? null : _sourceCtrl.text.trim(),
    );

    final mainTurkish = _turkishCtrl.text.trim().toLowerCase();
    final root = _rootCtrl.text.trim();
    final suffixParts = _suffixes.where((s) => s.trim().isNotEmpty).toList();
    final hasRoot = root.isNotEmpty && root.toLowerCase() != mainTurkish;

    if (!hasRoot && suffixParts.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (gemini.isConfigured && hasRoot) {
      final parts =
          await gemini.translateParts(root: root, suffixes: suffixParts);
      if (parts != null) {
        if (parts.root.isNotEmpty) {
          await repo.addWord(
              turkish: root,
              english: parts.root,
              root: root,
              suffixes: []);
        }
        for (var i = 0; i < suffixParts.length; i++) {
          final eng =
              i < parts.suffixes.length ? parts.suffixes[i] : null;
          if (eng != null && eng.isNotEmpty) {
            await repo.addWord(
                turkish: suffixParts[i],
                english: eng,
                root: suffixParts[i],
                suffixes: []);
          }
        }
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    // MyMemory fallback.
    final allParts = [if (hasRoot) root, ...suffixParts];
    final translations = await Future.wait(
        allParts.map((p) => translator.translate(p)));
    for (var i = 0; i < allParts.length; i++) {
      final eng = translations[i];
      if (eng != null) {
        await repo.addWord(
            turkish: allParts[i],
            english: eng,
            root: allParts[i],
            suffixes: []);
      }
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _savePhrase() async {
    final repo = ref.read(wordRepositoryProvider);
    final gemini = ref.read(geminiServiceProvider);
    final translator = ref.read(translationServiceProvider);
    final phrase = _turkishCtrl.text.trim();

    // 1. Save the full phrase entry.
    await repo.addWord(
      turkish: phrase,
      english: _englishCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      source:
          _sourceCtrl.text.trim().isEmpty ? null : _sourceCtrl.text.trim(),
    );

    // 2. One Gemini call for all words' breakdowns.
    if (gemini.isConfigured) {
      final breakdown = await gemini.translatePhraseBreakdown(
        phrase: phrase,
        wordParts: _wordParts,
      );
      if (breakdown != null) {
        for (var i = 0; i < _wordParts.length; i++) {
          final part = _wordParts[i];
          final bd =
              i < breakdown.words.length ? breakdown.words[i] : null;

          // Save the inflected word (skip if same as root — already saved below).
          final wordDiffersFromRoot =
              part.word.toLowerCase() != part.root.toLowerCase();
          if (wordDiffersFromRoot && bd?.wordMeaning.isNotEmpty == true) {
            await repo.addWord(
              turkish: part.word,
              english: bd!.wordMeaning,
              root: part.root,
              suffixes: part.suffixes,
            );
          }

          // Save root.
          if (part.root.isNotEmpty && bd?.rootMeaning.isNotEmpty == true) {
            await repo.addWord(
              turkish: part.root,
              english: bd!.rootMeaning,
              root: part.root,
              suffixes: [],
            );
          }

          // Save each suffix.
          for (var j = 0; j < part.suffixes.length; j++) {
            final meaning = (bd != null && j < bd.suffixMeanings.length)
                ? bd.suffixMeanings[j]
                : null;
            if (meaning != null && meaning.isNotEmpty) {
              await repo.addWord(
                turkish: part.suffixes[j],
                english: meaning,
                root: part.suffixes[j],
                suffixes: [],
              );
            }
          }
        }
        if (mounted) Navigator.pop(context);
        return;
      }
    }

    // Fallback: translate each word individually via MyMemory.
    for (final part in _wordParts) {
      final wordEng = await translator.translate(part.word);
      if (wordEng != null) {
        await repo.addWord(
            turkish: part.word,
            english: wordEng,
            root: part.root,
            suffixes: part.suffixes);
      }
      if (part.root.isNotEmpty &&
          part.root.toLowerCase() != part.word.toLowerCase()) {
        final rootEng = await translator.translate(part.root);
        if (rootEng != null) {
          await repo.addWord(
              turkish: part.root,
              english: rootEng,
              root: part.root,
              suffixes: []);
        }
      }
    }
    if (mounted) Navigator.pop(context);
  }

  // ── Suffix editing (single-word mode only) ────────────────────────────────

  void _removeSuffix(int i) =>
      setState(() => _suffixes = List.from(_suffixes)..removeAt(i));

  void _addSuffix(String s) {
    final trimmed = s.trim();
    if (trimmed.isNotEmpty) {
      setState(() => _suffixes = [..._suffixes, trimmed]);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final busy = _analyzing || _translating || _saving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add word'),
        actions: [
          if (busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                  dimension: 20, child: CircularProgressIndicator()),
            )
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Turkish word / phrase ─────────────────────────────────────
            TextFormField(
              controller: _turkishCtrl,
              decoration: InputDecoration(
                labelText: 'Turkish word or phrase *',
                hintText: 'e.g. gitmek  or  eve gidiyorum',
                border: const OutlineInputBorder(),
                suffixIcon: _analyzing
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator()),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_fix_high),
                        tooltip: 'Analyse morphology + auto-translate',
                        onPressed: _analyze,
                      ),
              ),
              onFieldSubmitted: (_) => _analyze(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // ── Single-word: root + suffixes ──────────────────────────────
            if (!_isPhrase) ...[
              TextFormField(
                controller: _rootCtrl,
                decoration: const InputDecoration(
                  labelText: 'Root / lemma',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_suffixes.isNotEmpty) ...[
                Text('Suffixes',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._suffixes.asMap().entries.map((e) => Chip(
                          label: Text(e.value),
                          onDeleted: () => _removeSuffix(e.key),
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      onPressed: _showAddSuffixDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else ...[
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: const Text('Add suffix'),
                  onPressed: _showAddSuffixDialog,
                ),
                const SizedBox(height: 12),
              ],
            ],

            // ── Phrase: per-word breakdown ────────────────────────────────
            if (_isPhrase) ...[
              Text('Word breakdown',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              ..._wordParts.map((p) => _WordPartTile(part: p)),
              const SizedBox(height: 4),
            ],

            const Divider(),
            const SizedBox(height: 8),

            // ── English translation ───────────────────────────────────────
            TextFormField(
              controller: _englishCtrl,
              decoration: InputDecoration(
                labelText: 'English translation *',
                border: const OutlineInputBorder(),
                suffixIcon: _translating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator()),
                      )
                    : IconButton(
                        icon: const Icon(Icons.translate),
                        tooltip: 'Auto-translate',
                        onPressed: _translateEnglish,
                      ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 6),
            _saveHint(context),
            const SizedBox(height: 16),

            // ── Note / Source ─────────────────────────────────────────────
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note / example sentence',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Source (manhwa, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveHint(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.grey);

    if (_isPhrase) {
      final wordCount = _wordParts.length;
      final suffixCount =
          _wordParts.fold(0, (s, p) => s + p.suffixes.length);
      return Text(
        'Saving will also add $wordCount word${wordCount == 1 ? '' : 's'}, '
        '$wordCount root${wordCount == 1 ? '' : 's'}, and '
        '$suffixCount suffix${suffixCount == 1 ? '' : 'es'} as separate entries.',
        style: style,
      );
    }
    if (_rootCtrl.text.isNotEmpty || _suffixes.isNotEmpty) {
      return Text(
        'Saving will also auto-translate & add the root'
        '${_suffixes.isNotEmpty ? ' and ${_suffixes.length} suffix${_suffixes.length == 1 ? '' : 'es'}' : ''} as separate words.',
        style: style,
      );
    }
    return const SizedBox.shrink();
  }

  void _showAddSuffixDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add suffix'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Suffix morpheme'),
          onSubmitted: (v) {
            _addSuffix(v);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              _addSuffix(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Per-word breakdown tile (phrase mode) ─────────────────────────────────────

class _WordPartTile extends StatelessWidget {
  final _WordPart part;
  const _WordPartTile({required this.part});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(part.word,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (part.root.isNotEmpty &&
                  part.root.toLowerCase() != part.word.toLowerCase()) ...[
                const SizedBox(width: 6),
                Text('→', style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(width: 6),
                Text(part.root,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade700)),
              ],
            ],
          ),
          if (part.suffixes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: part.suffixes
                  .map((s) => Chip(
                        label: Text(s),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
