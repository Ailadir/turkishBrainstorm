import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/providers.dart';

// ── Pre-configured ElevenLabs voices (multilingual_v2 compatible) ─────────────
class _Voice {
  final String id;
  final String name;
  final bool isMale;
  const _Voice(this.id, this.name, {required this.isMale});
}

const _voices = [
  _Voice('pNInz6obpgDQGcFmaJgB', 'Adam', isMale: true),
  _Voice('ErXwobaYiN019PkySvjV', 'Antoni', isMale: true),
  _Voice('TxGEqnHWrfWFTfGW9XjX', 'Josh', isMale: true),
  _Voice('VR6AewLTigWG4xSOukaG', 'Arnold', isMale: true),
  _Voice('21m00Tcm4TlvDq8ikWAM', 'Rachel', isMale: false),
  _Voice('AZnzlk1XvdvUeBnXmlld', 'Domi', isMale: false),
  _Voice('EXAVITQu4vr4xnSDxMaL', 'Bella', isMale: false),
  _Voice('MF3mGyEYCl7XYWbV9V6O', 'Elli', isMale: false),
];

const _customVoiceId = '__custom__';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _elKeyCtrl;
  late TextEditingController _customVoiceCtrl;
  late TextEditingController _geminiKeyCtrl;
  bool _obscureElKey = true;
  bool _obscureGeminiKey = true;
  String _selectedVoiceId = '';  // preset voice id or __custom__

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _elKeyCtrl = TextEditingController(text: settings.elevenLabsApiKey ?? '');
    _geminiKeyCtrl = TextEditingController(text: settings.geminiApiKey ?? '');

    final savedId = settings.elevenLabsVoiceId ?? '';
    final isPreset = _voices.any((v) => v.id == savedId);
    _selectedVoiceId = isPreset ? savedId : (savedId.isEmpty ? '' : _customVoiceId);
    _customVoiceCtrl = TextEditingController(
      text: isPreset || savedId.isEmpty ? '' : savedId,
    );
  }

  @override
  void dispose() {
    _elKeyCtrl.dispose();
    _customVoiceCtrl.dispose();
    _geminiKeyCtrl.dispose();
    super.dispose();
  }

  String get _effectiveVoiceId => _selectedVoiceId == _customVoiceId
      ? _customVoiceCtrl.text.trim()
      : _selectedVoiceId;

  Future<void> _save() async {
    final settings = ref.read(settingsServiceProvider);
    await settings.setElevenLabsApiKey(_elKeyCtrl.text.trim());
    await settings.setElevenLabsVoiceId(_effectiveVoiceId);
    await settings.setGeminiApiKey(_geminiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  Future<void> _testVoice() async {
    await _save();
    ref.read(ttsServiceProvider).speak('Merhaba, nasılsın?');
  }

  Future<void> _testGemini() async {
    await _save();
    final gemini = ref.read(geminiServiceProvider);
    if (!gemini.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter and save a Gemini API key first')));
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Testing Gemini...')));
    }
    final result = await gemini.testTranslation('gitmek');
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gemini test result'),
          content: SelectableText(result),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _clearAudioCache() async {
    final docs = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(docs.path, 'tts_cache'));
    int count = 0;
    if (await cacheDir.exists()) {
      count = cacheDir.listSync().whereType<File>().length;
      await cacheDir.delete(recursive: true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Cleared $count cached audio clip${count == 1 ? '' : 's'}'),
      ));
    }
  }

  Future<void> _clearDictionary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear dictionary?'),
        content: const Text(
            'This will permanently delete ALL words, practice history, and review '
            'data. Audio cache is kept. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(wordRepositoryProvider).deleteAllWords();
    ref.invalidate(statsProvider);
    ref.invalidate(dueQueueProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dictionary cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── Gemini AI Translation ─────────────────────────────────────────
          Text('Gemini AI Translation', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Used to translate Turkish roots and grammatical suffixes. '
            'Get a free API key at aistudio.google.com → "Get API key". '
            'Free tier: 1 500 requests/day.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _geminiKeyCtrl,
            obscureText: _obscureGeminiKey,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureGeminiKey
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscureGeminiKey = !_obscureGeminiKey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.science_outlined),
            label: const Text('Test Gemini translation'),
            onPressed: _testGemini,
          ),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),

          // ── ElevenLabs TTS ────────────────────────────────────────────────
          Text('ElevenLabs TTS', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Free tier: 10 000 characters/month. Sign up at elevenlabs.io. '
            'Each word is fetched once then cached for offline playback.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _elKeyCtrl,
            obscureText: _obscureElKey,
            decoration: InputDecoration(
              labelText: 'ElevenLabs API Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureElKey
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscureElKey = !_obscureElKey),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Voice selector ──────────────────────────────────────────────────
          Text('Voice', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text('Male voices', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _voices
                .where((v) => v.isMale)
                .map((v) => _VoiceChip(
                      voice: v,
                      selected: _selectedVoiceId == v.id,
                      onTap: () => setState(() => _selectedVoiceId = v.id),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Text('Female voices', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _voices
                .where((v) => !v.isMale)
                .map((v) => _VoiceChip(
                      voice: v,
                      selected: _selectedVoiceId == v.id,
                      onTap: () => setState(() => _selectedVoiceId = v.id),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          ChoiceChip(
            label: const Text('Custom voice ID'),
            selected: _selectedVoiceId == _customVoiceId,
            onSelected: (_) =>
                setState(() => _selectedVoiceId = _customVoiceId),
          ),
          if (_selectedVoiceId == _customVoiceId) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customVoiceCtrl,
              decoration: const InputDecoration(
                labelText: 'Voice ID',
                hintText: 'Paste ElevenLabs voice ID here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),

          // ── Storage ───────────────────────────────────────────────────────
          Text('Storage', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Audio clips are saved locally — each word is only ever downloaded '
            'once. Clear the cache to free space (clips will re-download on next play).',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear audio cache'),
            onPressed: _clearAudioCache,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: Icon(Icons.delete_forever, color: cs.error),
            label: Text('Clear dictionary (delete all words)',
                style: TextStyle(color: cs.error)),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.error)),
            onPressed: _clearDictionary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VoiceChip extends StatelessWidget {
  final _Voice voice;
  final bool selected;
  final VoidCallback onTap;
  const _VoiceChip(
      {required this.voice, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(voice.name),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
