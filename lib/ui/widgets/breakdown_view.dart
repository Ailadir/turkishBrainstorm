import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/morpheme_ref.dart';
import '../../domain/suffix_glosses.dart';
import '../../providers/providers.dart';

/// Root chip followed by suffix chips joined with `·`, with a gloss under
/// each: `ev · ler · imiz · de` / `house · plural · our · in`.
/// Renders nothing when the word has no suffixes.
class BreakdownView extends ConsumerWidget {
  final String? lemma;
  final List<MorphemeRef> morphemes;

  const BreakdownView({super.key, this.lemma, required this.morphemes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (morphemes.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // English meaning of the root from the offline dictionary, if it has one.
    final rootGloss = (lemma == null || lemma!.isEmpty)
        ? null
        : ref.watch(rootGlossProvider(lemma!)).value;

    Widget cell(String text, String caption, {bool root = false}) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: root ? cs.primaryContainer : cs.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );

    final items = <Widget>[
      if (lemma != null && lemma!.isNotEmpty)
        cell(lemma!, rootGloss ?? 'root', root: true),
      for (final m in morphemes) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text('·', style: theme.textTheme.titleLarge),
        ),
        cell(m.surface, suffixInfo(m.id).label),
      ],
    ];
    // Drop the leading separator when there is no root chip.
    if (lemma == null || lemma!.isEmpty) items.removeAt(0);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 6,
      runSpacing: 8,
      children: items,
    );
  }
}
