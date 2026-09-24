import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TurkishVocabApp(),
    ),
  );
}

class TurkishVocabApp extends ConsumerWidget {
  const TurkishVocabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm up morphology bridge on startup (fire-and-forget).
    // Ignore errors — the service falls back gracefully.
    ref.read(morphologyServiceProvider).analyze('test').ignore();

    return MaterialApp(
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
