import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/mastery.dart';
import '../../domain/suffix_drill_session.dart';
import '../../domain/suffix_glosses.dart';
import '../../providers/providers.dart';

/// Every suffix by CEFR level, with gloss, example count and progress.
class SuffixListScreen extends ConsumerWidget {
  const SuffixListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final future = ref.watch(morphemeRepositoryProvider).candidates('B2');
    return Scaffold(
      appBar: AppBar(title: const Text('Suffixes')),
      body: FutureBuilder<List<DrillCandidate>>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final byId = {for (final c in snap.data!) c.id: c};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final level in cefrLevels) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(level, style: theme.textTheme.titleLarge),
                ),
                for (final e in suffixGlosses.entries.where(
                  (e) => e.value.level == level,
                ))
                  _row(theme, e.key, e.value, byId[e.key]),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(ThemeData theme, String id, SuffixInfo info, DrillCandidate? c) {
    final mastery = c == null || c.isNew
        ? 0.0
        : Mastery.ofWord(status: 'review', repetitions: c.repetitions);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(info.gloss),
      subtitle: Text(
        '${info.category} · ${c == null ? 'no examples yet' : '${c.examples.length} examples'}'
        '${c != null && c.examples.isNotEmpty ? '  e.g. ${c.examples.first.word}' : ''}',
      ),
      trailing: SizedBox(
        width: 56,
        child: LinearProgressIndicator(
          value: mastery,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
