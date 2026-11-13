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

    final words = input
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
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
        final results = await Future.wait(
          words.map((w) => morphService.analyze(w)),
        );
        setState(() {
          _wordParts = [
            for (var i = 0; i < words.length; i++)
              (
                word: words[i],
                root: results[i].root,
                suffixes: results[i].suffixes,
              ),
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
      translation ??= await ref
          .read(translationServiceProvider)
          .translate(word);
      if (translation != null && mounted) {
        _englishCtrl.text = translation;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Translation failed. Type the English meaning.'),
          ),
        );
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
      final repo = ref.read(wordRepositoryProvider);
      // Exactly one row per save; root/suffixes are stored on it. Roots and
      // suffixes are never created as separate vocabulary cards.
      final result = await repo.addWord(
        turkish: _turkishCtrl.text.trim(),
        english: _englishCtrl.text.trim(),
        root: _isPhrase
            ? _wordParts.map((p) => p.root).join(' ')
            : _rootCtrl.text.trim(),
        suffixes: _isPhrase ? const [] : _suffixes,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        source: _sourceCtrl.text.trim().isEmpty
            ? null
            : _sourceCtrl.text.trim(),
      );
      if (!mounted) return;
      if (result.existed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Already in your list')));
      }
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                dimension: 20,
                child: CircularProgressIndicator(),
              ),
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
                          child: CircularProgressIndicator(),
                        ),
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
                Text(
                  'Suffixes',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ..._suffixes.asMap().entries.map(
                      (e) => Chip(
                        label: Text(e.value),
                        onDeleted: () => _removeSuffix(e.key),
                      ),
                    ),
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
              Text(
                'Word breakdown',
                style: Theme.of(context).textTheme.labelMedium,
              ),
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
                          child: CircularProgressIndicator(),
                        ),
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
            child: const Text('Cancel'),
          ),
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
              Text(
                part.word,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (part.root.isNotEmpty &&
                  part.root.toLowerCase() != part.word.toLowerCase()) ...[
                const SizedBox(width: 6),
                Text('→', style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(width: 6),
                Text(
                  part.root,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
          if (part.suffixes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: part.suffixes
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
