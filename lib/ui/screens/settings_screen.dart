import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _keyCtrl;
  late TextEditingController _voiceCtrl;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _keyCtrl = TextEditingController(text: settings.elevenLabsApiKey ?? '');
    _voiceCtrl =
        TextEditingController(text: settings.elevenLabsVoiceId ?? '');
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _voiceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = ref.read(settingsServiceProvider);
    await settings.setElevenLabsApiKey(_keyCtrl.text.trim());
    await settings.setElevenLabsVoiceId(_voiceCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _testVoice() async {
    await _save(); // persist first so the TTS service picks up the new key
    ref.read(ttsServiceProvider).speak('Merhaba');
  }

  Future<void> _clearCache() async {
    final docs = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(docs.path, 'tts_cache'));
    int count = 0;
    if (await cacheDir.exists()) {
      count = cacheDir.listSync().whereType<File>().length;
      await cacheDir.delete(recursive: true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Cleared $count cached audio clip${count == 1 ? '' : 's'}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── ElevenLabs section ────────────────────────────────────────────
          Text('ElevenLabs TTS', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Sign up at elevenlabs.io for a free account (10,000 characters/month). '
            'Find the Voice ID under Voices → click a voice → copy the ID shown in '
            'the voice info panel. Each Turkish word is fetched once then stored '
            'permanently — replays are free and work offline.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              labelText: 'API Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureKey ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voiceCtrl,
            decoration: const InputDecoration(
              labelText: 'Voice ID',
              hintText: 'e.g. pNInz6obpgDQGcFmaJgB',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Test voice'),
                  onPressed: _testVoice,
                ),
              ),
            ],
          ),

          // ── Audio cache section ───────────────────────────────────────────
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),
          Text('Audio cache', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'MP3 clips are saved in your app storage. Each word is only ever '
            'downloaded once — tap the button below to free up space if needed.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear audio cache'),
            onPressed: _clearCache,
          ),
        ],
      ),
    );
  }
}
