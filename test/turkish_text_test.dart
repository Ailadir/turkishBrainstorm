import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_vocab/domain/turkish_text.dart';

void main() {
  test('trLower handles dotted/dotless I', () {
    expect(trLower('IŞIK'), 'ışık');
    expect(trLower('GİTTİ'), 'gitti');
    expect(trLower('İstanbul'), 'istanbul');
  });

  test('trNormalize trims, collapses and strips edge punctuation', () {
    expect(trNormalize('  "Evlerimizde!"  '), 'evlerimizde');
    expect(trNormalize('Eve   gidiyorum...'), 'eve gidiyorum');
    expect(trNormalize("Kitap'ta"), "kitap'ta");
  });

  test('stripDiacritics', () {
    expect(stripDiacritics('çığşöüğ'), 'cigsoug');
    expect(stripDiacritics('kâğıt'), 'kagit');
  });
}
