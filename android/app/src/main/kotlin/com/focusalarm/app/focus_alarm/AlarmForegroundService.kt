package com.focusalarm.app.focus_alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmForegroundService : Service() {
    companion object {
        const val TAG = "AlarmForegroundService"
        const val CHANNEL_ID = "focus_alarm_channel"
        const val NOTIFICATION_ID = 9999

        var isRinging: Boolean = false
            private set
        var currentAlarmId: Int = 0
            private set
        var currentAlarmLabel: String = ""
            private set
        var currentSoundPath: String = ""
            private set
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate called inside AlarmForegroundService.")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == "PAUSE_RING") {
            Log.d(TAG, "PAUSE_RING received in AlarmForegroundService")
            try {
                if (mediaPlayer?.isPlaying == true) {
                    mediaPlayer?.pause()
                }
                vibrator?.cancel()
            } catch (e: Exception) {
                Log.e(TAG, "Error pausing audio/vibration", e)
            }
            return START_STICKY
        } else if (action == "RESUME_RING") {
            Log.d(TAG, "RESUME_RING received in AlarmForegroundService")
            try {
                if (mediaPlayer == null) {
                    startRingingAndVibration(currentSoundPath)
                } else {
                    mediaPlayer?.start()
                    startVibrationOnly()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error resuming audio/vibration", e)
            }
            return START_STICKY
        }

        val id = intent?.getIntExtra("id", 0) ?: 0
        val label = intent?.getStringExtra("label") ?: "Wake Up!"
        val soundPath = intent?.getStringExtra("soundPath") ?: ""
        currentAlarmId = id
        currentAlarmLabel = label
        currentSoundPath = soundPath
        isRinging = true

        Log.d(TAG, "onStartCommand for alarm id=$id label=$label soundPath=$soundPath")

        // Acquire WakeLock to keep processor awake while alarm rings
        acquireWakeLock()

        // Build Full Screen Intent targeting RingingActivity
        val ringingIntent = Intent(this, RingingActivity::class.java).apply {
            putExtra("id", id)
            putExtra("label", label)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_NO_USER_ACTION
            )
        }

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            id,
            ringingIntent,
            pendingIntentFlags
        )

        val notifTitle = if (id >= 90000) "WAKE-UP CHECK-IN" else "WAKELOCK ALARM RINGING"
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(notifTitle)
            .setContentText(label)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK or ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
                } else {
                    startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
                }
            } catch (e: Exception) {
                Log.w(TAG, "startForeground with service type failed, falling back to basic startForeground", e)
                startForeground(NOTIFICATION_ID, notification)
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Also launch RingingActivity directly
        try {
            startActivity(ringingIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to direct startActivity, relying on fullScreenIntent", e)
        }

        // For Wake-Up Verification Check (id >= 90000), do NOT start ringing until 60s timeout
        if (id < 90000) {
            startRingingAndVibration(soundPath)
        } else {
            Log.d(TAG, "Wake-up check-in initialized silently for id=$id. Waiting for 60s timeout before ringing.")
        }

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "WakeLock High Priority",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for WakeLock wake-up alarms"
                setSound(null, null) // Sound is handled via MediaPlayer directly
                enableVibration(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "FocusAlarm::ServiceRingingWakeLock"
            ).apply {
                acquire(30 * 60 * 1000L) // Hold up to 30 minutes maximum
            }
        }
    }

    private fun startRingingAndVibration(soundPath: String) {
        if (mediaPlayer != null) {
            try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
                mediaPlayer = null
            } catch (e: Exception) {
                Log.e(TAG, "Error resetting existing mediaPlayer", e)
            }
        }

        // Start sound
        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                isLooping = true

                var sourceSet = false
                if (soundPath.isNotEmpty()) {
                    try {
                        val file = java.io.File(soundPath)
                        if (file.exists()) {
                            setDataSource(soundPath)
                            sourceSet = true
                            Log.d(TAG, "Successfully setDataSource to custom file path: $soundPath")
                        } else {
                            val uri = android.net.Uri.parse(soundPath)
                            setDataSource(applicationContext, uri)
                            sourceSet = true
                            Log.d(TAG, "Successfully setDataSource to custom URI: $soundPath")
                        }
                    } catch (e: Exception) {
                        Log.w(TAG, "Failed to load custom audio $soundPath, trying system ringtones", e)
                        sourceSet = false
                    }
                }

                if (!sourceSet) {
                    val ringtoneTypes = arrayOf(
                        RingtoneManager.TYPE_ALARM,
                        RingtoneManager.TYPE_RINGTONE,
                        RingtoneManager.TYPE_NOTIFICATION
                    )
                    for (type in ringtoneTypes) {
                        try {
                            val uri = RingtoneManager.getDefaultUri(type)
                            if (uri != null) {
                                reset()
                                setAudioAttributes(
                                    AudioAttributes.Builder()
                                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                        .setUsage(AudioAttributes.USAGE_ALARM)
                                        .build()
                                )
                                isLooping = true
                                setDataSource(applicationContext, uri)
                                sourceSet = true
                                Log.d(TAG, "Successfully setDataSource to system ringtone type=$type")
                                break
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Failed fallback system ringtone type=$type", e)
                        }
                    }
                }

                if (sourceSet) {
                    prepare()
                    start()
                } else {
                    Log.e(TAG, "All audio sources failed to initialize in MediaPlayer")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start MediaPlayer sound", e)
        }

        // Start vibration
        try {
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            val pattern = longArrayOf(0, 1000, 500, 1000, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start vibration", e)
        }
    }

    private fun startVibrationOnly() {
        try {
            if (vibrator == null) {
                vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                    vibratorManager.defaultVibrator
                } else {
                    @Suppress("DEPRECATION")
                    getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                }
            }
            val pattern = longArrayOf(0, 1000, 500, 1000, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to resume vibration", e)
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        if (isRinging) {
            Log.w(TAG, "Task removed while ringing! Restarting service and activity immediately.")
            val restartServiceIntent = Intent(applicationContext, AlarmForegroundService::class.java).apply {
                putExtra("id", currentAlarmId)
                putExtra("label", currentAlarmLabel)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(restartServiceIntent)
            } else {
                startService(restartServiceIntent)
            }
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy called inside AlarmForegroundService.")
        isRinging = false
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping mediaPlayer", e)
        }

        try {
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling vibrator", e)
        }

        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
            wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing wakeLock", e)
        }

        super.onDestroy()
    }
}
