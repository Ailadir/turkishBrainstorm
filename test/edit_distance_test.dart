import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/edit_distance.dart';

void main() {
  group('EditDistance.compute', () {
    test('identical strings → 0', () {
      expect(EditDistance.compute('kitap', 'kitap'), 0);
    });
    test('empty vs non-empty → full length', () {
      expect(EditDistance.compute('', 'abc'), 3);
      expect(EditDistance.compute('abc', ''), 3);
    });
    test('one substitution', () {
      expect(EditDistance.compute('kitap', 'kıtap'), 1);
    });
    test('one insertion', () {
      expect(EditDistance.compute('kita', 'kitap'), 1);
    });
    test('one deletion', () {
      expect(EditDistance.compute('kitapp', 'kitap'), 1);
    });
    test('completely different', () {
      expect(EditDistance.compute('abc', 'xyz'), 3);
    });
  });

  group('EditDistance.isCloseEnough', () {
    test('exact match passes', () {
      expect(EditDistance.isCloseEnough('kitap', 'kitap'), isTrue);
    });
    test('case-insensitive', () {
      expect(EditDistance.isCloseEnough('Kitap', 'kitap'), isTrue);
    });
    test('whitespace trimmed', () {
      expect(EditDistance.isCloseEnough(' kitap ', 'kitap'), isTrue);
    });
    test('1-char typo passes for word > 4 chars', () {
      // 'gelmek' → 'gelmek': "gelmek" len 6, one typo should pass
      expect(EditDistance.isCloseEnough('gelme', 'gelmek'), isTrue);
    });
    test('2-char diff fails by default tolerance', () {
      expect(EditDistance.isCloseEnough('gelm', 'gelmek'), isFalse);
    });
    test('short word (≤4 chars): no tolerance — must be exact', () {
      // 'git' → 'gıt' is 1 off but word length 3, so tolerance 0
      expect(EditDistance.isCloseEnough('git', 'gıt'), isFalse);
    });
    test('exact short word passes', () {
      expect(EditDistance.isCloseEnough('ev', 'ev'), isTrue);
    });
    test('explicit tolerance override', () {
      expect(EditDistance.isCloseEnough('abcd', 'abef', tolerance: 2), isTrue);
      expect(EditDistance.isCloseEnough('abcd', 'wxyz', tolerance: 2), isFalse);
    });
  });
}
