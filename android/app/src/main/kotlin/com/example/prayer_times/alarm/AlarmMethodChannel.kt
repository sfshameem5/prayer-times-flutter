package com.example.prayer_times.alarm

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AlarmMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "AlarmMethodChannel"
        const val CHANNEL_NAME = "com.example.prayer_times/alarm"
    }

    private val scheduler = AlarmScheduler(context)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scheduleAlarm" -> {
                try {
                    val id = call.argument<Int>("id") ?: throw IllegalArgumentException("id required")
                    val timestamp = call.argument<Number>("timestamp")?.toLong() ?: throw IllegalArgumentException("timestamp required")
                    val title = call.argument<String>("title") ?: "Prayer Time"
                    val body = call.argument<String>("body") ?: ""
                    val audioPath = call.argument<String>("audioPath") ?: ""

                    val alarm = AlarmData(
                        id = id,
                        timestamp = timestamp,
                        title = title,
                        body = body,
                        audioPath = audioPath
                    )

                    scheduler.schedule(alarm)
                    Log.d(TAG, "Alarm scheduled from Flutter: id=$id, timestamp=$timestamp")
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error scheduling alarm: ${e.message}")
                    result.error("SCHEDULE_ERROR", e.message, null)
                }
            }

            "cancelAlarm" -> {
                try {
                    val id = call.argument<Int>("id") ?: throw IllegalArgumentException("id required")
                    scheduler.cancel(id)
                    Log.d(TAG, "Alarm cancelled from Flutter: id=$id")
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error cancelling alarm: ${e.message}")
                    result.error("CANCEL_ERROR", e.message, null)
                }
            }

            "cancelAllAlarms" -> {
                try {
                    scheduler.cancelAll()
                    Log.d(TAG, "All alarms cancelled from Flutter")
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error cancelling all alarms: ${e.message}")
                    result.error("CANCEL_ALL_ERROR", e.message, null)
                }
            }

            "stopFiringAlarm" -> {
                try {
                    val stopIntent = Intent(context, AlarmFiringService::class.java).apply {
                        action = "STOP"
                    }
                    context.startService(stopIntent)
                    Log.d(TAG, "Stop firing alarm from Flutter")
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error stopping firing alarm: ${e.message}")
                    result.error("STOP_ERROR", e.message, null)
                }
            }

            "snoozeFiringAlarm" -> {
                try {
                    val snoozeIntent = Intent(context, AlarmFiringService::class.java).apply {
                        action = "SNOOZE"
                    }
                    context.startService(snoozeIntent)
                    Log.d(TAG, "Snooze firing alarm from Flutter")
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Error snoozing firing alarm: ${e.message}")
                    result.error("SNOOZE_ERROR", e.message, null)
                }
            }

            "getScheduledAlarms" -> {
                try {
                    val storage = AlarmStorage(context)
                    val alarms = storage.getAllAlarms()
                    val alarmList = alarms.map { alarm ->
                        mapOf(
                            "id" to alarm.id,
                            "timestamp" to alarm.timestamp,
                            "title" to alarm.title,
                            "body" to alarm.body,
                            "audioPath" to alarm.audioPath
                        )
                    }
                    result.success(alarmList)
                } catch (e: Exception) {
                    Log.e(TAG, "Error getting scheduled alarms: ${e.message}")
                    result.error("GET_ERROR", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }
}
