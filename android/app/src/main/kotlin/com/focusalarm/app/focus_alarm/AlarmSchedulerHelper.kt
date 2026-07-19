package com.focusalarm.app.focus_alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

object AlarmSchedulerHelper {
    const val TAG = "AlarmSchedulerHelper"
    const val PREFS_NAME = "FocusAlarmPrefs"
    const val PREFS_KEY_ALARMS = "scheduled_alarms"

    fun scheduleAlarm(context: Context, id: Int, timestampMillis: Long, label: String, soundPath: String = ""): Boolean {
        Log.d(TAG, "Scheduling exact alarm id=$id label=$label soundPath=$soundPath for timestamp=$timestampMillis")
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w(TAG, "Cannot schedule exact alarms! Permission not granted.")
                return false
            }
        }

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("label", label)
            putExtra("timestampMillis", timestampMillis)
            putExtra("soundPath", soundPath)
        }

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            pendingIntentFlags
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestampMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, timestampMillis, pendingIntent)
            }
            saveToPrefs(context, id, timestampMillis, label, soundPath)
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error calling setExactAndAllowWhileIdle", e)
            return false
        }
    }

    fun cancelAlarm(context: Context, id: Int) {
        Log.d(TAG, "Cancelling alarm id=$id")
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getBroadcast(context, id, intent, pendingIntentFlags)
        alarmManager?.cancel(pendingIntent)
        removeFromPrefs(context, id)
    }

    private fun saveToPrefs(context: Context, id: Int, timestampMillis: Long, label: String, soundPath: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentSet = prefs.getStringSet(PREFS_KEY_ALARMS, mutableSetOf())?.toMutableSet() ?: mutableSetOf()
        // Remove existing entry for id if present
        currentSet.removeAll { it.startsWith("$id|") }
        // Format: id|timestampMillis|label|soundPath
        currentSet.add("$id|$timestampMillis|$label|$soundPath")
        prefs.edit().putStringSet(PREFS_KEY_ALARMS, currentSet).apply()
    }

    private fun removeFromPrefs(context: Context, id: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentSet = prefs.getStringSet(PREFS_KEY_ALARMS, mutableSetOf())?.toMutableSet() ?: return
        if (currentSet.removeAll { it.startsWith("$id|") }) {
            prefs.edit().putStringSet(PREFS_KEY_ALARMS, currentSet).apply()
        }
    }

    fun rescheduleAllFromPrefs(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentSet = prefs.getStringSet(PREFS_KEY_ALARMS, setOf()) ?: return
        val now = System.currentTimeMillis()
        Log.d(TAG, "Rescheduling ${currentSet.size} alarms from preferences after boot/timezone change.")

        val validAlarms = mutableSetOf<String>()
        for (entry in currentSet) {
            val parts = entry.split("|", limit = 4)
            if (parts.size >= 3) {
                val id = parts[0].toIntOrNull() ?: continue
                val timestampMillis = parts[1].toLongOrNull() ?: continue
                val label = parts[2]
                val soundPath = if (parts.size == 4) parts[3] else ""

                if (timestampMillis > now) {
                    scheduleAlarm(context, id, timestampMillis, label, soundPath)
                    validAlarms.add(entry)
                } else {
                    Log.d(TAG, "Alarm id=$id timestamp=$timestampMillis is in the past, removing from prefs.")
                }
            }
        }
        prefs.edit().putStringSet(PREFS_KEY_ALARMS, validAlarms).apply()
    }
}
