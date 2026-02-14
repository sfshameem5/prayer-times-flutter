package com.example.prayer_times.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmActionReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmActionReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Action received: ${intent.action}")

        when (intent.action) {
            "com.example.prayer_times.DISMISS_ALARM" -> {
                val stopIntent = Intent(context, AlarmFiringService::class.java).apply {
                    action = "STOP"
                }
                context.stopService(stopIntent)
            }
            "com.example.prayer_times.SNOOZE_ALARM" -> {
                val snoozeIntent = Intent(context, AlarmFiringService::class.java).apply {
                    action = "SNOOZE"
                }
                context.startService(snoozeIntent)
            }
        }
    }
}
