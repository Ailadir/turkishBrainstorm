import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/word_repository.dart';
import '../../domain/morpheme_ref.dart';
import '../../providers/providers.dart';
import '../widgets/breakdown_view.dart';

class WordEditScreen extends ConsumerStatefulWidget {
  final Word word;
  const WordEditScreen({super.key, required this.word});

  @override
  ConsumerState<WordEditScreen> createState() => _WordEditScreenState();
}

class _WordEditScreenState extends ConsumerState<WordEditScreen> {
  late final _turkishCtrl = TextEditingController(text: widget.word.turkish);
  late final _englishCtrl = TextEditingController(text: widget.word.english);
  late final _rootCtrl = TextEditingController(text: widget.word.lemma ?? '');
  late final _noteCtrl = TextEditingController(text: widget.word.note ?? '');
  late final _sourceCtrl = TextEditingController(
    text: widget.word.source ?? '',
  );
  bool _saving = false;
  late List<MorphemeRef> _morphemes = widget.word.morphemeRefs;

  @override
  void dispose() {
    _turkishCtrl.dispose();
    _englishCtrl.dispose();
    _rootCtrl.dispose();
    _noteCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(wordRepositoryProvider)
          .updateWordFields(
            wordId: widget.word.id,
            turkish: _turkishCtrl.text.trim(),
            english: _englishCtrl.text.trim(),
            lemma: _rootCtrl.text.trim(),
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            source: _sourceCtrl.text.trim().isEmpty
                ? null
                : _sourceCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete word?'),
        content: Text('Delete "${widget.word.turkish}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(wordRepositoryProvider).deleteWord(widget.word.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _reanalyze() async {
    final r = await ref
        .read(morphologyServiceProvider)
        .analyze(_turkishCtrl.text.trim());
    await ref
        .read(wordRepositoryProvider)
        .applyAnalysis(
          widget.word.id,
          lemma: r.lemma,
          pos: r.pos,
          morphemes: r.morphemes,
        );
    if (!mounted) return;
    setState(() {
      _rootCtrl.text = r.lemma;
      _morphemes = r.morphemes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit word'),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
          if (_saving)
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _turkishCtrl,
            decoration: InputDecoration(
              labelText: 'Turkish',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.auto_fix_high),
                tooltip: 'Re-analyze morphology',
                onPressed: _reanalyze,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rootCtrl,
            decoration: const InputDecoration(
              labelText: 'Root / lemma',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _englishCtrl,
            decoration: const InputDecoration(
              labelText: 'English',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note / example',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sourceCtrl,
            decoration: const InputDecoration(
              labelText: 'Source',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          BreakdownView(lemma: _rootCtrl.text, morphemes: _morphemes),
          TextButton.icon(
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Re-analyze'),
            onPressed: _reanalyze,
          ),
        ],
      ),
    );
  }
}
