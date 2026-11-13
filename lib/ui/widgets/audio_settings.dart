import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../services/piper_engine.dart';
import '../../services/tts_service.dart';

/// Settings block for audio: offline voice, ElevenLabs model/quota, and
/// bulk audio generation for your own words.
class AudioSettings extends ConsumerStatefulWidget {
  const AudioSettings({super.key});

  @override
  ConsumerState<AudioSettings> createState() => _AudioSettingsState();
}

class _AudioSettingsState extends ConsumerState<AudioSettings> {
  bool? _installed;
  double? _progress; // non-null while downloading
  String? _quotaText;
  late final TextEditingController _modelCtrl;

  @override
  void initState() {
    super.initState();
    _modelCtrl = TextEditingController(
      text: ref.read(settingsServiceProvider).elevenLabsModel,
    );
    _refresh();
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final s = ref.read(settingsServiceProvider);
    final installed = await ref
        .read(piperEngineProvider)
        .isInstalled(s.piperVoice);
    String? quota;
    if (s.hasElevenLabs) {
      final q = await ElevenLabsVoice(s).quota();
      if (q != null) {
        quota = '${q.limit - q.used} of ${q.limit} characters left';
      }
    }
    if (!mounted) return;
    setState(() {
      _installed = installed;
      _quotaText = quota;
    });
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _download() async {
    final s = ref.read(settingsServiceProvider);
    setState(() => _progress = 0);
    try {
      await ref
          .read(piperEngineProvider)
          .download(
            s.piperVoice,
            onProgress: (f) {
              if (mounted) setState(() => _progress = f);
            },
          );
      _toast('Offline voice installed');
    } catch (e) {
      _toast('Download failed: $e');
    } finally {
      if (mounted) setState(() => _progress = null);
      await _refresh();
    }
  }

  Future<void> _delete() async {
    await ref
        .read(piperEngineProvider)
        .delete(ref.read(settingsServiceProvider).piperVoice);
    await _refresh();
  }

  Future<void> _bulk() async {
    final repo = ref.read(wordRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final s = ref.read(settingsServiceProvider);
    final texts = await repo.ownWordTexts();
    if (texts.isEmpty) {
      _toast("You haven't added any words of your own yet");
      return;
    }
    final missing = <String>[];
    for (final t in texts) {
      if (!await tts.isCached(t)) missing.add(t);
    }
    if (missing.isEmpty) {
      _toast('All your words already have audio');
      return;
    }
    final chars = missing.fold<int>(0, (n, t) => n + t.length);
    final cloud = s.hasElevenLabs;
    final quota = cloud ? await ElevenLabsVoice(s).quota() : null;
    final left = quota == null ? null : quota.limit - quota.used;
    final enough = left == null || chars <= left;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download audio for my words'),
        content: Text(
          '${missing.length} words need audio ($chars characters).'
          '${cloud ? (left == null ? '\nElevenLabs quota unknown.' : '\nElevenLabs has $left characters left.${enough ? '' : ' Not enough: the rest will use the offline voice if installed.'}') : '\nNo ElevenLabs key: the offline voice is used.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(audioPrefetchProvider).enqueue(missing);
      _toast('Generating in the background');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.read(settingsServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speech speed', style: theme.textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: s.speechSpeed,
                min: 0.5,
                max: 1.0,
                divisions: 10,
                label: '${s.speechSpeed.toStringAsFixed(2)}×',
                onChanged: (v) {
                  s.setSpeechSpeed(v);
                  setState(() {});
                },
                onChangeEnd: (_) =>
                    ref.read(ttsServiceProvider).speak('Merhaba, nasılsın?'),
              ),
            ),
            Text('${s.speechSpeed.toStringAsFixed(2)}×'),
          ],
        ),
        const SizedBox(height: 12),
        Text('Offline voice', style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'A Turkish voice that works without internet or Google services. '
          'About 65 MB, downloaded once from GitHub.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Text('Voice')),
            DropdownButton<String>(
              value: s.piperVoice,
              items: [
                for (final e in piperVoices.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: _progress != null
                  ? null
                  : (v) async {
                      if (v == null) return;
                      await s.setPiperVoice(v);
                      await _refresh();
                    },
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (_progress != null)
          LinearProgressIndicator(value: _progress)
        else if (_installed == true)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              const Text('Installed'),
              const Spacer(),
              TextButton(onPressed: _delete, child: const Text('Delete')),
              TextButton(
                onPressed: () => ref
                    .read(ttsServiceProvider)
                    .speak('Merhaba, nasılsın?')
                    .then(
                      (o) => _toast(
                        o.ok
                            ? 'Played via ${o.via}'
                            : 'No sound: ${ref.read(piperEngineProvider).lastError ?? o.problem}',
                      ),
                    ),
                child: const Text('Test'),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Download offline voice (~65 MB)'),
            onPressed: _installed == null ? null : _download,
          ),
        const SizedBox(height: 20),
        Text('ElevenLabs options', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _modelCtrl,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Model (eleven_multilingual_v2, eleven_flash_v2_5…)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (v) {
            if (v.trim().isNotEmpty) s.setElevenLabsModel(v.trim());
          },
        ),
        if (_quotaText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_quotaText!, style: theme.textTheme.bodySmall),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Use ElevenLabs for pack words too'),
          subtitle: const Text('Off: pack words use the offline voice'),
          value: s.elevenLabsForPackWords,
          onChanged: (v) async {
            await s.setElevenLabsForPackWords(v);
            setState(() {});
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.cloud_download_outlined),
          label: const Text('Download audio for my words'),
          onPressed: _bulk,
        ),
      ],
    );
  }
}
