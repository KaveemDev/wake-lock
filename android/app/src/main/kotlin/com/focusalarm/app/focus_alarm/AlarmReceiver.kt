package com.focusalarm.app.focus_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "AlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Exact alarm triggered inside AlarmReceiver. onReceive called.")

        // Acquire temporary partial wake lock to prevent Doze sleep during service launch
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "FocusAlarm::AlarmReceiverWakeLock"
        )
        wakeLock.acquire(10000L) // 10 seconds max

        val id = intent.getIntExtra("id", 0)
        val label = intent.getStringExtra("label") ?: "Wake Up!"
        val timestampMillis = intent.getLongExtra("timestampMillis", System.currentTimeMillis())
        val soundPath = intent.getStringExtra("soundPath") ?: ""

        Log.d(TAG, "Triggering AlarmForegroundService and launching RingingActivity for alarm id=$id label=$label soundPath=$soundPath")

        val serviceIntent = Intent(context, AlarmForegroundService::class.java).apply {
            putExtra("id", id)
            putExtra("label", label)
            putExtra("timestampMillis", timestampMillis)
            putExtra("soundPath", soundPath)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        try {
            val ringingIntent = Intent(context, RingingActivity::class.java).apply {
                putExtra("id", id)
                putExtra("label", label)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val options = android.app.ActivityOptions.makeBasic()
                options.setPendingIntentBackgroundActivityStartMode(android.app.ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED)
                context.startActivity(ringingIntent, options.toBundle())
            } else {
                context.startActivity(ringingIntent)
            }
            Log.d(TAG, "Successfully launched RingingActivity directly from AlarmReceiver")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to direct launch RingingActivity from AlarmReceiver", e)
        }
    }
}
