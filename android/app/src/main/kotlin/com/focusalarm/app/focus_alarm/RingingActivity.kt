package com.focusalarm.app.focus_alarm

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class RingingActivity : FlutterActivity() {
    companion object {
        const val TAG = "RingingActivity"
        const val CHANNEL = "com.focusalarm.app/ringing"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate called inside RingingActivity.")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            keyguardManager?.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        super.onCreate(savedInstanceState)
    }

    override fun getInitialRoute(): String {
        val id = intent.getIntExtra("id", 0)
        val label = intent.getStringExtra("label") ?: "Wake Up!"
        return "/ringing?id=$id&label=$label"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "stopAlarm" -> {
                    Log.d(TAG, "stopAlarm called from Dart.")
                    stopAlarmServiceAndFinish()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopAlarmServiceAndFinish() {
        try {
            val stopIntent = Intent(this, AlarmForegroundService::class.java)
            stopService(stopIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping AlarmForegroundService", e)
        }
        finish()
    }

    override fun onBackPressed() {
        // Do not allow back button to dismiss alarm without stopping/completing mission
        Log.d(TAG, "onBackPressed ignored while ringing.")
    }

    override fun onKeyDown(keyCode: Int, event: android.view.KeyEvent?): Boolean {
        if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_DOWN ||
            keyCode == android.view.KeyEvent.KEYCODE_VOLUME_MUTE ||
            keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP) {
            Log.d(TAG, "Volume key intercepted by RingingActivity.")
            return true // Consume event so volume doesn't drop
        }
        return super.onKeyDown(keyCode, event)
    }
}
