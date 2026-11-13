# Turkish Vocabulary Trainer

Personal Android app for learning Turkish vocabulary found "in the wild" (manhwa,
etc.). Works without Google services. Core learning (dictionary, morphology,
practice) is offline; AI translation and cloud voices are optional.

## What it does

- **Add words fast.** Type or paste a word/phrase, or select text in any app and
  choose "Add to Turkish Vocab" (Share also works). The offline dictionary and
  Zemberek fill in the meaning and the breakdown (`ev · ler · imiz · de` with a
  gloss under each suffix). AI is only used when the offline lookup can't answer.
- **Brainstorm.** 5 new words per round: choose the meaning, choose the Turkish,
  listen and choose, build the word from letters. A result panel after every answer
  shows the word, audio, meaning and suffixes.
- **Review.** Due words get one exercise each, graded automatically (correctness +
  speed), scheduled with SM-2.
- **Suffix drill.** Ten short questions on the suffixes (`Loc`, `A3pl`, `P1pl`…),
  level by level (A1 to B2), using your own words and grammar-pack examples.
- **Word packs.** A1 starter (essentials + ~550 frequent words + suffix examples) is
  bundled. A2, B1, B2 and more suffix levels download from this repo, or import from
  a file.
- **Audio.** ElevenLabs (cached, optional) → offline Piper voice → phone TTS if it
  has Turkish → a clear message instead of silence.
- **Three free AI providers** (Gemini, Groq, OpenRouter) tried in order; when one
  hits its limit the next one answers. You enter your own keys in Settings; they
  stay on the phone.
- **In-app updates.** The app checks GitHub Releases, shows the patch notes once per
  release, and installs the update in one tap.

## Run it

```bash
flutter pub get
flutter run
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # after schema changes
```

Requirements: Flutter 3.47+, Android SDK, a device or emulator.
Morphology uses the bundled Zemberek jar (`android/app/libs/zemberek-full.jar`);
if it fails to load the app falls back to "the whole word is the root".

## Rebuilding the data (only when you want to change it)

Inputs go in `~/turkish-data/` (or anywhere), never in git:

```bash
# 1. Dictionary (Wiktionary dump from kaikki.org) -> assets/dict/tr_en.db
dart run tool/build_dictionary.dart kaikki.org-dictionary-Turkish.jsonl assets/dict/tr_en.db

# 2. Lemma frequencies (tr_50k.txt) and attested suffix forms (tr_full.txt)
java -cp android/app/libs/zemberek-full.jar tool/LemmaCounter.java tr_50k.txt > ~/turkish-data/lemmas.tsv
java -cp android/app/libs/zemberek-full.jar tool/GrammarMiner.java tr_full.txt 150000 > ~/turkish-data/forms.tsv

# 3. Packs + index.json (review CSVs go to ~/turkish-data/review/)
dart run tool/build_packs.dart ~/turkish-data/lemmas.tsv ~/turkish-data/forms.tsv \
    assets/dict/tr_en.db packs ~/turkish-data/review
cp packs/tr-a1-core.json packs/tr-a1-essentials.json packs/tr-grammar-a1.json assets/packs/

# 4. Check everything
dart run tool/validate_pack.dart packs/*.json
```

Fix a bad meaning by adding a line to `tool/overrides.tsv` (`lemma<TAB>english`, or
`-` to drop it) and re-running step 3. Hand-made basics live in `tool/essentials.tsv`.
Levels are approximate: A1 = the 600 most frequent lemmas, A2 = 601-1500, B1 =
1501-3000, B2 = 3001-5000 (subtitle frequency, not an official CEFR list).

## Releasing

1. Bump `version:` in `pubspec.yaml` (e.g. `1.2.0+3`; the `+N` build must increase).
2. Add a section at the top of `CHANGELOG.md`:
   ```markdown
   ## 1.2.0+3
   - What changed, one bullet per line
   ```
3. `git commit -am "release 1.2.0" && git tag v1.2.0+3 && git push --follow-tags`

GitHub Actions builds a signed arm64 APK and publishes a release with `version.json`
and your patch notes. A missing changelog section or a tag that doesn't match
`pubspec.yaml` fails the build.

### One-time setup

1. Create the keystore (keep the file and passwords somewhere safe; if you lose it,
   updates can no longer install over the app):
   ```bash
   keytool -genkey -v -keystore ~/keys/turkish_vocab.jks -keyalg RSA -keysize 2048 \
       -validity 10000 -alias turkishvocab
   ```
2. For local release builds create `android/key.properties` (gitignored):
   ```properties
   storeFile=/Users/you/keys/turkish_vocab.jks
   storePassword=...
   keyPassword=...
   keyAlias=turkishvocab
   ```
3. In the GitHub repo, Settings → Secrets and variables → Actions, add:
   `ANDROID_KEYSTORE_BASE64` (`base64 -i ~/keys/turkish_vocab.jks | pbcopy`),
   `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`.
4. Put the repo slug in `lib/config.dart` (`kReleaseRepo = 'owner/repo'`).
5. The first install of the release-signed app needs the old debug-signed app
   uninstalled once (different signing key).

Never commit the keystore, `key.properties` or any API key.

## Data sources and licences

- Dictionary: Wiktionary via [kaikki.org](https://kaikki.org) (CC BY-SA 4.0)
- Word frequencies: [FrequencyWords](https://github.com/hermitdave/FrequencyWords)
  (code MIT, data CC BY-SA 4.0)
- Morphology: [Zemberek-NLP](https://github.com/ahmetaa/zemberek-nlp) (Apache 2.0)
- Offline voice: [Piper](https://github.com/rhasspy/piper) Turkish voices via
  [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) (the `dfki` voice is
  CC BY-NC-SA 4.0)

## Project structure

```
lib/
  domain/       pure Dart: SRS, sessions, packs, suffix glosses, Turkish text
  data/         Drift schema + repositories (words, packs, morphemes)
  services/     morphology, dictionary, translation pipeline, AI providers,
                audio, packs, updates
  providers/    Riverpod wiring
  ui/           screens and widgets
tool/           data builders, validators, release scripts
packs/          generated packs + index.json (published from this repo)
assets/         bundled dictionary and A1 starter packs
android/        Kotlin side: Zemberek bridge, share intake, APK installer
test/           unit and integration tests
```
