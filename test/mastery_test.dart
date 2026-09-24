import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/mastery.dart';
import 'package:turkish_vocab/domain/practice_mode.dart';

void main() {
  group('Mastery', () {
    test('empty state is zero', () {
      expect(Mastery.overall({}), 0);
    });

    test('mode score clamps at 5 repetitions', () {
      expect(Mastery.modeScore(0), 0);
      expect(Mastery.modeScore(5), 1.0);
      expect(Mastery.modeScore(10), 1.0);
      expect(Mastery.modeScore(3), closeTo(0.6, 0.001));
    });

    test('fully mastered across all modes is 1.0', () {
      final m = Mastery.overall({
        PracticeMode.recognitionTrEn: 5,
        PracticeMode.recognitionEnTr: 5,
        PracticeMode.listening: 5,
        PracticeMode.writing: 5,
      });
      expect(m, closeTo(1.0, 0.001));
    });

    test('harder modes weigh more in the average', () {
      // Writing mastered, recognition not.
      final writingStrong = Mastery.overall({
        PracticeMode.recognitionTrEn: 0,
        PracticeMode.writing: 5,
      });
      // Recognition mastered, writing not.
      final recStrong = Mastery.overall({
        PracticeMode.recognitionTrEn: 5,
        PracticeMode.writing: 0,
      });
      // Weight writing=2, recognition=1 -> writingStrong = 2/3, recStrong = 1/3.
      expect(writingStrong, closeTo(2 / 3, 0.001));
      expect(recStrong, closeTo(1 / 3, 0.001));
      expect(writingStrong, greaterThan(recStrong));
    });
  });
}
