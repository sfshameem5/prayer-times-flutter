package com.example.prayer_times.alarm

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.util.Log
import android.view.View
import android.view.WindowManager
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import com.example.prayer_times.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmActivity : Activity() {
    companion object {
        private const val TAG = "AlarmActivity"
    }

    private var wakeLock: PowerManager.WakeLock? = null

    @Suppress("DEPRECATION")
    override fun onCreate(savedInstanceState: Bundle?) {
        // Set show-when-locked BEFORE super.onCreate() for maximum reliability
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        super.onCreate(savedInstanceState)

        // Acquire a FULL_WAKE_LOCK to guarantee the screen turns on
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
            PowerManager.ACQUIRE_CAUSES_WAKEUP or
            PowerManager.ON_AFTER_RELEASE,
            "PrayerTimes:AlarmActivityWakeLock"
        ).apply {
            acquire(5L * 60 * 1000) // 5 minutes max
        }

        // For pre-O_MR1 devices, use legacy window flags (setShowWhenLocked/setTurnScreenOn above handle O_MR1+)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }

        // Keep screen on while alarm is showing
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        setContentView(R.layout.activity_alarm)

        val alarmId = intent.getIntExtra("alarm_id", -1)
        val title = intent.getStringExtra("alarm_title") ?: "Prayer Time"
        val body = intent.getStringExtra("alarm_body") ?: ""
        val timestamp = intent.getLongExtra("alarm_timestamp", System.currentTimeMillis())

        Log.d(TAG, "AlarmActivity created: id=$alarmId, title=$title")

        // Set prayer name
        val prayerNameView = findViewById<TextView>(R.id.prayer_name)
        prayerNameView.text = title

        // Set prayer time
        val prayerTimeView = findViewById<TextView>(R.id.prayer_time)
        val timeFormat = SimpleDateFormat("h:mm a", Locale.getDefault())
        prayerTimeView.text = timeFormat.format(Date(timestamp))

        // Set prayer body
        val prayerBodyView = findViewById<TextView>(R.id.prayer_body)
        prayerBodyView.text = body

        // Set prayer icon based on name
        val iconView = findViewById<ImageView>(R.id.prayer_icon)
        setPrayerIcon(iconView, title)

        // Dismiss button
        val dismissButton = findViewById<View>(R.id.btn_dismiss)
        dismissButton.setOnClickListener {
            dismissAlarm()
        }

        // Snooze button
        val snoozeButton = findViewById<View>(R.id.btn_snooze)
        snoozeButton.setOnClickListener {
            snoozeAlarm()
            snoozeButton.isEnabled = false
            snoozeButton.alpha = 0.5f
        }
    }

    private fun setPrayerIcon(iconView: ImageView, title: String) {
        val lowerTitle = title.lowercase()
        val iconRes = when {
            lowerTitle.contains("fajr") -> android.R.drawable.btn_star_big_on
            lowerTitle.contains("sunrise") -> android.R.drawable.btn_star_big_on
            lowerTitle.contains("dhuhr") || lowerTitle.contains("luhr") -> android.R.drawable.btn_star_big_on
            lowerTitle.contains("asr") -> android.R.drawable.btn_star_big_on
            lowerTitle.contains("magrib") || lowerTitle.contains("maghrib") -> android.R.drawable.btn_star_big_on
            lowerTitle.contains("isha") -> android.R.drawable.btn_star_big_on
            else -> android.R.drawable.btn_star_big_on
        }
        iconView.setImageResource(iconRes)
    }

    private fun dismissAlarm() {
        Log.d(TAG, "Dismissing alarm")
        releaseWakeLock()
        val stopIntent = Intent(this, AlarmFiringService::class.java).apply {
            action = "STOP"
        }
        startService(stopIntent)
        finishAndRemoveTask()
    }

    private fun snoozeAlarm() {
        Log.d(TAG, "Snoozing alarm")
        releaseWakeLock()
        val snoozeIntent = Intent(this, AlarmFiringService::class.java).apply {
            action = "SNOOZE"
        }
        startService(snoozeIntent)
        finishAndRemoveTask()
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) it.release()
            }
            wakeLock = null
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing wake lock: ${e.message}")
        }
    }

    override fun onDestroy() {
        releaseWakeLock()
        super.onDestroy()
    }

    override fun onBackPressed() {
        // Prevent back button from dismissing the alarm screen
        // User must use dismiss or snooze buttons
    }
}
