import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pack_repository.dart';
import '../../domain/pack.dart';
import '../../providers/providers.dart';

class PacksScreen extends ConsumerStatefulWidget {
  const PacksScreen({super.key});

  @override
  ConsumerState<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends ConsumerState<PacksScreen> {
  List<InstalledPack> _installed = [];
  List<PackIndexEntry> _available = [];
  String? _offlineMessage;
  bool _loading = true;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(packRepositoryProvider);
    final service = ref.read(packServiceProvider);
    final installed = await repo.installed();
    var available = <PackIndexEntry>[];
    String? message;
    if (!service.hasRemote) {
      message = 'No pack server is set up yet. You can still import a file.';
    } else {
      try {
        available = await service.fetchIndex();
      } catch (_) {
        message = 'Offline: showing installed packs only.';
      }
    }
    if (!mounted) return;
    setState(() {
      _installed = installed;
      _available = available;
      _offlineMessage = message;
      _loading = false;
    });
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _run(String id, Future<String> Function() action) async {
    setState(() => _busyId = id);
    try {
      _toast(await action());
    } on PackFormatException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Failed: $e');
    } finally {
      ref.read(analysisJobProvider).run().ignore();
      ref.invalidate(statsProvider);
      if (mounted) setState(() => _busyId = null);
      await _load();
    }
  }

  Future<void> _remove(InstalledPack p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${p.pack.title}"?'),
        content: const Text(
          'Words you never studied are deleted. Words you have started '
          'learning stay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(p.pack.id, () async {
      final n = await ref.read(packRepositoryProvider).remove(p.pack.id);
      return 'Removed ($n unused words deleted)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(packServiceProvider);
    final installedIds = {
      for (final p in _installed) p.pack.id: p.pack.version,
    };
    final todo = _available.where((e) {
      final v = installedIds[e.id];
      return v == null || v < e.version;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Word packs')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_offlineMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _offlineMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Text(
                  'Installed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_installed.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing installed yet.'),
                  ),
                for (final p in _installed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.pack.title),
                    subtitle: Text(
                      p.pack.kind == 'words'
                          ? '${p.pack.level ?? ''} · ${p.wordCount} words · ${p.learned} started'
                          : '${p.pack.level ?? ''} · ${p.wordCount} examples',
                    ),
                    trailing: _busyId == p.pack.id
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Remove',
                            onPressed: () => _remove(p),
                          ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (todo.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nothing new to download.'),
                  ),
                for (final e in todo)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.title),
                    subtitle: Text(
                      '${e.level ?? ''} · ${e.count} '
                      '${e.kind == 'words' ? 'words' : 'suffixes'} · '
                      '${(e.size / 1024).round()} KB'
                      '${installedIds.containsKey(e.id) ? ' · update' : ''}',
                    ),
                    trailing: _busyId == e.id
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.download),
                            tooltip: installedIds.containsKey(e.id)
                                ? 'Update'
                                : 'Download',
                            onPressed: () => _run(e.id, () async {
                              final r = await service.download(e);
                              return '${e.title}: ${r.added} added';
                            }),
                          ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Import from file'),
                  onPressed: () => _run('file', () async {
                    final p = await service.importFromFile();
                    return p == null ? 'Cancelled' : 'Imported ${p.title}';
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  'Word data: Wiktionary via kaikki.org (CC BY-SA 4.0). '
                  'Frequencies: FrequencyWords / OpenSubtitles. Levels are '
                  'approximate (by how common a word is).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
