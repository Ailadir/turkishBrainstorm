import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/word_repository.dart';
import '../../providers/providers.dart';
import 'add_word_screen.dart';
import 'browse_screen.dart';
import 'review_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final dueAsync = ref.watch(dueQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turkish Vocab'),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _StatCards(stats: stats),
            const SizedBox(height: 24),
            dueAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, st) => const SizedBox.shrink(),
              data: (queue) => FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  queue.isEmpty
                      ? 'No cards due'
                      : 'Start review (${queue.length} due)',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: queue.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReviewScreen()),
                        ).then((_) {
                          ref.invalidate(dueQueueProvider);
                          ref.invalidate(statsProvider);
                        }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('Browse'),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const BrowseScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Stats'),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const StatsScreen())),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add word'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddWordScreen()),
        ).then((_) {
          ref.invalidate(statsProvider);
          ref.invalidate(dueQueueProvider);
        }),
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  final VocabStats stats;
  const _StatCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final mastery = (stats.averageMastery * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Card('Words', '${stats.totalWords}', Icons.book),
            const SizedBox(width: 12),
            _Card('Due now', '${stats.dueNow}', Icons.schedule),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Card('Reviewed today', '${stats.reviewsToday}', Icons.check),
            const SizedBox(width: 12),
            _Card('Avg mastery', '$mastery%', Icons.trending_up),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: stats.averageMastery,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Card(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        color: cs.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
