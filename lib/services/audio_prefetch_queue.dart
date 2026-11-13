import 'dart:async';

import 'tts_service.dart';

/// Generates audio ahead of time, one word at a time, failing quietly.
/// Which voice is used (ElevenLabs for your own words, Piper for pack words)
/// is decided by [TtsService]; this only keeps the work off the critical path.
class AudioPrefetchQueue {
  final TtsService tts;
  final List<String> _pending = [];
  final Set<String> _queued = {};
  bool _running = false;

  AudioPrefetchQueue(this.tts);

  int get pending => _pending.length;

  void enqueue(Iterable<String> texts) {
    for (final t in texts) {
      final text = t.trim();
      if (text.isEmpty || !_queued.add(text)) continue;
      _pending.add(text);
    }
    if (!_running) unawaited(_drain());
  }

  Future<void> _drain() async {
    _running = true;
    try {
      while (_pending.isNotEmpty) {
        final text = _pending.removeAt(0);
        try {
          await tts.prefetch(text);
        } catch (_) {
          // Best effort only.
        }
        _queued.remove(text);
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    } finally {
      _running = false;
    }
  }
}
