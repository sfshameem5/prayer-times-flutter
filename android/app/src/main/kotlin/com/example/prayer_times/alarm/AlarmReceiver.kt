package com.example.prayer_times.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra("alarm_id", -1)
        Log.d(TAG, "Alarm received: id=$alarmId")

        if (alarmId == -1) return

        // Read alarm data from storage so we can pass it to the activity
        val storage = AlarmStorage(context)
        val alarmData = storage.getAlarm(alarmId)

        // Start the foreground service for audio, vibration, and notification
        val serviceIntent = Intent(context, AlarmFiringService::class.java).apply {
            putExtra("alarm_id", alarmId)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        // Launch AlarmActivity directly from the BroadcastReceiver.
        // This works because AlarmManager.setAlarmClock() grants the receiver
        // a background activity start exemption for a few seconds.
        val activityIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("alarm_id", alarmId)
            putExtra("alarm_title", alarmData?.title ?: "Prayer Time")
            putExtra("alarm_body", alarmData?.body ?: "")
            putExtra("alarm_timestamp", alarmData?.timestamp ?: System.currentTimeMillis())
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        context.startActivity(activityIntent)
        Log.d(TAG, "AlarmActivity launched directly from receiver")
    }
}
