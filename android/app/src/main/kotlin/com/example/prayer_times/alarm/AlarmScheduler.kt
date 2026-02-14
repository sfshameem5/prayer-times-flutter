package com.example.prayer_times.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmScheduler(private val context: Context) {
    companion object {
        private const val TAG = "AlarmScheduler"
    }

    private val alarmManager: AlarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    private val storage = AlarmStorage(context)

    fun schedule(alarm: AlarmData) {
        storage.saveAlarm(alarm)

        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.prayer_times.ALARM_FIRED"
            putExtra("alarm_id", alarm.id)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Create a show intent that opens the app when the user taps the alarm clock icon
        val showIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("alarm_id", alarm.id)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val showPendingIntent = PendingIntent.getActivity(
            context,
            alarm.id,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmClockInfo = AlarmManager.AlarmClockInfo(
            alarm.timestamp,
            showPendingIntent
        )

        try {
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            Log.d(TAG, "Alarm scheduled: id=${alarm.id}, time=${alarm.timestamp}, title=${alarm.title}")
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException scheduling alarm: ${e.message}")
        }
    }

    fun cancel(alarmId: Int) {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = "com.example.prayer_times.ALARM_FIRED"
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        storage.removeAlarm(alarmId)
        Log.d(TAG, "Alarm cancelled: id=$alarmId")
    }

    fun cancelAll() {
        val alarms = storage.getAllAlarms()
        alarms.forEach { cancel(it.id) }
        storage.clearAll()
        Log.d(TAG, "All alarms cancelled")
    }

    fun rescheduleAll() {
        val alarms = storage.getAllAlarms()
        val now = System.currentTimeMillis()

        alarms.forEach { alarm ->
            if (alarm.timestamp > now) {
                schedule(alarm)
                Log.d(TAG, "Rescheduled alarm: id=${alarm.id}")
            } else {
                storage.removeAlarm(alarm.id)
                Log.d(TAG, "Removed expired alarm: id=${alarm.id}")
            }
        }
    }
}
