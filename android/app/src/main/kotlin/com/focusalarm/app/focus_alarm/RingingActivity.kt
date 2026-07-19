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
                "pauseRing" -> {
                    Log.d(TAG, "pauseRing called from Dart.")
                    val pauseIntent = Intent(this@RingingActivity, AlarmForegroundService::class.java).apply {
                        action = "PAUSE_RING"
                    }
                    startService(pauseIntent)
                    result.success(true)
                }
                "resumeRing" -> {
                    Log.d(TAG, "resumeRing called from Dart.")
                    val resumeIntent = Intent(this@RingingActivity, AlarmForegroundService::class.java).apply {
                        action = "RESUME_RING"
                    }
                    startService(resumeIntent)
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

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (!hasFocus && AlarmForegroundService.isRinging) {
            Log.w(TAG, "Lost window focus while ringing (power dialog or status bar pulled). Pulling back on top!")
            try {
                val closeDialogsIntent = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                sendBroadcast(closeDialogsIntent)
            } catch (ignored: Exception) {}

            try {
                val pullBackIntent = Intent(this, RingingActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                }
                startActivity(pullBackIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to reorder to front on focus loss", e)
            }
        }
    }

    override fun onBackPressed() {
        // Do not allow back button to dismiss alarm without stopping/completing mission
        Log.d(TAG, "onBackPressed ignored while ringing.")
    }

    override fun onKeyDown(keyCode: Int, event: android.view.KeyEvent?): Boolean {
        if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_DOWN ||
            keyCode == android.view.KeyEvent.KEYCODE_VOLUME_MUTE ||
            keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP ||
            keyCode == android.view.KeyEvent.KEYCODE_APP_SWITCH) {
            Log.d(TAG, "System/Volume key intercepted by RingingActivity.")
            return true // Consume event so volume doesn't drop and app switch is blocked
        }
        return super.onKeyDown(keyCode, event)
    }
}
