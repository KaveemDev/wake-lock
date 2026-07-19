package com.focusalarm.app.focus_alarm

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        const val TAG = "MainActivity"
        const val CHANNEL = "com.focusalarm.app/scheduler"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val timestampMillis = call.argument<Long>("timestampMillis") ?: 0L
                    val label = call.argument<String>("label") ?: "Wake Up!"
                    val soundPath = call.argument<String>("soundPath") ?: ""

                    Log.d(TAG, "MethodChannel scheduleAlarm id=$id timestampMillis=$timestampMillis label=$label soundPath=$soundPath")
                    val success = AlarmSchedulerHelper.scheduleAlarm(this, id, timestampMillis, label, soundPath)
                    result.success(success)
                }
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    Log.d(TAG, "MethodChannel cancelAlarm id=$id")
                    AlarmSchedulerHelper.cancelAlarm(this, id)
                    result.success(true)
                }
                "canScheduleExactAlarms" -> {
                    val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                        alarmManager?.canScheduleExactAlarms() == true
                    } else {
                        true
                    }
                    result.success(canSchedule)
                }
                else -> result.notImplemented()
            }
        }
    }
}
