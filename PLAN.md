# PLAN: mobileApp (Turkish vocab trainer)

Planning session: 2026-11-12. Revised the same day after owner feedback: wiping existing
data is OK. Added CEFR A1–B2 word/suffix packs, downloadable packs and in-app updates from
GitHub.
Based on a full read of `lib/`, `test/`, the Android bridge (`MainActivity.kt`,
`MorphologyPlugin.kt`), `android/app/build.gradle.kts`, and the owner's answers about real use.
Baseline: `flutter analyze` is clean, `flutter test` has 36/36 passing. The problems are
design problems, not crashes.

---

## Summary

### Current state
A Flutter/Riverpod/Drift app. You add a Turkish word or phrase, Zemberek (bundled jar,
it works) splits it into root + suffixes, and Gemini (falling back to MyMemory)
translates it. It is reviewed Anki-style. There is one SM-2 state per (word, mode), with
modes TR→EN, EN→TR, writing and listening, and you grade yourself with
Again/Hard/Good/Easy. Audio comes from ElevenLabs (cached after the first play), with
`flutter_tts` as the fallback. The app is sideloaded. Release builds are signed with
the **debug key** (`build.gradle.kts`), and there is no git remote.

### What the owner experienced
Huawei phone with **no Google services**, so there is no Turkish system voice.
Reviews felt boring and slow. Too many junk cards. "I got repeat the same words few
times right after I just got it." Unclear cards: "sometimes it says the word but no
translation after." Adding words is painful. Sometimes the translation is bad. Gemini
free-tier limits are too low.

### Problems found (ranked by impact)

1. **Saving floods the deck with junk cards.** `AddWordScreen._saveSingleWord` /
   `_savePhrase` save the root and *every suffix* as separate words, and each gets
   3 SRS states. `evlerimizde` turns into ~18 due cards, including "ler → plural
   suffix". `ler`/`lar` become separate cards, while locative `de` and the
   conjunction `de` collide.
2. **The review loop is Anki, not Brainstorm.**
   - 3 sibling states per word are due at the same moment, and `dueQueue` orders by
     `dueAt`, so they come up **back to back** (the "same word right after" problem).
   - Self-grading with 4 buttons is slow.
   - Writing mode is on from day one.
   - Lapsed cards never come back in the session.
   - There's no limit on new cards or session size.
3. **The cards are confusing.**
   - `ListeningCard` never shows the Turkish spelling.
   - `WritingCard` "Hear it once" speaks the answer before you type.
   - Audio is silent on this phone.
   - Distractors are random rows, including suffix glosses.
4. **Translation uses AI for work that needs none, and does it badly.**
   - Zemberek knows each suffix's ID (`A3pl`, `Loc`, `P1pl`, `Past`...), but
     `MorphologyPlugin.kt` keeps only `surface` and then pays Gemini to explain the
     suffixes.
   - Every word costs 2+ AI calls, and nothing is cached.
   - A 429 doesn't try the next model or provider.
   - No context sentence is sent to the AI.
   - There's no offline dictionary.
5. **No content to learn from.** Every word has to be typed in by hand. There's no
   beginner vocabulary or grammar path.
6. **Audio fails silently.** ElevenLabs is fetched lazily, so it fails offline or when
   the quota runs out. `flutter_tts` has no tr-TR voice on this phone.
7. **Data integrity bugs.**
   - Drift never runs `PRAGMA foreign_keys = ON`, so cascades never fire. Deleted
     words leave orphan states, and `dueCount` (Home "Due now") counts them.
   - Dart `toLowerCase()` is not Turkish-aware (`İ`→`i̇`, `I`→`i`), which breaks
     dedupe, writing checks and ALL-CAPS manhwa input.
   - There's no `MigrationStrategy`.
8. **Shipping is manual.** Building and copying the APK by hand, and the debug key
   differs per machine, so updates won't install over each other reliably.
9. **Smaller issues.**
   - Zemberek runs on the Android main thread (ANR risk).
   - `analyze('test')` runs on every app `build`.
   - `updateWordFields` drops suffixes.
   - README is outdated.
   - No tests for the translation, bridge or UI flows.

### Target state
- **Brainstorm** (Lingualeo-style) for new words, and an auto-graded **Review** with
  one SRS state per word. Every answer ends on a result panel showing Turkish + audio
  + English + suffix breakdown (`ev·ler·imiz·de` = house·plural·our·in).
- **Content packs.**
  - Built-in **A1** pack, plus downloadable **A2/B1/B2** word packs and grammar
    (suffix) packs, listed from an `index.json` on GitHub.
  - Packs can also be imported from a local file.
  - Brainstorm takes new words from your own words first, then from packs in level
    order.
- **Suffix drill** with CEFR levels (A1 → B2), using pack examples + your own words.
- **Local-first translation:** Zemberek IDs + static suffix glosses + a bundled
  Wiktionary dictionary. AI only for sentences, cached, falling back to another
  provider on 429.
- **Audio:** cached → ElevenLabs (prefetched for words about to be learned) →
  offline Piper Turkish voice → a visible message.
- **CI/CD + in-app updates:** pushing a `v*` tag makes GitHub Actions build a signed
  APK and publish a release, with patch notes taken from `CHANGELOG.md`. The app
  shows a closable "New version + patch notes" alert **once per release**,
  downloads the APK, verifies its SHA-256, and opens Android's installer. You tap
  **Install** once; Android doesn't allow a fully silent install for normal apps.
  After updating, "What's new" shows once.
- **Fast adding:** live offline analysis, "Save & add another", and "Add to Turkish
  Vocab" in the text-selection/Share menus.

---

## Decisions

| Decision | Rationale | Rejected alternative |
|---|---|---|
| **Wipe data at schema v2 (owner approved)** | No migration code, no cleanup screen, much less risk and work. | Migrate v1 data plus a junk-cleanup screen. |
| **Fix incrementally; rewrite only the review loop and the add-word screen** | Drift, Riverpod, the Zemberek bridge, TTS caching and the domain code are sound. | A full rewrite: weeks of work, and it throws away working morphology. |
| **One SRS state per word; exercises are presentation only** | Removes sibling repeats by construction, and it's how Lingualeo works. | Per-mode states with sibling burying: more cards, more complexity. |
| **Auto-grade from correctness + response time** | Fast and consistent, which fixes "boring/slow". | 4-button self-grading. |
| **Suffixes are never vocabulary cards. Separate Suffix drill keyed by Zemberek ID, each ID tagged with a CEFR level** | The owner chose "word card + small suffix drill". `ler`/`lar` merge. | Suffix-as-word cards. |
| **Suffix glosses come from a static table of Zemberek IDs** | Free, offline, deterministic. | Asking the AI per suffix. |
| **Word packs = versioned JSON files hosted in a public GitHub repo, with `index.json`** | Free hosting, easy to update with a `git push`, no backend. Fits a solo side project. | A custom backend (it costs money), or bundling everything in the APK (any change needs a new release). |
| **CEFR word levels are *approximate*: subtitle frequency list → Zemberek lemmas → frequency-rank bands, plus a hand-made A1 essentials pack** | There's no free, openly licensed official Turkish CEFR word list. Subtitle frequency is conversational, which suits manhwa. | Scrape commercial course lists (licensing), or AI-only lists (it invents and mislevels words). |
| **Bundle only A1 in the APK; download the rest** | Works offline on first run, and keeps the APK small. | Bundling all levels. |
| **Bundled offline lemma dictionary from kaikki.org (Wiktionary)** | Free, unlimited, offline. Also supplies glosses when building packs. | Google ML Kit (needs Google services), online APIs (quotas). |
| **Generic `OpenAiCompatibleProvider` next to Gemini** | One class covers Groq/OpenRouter/Mistral for the 429 fallback. | One class per vendor. |
| **ElevenLabs prefetch + Piper (`sherpa_onnx`) offline voice, downloaded from Settings** | The owner chose this. It works without Google services. ElevenLabs free quota can't cover thousands of pack words, so Piper is the main voice for pack words. | ElevenLabs only, or `flutter_tts`. |
| **Self-updater: GitHub Releases API + a `version.json` asset + native `ACTION_VIEW` installer through `FileProvider` (~40 lines Kotlin)** | No extra plugin, no store needed (and no Google Play on the phone anyway). | `ota_update` or another plugin (an extra dependency for little code), or Huawei AppGallery publishing (review process). |
| **Release signing with a dedicated keystore in `android/key.properties` (gitignored)** | Updates only install over an APK signed with the *same* key. The debug key is per machine. | Keep the debug key: updates break when the machine or SDK changes. |
| **Releases are built by GitHub Actions on a pushed tag `v*` in the app's own public repo; patch notes come from `CHANGELOG.md`** | Reproducible builds on a clean machine, no manual APK handling, and notes written in a plain markdown file. Free for public repos. | Building locally and uploading with `gh` (manual, depends on the Mac's state). A separate dist repo is unnecessary once the repo is public. |
| **One-time update alert, remembered per build in prefs** | The owner asked for an alert that shows once with patch notes and can be closed. | A persistent banner (nagging), or only a manual check (easy to miss). |
| **Publish only an `arm64-v8a` APK** | Every modern Huawei phone is arm64. It keeps the download small (Zemberek + sherpa native libs). | A fat APK (larger), or all ABIs. |
| **API keys stay in `shared_preferences`** | Personal device, user-entered keys. No secrets in the repo or git history (checked: only the `xi-api-key` header name). | `flutter_secure_storage`. |

---

## Phases

Before every phase, run `flutter test`. After it, run `flutter analyze && flutter test`.
Both must stay green. After any change to `database.dart`, run
`dart run build_runner build --delete-conflicting-outputs`.

### Phase 1: Stop the bleeding (no schema change)
**Goal:** Remove the junk-card flood, the back-to-back repeats and the confusing card
behaviour, using small changes to the existing code.

**Files:** `lib/domain/turkish_text.dart` (new), `lib/domain/practice_mode.dart`,
`lib/domain/edit_distance.dart`, `lib/data/database.dart`, `lib/data/word_repository.dart`,
`lib/ui/screens/add_word_screen.dart`, `lib/ui/screens/review_screen.dart`,
`lib/ui/widgets/{listening_card,writing_card,recognition_card}.dart`, `lib/main.dart`,
`android/.../MorphologyPlugin.kt`, `android/.../MainActivity.kt`, `README.md`,
`test/turkish_text_test.dart` (new), `test/word_repository_test.dart`.

**Steps:**
1. `lib/domain/turkish_text.dart` (pure functions):
   - `trLower`: map `I`→`ı` and `İ`→`i` before `toLowerCase()`, then remove U+0307.
   - `trNormalize`: `trLower`, trim, collapse whitespace, and strip leading/trailing
     `.,!?;:…"'«»“”‘’()[]-–—`. Inner apostrophes stay.
   - `stripDiacritics`: `ı→i ş→s ğ→g ç→c ö→o ü→u â→a î→i û→u`.
2. `edit_distance.dart` `isCloseEnough` and `writing_card.dart` `_check` use
   `trNormalize`.
   - Exact match → good.
   - Equal after `stripDiacritics` → hard.
   - Otherwise keep the existing edit-distance rule.
3. `word_repository.dart` `addWord` (building on the uncommitted dedupe change):
   - Find candidates with a case-insensitive `like` on the trimmed input, then
     compare in Dart with `trNormalize`.
   - Return `({int id, bool existed})`, update the callers and tests, and have the
     UI show "Already in your list".
4. `database.dart`: add a `MigrationStrategy` whose `beforeOpen` runs
   `PRAGMA foreign_keys = ON`, then
   `DELETE FROM practice_states WHERE word_id NOT IN (SELECT id FROM words)` and the
   same for `review_log`. `schemaVersion` stays 1.
5. `practice_mode.dart`: `initialModes = [recognitionTrEn, recognitionEnTr]`.
6. `dueQueue`: keep **at most one card per `wordId`**, preferring
   recognitionTrEn > recognitionEnTr > listening > writing. Make the order
   deterministic. `dueCount` and `dueCountByMode` count one per word.
7. `add_word_screen.dart`: **stop creating root/suffix entries.**
   - A single word or a phrase saves exactly 1 row (with `root`/`suffixes` filled).
   - Remove the `translateParts` / `translatePhraseBreakdown` calls and the "will
     also add" hint.
   - Show a SnackBar when translation fails.
8. `review_screen.dart`: a card graded `again` is appended once to the end of
   `_queue`.
9. Card fixes:
   - Listening shows `word.turkish` plus a replay button after you answer.
   - Writing removes the pre-answer "Hear it once" and autoplays audio after
     checking.
   - Recognition autoplays audio when revealed.
   - Each card shows a one-line instruction under its mode label.
10. `main.dart`: run the Zemberek warm-up once, from `main()`, not in `build`.
11. Kotlin: run `analyze` on `Executors.newSingleThreadExecutor()` and post
    `result.success` back through `Handler(Looper.getMainLooper())`. Lowercase input
    with `lowercase(Locale.forLanguageTag("tr"))`.
12. README: Zemberek is bundled; Gemini/ElevenLabs are optional online services.
13. Tests:
    - `turkish_text_test.dart`: `IŞIK`→`ışık`, `GİTTİ`→`gitti`, punctuation,
      diacritics.
    - Repository: `EV` after `ev` → `existed`; one card per word in the queue;
      after `deleteWord`, `dueCount == 0`; a new word creates 2 states.

**Done when:**
- Tests are green.
- Adding `evlerimizde` creates exactly 1 Browse entry.
- No word appears twice in a row, and missed cards return later in the session.
- Listening shows the spelling.
- Deleting all words makes "Due now" 0.

**Risks:** With FK enforcement on, bad inserts now throw. Run the full suite.

---

### Phase 2: Public repo, CI/CD releases, in-app updater with a one-time patch-notes alert
**Goal:** Pushing a version tag makes GitHub Actions build a signed APK and publish a
release with patch notes. The app shows a closable "new version" alert once per
release and installs the update in one tap. Done early because changing the signing
key forces a one-time reinstall, which is fine now that wiping data is OK.

**How to release (the owner's whole workflow after this phase):**
1. Bump `version:` in `pubspec.yaml` (e.g. `1.3.0+8`; the `+N` build number must
   always increase).
2. Add a section at the top of `CHANGELOG.md`:
   ```markdown
   ## 1.3.0+8
   - Brainstorm now skips words you just answered
   - New A2 pack
   ```
3. `git commit -am "release 1.3.0" && git tag v1.3.0+8 && git push --follow-tags`.

CI does the rest. A missing changelog section fails the build, with a clear message.

**Files:** `.github/workflows/ci.yml` (new), `.github/workflows/release.yml` (new),
`tool/extract_changelog.sh` (new), `tool/check_release_version.sh` (new),
`CHANGELOG.md` (new), `android/app/build.gradle.kts`,
`android/key.properties` (local only, **gitignored**), `.gitignore`,
`android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/xml/file_paths.xml`
(new), `MainActivity.kt`, `pubspec.yaml` (`package_info_plus`, `flutter_markdown_plus`
or plain `Text`, see step 8), `lib/services/update_service.dart` (new),
`lib/ui/widgets/update_dialog.dart` (new), `lib/ui/screens/settings_screen.dart`,
`lib/ui/screens/home_screen.dart`, `test/update_service_test.dart` (new), `README.md`.

**Steps:**
0. **Before making the repo public**, check that nothing secret is tracked:
   - `git ls-files | grep -iE "\.jks|\.keystore|key\.properties|\.env"` returns
     nothing.
   - `git log -p | grep -iE "AIza[0-9A-Za-z_-]{30}|sk_[0-9a-f]{20}"` returns nothing.
     The planning session already checked this, but re-run it.

   Then create the GitHub repo, `git remote add origin ...`, push `main`, and set
   the repo to public. `android/app/libs/zemberek-full.jar` (31 MB) is under
   GitHub's 100 MB limit, so it's OK to keep in git.
1. **Keystore** (the owner runs this once and stores the file + passwords in a password manager):
   `keytool -genkey -v -keystore ~/keys/turkish_vocab.jks -keyalg RSA -keysize 2048 -validity 10000 -alias turkishvocab`.
   Create `android/key.properties` with `storePassword`, `keyPassword`,
   `keyAlias=turkishvocab`, `storeFile=/Users/<you>/keys/turkish_vocab.jks`.
   Add `android/key.properties`, `*.jks` and `*.keystore` to `.gitignore`.
2. `build.gradle.kts`: load `key.properties` if it exists (the standard Flutter
   "Build and release an Android app" snippet, Kotlin DSL). Create
   `signingConfigs.create("release")` and use it for `release`. **If the file is
   missing, fall back to debug signing** so `flutter run --release` still works on
   other machines.
3. **Native installer.**
   - Manifest:
     - `<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>`.
     - A `<provider android:name="androidx.core.content.FileProvider" android:authorities="${applicationId}.fileprovider" android:exported="false" android:grantUriPermissions="true">`
       with meta-data `android.support.FILE_PROVIDER_PATHS` → `@xml/file_paths`.
   - `file_paths.xml`: `<paths><cache-path name="updates" path="updates/"/></paths>`.
   - If `androidx.core` isn't already on the classpath, add
     `implementation("androidx.core:core-ktx:<current stable>")`.
   - `MainActivity.kt`, on a new channel `app_update`:
     - `canInstall` → `packageManager.canRequestPackageInstalls()`.
     - `openInstallPermission` → start `Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES`
       with `Uri.parse("package:$packageName")`.
     - `installApk(path)` → `FileProvider.getUriForFile(...)` and
       `Intent(Intent.ACTION_VIEW).setDataAndType(uri, "application/vnd.android.package-archive")`
       with `FLAG_GRANT_READ_URI_PERMISSION | FLAG_ACTIVITY_NEW_TASK`.
4. **`version.json` release asset** (written by CI):
   `{"version":"1.3.0","build":8,"apk":"app-arm64-v8a-release.apk","sha256":"<hex>","notes":"- Brainstorm now...\n- New A2 pack","published":"2026-11-20"}`.
5. **CI/CD.**
   - **GitHub secrets** (repo Settings → Secrets and variables → Actions), set once
     by the owner:
     - `ANDROID_KEYSTORE_BASE64` = `base64 -i ~/keys/turkish_vocab.jks | pbcopy`
     - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`
   - **`tool/extract_changelog.sh <version+build>`**: prints the lines between
     `## <version+build>` and the next `## `. Exits 1 if the section is missing or
     empty.
   - **`tool/check_release_version.sh <tag>`**: checks that the tag (`v1.3.0+8`)
     equals `v` + the `version:` in `pubspec.yaml`. Exits 1 otherwise.
   - **`.github/workflows/ci.yml`**, on `push` to `main` and on `pull_request`.
     Runs on `ubuntu-latest`:
     - `actions/checkout`
     - `subosito/flutter-action` (pin the Flutter version that matches the local
       `flutter --version`, with `cache: true`)
     - `flutter pub get`
     - `dart run build_runner build --delete-conflicting-outputs`, **only if**
       `database.g.dart` isn't committed (it is committed today, so skip this)
     - `flutter analyze`
     - `flutter test`
     - From Phase 5 on, also `dart run tool/validate_pack.dart packs/*.json`.
   - **`.github/workflows/release.yml`**, on `push` with `tags: ['v*']`, with
     `permissions: contents: write`:
     1. Checkout, then `actions/setup-java` (temurin 17), then
        `subosito/flutter-action` (same pin).
     2. `tool/check_release_version.sh "$GITHUB_REF_NAME"`.
     3. `tool/extract_changelog.sh "${GITHUB_REF_NAME#v}" > notes.md`.
     4. `flutter pub get && flutter analyze && flutter test`.
     5. Decode the keystore:
        `echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > $RUNNER_TEMP/release.jks`.
        Write `android/key.properties` with `storeFile=$RUNNER_TEMP/release.jks` and
        the secrets. Never `echo`/`cat` the secret values into the log.
     6. `flutter build apk --release --split-per-abi --target-platform android-arm64`.
     7. Compute the sha256 of `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
        and write `version.json` (fill `notes` from `notes.md` with `jq --rawfile`).
     8. Create the release with `softprops/action-gh-release` (pin a major version):
        `tag_name: ${{ github.ref_name }}`, `body_path: notes.md`, files = the APK +
        `version.json`.
     9. **Fail the job** if `build.gradle.kts` fell back to debug signing. Make
        `build.gradle.kts` throw when the env var `CI=true` is set and
        `key.properties` is missing.
6. **`update_service.dart`:**
   - `checkLatest()`: GET `https://api.github.com/repos/<kReleaseRepo>/releases/latest`
     with headers `Accept: application/vnd.github+json` and
     `User-Agent: turkish-vocab-app` (no personal data). Find the `version.json`
     asset, download it, and compare `build` with `PackageInfo.fromPlatform().buildNumber`.
     Returns `UpdateInfo?`.
   - `downloadAndInstall(info, onProgress)`: stream the APK asset
     (`browser_download_url`) to `<cacheDir>/updates/update.apk` and verify the
     SHA-256 (the `crypto` package is already a dependency). On a mismatch, delete
     the file and show an error. If `!canInstall`, show a dialog explaining the
     permission, then call `openInstallPermission`, and the user taps again
     afterwards. Otherwise call `installApk`.
   - Keep the repo slug in one constant, `kReleaseRepo`, in
     `lib/services/update_service.dart`.
7. **Auto-check + one-time alert.**
   - At start-up (after the first frame), if "Check automatically" is on (default)
     and the last check was more than 6 h ago, call `checkLatest()`. Fail silently
     when offline.
   - If `info.build > currentBuild` **and** `info.build != prefs.dismissedUpdateBuild`,
     show `update_dialog.dart` **once**:
     - Title "New version 1.3.0 available".
     - A scrollable patch-notes body (`info.notes`).
     - Buttons **"Update now"** (download with a progress bar → install flow) and
       **"Later"** (closes it).
   - Any close (Later, back, tapping outside) saves `dismissedUpdateBuild = info.build`,
     so that release never pops up again. A *newer* release shows the alert again.
   - **"What's new" after updating:** on start, if `currentBuild > prefs.lastSeenBuild`
     and `lastSeenBuild != 0`, show the same dialog in read-only mode with the
     current version's notes. Fetch them from
     `GET /repos/<repo>/releases/tags/v<version+build>`, or skip if offline. Then
     store `lastSeenBuild = currentBuild`. On a fresh install, just store it
     without showing anything.
   - Patch notes are plain text with `- ` bullets. Render them with a simple
     `Text` per line. No markdown package unless the owner wants rich formatting.
8. Settings "About & updates": current version/build, "Check for updates" (always
   checks, ignoring `dismissedUpdateBuild`, and opens the same dialog), the
   "Check automatically" toggle, and a link "All releases" that opens the GitHub
   releases page through `url_launcher`, or just shows the URL as selectable text
   to avoid the dependency. Network errors are shown as text, never as a crash.
9. Tests (mocked `http.Client` + `SharedPreferences.setMockInitialValues`):
   - Newer build → `UpdateInfo`; same or older → null; missing `version.json` →
     null.
   - SHA mismatch → error and the file deleted.
   - Dialog decision logic, as a pure function
     `shouldShowUpdateAlert(info, currentBuild, dismissedBuild)`: shown once,
     hidden after dismissal, shown again for a newer build.
   - "What's new" decision: `shouldShowWhatsNew(current, lastSeen)`.
   - `extract_changelog.sh`: a small shell test in CI against a fixture changelog
     (a section is found; a missing section exits 1).
10. README "Releasing": the 3-step workflow above, plus the secrets setup.

**Done when:**
- Pushing to `main` runs CI (analyze + test) green.
- Pushing tag `v1.0.1+2` (with a matching pubspec version and changelog section)
  produces a GitHub Release with `app-arm64-v8a-release.apk`, `version.json` and
  the changelog as the release body.
- A tag without a changelog section, or with a version mismatch, fails the
  workflow.
- On the phone, the old debug-signed app has been **uninstalled once** and the
  release APK installed.
- After the next release, opening the app shows the patch-notes alert **once**.
  "Update now" → Android installer → Install updates the app **without** losing
  data. Re-opening the app doesn't show the alert again, and after the update
  "What's new" appears once.

**Risks:**
- **Losing the keystore means no more updates** (the phone would need another
  uninstall). Back it up.
- Huawei EMUI/HarmonyOS "Pure mode" / "security check" may block or warn about
  installs from unknown sources. Allow this app, or turn Pure mode off.
- The unauthenticated GitHub API limit is 60 requests/hour per IP, which is plenty.
- The repo is public, so never put a GitHub token or API key in the app or the
  repo. The keystore lives only in GitHub secrets and on the owner's machine.
- GitHub Actions minutes are free for public repos. A build takes ~5–10 min.
- Pin the Flutter version in both workflows, and bump it deliberately when
  upgrading locally.
- If `version.json` is missing from a release (e.g. a manual release), the app
  ignores that release.

---

### Phase 3: Fresh schema v2, real morphology data, breakdown on cards
**Goal:** A new clean database (old data wiped) with Zemberek morpheme IDs, per-word
SRS, and pack tables, plus the glossed breakdown on every card.

**Files:** `lib/data/database.dart`, `lib/data/word_repository.dart`,
`lib/domain/suffix_glosses.dart` (new), `lib/services/morphology_service.dart`,
`MorphologyPlugin.kt`, `MainActivity.kt`, `lib/ui/widgets/breakdown_view.dart` (new),
`lib/ui/widgets/*_card.dart`, `lib/ui/screens/word_edit_screen.dart`,
`test/database_v2_test.dart` (new), `test/suffix_glosses_test.dart` (new).

**Steps:**
1. **Bridge returns IDs.** `MorphologyPlugin.analyze` returns
   `{lemma, pos (primaryPos.shortForm), stem, morphemes:[{surface, id: md.morpheme.id}]}`
   (`drop(1)`, skip blank surfaces).
   - Add `analyzeSentence(text)` using
     `morphology.analyzeAndDisambiguate(text).bestAnalysis()`, which returns a list
     of the same maps, each with `token`.
   - Add `analyzeBatch(words: List<String>)` (used by the pack import in Phase 5).
   - Dart `MorphologyService` mirrors this, and the fallback is lemma = word with no
     morphemes.
2. **`suffix_glosses.dart`.** Write
   `const Map<String, SuffixInfo> suffixGlosses`, with
   `SuffixInfo(label, gloss, category, level)`.
   - `category` ∈ `case, possessive, plural, person, tense, mood, voice, negation,
     participle, converb, derivation, copula, question`.
   - `level` ∈ `A1, A2, B1, B2`.
   - Unknown IDs → gloss = the ID, level B2.
   - Verify the ID strings by logging `md.morpheme.id` on the device, against the
     bundled jar (`TurkishMorphotactics`, 0.17.x).
   - Default levels (approximate, may be tuned):
     - **A1:** `A3pl`, `P1sg P2sg P3sg P1pl P2pl P3pl`, `Loc Dat Abl Acc Gen`,
       `Prog1` (-iyor), `Past` (-di), `Neg`, `Ques` (mi), `Cop`,
       `A1sg A2sg A1pl A2pl A3sg A3pl`, `With` (-li), `Without` (-siz), `Imp`.
     - **A2:** `Fut` (-ecek), `Aor` (-ir), `Narr` (-miş), `Able` (-ebil), `Neces`
       (-meli), `Ins` (-le), `Opt` (-e), `Agt` (-ci), `Ness` (-lik), `Inf1` (-mek),
       `Rel` (-ki).
     - **B1:** `Cond` (-se), `PastPart` (-dik), `FutPart` (-ecek), `PresPart` (-en),
       `Pass`, `Caus`, `When` (-ince), `ByDoingSo` (-erek), `While` (-ken),
       `AfterDoingSo` (-ip), `Since` (-eli), `Desr`, `Inf2` (-me), `Equ` (-ce),
       `Become` (-leş), `Dim`.
     - **B2:** `Reflex`, `Recip`, `AorPart`, `NarrPart`, `Prog2` (-mekte),
       `Unable`, `Ly`, `AsIf` (-casına), `Related`, `Inf3` (-iş), and anything else.
3. **Schema v2** (`schemaVersion = 2`). `onUpgrade` `from < 2`: **drop every existing
   table and `m.createAll()`** (the owner approved the wipe). Also delete the
   `tts_cache` dir. Tables:
   - `Words`: `id`, `turkish`, `normalized` (unique), `english`, `englishEdited`
     bool (default false), `kind` (`word|phrase|sentence`), `lemma?`, `pos?`,
     `morphemes` JSON `[{"s":"ler","id":"A3pl"}]` default `'[]'`, `note?`,
     `noteEn?`, `source?`, `level?` (`A1..B2`), `status` (`new|learning|review|suspended`,
     default `new`), `intervalDays` real 0, `easeFactor` real 2.5,
     `repetitions` int 0, `lapses` int 0, `dueAt?`, `lastReviewedAt?`,
     `needsAnalysis` bool true, `createdAt`.
   - `WordMorphemes`: `wordId` FK cascade, `morphemeId`, `surface`, `position`;
     PK (wordId, position).
   - `Morphemes`: `id` PK (Zemberek ID), `status`, the same SRS columns.
   - `MorphemeExamples`: `id`, `morphemeId`, `turkish`, `english`, `packId` FK
     cascade. These are grammar examples from packs.
   - `Packs`: `id` text PK, `title`, `level?`, `kind` (`words|grammar`), `version`
     int, `installedAt`.
   - `WordPacks`: `wordId` FK cascade, `packId` FK cascade, `rank` int; PK (wordId,
     packId).
   - `TranslationCache`: `key` PK, `payload` JSON, `provider`, `createdAt`.
   - `ReviewLog`: `id`, `wordId?` FK cascade, `morphemeId?`, `exercise` text,
     `result` text, `reviewedAt`.
   - **Delete `PracticeStates`.** The old review screen and cards keep working until
     Phase 4: as a temporary bridge, map them onto the per-word SRS columns with
     `PracticeMode.recognitionTrEn` math, and have `dueQueue` return one card per
     word.
4. **Analysis job.** Whenever a word is saved, or at start-up for rows with
   `needsAnalysis = true` (in batches of 20, yielding between batches): analyze,
   write `lemma/pos/morphemes`, fill `WordMorphemes`, and insert missing
   `Morphemes` rows with status `new`.
5. **`breakdown_view.dart`.** Root chip, then suffix chips joined by `·`, with the
   gloss under each (`ev · ler · imiz · de` / `house · plural · our · in`). Wraps on
   narrow screens. Use it on the revealed side of every card, and in
   `word_edit_screen` (read-only, with a "Re-analyze" button that saves the new
   result).
6. Tests:
   - `database_v2_test.dart`: create a v1 DB with raw SQL, open it as v2, and check
     that all tables exist, old data is gone, and FK cascade works (deleting a word
     removes its `WordMorphemes`/`WordPacks`).
   - `suffix_glosses_test.dart`: unknown ID fallback; every entry has a gloss, a
     valid category and a valid level.

**Done when:**
- Tests are green.
- After a Phase 2-style update on the phone, the app starts empty and works.
- Adding `evlerimizde` shows `ev·ler·imiz·de` with glosses on its cards.

**Risks:** Zemberek IDs differ between versions, so log them on the device before
writing the table. `analyzeAndDisambiguate` is slower; use it only for multi-word
input.

---

### Phase 4: Brainstorm + per-word review (core UX rewrite)
**Goal:** Replace the Anki loop with Lingualeo-like Brainstorm for new words and
fast, auto-graded Review.

**Files:** `lib/domain/srs.dart`, `lib/domain/exercise.dart` (new),
`lib/domain/brainstorm_session.dart` (new), `lib/domain/review_session.dart` (new),
`lib/data/word_repository.dart`, `lib/providers/providers.dart`,
`lib/services/settings_service.dart`, `lib/ui/screens/home_screen.dart`,
`lib/ui/screens/session_screen.dart` (new),
`lib/ui/widgets/exercises/{choice_exercise,construct_exercise,typing_exercise,listen_choice_exercise,reveal_exercise}.dart`
(new), `lib/ui/widgets/result_panel.dart` (new), tests
`test/brainstorm_session_test.dart`, `test/review_session_test.dart`, `test/srs_test.dart`.
Delete `review_screen.dart`, `recognition_card.dart`, `writing_card.dart`,
`listening_card.dart`, `grade_buttons.dart` and `practice_mode.dart` (along with
`mastery.dart`/tests if nothing else uses them) at the end.

**Steps:**
1. `exercise.dart`:
   - `enum ExerciseType { chooseMeaning, chooseTurkish, listenChoose, construct, typing, reveal }`.
   - `class Exercise { int wordId; ExerciseType type; List<String> options; String answer; }`.
2. `srs.dart`: `SrsScheduler.reviewWord(SrsState, ReviewGrade, {now})`, using SM-2
   with interval factor 1.0, intervals 1 → 3 → interval×ease. Lapse:
   `repetitions = 0`, `lapses++`, due in 10 min. Remove the `PracticeMode`-based
   `review`.
3. **`brainstorm_session.dart`** (pure Dart):
   - Steps for a word: `[chooseMeaning, chooseTurkish, listenChoose, construct]`,
     plus `typing` if enabled. Words with `kind != word` or longer than 14 chars get
     `[reveal, listenChoose]`.
   - `next()` takes the lowest pending step, **never the same word twice in a row**
     (unless it's the only word left), round-robin.
   - `answer(correct, took)`: if correct, advance; if wrong, `mistakes++` and the
     word is blocked for the next 2 exercises.
   - Choice options: 1 correct + up to 4 distractors (same kind, similar length
     ±3, no duplicates). Use at least 2 options in total, and never duplicate one
     to fill the count.
   - Construct: shuffled letters of `trLower(turkish)` (re-shuffle if unchanged).
     More than 2 wrong taps = wrong.
4. **`review_session.dart`** (pure Dart):
   - Due words (`status=review`, `dueAt<=now`), most overdue first, capped by a
     setting.
   - Exercise by `repetitions`: 0–1 chooseMeaning, 2 chooseTurkish, 3 listenChoose,
     4 construct, ≥5 typing (if enabled) or alternating construct/chooseTurkish.
     Sentences use reveal/listenChoose.
   - Grading: correct in < 8 s → good; slower, or 1–2 wrong taps, or a
     diacritic-only typo → hard; wrong → again. `reveal` has "Knew it" / "Didn't".
   - A lapse is re-asked once with chooseMeaning, at least 3 exercises later.
5. Repository:
   - `pickNewWords(n)`: **own words** (no `WordPacks` row) with status `new`, newest
     first. Then, if the setting `usePackWords` is on, pack words with status `new`,
     ordered by level (A1 < A2 < B1 < B2) and then `rank`. Pack words come from
     Phase 5; until then, own words only.
   - `finishBrainstorm(mistakes)`: `status=review`, `repetitions=1`,
     `interval=1d`, `ease = 2.5 − 0.15×min(mistakes,3)`.
   - `applyWordReview(wordId, grade, exercise)`, and the counts `newCount` /
     `dueCount`.
   - Distractor pool: all words of the same kind; once Phase 5/6 exist, pad with
     pack and dictionary words.
6. Settings "Practice":
   - `wordsPerBrainstorm` (5, range 3–10)
   - `maxReviewsPerSession` (50)
   - `typingEnabled` (false)
   - `autoAdvanceOnCorrect` (true, 900 ms)
   - `usePackWords` (true)
7. **`session_screen.dart`.**
   - Progress bar, then the exercise widget, then `result_panel.dart`: Turkish +
     autoplayed audio + English + `BreakdownView` + example/note, with a
     green or red header.
   - Correct + auto-advance → move on after 900 ms. Wrong → "Continue" button.
   - Persist after each answer.
   - End screen: learned count, accuracy, time, "Another round" / "Home".
8. `home_screen.dart`: **"Brainstorm (N new)"** and **"Review (M due)"** buttons.
   When disabled, show a hint. If there are no words at all: "Add words or install
   the A1 pack". The A1 pack button arrives in Phase 5.
9. Tests:
   - Brainstorm: no back-to-back repeats; a wrong word is blocked for 2; the session
     ends when all steps pass; options are valid; sentences get only reveal/listen.
   - Review: exercise per repetitions, grading thresholds, lapse re-ask.
   - SRS: 1 → 3 → 3×ease.

**Done when:**
- Tests are green.
- On the phone, 5 new words take ~3–5 min with taps only, never back to back, and
  missed words come back.
- Every answer shows the full result panel.
- Learned words are due tomorrow, with one exercise per word in Review.

**Risks:**
- A small distractor pool before packs exist means fewer options (handled).
- If `listenChoose` has no audio, show the text and log it as chooseMeaning.

---

### Phase 5: Word packs (A1–B2) + grammar packs + download/import
**Goal:** Ready-made CEFR-levelled content. A1 is bundled; A2/B1/B2 and grammar packs
download from GitHub. Packs can also be imported from a file.

**Pack file format** (`format: 1`, UTF-8 JSON):
```json
{
  "format": 1,
  "id": "tr-a1-core", "version": 1, "kind": "words",
  "title": "A1 core words", "level": "A1",
  "license": "CC BY-SA 4.0", "attribution": "Wiktionary via kaikki.org; FrequencyWords (OpenSubtitles)",
  "words": [
    {"tr": "ev", "en": "house, home", "pos": "Noun", "rank": 12,
     "example": "Evde misin?", "example_en": "Are you at home?", "tags": ["home"]}
  ]
}
```
A grammar pack has `"kind": "grammar"` and
`"suffixes": [{"id": "Loc", "examples": [{"tr": "evde", "en": "at home"}, ...]}]`
(8–12 examples per suffix, preferring words from the same-level word pack).

**Index** (`packs/index.json` in the release repo):
`{"format":1,"packs":[{"id","title","kind","level","version","count","file":"tr-a2-core.json","sha256","size"}]}`.

**Files:** `tool/build_dictionary.dart` (new), `tool/LemmaCounter.java` (new),
`tool/build_packs.dart` (new), `tool/validate_pack.dart` (new),
`packs/` (generated JSON + `index.json`; published to the public repo),
`assets/dict/tr_en.db` (new), `assets/packs/tr-a1-core.json`,
`assets/packs/tr-a1-essentials.json`, `assets/packs/tr-grammar-a1.json` (bundled),
`pubspec.yaml` (assets, `sqlite3`, `file_picker`),
`lib/services/dictionary_service.dart` (new), `lib/domain/pack.dart` (new: model +
parser + validation), `lib/services/pack_service.dart` (new),
`lib/ui/screens/packs_screen.dart` (new), `lib/ui/screens/home_screen.dart`,
`lib/ui/screens/settings_screen.dart`, tests `test/pack_parse_test.dart`,
`test/pack_service_test.dart`, `test/dictionary_service_test.dart`.

**Steps (build tools run on the Mac, outside the app):**
1. **Inputs**, downloaded to `~/turkish-data/` and **not committed**:
   - the Turkish Wiktionary JSONL from kaikki.org (Turkish dictionary → raw JSONL
     download)
   - `tr_50k.txt` from the `hermitdave/FrequencyWords` repo
     (`content/2018/tr/tr_50k.txt`; OpenSubtitles-based; check its licence, see Open
     issues)
2. **`tool/build_dictionary.dart <kaikki.jsonl> assets/dict/tr_en.db`.**
   - Stream the file. Keep `lang_code=="tr"` and skip `form-of`/`alt-of` senses.
   - Table `entries(lemma, pos, glosses JSON ≤3 × ≤80 chars)` with
     `lemma = trNormalize(word)`, plus an index on `lemma`.
   - Print the count and size. If the file is over 25 MB, keep 2 glosses.
   - Commit the `.db` and add the attribution to the README.
3. **`tool/LemmaCounter.java`.** A single-file Java program, run as
   `java -cp android/app/libs/zemberek-full.jar tool/LemmaCounter.java ~/turkish-data/tr_50k.txt > ~/turkish-data/lemmas.tsv`.
   - For each `word count` line, analyze it with Zemberek and take the first
     analysis's lemma + primary POS.
   - Sum the counts per (lemma, pos).
   - Skip unknowns, `Punc`, `Num`, and proper nouns (`Prop` in the analysis).
   - Output `lemma\tpos\tcount`, sorted by count descending.
4. **`tool/build_packs.dart lemmas.tsv assets/dict/tr_en.db packs/`.**
   - Join each lemma with the dictionary (verbs try `lemma` and `lemma` without
     `-mak/-mek`). Drop lemmas with no gloss and interjections. `rank` = row
     index.
   - Band into levels by rank: **A1 1–600, A2 601–1500, B1 1501–3000,
     B2 3001–5000.**
   - `en` = the first gloss, shortened to ≤40 chars at a comma/semicolon.
   - Write `tr-a1-core.json`, `tr-a2-core.json`, `tr-b1-core.json`,
     `tr-b2-core.json` and `index.json` with each pack's sha256/size.
   - Also write a `review.csv` per pack so it can be spot-checked by hand.
5. **Hand-made packs**, written in a planning/implementation session (can be
   drafted with an LLM, then checked by the owner):
   - `tr-a1-essentials.json` (~150 words): numbers 0–20, tens, 100, 1000; days;
     months; colours; family; pronouns (`ben sen o biz siz onlar`);
     question words (`ne, kim, nerede, nereye, nereden, ne zaman, neden, nasıl, kaç`);
     greetings/politeness (`merhaba, teşekkürler, lütfen, evet, hayır, tamam`);
     body; food basics; time words (`bugün, yarın, dün, şimdi`).
   - Grammar packs `tr-grammar-a1/a2/b1/b2.json`: for each suffix ID at that level
     in `suffixGlosses`, 8–12 short example forms with English.
6. **`tool/validate_pack.dart <file>`** runs in CI or before publishing:
   - Schema check.
   - No duplicate `trNormalize(tr)`.
   - Non-empty `en`.
   - For grammar packs: run every example through Zemberek (same `java -cp`
     approach, through a small `tool/AnalyzeExamples.java`) and **fail** if the
     declared suffix ID isn't in the analysis.
   - Publish only packs that pass.
7. Publishing: packs live in this same public repo under `packs/`. Commit them and
   push to `main`; CI validates them. The app reads
   `https://raw.githubusercontent.com/<kReleaseRepo>/main/packs/index.json`. New or
   updated packs need **no app release**.

**Steps (in the app):**
8. `dictionary_service.dart`:
   - Copy the asset DB to the app support dir on first use (or when its size
     changes) and open it read-only with `sqlite3`.
   - `lookup(lemma)` tries exact, then ±`mek/mak` for verbs.
9. `lib/domain/pack.dart`: pure parse + validation, mirroring `validate_pack`
   (format == 1, required fields, levels, de-duplication). Returns `Pack` or
   throws `PackFormatException(message)`.
10. `pack_service.dart`:
    - `fetchIndex()`: GET the index URL. The URL is a setting whose default is
      built from `kReleaseRepo`.
    - `download(entry)`: GET the file and verify its sha256.
    - `importPack(Pack)`, in one transaction:
      - For words: upsert by `normalized`. An existing word keeps its SRS and
        `english` if `englishEdited`, otherwise its english is updated. Insert
        `WordPacks(rank)`, set `level` if null, `note = example`,
        `noteEn = example_en`, `needsAnalysis = true`.
      - For grammar packs: replace that pack's `MorphemeExamples` and insert
        missing `Morphemes`.
      - Upsert the `Packs` row with the version.
    - `removePack(id)`: delete words linked **only** to this pack **and** with
      `status = 'new'` (never studied). Learned words stay, with the link removed.
      Then delete the `Packs` row (its examples cascade).
    - `updatePack`: download the newer version, then import. Words that disappeared
      from the pack keep their progress; only the link is removed.
    - `importFromFile()`: `file_picker` (works without Google services through the
      system file picker) → parse → import.
    - On first launch with an empty DB, auto-import the bundled
      `tr-a1-essentials`, `tr-a1-core` and `tr-grammar-a1` only after the user taps
      "Install A1 starter" on Home (one button). Do not import silently.
11. `packs_screen.dart` (Settings → "Word packs", and a Home link):
    - Installed packs (title, level, word count, how many learned) with
      Update/Remove.
    - Available packs from the index (Download).
    - "Import from file".
    - Offline → show only installed packs plus a message.
12. The analysis job (Phase 3) processes pack words in the background. A1+A2 is
    ~1500 words, so in batches. Pack words already carry `en`, so they need no AI
    call.
13. Tests:
    - Pack parsing (valid, missing fields, bad format, duplicate words).
    - Import (dedupe with an own word keeps its SRS; `englishEdited` respected).
    - Remove (keeps learned words).
    - Update (new words added, links fixed).
    - Index parsing; sha mismatch rejected.
    - Dictionary lookup with the `gitmek`/`git` fallback.

**Done when:**
- `dart run tool/validate_pack.dart packs/*.json` passes.
- On a fresh install, "Install A1 starter" adds ~750 words and Brainstorm starts
  serving them, with own words first.
- Packs screen downloads A2 from GitHub, and B1 imports from a file copied to the
  phone.
- Removing an unused pack deletes only words that were never studied.

**Risks:**
- **Levels are approximate** (frequency-based, not an official CEFR list).
  Subtitle frequency over-weights spoken words (fine for manhwa) and under-weights
  some classroom A1 words, which is why the hand-made essentials pack exists.
- Wiktionary's first gloss is sometimes a rare sense. `review.csv` exists so the
  worst cases can be fixed by hand. Re-running the build overwrites manual fixes,
  so keep fixes in a `tool/overrides.tsv` (`lemma\ten`) that `build_packs` applies
  last.
- Zemberek may lemmatize a few frequent words wrongly. The overrides file covers
  that too.
- Bundled assets add a few MB (the dictionary + A1 JSON).

---

### Phase 6: Local-first translation + multi-provider AI + fast add flow
**Goal:** Most words translate offline and instantly. AI is rare, cached, and
switches provider on 429. Adding a word takes seconds, including from other apps.

**Files:** `lib/services/ai/ai_provider.dart`, `lib/services/ai/gemini_provider.dart`
(from `gemini_service.dart`), `lib/services/ai/openai_compatible_provider.dart` (new),
`lib/services/translation_pipeline.dart` (new; absorbs `translation_service.dart`),
`lib/services/settings_service.dart`, `lib/ui/screens/add_word_screen.dart` (rewrite),
`lib/ui/screens/settings_screen.dart`, `MainActivity.kt`, `AndroidManifest.xml`,
`test/translation_pipeline_test.dart`.

**Steps:**
1. AI layer:
   - `AiProvider { name; Future<AiResult> complete(system, user) }`, where
     `AiResult` is ok(text) or error(rateLimited|auth|notFound|network|other).
   - `GeminiProvider`: model list editable in Settings. Every non-200 status maps
     to an error kind: 429 → rateLimited; 404 → try the next model.
   - `OpenAiCompatibleProvider(baseUrl, model, key)`: POST `/chat/completions`
     with `response_format: json_object`, `temperature: 0.2`. On a 400, retry once
     without `response_format` and strip ```json fences.
2. `translation_pipeline.dart` `translate(text, {context})`:
   1. Check the cache (`kind|trNormalize(text)`).
   2. **Local:** Zemberek + the dictionary (Phase 5) + suffix glosses, giving
      `literal` ("house + plural + our + in"). Also check whether the word already
      exists in an installed pack (use its `en`).
   3. Use local without AI when it's a single word whose lemma is in the
      dictionary or a pack, with ≤1 suffix.
   4. Otherwise call AI **once**, going through the providers in order. A provider
      that returns rateLimited cools down for 10 min. The prompt includes the
      context sentence, the breakdown with IDs/glosses, and the dictionary gloss.
      Response JSON: `{"translation","alternatives":[],"note"}`.
   5. Then MyMemory, then `literal`.
   6. Cache the result, and return `source` + `warning`. Count AI calls per day in
      prefs.
3. **Add-word rewrite.**
   - Fields: Turkish, Context sentence (→ `note`), English (auto-filled), Source
     (remembers the last value).
   - 400 ms debounced *local* analysis while typing: breakdown + gloss, filling
     English unless the user has edited it.
   - A source chip (dictionary / pack / AI: gemini / AI: groq / MyMemory) and an
     "Ask AI" icon.
   - Phrases call AI only on Done, the "Translate" button, or Save with English
     empty.
   - Token chips toggle "also save this word as a card" (off by default).
   - **Save** and **Save & add another**. Save never waits for the network. Typing
     in English sets `englishEdited = true`.
4. **Capture from other apps.**
   - Manifest: intent filters for `PROCESS_TEXT` (text/plain, label "Add to Turkish
     Vocab") and `SEND` (text/plain).
   - `MainActivity.kt`: read `EXTRA_PROCESS_TEXT`/`EXTRA_TEXT` in `onCreate` /
     `onNewIntent`, expose `getSharedText` (consume once), and push
     `invokeMethod("sharedText")`.
   - Dart opens `AddWordScreen(initialText)`.
5. Settings "Translation":
   - Ordered provider list: Gemini + up to 2 OpenAI-compatible entries, each with
     a Test button.
   - Daily AI call counter.
   - Replace the stale "1 500 requests/day" text.
6. Delete `gemini_service.dart` and `translation_service.dart`.
7. Tests (fake providers/dictionary):
   - A dictionary word → 0 AI calls.
   - A phrase → 1 call, then a cache hit.
   - A 429 → the next provider, with a warning.
   - All fail → MyMemory → literal.
   - Bad JSON → falls through.

**Done when:**
- Tests are green.
- In airplane mode, `evlerimizde` shows the breakdown + gloss in ~0.5 s and saves.
- A sentence uses ≤1 AI call, and repeats use 0.
- Selecting text in the browser → "Add to Turkish Vocab" opens prefilled.
- 5 words added in under a minute.

**Risks:**
- `PROCESS_TEXT` depends on the ROM; Share is the fallback.
- Model names change. Keep them editable in one place.

---

### Phase 7: Reliable audio (ElevenLabs prefetch + offline Piper)
**Goal:** Every word has audio, even offline and without Google services, and
failures are visible.

**Files:** `pubspec.yaml` (`sherpa_onnx`, `archive`), `lib/services/audio_service.dart`
(refactor of `tts_service.dart`), `lib/services/piper_engine.dart` (new),
`lib/services/audio_prefetch_queue.dart` (new), `lib/ui/screens/settings_screen.dart`,
`lib/ui/screens/session_screen.dart`, `test/audio_service_test.dart` (new).

**Steps:**
1. `audio_service.dart` → `speak(text) → AudioOutcome`. Try in order:
   1. A cached file (`el_<voice>_<sha1>`, then `piper_<sha1>`).
   2. ElevenLabs (if configured, with a 15 s timeout).
   3. Piper (if installed).
   4. `flutter_tts`, only if `isLanguageAvailable('tr-TR')`.
   5. Otherwise `unavailable(reason)`.

   On `unavailable`, show a SnackBar once per session: "No Turkish voice: download
   the offline voice in Settings".
2. `piper_engine.dart` (`sherpa_onnx`, Flutter Android support since 1.10.7; pin
   the current version):
   - `isInstalled`.
   - `download(onProgress)` of the sherpa-onnx `vits-piper-tr_TR-dfki-medium`
     archive from the sherpa-onnx `tts-models` GitHub release. Check the exact URL
     and that it includes `espeak-ng-data`. Extract with `archive` to app support.
   - `synthesize(text) → wav` with one long-lived `OfflineTts`, off the UI thread.
   - Settings: Download (~60 MB) / Installed ✓ Delete / Test.
3. ElevenLabs:
   - `model_id` comes from a setting, default `eleven_multilingual_v2`.
   - 401/429/quota errors → fall through to Piper.
   - Settings shows the remaining characters from `GET /v1/user/subscription`.
4. `audio_prefetch_queue.dart` (sequential worker, fails quietly):
   - Enqueue **manually added words** on save.
   - When a Brainstorm session is built, enqueue the **next 2 rounds' worth** of new
     words. Pack words are *not* enqueued at import, because thousands of words
     would burn the ElevenLabs quota.
   - Prefer ElevenLabs for own words and Piper for pack words (setting:
     "ElevenLabs for pack words", default off).
   - Settings "Download audio for my words": count the characters, compare against
     the remaining quota, and confirm.
5. Autoplay in the result panel and `listenChoose` goes through `AudioService`.
6. Tests (fake engines): fallback order, EL 429 → Piper, stable cache keys, and pack
   words routed to Piper by default.

**Done when:**
- Without an ElevenLabs key and with Piper installed, airplane mode plays audio for
  any word.
- With ElevenLabs set, own words added online play offline later.
- With neither, a clear message appears instead of silence.

**Risks:**
- `sherpa_onnx` native libs add ~10–20 MB (arm64 only, see Phase 2).
- The first synthesis takes ~0.5–1 s per word; after that it's cached.
- Confirm the dfki voice licence (a survey lists it as MIT); fahrettin/fettah are
  male alternatives.

---

### Phase 8: Suffix drill with CEFR levels
**Goal:** A short separate drill that teaches suffixes level by level, using grammar
pack examples and your own words.

**Files:** `lib/domain/suffix_drill_session.dart` (new),
`lib/data/morpheme_repository.dart` (new), `lib/ui/screens/suffix_drill_screen.dart` (new),
`lib/ui/screens/suffix_list_screen.dart` (new), `lib/ui/screens/home_screen.dart`,
`lib/services/settings_service.dart`, `test/suffix_drill_session_test.dart`.

**Steps:**
1. Setting `grammarLevel` (default A1; options A1, A2, B1, B2). A suffix is
   drillable when its `level` ≤ `grammarLevel` and it has ≥1 example, from
   `MorphemeExamples` or from the user's own `WordMorphemes`.
2. `suffix_drill_session.dart` (pure Dart), 10 questions: due morphemes first, then
   up to 3 new ones, lowest level first.
   - Example source: prefer the user's own words (more meaningful), otherwise
     pack examples. Pick a different one each time when possible.
   - Question: the word with the target suffix highlighted (`ev·ler·`**`imiz`**`·de`)
     plus the word's English. The user picks the meaning from 4 glosses, with
     distractors from the **same category** first.
   - Grading and scheduling: `reviewWord` on the `Morphemes` SRS columns. Wrong →
     one re-ask at the end.
3. `suffix_drill_screen.dart` reuses the session layout and result panel (gloss,
   label, category, level, 2–3 more examples).
4. Home: a third button "Suffix drill (K due)". Stats links to
   `suffix_list_screen.dart`: suffixes grouped by level, with gloss, examples and
   mastery. A prompt "A1 grammar 80% learned: unlock A2?" raises `grammarLevel`.
5. Tests: the level gate, example source preference, same-category distractors,
   the answer appearing exactly once, and ≤10 questions.

**Done when:**
- Tests are green.
- On a fresh install with the A1 starter, the drill offers A1 suffixes (`Loc`,
  `A3pl`, possessives...) with pack examples.
- Adding `evlerimizde` makes it appear as an example.
- `ler`/`lar` count as one suffix (`A3pl`).

**Risks:** A wrong Zemberek analysis gives a wrong example. Pack examples are
validated in Phase 5, and own words can be re-analyzed or edited.

---

## Open issues (questions for the owner)

1. **GitHub repo:** decided, this app's repo becomes public, with CI/CD releases
   and packs in it. Still needed: the `owner/repo` slug for `kReleaseRepo` (there's
   no git remote yet). Phase 2 step 0 covers the pre-publish secret check.
2. **Keystore:** where will you back up `turkish_vocab.jks` and its passwords? If
   it's lost, future updates can't install over the app.
3. **CEFR accuracy:** are frequency-based levels (approximate) plus a hand-made A1
   essentials list OK, or do you want the A1/A2 lists fully curated by hand/LLM?
   That means more manual review time. Also confirm you're fine with the licences:
   Wiktionary/kaikki CC BY-SA, and FrequencyWords content (check the repo's
   licence; it's believed to be CC BY-SA 4.0).
4. **Second AI provider (secrets):** which free tier for the 429 fallback: Groq,
   OpenRouter or Mistral? You create the key. Also, in AI Studio, check that
   `gemini-3.8-flash` / `gemini-3.5-flash-lite` (hardcoded in `gemini_service.dart`)
   are valid. A 404 is skipped silently today. Public free-tier figures disagree
   (some say ~20–50 requests/day for Flash), so check your AI Studio rate-limit page.
5. **ElevenLabs:** a native Turkish voice from the Voice Library instead of the
   English-native presets? A cheaper Flash model? Either one changes cost and
   voice.
6. **Manhwa capture:** is the text you read selectable, or in images? If images,
   a later phase could add screenshot OCR. ML Kit's *bundled* text recognizer
   should work without Google services, but that needs checking on your phone.
7. **Brainstorm defaults:** 5 words per round, typing off, auto-advance, and own
   words before pack words. OK?
8. **Offline voice:** OK to download ~60 MB from GitHub (sherpa-onnx releases) once?
   Female `dfki` or a male voice?
9. **Zemberek speed:** how long does the first analysis take after opening the app,
   and has it ever frozen there?

---

## Status

- [ ] Phase 1: Stop the bleeding (no schema change)
- [ ] Phase 2: Public repo, CI/CD releases, in-app updater with one-time patch-notes alert
- [ ] Phase 3: Fresh schema v2, morphology IDs, breakdown on cards
- [ ] Phase 4: Brainstorm + per-word review
- [ ] Phase 5: Word packs A1–B2 + grammar packs + download/import
- [ ] Phase 6: Local-first translation, multi-provider AI, fast add flow, share-to-app
- [ ] Phase 7: Reliable audio (ElevenLabs prefetch + offline Piper)
- [ ] Phase 8: Suffix drill with CEFR levels
