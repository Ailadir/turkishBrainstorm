import 'package:flutter/services.dart';

/// Result of a morphological analysis.
class MorphologyResult {
  final String root;
  final List<String> suffixes;
  const MorphologyResult(this.root, this.suffixes);
}

/// Bridge to the Kotlin/Zemberek side (build plan §5). Exposed as a single
/// `analyze` method over `MethodChannel("turkish_morphology")`.
///
/// Falls back to a naive no-op split (root = whole word, no suffixes) if the
/// native side isn't wired up yet or throws — Zemberek isn't bundled until
/// the Android jar + Kotlin bridge are added, so the app must still run and
/// let the user save words (editing the split by hand) in the meantime.
class MorphologyService {
  static const MethodChannel _channel =
      MethodChannel('turkish_morphology');

  Future<MorphologyResult> analyze(String word) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'analyze',
        {'word': word},
      );
      if (result == null) return _fallback(word);
      final root = result['root'] as String? ?? word;
      final suffixes = (result['suffixes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      return MorphologyResult(root, suffixes);
    } on PlatformException catch (_) {
      return _fallback(word);
    } on MissingPluginException catch (_) {
      // Native bridge not implemented yet (e.g. jar not bundled).
      return _fallback(word);
    }
  }

  MorphologyResult _fallback(String word) => MorphologyResult(word, const []);
}
