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
        val id = intent?.getIntExtra("id", 0) ?: 0
        val label = intent?.getStringExtra("label") ?: "Wake Up!"
        val soundPath = intent?.getStringExtra("soundPath") ?: ""
        currentAlarmId = id
        currentAlarmLabel = label
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

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("WAKELOCK ALARM RINGING")
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

        startRingingAndVibration(soundPath)

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
        // Start sound
        try {
            mediaPlayer = MediaPlayer().apply {
                var sourceSet = false
                if (soundPath.isNotEmpty()) {
                    try {
                        Log.d(TAG, "Attempting to play custom audio from path/URI: $soundPath")
                        val uri = android.net.Uri.parse(soundPath)
                        setDataSource(applicationContext, uri)
                        sourceSet = true
                    } catch (e: Exception) {
                        Log.w(TAG, "Could not play custom audio path $soundPath via Uri, trying direct file path", e)
                        try {
                            setDataSource(soundPath)
                            sourceSet = true
                        } catch (e2: Exception) {
                            Log.e(TAG, "Direct file path also failed, falling back to default ringtone", e2)
                        }
                    }
                }
                if (!sourceSet) {
                    var alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    if (alarmUri == null) {
                        alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                    }
                    setDataSource(applicationContext, alarmUri)
                }
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                isLooping = true
                prepare()
                start()
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
