package com.example.prayer_times.alarm

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import com.example.prayer_times.R

class AlarmFiringService : Service() {
    companion object {
        private const val TAG = "AlarmFiringService"
        const val CHANNEL_ID = "prayer_alarm_channel"
        const val NOTIFICATION_ID = 7777
        const val ACTION_ALARM_STOPPED = "com.example.prayer_times.ALARM_STOPPED"
        private const val AUTO_STOP_TIMEOUT_MS = 5L * 60 * 1000 // 5 minutes
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var vibrator: Vibrator? = null
    private val handler = Handler(Looper.getMainLooper())
    private var currentAlarmId: Int = -1
    private var currentAudioPath: String = ""
    private var currentIsTest: Boolean = false
    private var currentLocaleCode: String? = null
    private var isStopping: Boolean = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun attachBaseContext(newBase: Context?) {
        // Locale will be re-applied per-alarm in onStartCommand once we know the localeCode.
        // This initial override uses the stored preference as a best-effort default.
        val localized = newBase?.let { ctx ->
            val code = AlarmLocaleHelper.getLocaleCode(ctx)
            AlarmLocaleHelper.applyLocale(ctx, code)
        }
        super.attachBaseContext(localized ?: newBase)
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireWakeLock()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Handle stop/snooze actions from notification
        when (intent?.action) {
            "STOP" -> {
                stopAlarm()
                return START_NOT_STICKY
            }
            "SNOOZE" -> {
                snoozeAlarm()
                return START_NOT_STICKY
            }
        }

        val alarmId = intent?.getIntExtra("alarm_id", -1) ?: -1
        Log.d(TAG, "Service started for alarm: id=$alarmId")

        if (alarmId == -1) {
            stopSelf()
            return START_NOT_STICKY
        }

        currentAlarmId = alarmId
        isStopping = false

        val storage = AlarmStorage(this)
        val alarmData = storage.getAlarm(alarmId)

        if (alarmData == null) {
            Log.e(TAG, "Alarm data not found for id=$alarmId")
            stopSelf()
            return START_NOT_STICKY
        }

        currentAudioPath = alarmData.audioPath
        currentIsTest = alarmData.isTest
        currentLocaleCode = alarmData.localeCode

        // Remove from storage since it's now firing
        storage.removeAlarm(alarmId)

        // Cancel any stale notification with the same ID before re-posting.
        // This ensures the system treats the new fullScreenIntent as fresh and
        // auto-launches AlarmActivity when the screen is off/locked.
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.cancel(NOTIFICATION_ID + alarmId)

        // Start foreground with notification — use alarm-specific ID so
        // subsequent alarms don't reuse the same notification (which blocks fullScreenIntent)
        // Re-create the notification channel with the alarm's locale so channel name is localised
        val localizedCtx = AlarmLocaleHelper.applyLocale(this, alarmData.localeCode)
        createNotificationChannel(localizedCtx)

        startForeground(NOTIFICATION_ID + alarmId, buildNotification(alarmData, localizedCtx))

        // Start audio playback
        startAudio(currentAudioPath)

        // Start vibration
        startVibration()

        // Auto-stop after timeout
        handler.postDelayed({
            Log.d(TAG, "Auto-stopping alarm after timeout")
            stopAlarm()
        }, AUTO_STOP_TIMEOUT_MS)

        return START_NOT_STICKY
    }

    private fun createNotificationChannel(ctx: Context = this) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            // Recreate channel to ensure name/description refresh when locale changes
            manager.deleteNotificationChannel(CHANNEL_ID)

            val channel = NotificationChannel(
                CHANNEL_ID,
                ctx.getString(R.string.alarm_channel_name),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = ctx.getString(R.string.alarm_channel_description)
                setBypassDnd(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setSound(null, null) // We handle audio ourselves
                enableVibration(false) // We handle vibration ourselves
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(alarm: AlarmData, ctx: Context = this): Notification {
        val fullScreenIntent = Intent(this, AlarmActivity::class.java).apply {
            putExtra("alarm_id", alarm.id)
            putExtra("alarm_title", alarm.title)
            putExtra("alarm_body", alarm.body)
            putExtra("alarm_timestamp", alarm.timestamp)
            putExtra("alarm_is_test", alarm.isTest)
            putExtra("alarm_locale_code", alarm.localeCode)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }

        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            alarm.id,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Dismiss action
        val dismissIntent = Intent(this, AlarmActionReceiver::class.java).apply {
            action = "com.example.prayer_times.DISMISS_ALARM"
            putExtra("alarm_id", alarm.id)
        }
        val dismissPendingIntent = PendingIntent.getBroadcast(
            this,
            alarm.id + 10000,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder
            .setSmallIcon(R.drawable.ic_new)
            .setContentTitle(alarm.title)
            .setContentText(alarm.body)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setPriority(Notification.PRIORITY_MAX)
            .setOngoing(true)
            .setAutoCancel(false)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(
                Notification.Action.Builder(
                    null,
                    ctx.getString(R.string.alarm_action_dismiss),
                    dismissPendingIntent
                ).build()
            )

        // Only add snooze action for production alarms, never for test alarms
        if (!alarm.isTest) {
            val snoozeIntent = Intent(this, AlarmActionReceiver::class.java).apply {
                action = "com.example.prayer_times.SNOOZE_ALARM"
                putExtra("alarm_id", alarm.id)
            }
            val snoozePendingIntent = PendingIntent.getBroadcast(
                this,
                alarm.id + 20000,
                snoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.addAction(
                Notification.Action.Builder(
                    null,
                    ctx.getString(R.string.alarm_action_snooze),
                    snoozePendingIntent
                ).build()
            )
        }

        return builder.build()
    }

    private fun startAudio(audioPath: String) {
        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )

                // Set volume to max for alarm stream
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
                audioManager.setStreamVolume(
                    AudioManager.STREAM_ALARM,
                    maxVolume,
                    0
                )

                // Strict audio mapping:
                // - Test alarms: ALWAYS azaan_short (never azaan_full or azaan_fajr)
                // - Real alarms: fajr → azaan_fajr, all others → azaan_full
                val rawResId = if (currentIsTest) {
                    R.raw.azaan_short
                } else {
                    when {
                        audioPath.contains("fajr", ignoreCase = true) -> R.raw.azaan_fajr
                        else -> R.raw.azaan_full
                    }
                }
                Log.d(TAG, "Playing audio: isTest=$currentIsTest, audioPath=$audioPath, resId=$rawResId")

                val afd = resources.openRawResourceFd(rawResId)
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()

                isLooping = false
                prepare()
                start()

                setOnCompletionListener {
                    Log.d(TAG, "Audio playback completed, stopping alarm")
                    stopAlarm()
                }
            }
            Log.d(TAG, "Audio playback started")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting audio: ${e.message}")
        }
    }

    private fun startVibration() {
        try {
            vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            // Vibrate pattern: wait 0ms, vibrate 500ms, pause 1000ms, repeat
            val pattern = longArrayOf(0, 500, 1000, 500, 1000)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting vibration: ${e.message}")
        }
    }

    @Suppress("DEPRECATION")
    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
            PowerManager.ACQUIRE_CAUSES_WAKEUP or
            PowerManager.ON_AFTER_RELEASE,
            "PrayerTimes:AlarmWakeLock"
        ).apply {
            acquire(AUTO_STOP_TIMEOUT_MS)
        }
    }

    fun stopAlarm() {
        if (isStopping) {
            Log.d(TAG, "stopAlarm() already in progress, skipping")
            return
        }
        isStopping = true
        Log.d(TAG, "Stopping alarm")
        handler.removeCallbacksAndMessages(null)

        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
            mediaPlayer = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping media player: ${e.message}")
        }

        try {
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping vibrator: ${e.message}")
        }

        try {
            wakeLock?.let {
                if (it.isHeld) it.release()
            }
            wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing wake lock: ${e.message}")
        }

        // Clear all currently shown notifications from the tray (does not affect future scheduled ones)
        try {
            getSystemService(NotificationManager::class.java).cancelAll()
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling notifications: ${e.message}")
        }

        // Broadcast so AlarmActivity can finish itself
        try {
            val stoppedIntent = Intent(ACTION_ALARM_STOPPED)
            stoppedIntent.setPackage(packageName)
            sendBroadcast(stoppedIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error sending alarm stopped broadcast: ${e.message}")
        }

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    fun snoozeAlarm(snoozeMinutes: Int = 10) {
        // Never snooze test alarms
        if (currentIsTest) {
            Log.d(TAG, "Test alarm — snooze disabled, dismissing instead")
            stopAlarm()
            return
        }

        Log.d(TAG, "Snoozing alarm for $snoozeMinutes minutes")

        if (currentAlarmId != -1) {
            val storage = AlarmStorage(this)
            val snoozeTimestamp = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)

            // Use localized strings for snooze notification
            val localizedCtx = AlarmLocaleHelper.applyLocale(this, currentLocaleCode)
            val originalTitle = localizedCtx.getString(R.string.alarm_snoozed_title)
            val originalBody = localizedCtx.getString(R.string.alarm_snoozed_body, snoozeMinutes)

            val snoozeAlarm = AlarmData(
                id = currentAlarmId,
                timestamp = snoozeTimestamp,
                title = originalTitle,
                body = originalBody,
                audioPath = "",
                localeCode = currentLocaleCode
            )

            val scheduler = AlarmScheduler(this)
            scheduler.schedule(snoozeAlarm)
        }

        stopAlarm()
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }
}
