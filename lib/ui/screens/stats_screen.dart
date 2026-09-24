import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/practice_mode.dart';
import '../../providers/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final repo = ref.read(wordRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => FutureBuilder(
          future: repo.dueCountByMode(),
          builder: (ctx, snap) {
            final byMode = snap.data ?? {};
            final mastery = (stats.averageMastery * 100).round();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Section('Overview', [
                  _Row('Total words', '${stats.totalWords}'),
                  _Row('Cards due now', '${stats.dueNow}'),
                  _Row('Reviewed today', '${stats.reviewsToday}'),
                  _Row('Average mastery', '$mastery%'),
                ]),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LinearProgressIndicator(
                    value: stats.averageMastery,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 24),
                _Section('Due by mode', [
                  for (final mode in PracticeMode.values)
                    _Row(mode.label, '${byMode[mode] ?? 0}'),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _Section(this.title, this.rows);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
