package com.sunfire.app

import android.content.Intent
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        /** A7.5: action fired by SyncTileService to request a library sync. */
        const val ACTION_SYNC = "com.sunfire.app.ACTION_SYNC"
        private const val QUICK_ACTIONS_CHANNEL = "sunfire/quick_actions"
    }

    private var pendingSyncRequest = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QUICK_ACTIONS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "consumePendingSync") {
                    val pending = pendingSyncRequest
                    pendingSyncRequest = false
                    result.success(pending)
                } else if (call.method == "refreshWidget") {
                    // A7.4: push a widget refresh after Dart updates prefs.
                    try {
                        ContinueReadingWidget.refreshAll(this@MainActivity)
                    } catch (_: Exception) {}
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
        if (intent?.action == ACTION_SYNC) {
            pendingSyncRequest = true
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val display = window.context.display
                val modes = display?.supportedModes
                val maxMode = modes?.maxByOrNull { it.refreshRate }
                if (maxMode != null) {
                    val params = window.attributes
                    params.preferredDisplayModeId = maxMode.modeId
                    window.attributes = params
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val modes = window.windowManager.defaultDisplay.supportedModes
                val maxMode = modes?.maxByOrNull { it.refreshRate }
                if (maxMode != null) {
                    val params = window.attributes
                    params.preferredDisplayModeId = maxMode.modeId
                    window.attributes = params
                }
            }
        } catch (_: Exception) {}
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == ACTION_SYNC) {
            pendingSyncRequest = true
        }
    }
}
