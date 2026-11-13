package com.turkishvocab.turkish_vocab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val channel = "turkish_morphology"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

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
                    // Zemberek is slow on first use: keep it off the main thread.
                    executor.execute {
                        val analysis = MorphologyPlugin.analyze(word)
                        // null → Dart side uses its fallback (root = word)
                        mainHandler.post { result.success(analysis) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
