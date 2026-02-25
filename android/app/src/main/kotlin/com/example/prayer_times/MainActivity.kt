package com.example.prayer_times

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.prayer_times.alarm.AlarmMethodChannel
import com.example.prayer_times.qibla.QiblaMethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val alarmHandler = AlarmMethodChannel(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AlarmMethodChannel.CHANNEL_NAME
        ).setMethodCallHandler(alarmHandler)

        QiblaMethodChannel(flutterEngine.dartExecutor.binaryMessenger, this)
    }
}
