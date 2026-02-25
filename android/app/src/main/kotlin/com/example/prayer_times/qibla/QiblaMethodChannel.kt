package com.example.prayer_times.qibla

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class QiblaMethodChannel(
    messenger: BinaryMessenger,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val methodChannel = MethodChannel(messenger, CHANNEL_NAME)
    private val eventChannel = EventChannel(messenger, EVENTS_NAME)

    private var provider: QiblaProvider? = null
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val storedLat = call.argument<Double>("storedLat") ?: 0.0
                val storedLng = call.argument<Double>("storedLng") ?: 0.0
                val storedName = call.argument<String>("storedName") ?: ""
                startProvider(activity, storedLat, storedLng, storedName)
                PermissionUtils.requestLocationIfNeeded(activity)
                result.success(null)
            }
            "stop" -> {
                stopProvider()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun startProvider(context: Context, storedLat: Double, storedLng: Double, storedName: String) {
        stopProvider()
        provider = QiblaProvider(context) { update ->
            val payload = mapOf(
                "heading" to update.heading,
                "qiblaBearing" to update.qiblaBearing,
                "fallbackMode" to update.fallbackMode,
                "locationAccuracy" to update.locationAccuracy,
                "provider" to update.provider,
                "locationName" to storedName,
                "needsCalibration" to update.needsCalibration,
            )
            eventSink?.success(payload)
        }
        provider?.start(storedLat, storedLng, storedName)
    }

    private fun stopProvider() {
        provider?.stop()
        provider = null
    }

    companion object {
        const val CHANNEL_NAME = "com.example.prayer_times/qibla"
        const val EVENTS_NAME = "com.example.prayer_times/qibla/events"
    }
}
