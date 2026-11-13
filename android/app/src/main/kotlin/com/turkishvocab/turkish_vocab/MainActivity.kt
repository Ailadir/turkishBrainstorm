package com.turkishvocab.turkish_vocab

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.core.content.FileProvider
import java.io.File
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val channel = "turkish_morphology"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    // Text from PROCESS_TEXT / SEND, waiting for Dart to pick it up once.
    private var pendingShared: String? = null
    private var shareChannel: MethodChannel? = null

    private fun sharedTextOf(i: Intent?): String? = when (i?.action) {
        Intent.ACTION_PROCESS_TEXT ->
            i.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        Intent.ACTION_SEND -> i.getStringExtra(Intent.EXTRA_TEXT)
        else -> null
    }?.trim()?.takeIf { it.isNotEmpty() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingShared = sharedTextOf(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val text = sharedTextOf(intent) ?: return
        val ch = shareChannel
        if (ch != null) ch.invokeMethod("sharedText", text) else pendingShared = text
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Pre-warm Zemberek off the main thread so the first analyze() call
        // isn't slow (build plan §5). No-op until the jar is in place.
        MorphologyPlugin.warmUp()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app_update"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "canInstall" ->
                    result.success(packageManager.canRequestPackageInstalls())
                "openInstallPermission" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:$packageName")
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    )
                    result.success(null)
                }
                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("no_path", "path missing", null)
                    } else {
                        try {
                            val uri = FileProvider.getUriForFile(
                                this, "$packageName.fileprovider", File(path)
                            )
                            startActivity(
                                Intent(Intent.ACTION_VIEW)
                                    .setDataAndType(
                                        uri,
                                        "application/vnd.android.package-archive"
                                    )
                                    .addFlags(
                                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                            Intent.FLAG_ACTIVITY_NEW_TASK
                                    )
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("install_failed", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        shareChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "share_intake"
        ).also { ch ->
            ch.setMethodCallHandler { call, result ->
                if (call.method == "getSharedText") {
                    result.success(pendingShared)
                    pendingShared = null
                } else result.notImplemented()
            }
        }

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
                        // null -> Dart side uses its fallback (lemma = word)
                        mainHandler.post { result.success(analysis) }
                    }
                }
                "analyzeSentence" -> {
                    val text = call.argument<String>("text") ?: ""
                    executor.execute {
                        val analysis = MorphologyPlugin.analyzeSentence(text)
                        mainHandler.post { result.success(analysis) }
                    }
                }
                "analyzeBatch" -> {
                    val words = call.argument<List<String>>("words") ?: emptyList()
                    executor.execute {
                        val analysis = MorphologyPlugin.analyzeBatch(words)
                        mainHandler.post { result.success(analysis) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
