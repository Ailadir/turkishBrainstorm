import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'word_edit_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(wordSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search words…',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (words) => words.isEmpty
            ? const Center(child: Text('No words yet — add some!'))
            : ListView.builder(
                itemCount: words.length,
                itemBuilder: (ctx, i) {
                  final word = words[i];
                  return FutureBuilder(
                    future: ref.read(wordRepositoryProvider).withMastery(word),
                    builder: (ctx, snap) {
                      final mastery = snap.data?.mastery ?? 0;
                      final pct = (mastery * 100).round();
                      return ListTile(
                        title: Text(word.turkish,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(word.english),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$pct%',
                                style: TextStyle(
                                  color: _masteryColor(mastery),
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: LinearProgressIndicator(
                                value: mastery,
                                color: _masteryColor(mastery),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordEditScreen(word: word),
                          ),
                        ).then((_) {
                          ref.invalidate(wordSearchProvider(_query));
                          ref.invalidate(statsProvider);
                        }),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Color _masteryColor(double m) {
    if (m >= 0.8) return Colors.green;
    if (m >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
