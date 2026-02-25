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

        val alarm = storage.getAlarm(alarmId)

        if (alarm != null) {
            val serviceIntent = Intent(context, AlarmFiringService::class.java).apply {
                putExtra("alarm_id", alarm.id)
                putExtra("alarm_title", alarm.title)
                putExtra("alarm_body", alarm.body)
                putExtra("alarm_timestamp", alarm.timestamp)
                putExtra("alarm_audio_path", alarm.audioPath)
                putExtra("alarm_is_test", alarm.isTest)
                putExtra("alarm_locale_code", alarm.localeCode)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        }

        // Do NOT call startActivity() here. Rely solely on the notification's
        // fullScreenIntent to launch AlarmActivity (same pattern as Google Clock).
        // Direct startActivity() from a BroadcastReceiver is silently blocked on
        // Android 10+ when the screen is off, and it can interfere with the
        // system's fullScreenIntent auto-launch mechanism.
        Log.d(TAG, "AlarmFiringService started; relying on fullScreenIntent to launch AlarmActivity")
    }
}
