import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'services/share_intake.dart';
import 'services/update_flow.dart';
import 'ui/messenger.dart';
import 'ui/screens/add_word_screen.dart';
import 'ui/screens/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void _openAdd(String text) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => AddWordScreen(initialText: text)),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  // Warm up the Zemberek bridge once (fire-and-forget; falls back gracefully).
  container.read(morphologyServiceProvider).analyze('test').ignore();
  // Analyse any words still waiting for their morphology breakdown.
  container.read(analysisJobProvider).run().ignore();

  // Text sent from other apps ("Add to Turkish Vocab" / Share).
  ShareIntake.listen(_openAdd);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final text = await ShareIntake.initialText();
    if (text != null) _openAdd(text);
    // "What's new" / "new version" alerts (silent when offline).
    UpdateFlow(
      container.read(settingsServiceProvider),
      container.read(updateServiceProvider),
      container.read(appInstallerProvider),
      navigatorKey,
    ).run().ignore();
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TurkishVocabApp(),
    ),
  );
}

class TurkishVocabApp extends ConsumerWidget {
  const TurkishVocabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'Turkish Vocab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE30A17), // Turkish flag red
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE30A17),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
