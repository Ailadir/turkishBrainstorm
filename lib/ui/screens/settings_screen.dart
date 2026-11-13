import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../config.dart';
import '../../providers/providers.dart';
import '../../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../widgets/audio_settings.dart';
import 'packs_screen.dart';

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
  late TextEditingController _geminiModelCtrl;
  late TextEditingController _groqKeyCtrl;
  late TextEditingController _groqModelCtrl;
  late TextEditingController _orKeyCtrl;
  late TextEditingController _orModelCtrl;
  bool _obscureElKey = true;
  bool _obscureGeminiKey = true;
  bool _obscureGroqKey = true;
  bool _obscureOrKey = true;
  String _selectedVoiceId = ''; // preset voice id or __custom__

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _elKeyCtrl = TextEditingController(text: settings.elevenLabsApiKey ?? '');
    _geminiKeyCtrl = TextEditingController(text: settings.geminiApiKey ?? '');
    _geminiModelCtrl = TextEditingController(text: settings.geminiModel);
    _groqKeyCtrl = TextEditingController(text: settings.groqApiKey ?? '');
    _groqModelCtrl = TextEditingController(text: settings.groqModel);
    _orKeyCtrl = TextEditingController(text: settings.openRouterApiKey ?? '');
    _orModelCtrl = TextEditingController(text: settings.openRouterModel);

    final savedId = settings.elevenLabsVoiceId ?? '';
    final isPreset = _voices.any((v) => v.id == savedId);
    _selectedVoiceId = isPreset
        ? savedId
        : (savedId.isEmpty ? '' : _customVoiceId);
    _customVoiceCtrl = TextEditingController(
      text: isPreset || savedId.isEmpty ? '' : savedId,
    );
  }

  @override
  void dispose() {
    _elKeyCtrl.dispose();
    _customVoiceCtrl.dispose();
    _geminiKeyCtrl.dispose();
    _geminiModelCtrl.dispose();
    _groqKeyCtrl.dispose();
    _groqModelCtrl.dispose();
    _orKeyCtrl.dispose();
    _orModelCtrl.dispose();
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
    await settings.setGeminiModel(
      _orDefault(_geminiModelCtrl, 'gemini-3.8-flash'),
    );
    await settings.setGroqApiKey(_groqKeyCtrl.text.trim());
    await settings.setGroqModel(
      _orDefault(_groqModelCtrl, 'llama-3.3-70b-versatile'),
    );
    await settings.setOpenRouterApiKey(_orKeyCtrl.text.trim());
    await settings.setOpenRouterModel(
      _orDefault(_orModelCtrl, 'openrouter/free'),
    );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  Widget _keyField(
    TextEditingController c,
    String label,
    bool obscure,
    VoidCallback toggle,
  ) => TextField(
    controller: c,
    obscureText: obscure,
    autocorrect: false,
    enableSuggestions: false,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: toggle,
      ),
    ),
  );

  Widget _modelField(TextEditingController c, String label) => TextField(
    controller: c,
    autocorrect: false,
    enableSuggestions: false,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
  );

  String _orDefault(TextEditingController c, String fallback) =>
      c.text.trim().isEmpty ? fallback : c.text.trim();

  Future<void> _testVoice() async {
    await _save();
    ref.read(ttsServiceProvider).speak('Merhaba, nasılsın?');
  }

  Future<void> _checkUpdates() async {
    final service = ref.read(updateServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Always checks; ignores "dismissed" so a closed alert can be reopened.
      final info = await service.checkLatest();
      if (!mounted) return;
      if (info == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text("You're up to date")),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (_) => UpdateDialog(
          info: info,
          service: service,
          installer: ref.read(appInstallerProvider),
        ),
      );
    } on UpdateException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _testAi() async {
    await _save();
    final llm = ref.read(llmServiceProvider);
    if (!llm.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter and save at least one AI key')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Testing AI...')));
    }
    final result = await llm.test('gitmek');
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('AI test result'),
          content: SelectableText(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleared $count cached audio clip${count == 1 ? '' : 's'}',
          ),
        ),
      );
    }
  }

  Future<void> _clearDictionary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear dictionary?'),
        content: const Text(
          'This will permanently delete ALL words, practice history, and review '
          'data. Audio cache is kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(wordRepositoryProvider).deleteAllWords();
    ref.invalidate(statsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Dictionary cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settings = ref.read(settingsServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Practice ──────────────────────────────────────────────────────
          Text('Practice', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Suffix drill level')),
              DropdownButton<String>(
                value: settings.grammarLevel,
                items: [
                  for (final l in const ['A1', 'A2', 'B1', 'B2'])
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  await settings.setGrammarLevel(v);
                  ref.invalidate(suffixDueProvider);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Words per Brainstorm round: ${settings.wordsPerBrainstorm}'),
          Slider(
            min: 3,
            max: 10,
            divisions: 7,
            value: settings.wordsPerBrainstorm.toDouble(),
            label: '${settings.wordsPerBrainstorm}',
            onChanged: (v) async {
              await settings.setWordsPerBrainstorm(v.round());
              setState(() {});
            },
          ),
          Text('Max cards per review: ${settings.maxReviewsPerSession}'),
          Slider(
            min: 10,
            max: 200,
            divisions: 19,
            value: settings.maxReviewsPerSession.clamp(10, 200).toDouble(),
            label: '${settings.maxReviewsPerSession}',
            onChanged: (v) async {
              await settings.setMaxReviewsPerSession(v.round());
              setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Typing exercises'),
            subtitle: const Text('Type the Turkish word (harder, slower)'),
            value: settings.typingEnabled,
            onChanged: (v) async {
              await settings.setTypingEnabled(v);
              setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-advance after a correct answer'),
            subtitle: const Text('Moves on after about 1 second'),
            value: settings.autoAdvanceOnCorrect,
            onChanged: (v) async {
              await settings.setAutoAdvanceOnCorrect(v);
              setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use pack words in Brainstorm'),
            subtitle: const Text('Your own words always come first'),
            value: settings.usePackWords,
            onChanged: (v) async {
              await settings.setUsePackWords(v);
              ref.invalidate(statsProvider);
              setState(() {});
            },
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.library_books_outlined),
            title: const Text('Word packs'),
            subtitle: const Text('A1–B2 words and suffix examples'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PacksScreen()),
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),

          // ── AI translation (3 free providers, tried in this order) ────────
          Text('AI translation', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Tried in order: Gemini, then Groq, then OpenRouter. When one hits '
            'its free limit the next one is used. Fill in any or all. Keys '
            'stay on this phone.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _keyField(
            _geminiKeyCtrl,
            'Gemini API key (aistudio.google.com)',
            _obscureGeminiKey,
            () => setState(() => _obscureGeminiKey = !_obscureGeminiKey),
          ),
          const SizedBox(height: 8),
          _modelField(_geminiModelCtrl, 'Gemini model'),
          const SizedBox(height: 16),
          _keyField(
            _groqKeyCtrl,
            'Groq API key (console.groq.com)',
            _obscureGroqKey,
            () => setState(() => _obscureGroqKey = !_obscureGroqKey),
          ),
          const SizedBox(height: 8),
          _modelField(_groqModelCtrl, 'Groq model'),
          const SizedBox(height: 16),
          _keyField(
            _orKeyCtrl,
            'OpenRouter API key (openrouter.ai)',
            _obscureOrKey,
            () => setState(() => _obscureOrKey = !_obscureOrKey),
          ),
          const SizedBox(height: 8),
          _modelField(
            _orModelCtrl,
            'OpenRouter model (openrouter/free = any free model)',
          ),
          const SizedBox(height: 10),
          Text(
            'AI calls today: ${ref.read(settingsServiceProvider).aiCallsToday}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            icon: const Icon(Icons.science_outlined),
            label: const Text('Test AI translation'),
            onPressed: _testAi,
          ),

          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),

          const AudioSettings(),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),

          // ── About & updates ───────────────────────────────────────────────
          Text('About & updates', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.hasData
                  ? 'Version ${snap.data!.version} (build ${snap.data!.buildNumber})'
                  : 'Version…',
            ),
          ),
          if (!hasReleaseRepo)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Updates are off: no release repository is configured.',
                style: theme.textTheme.bodySmall,
              ),
            )
          else ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Check automatically'),
              value: settings.autoCheckUpdates,
              onChanged: (v) async {
                await settings.setAutoCheckUpdates(v);
                setState(() {});
              },
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.system_update),
              label: const Text('Check for updates'),
              onPressed: _checkUpdates,
            ),
            const SizedBox(height: 8),
            SelectableText(
              'All releases: https://github.com/$kReleaseRepo/releases',
              style: theme.textTheme.bodySmall,
            ),
          ],

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
                icon: Icon(
                  _obscureElKey ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureElKey = !_obscureElKey),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Voice selector ──────────────────────────────────────────────────
          Text('Voice', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Male voices',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _voices
                .where((v) => v.isMale)
                .map(
                  (v) => _VoiceChip(
                    voice: v,
                    selected: _selectedVoiceId == v.id,
                    onTap: () => setState(() => _selectedVoiceId = v.id),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            'Female voices',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _voices
                .where((v) => !v.isMale)
                .map(
                  (v) => _VoiceChip(
                    voice: v,
                    selected: _selectedVoiceId == v.id,
                    onTap: () => setState(() => _selectedVoiceId = v.id),
                  ),
                )
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
            label: Text(
              'Clear dictionary (delete all words)',
              style: TextStyle(color: cs.error),
            ),
            style: OutlinedButton.styleFrom(side: BorderSide(color: cs.error)),
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
  const _VoiceChip({
    required this.voice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(voice.name),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
