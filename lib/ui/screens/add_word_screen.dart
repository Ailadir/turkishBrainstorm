import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

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

  List<String> _suffixes = [];
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

  Future<void> _analyze() async {
    final word = _turkishCtrl.text.trim();
    if (word.isEmpty) return;
    setState(() => _analyzing = true);
    try {
      final result =
          await ref.read(morphologyServiceProvider).analyze(word);
      _rootCtrl.text = result.root;
      setState(() => _suffixes = result.suffixes);
    } finally {
      setState(() => _analyzing = false);
    }
  }

  Future<void> _translateEnglish() async {
    final word = _turkishCtrl.text.trim();
    if (word.isEmpty) return;
    setState(() => _translating = true);
    try {
      final translation =
          await ref.read(translationServiceProvider).translate(word);
      if (translation != null && mounted) {
        _englishCtrl.text = translation;
      }
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  /// Save the main word, then translate + save root and each suffix as
  /// separate vocabulary entries.
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(wordRepositoryProvider);
      final translator = ref.read(translationServiceProvider);

      // 1. Save the main inflected form.
      await repo.addWord(
        turkish: _turkishCtrl.text.trim(),
        english: _englishCtrl.text.trim(),
        root: _rootCtrl.text.trim(),
        suffixes: _suffixes,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        source: _sourceCtrl.text.trim().isEmpty
            ? null
            : _sourceCtrl.text.trim(),
      );

      // 2. Collect root + suffixes (de-duped, skip blank).
      final mainTurkish = _turkishCtrl.text.trim().toLowerCase();
      final parts = <String>{};
      final root = _rootCtrl.text.trim();
      if (root.isNotEmpty && root.toLowerCase() != mainTurkish) {
        parts.add(root);
      }
      for (final s in _suffixes) {
        if (s.trim().isNotEmpty) parts.add(s.trim());
      }

      if (parts.isNotEmpty) {
        // 3. Translate all parts in parallel.
        final partList = parts.toList();
        final translations = await Future.wait(
          partList.map((p) => translator.translate(p)),
        );

        // 4. Save each part that translated successfully.
        for (var i = 0; i < partList.length; i++) {
          final eng = translations[i];
          if (eng != null) {
            await repo.addWord(
              turkish: partList[i],
              english: eng,
              root: partList[i],
              suffixes: [],
            );
          }
        }
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _removeSuffix(int i) =>
      setState(() => _suffixes = List.from(_suffixes)..removeAt(i));

  void _addSuffix(String s) {
    final trimmed = s.trim();
    if (trimmed.isNotEmpty) {
      setState(() => _suffixes = [..._suffixes, trimmed]);
    }
  }

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
            TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Turkish word ──────────────────────────────────────────────
            TextFormField(
              controller: _turkishCtrl,
              decoration: InputDecoration(
                labelText: 'Turkish word *',
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
                        tooltip: 'Analyse morphology',
                        onPressed: _analyze,
                      ),
              ),
              onFieldSubmitted: (_) => _analyze(),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // ── Root / lemma ──────────────────────────────────────────────
            TextFormField(
              controller: _rootCtrl,
              decoration: const InputDecoration(
                labelText: 'Root / lemma',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Suffixes ──────────────────────────────────────────────────
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
                    onPressed: () => _showAddSuffixDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add suffix'),
                onPressed: () => _showAddSuffixDialog(),
              ),
              const SizedBox(height: 16),
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
            // Hint about what Save will do
            if (_rootCtrl.text.isNotEmpty || _suffixes.isNotEmpty)
              Text(
                'Saving will also auto-translate & add the root'
                '${_suffixes.isNotEmpty ? ' and ${_suffixes.length} suffix${_suffixes.length == 1 ? '' : 'es'}' : ''} as separate words.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
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
          decoration:
              const InputDecoration(labelText: 'Suffix morpheme id'),
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
