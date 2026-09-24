import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/data/database.dart';
import 'package:turkish_vocab/main.dart';
import 'package:turkish_vocab/providers/providers.dart';

void main() {
  testWidgets('home dashboard renders with empty DB', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const TurkishVocabApp(),
      ),
    );

    // Let futures resolve.
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Turkish Vocab'), findsOneWidget);
    expect(find.text('Add word'), findsOneWidget);
  });
}
