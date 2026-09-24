# Turkish Vocabulary Trainer

Personal, offline-first Android app for learning Turkish vocabulary encountered
"in the wild" (manhwa, etc.). Words are split into root + suffixes automatically,
and each practice mode (recognition, writing, listening) is scheduled independently
with SM-2 spaced repetition.

## What's built (v1)

- **Add words** — type a Turkish word, get morphological analysis (root + suffixes),
  enter the English translation + optional note/source, save.
- **Review queue** — mixed-mode daily queue using SM-2 with per-mode interval weighting:
  - Recognition TR→EN / EN→TR (self-grade, with TTS)
  - Writing (type the Turkish word, edit-distance typo tolerance)
  - Listening (TTS plays the word, pick the English meaning from 4 options)
- **Browse & edit** — search your word list, see mastery bars, edit any field,
  enable writing/listening modes per word, delete words.
- **Stats** — total words, due counts by mode, reviews today, average mastery.
- **Fully offline** — no backend, no network, no API costs.

## How to run

### Requirements
- Flutter 3.x (`flutter --version` to check)
- Android SDK + a device/emulator (`flutter devices`)

```bash
flutter pub get
flutter run
```

### Morphological analysis (optional, recommended)
Out of the box the app uses the whole word as the root (fallback). To get real
Turkish morphology, follow the steps in `android/app/libs/README.md` to bundle
the Zemberek jar — takes ~5 minutes.

### TTS (Turkish voice)
Uses Android's built-in TTS engine. On most Android devices, go to
**Settings → Accessibility → Text-to-speech → Install voice data** and install
a Turkish (tr-TR) voice if not already present.

## Project structure

```
lib/
  domain/          # Pure Dart: SM-2 scheduler, mastery, edit distance
  data/            # Drift schema + repository
  services/        # Morphology bridge, TTS wrapper
  providers/       # Riverpod providers
  ui/
    screens/       # Home, AddWord, Review, Browse, WordEdit, Stats
    widgets/       # RecognitionCard, WritingCard, ListeningCard, GradeButtons
android/
  app/libs/        # Drop zemberek-full.jar here (see README inside)
test/              # 36 unit + integration tests
```

## v2 (deferred — do not build yet)
- STT / `speech_to_text` for pronunciation checking
- Show context note during review (after a miss)
- Export / backup (SQLite file or JSON)
- Starter word list / publishing
