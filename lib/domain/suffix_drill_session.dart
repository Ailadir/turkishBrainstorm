import 'dart:math';

import 'morpheme_ref.dart';
import 'suffix_glosses.dart';

/// One word that shows a suffix: from the user's own words or a grammar pack.
class DrillExample {
  final String word;
  final String english;
  final bool own;

  /// Zemberek lemma and suffix parts when known (own words); pack examples
  /// are resolved by the screen before display.
  final String? lemma;
  final List<MorphemeRef> parts;
  const DrillExample({
    required this.word,
    required this.english,
    this.own = false,
    this.lemma,
    this.parts = const [],
  });
}

/// A suffix that can be drilled, with its scheduling state.
class DrillCandidate {
  final String id;
  final int repetitions;
  final DateTime? dueAt;
  final bool isNew;
  final List<DrillExample> examples;
  const DrillCandidate({
    required this.id,
    required this.examples,
    this.repetitions = 0,
    this.dueAt,
    this.isNew = true,
  });

  SuffixInfo get info => suffixInfo(id);
  bool isDue(DateTime now) => !isNew && (dueAt == null || !dueAt!.isAfter(now));
}

class DrillQuestion {
  final String morphemeId;
  final DrillExample example;
  final List<String> options;
  final String answer;
  final bool isReask;
  const DrillQuestion({
    required this.morphemeId,
    required this.example,
    required this.options,
    required this.answer,
    this.isReask = false,
  });
}

/// A piece of the example word, for the highlighted display `ev·ler·imiz·de`.
typedef DrillSegment = ({String text, bool highlighted});

/// Splits an example into root + suffix segments, highlighting [targetId].
/// Without a usable analysis the whole word is one plain segment.
List<DrillSegment> segmentsFor(
  String word,
  String? lemma,
  List<MorphemeRef> parts,
  String targetId,
) {
  if (parts.isEmpty || !parts.any((p) => p.id == targetId)) {
    return [(text: word, highlighted: false)];
  }
  final suffixLength = parts.fold<int>(0, (n, p) => n + p.surface.length);
  final rootLength = word.length - suffixLength;
  if (rootLength < 1) return [(text: word, highlighted: false)];
  var pos = rootLength;
  return [
    (text: word.substring(0, rootLength), highlighted: false),
    for (final p in parts)
      (
        text: word.substring(pos, pos += p.surface.length),
        highlighted: p.id == targetId,
      ),
  ];
}

/// Ten-question suffix drill: due suffixes first, then up to [maxNew] new ones
/// (lowest level first). A wrong answer is asked once more at the end.
class SuffixDrillSession {
  final Random _rng;
  final List<DrillCandidate> _all;
  final List<DrillCandidate> _plan;
  final Map<String, DrillExample> _lastExample = {};
  final List<DrillCandidate> _reasks = [];
  final Set<String> _reasked = {};
  int _index = 0;
  DrillCandidate? _current;
  bool _currentIsReask = false;

  /// Number of planned first-time questions (re-asks come on top).
  int get total => _plan.length;

  SuffixDrillSession({
    required List<DrillCandidate> candidates,
    DateTime? now,
    int maxQuestions = 10,
    int maxNew = 3,
    Random? rng,
  }) : _rng = rng ?? Random(),
       _all = candidates,
       _plan = _select(
         candidates.where((c) => c.examples.isNotEmpty).toList(),
         now ?? DateTime.now(),
         maxQuestions,
         maxNew,
       );

  static List<DrillCandidate> _select(
    List<DrillCandidate> usable,
    DateTime now,
    int maxQuestions,
    int maxNew,
  ) {
    final due = usable.where((c) => c.isDue(now)).toList()
      ..sort((a, b) => (a.dueAt ?? now).compareTo(b.dueAt ?? now));
    final fresh = usable.where((c) => c.isNew).toList()
      ..sort((a, b) {
        final byLevel = cefrLevels
            .indexOf(a.info.level)
            .compareTo(cefrLevels.indexOf(b.info.level));
        return byLevel != 0 ? byLevel : a.id.compareTo(b.id);
      });
    return [
      ...due.take(maxQuestions),
      ...fresh.take(maxNew),
    ].take(maxQuestions).toList();
  }

  bool get isDone => _index >= _plan.length && _reasks.isEmpty;

  /// The next question, or null when finished.
  DrillQuestion? next() {
    final DrillCandidate c;
    final bool reask;
    if (_index < _plan.length) {
      c = _plan[_index++];
      reask = false;
    } else if (_reasks.isNotEmpty) {
      c = _reasks.removeAt(0);
      reask = true;
    } else {
      return null;
    }
    _current = c;
    _currentIsReask = reask;
    final example = _pickExample(c);
    _lastExample[c.id] = example;
    final options = _options(c.id);
    return DrillQuestion(
      morphemeId: c.id,
      example: example,
      options: options,
      answer: c.info.gloss,
      isReask: reask,
    );
  }

  /// Record the answer to the question last returned by [next]. Returns true
  /// when this answer should be scheduled (a re-ask is practice only).
  bool answer({required bool correct}) {
    final c = _current;
    if (c == null) return false;
    if (!correct && !_currentIsReask && _reasked.add(c.id)) _reasks.add(c);
    return !_currentIsReask;
  }

  DrillExample _pickExample(DrillCandidate c) {
    final own = c.examples.where((e) => e.own).toList();
    final pool = own.isNotEmpty ? own : c.examples;
    final last = _lastExample[c.id];
    final fresh = pool.where((e) => e.word != last?.word).toList();
    final from = fresh.isNotEmpty ? fresh : pool;
    return from[_rng.nextInt(from.length)];
  }

  List<String> _options(String id) {
    final target = suffixInfo(id);
    bool usable(MapEntry<String, SuffixInfo> e) =>
        e.key != id && e.value.gloss != target.gloss;
    final others = suffixGlosses.entries.where(usable).toList();
    final same =
        others.where((e) => e.value.category == target.category).toList()
          ..shuffle(_rng);
    final rest =
        others.where((e) => e.value.category != target.category).toList()
          ..shuffle(_rng);
    final picked = <String>[];
    for (final e in [...same, ...rest]) {
      if (picked.length == 3) break;
      if (!picked.contains(e.value.gloss)) picked.add(e.value.gloss);
    }
    return [...picked, target.gloss]..shuffle(_rng);
  }

  /// All candidates, for callers that need level progress.
  List<DrillCandidate> get candidates => _all;
}
