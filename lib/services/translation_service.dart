import 'dart:convert';
import 'package:http/http.dart' as http;

/// Free TR→EN translation via MyMemory (no API key needed, 1 000 req/day).
class TranslationService {
  Future<String?> translate(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    try {
      final uri = Uri.parse(
        'https://api.mymemory.translated.net/get'
        '?q=${Uri.encodeComponent(trimmed)}&langpair=tr|en',
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['responseData'] as Map<String, dynamic>?;
        final translated = data?['translatedText'] as String?;
        if (translated != null &&
            translated.trim().toLowerCase() != trimmed.toLowerCase()) {
          return translated.trim();
        }
      }
    } catch (_) {}
    return null;
  }
}
