package com.turkishvocab.turkish_vocab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "turkish_morphology"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Pre-warm Zemberek off the main thread so the first analyze() call
        // isn't slow (build plan §5). No-op until the jar is in place.
        MorphologyPlugin.warmUp()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "analyze" -> {
                    val word = call.argument<String>("word") ?: ""
                    val analysis = MorphologyPlugin.analyze(word)
                    if (analysis != null) {
                        result.success(analysis)
                    } else {
                        // null → Dart side uses its fallback (root = word)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
