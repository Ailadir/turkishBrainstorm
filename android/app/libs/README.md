# Zemberek JAR — setup instructions

The Turkish morphological analysis (root + suffix splitting) requires Zemberek-NLP.
Drop the jar here, then uncomment the gradle block, and the app will use real morphology.

## Steps

1. Download `zemberek-full-0.17.1.jar` (or latest) from:
   https://github.com/ahmetaa/zemberek-nlp/releases

2. Place it in this directory (`android/app/libs/`).

3. In `android/app/build.gradle.kts`, uncomment the `Zemberek dependency block`
   at the bottom of the file.

4. In `MorphologyPlugin.kt`, uncomment the import and the implementation body.

5. Run:
   ```
   flutter clean && flutter run
   ```

## Expected APK size impact
+30–50 MB (the Zemberek dictionary is bundled). Non-issue for a personal app.

## Without the jar
The app runs fully — `MorphologyPlugin.analyze()` returns `null`, the Dart
`MorphologyService` falls back to returning the whole word as the root with no
suffixes. You can edit the split manually on the Add Word / Edit Word screens.
