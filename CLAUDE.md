# mobileApp: Turkish vocabulary trainer (Flutter)

Personal Android app for learning Turkish words found "in the wild" (manhwa etc.),
inspired by Lingualeo's brainstorm mode. Package name: `turkish_vocab`.

Stack: Flutter, Riverpod (`lib/providers`), Drift/SQLite (`lib/data`, codegen in
`database.g.dart`), SM-2 SRS (`lib/domain/srs.dart`) with independent modes
(recognition / writing / listening), morphology root+suffix split
(`lib/services/morphology_service.dart`), AI translation via Gemini
(`gemini_service.dart`, `translation_service.dart`), TTS via ElevenLabs or
`flutter_tts` fallback (`tts_service.dart`). The user enters API keys in Settings and
they are stored in shared_preferences.

Commands: `flutter pub get` · `flutter run` · `flutter test` ·
`dart run build_runner build --delete-conflicting-outputs` (after schema changes)

Note: README says "fully offline, no API costs". That is outdated, since AI translation
and ElevenLabs were added later.

## Current goal: figure out why it didn't work well, then fix it

The owner says it "didn't work as hugely as intended". The planning session should
first **diagnose** by reading the code, and ask the owner about anything it can't
tell from the code. Areas to check:
- Translation quality and reliability (Gemini free tier: prompts, rate limits,
  errors, caching, offline fallback); support for other free-tier providers
- Morphology split accuracy for Turkish suffixes
- ElevenLabs cost/quota: cache generated audio per word instead of regenerating
- Review UX: is the brainstorm/practice loop actually motivating and fast?
- SRS correctness and data-model problems, test coverage
- Whether to fix incrementally or rewrite parts (justify it)
