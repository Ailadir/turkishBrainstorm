import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/word_repository.dart';
import '../../providers/providers.dart';
import 'add_word_screen.dart';
import 'browse_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, SessionKind kind) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SessionScreen(kind: kind)),
    ).then((_) => ref.invalidate(statsProvider));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turkish Vocab'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _StatCards(stats: stats),
            const SizedBox(height: 24),
            _SessionButton(
              icon: Icons.bolt,
              label: 'Brainstorm (${stats.newCount} new)',
              enabled: stats.newCount > 0,
              primary: true,
              onPressed: () => _open(context, ref, SessionKind.brainstorm),
            ),
            const SizedBox(height: 12),
            _SessionButton(
              icon: Icons.replay,
              label: 'Review (${stats.dueNow} due)',
              enabled: stats.dueNow > 0,
              primary: false,
              onPressed: () => _open(context, ref, SessionKind.review),
            ),
            if (stats.totalWords == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Add words to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (stats.newCount == 0 && stats.dueNow == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'All caught up. Add more words or come back later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
        ).then((_) => ref.invalidate(statsProvider)),
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

class _SessionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool primary;
  final VoidCallback onPressed;
  const _SessionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = const Size.fromHeight(56);
    final cb = enabled ? onPressed : null;
    return primary
        ? FilledButton.icon(
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(minimumSize: size),
            onPressed: cb)
        : FilledButton.tonalIcon(
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(minimumSize: size),
            onPressed: cb);
  }
}
