import 'package:flutter/services.dart';

/// Text handed to the app from outside: the "Add to Turkish Vocab" entry in
/// the text-selection menu, or Share → Turkish Vocab.
class ShareIntake {
  static const _channel = MethodChannel('share_intake');

  /// Text the app was launched with (consumed once), or null.
  static Future<String?> initialText() async {
    try {
      return await _channel.invokeMethod<String>('getSharedText');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Text delivered while the app is already running.
  static void listen(void Function(String text) onText) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText' && call.arguments is String) {
        onText(call.arguments as String);
      }
    });
  }
}
