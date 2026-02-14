import 'dart:io';

import 'package:flutter/services.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/services/sentry_service.dart';

class AlarmService {
  static const _channel = MethodChannel('com.example.prayer_times/alarm');

  static Future scheduleAlarm(AlarmModel data) async {
    if (!Platform.isAndroid) return;

    SentryService.logString(
      "Scheduling alarm for prayer ${data.heading} with timestamp ${data.timestamp}",
    );

    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'id': data.id,
        'timestamp': data.timestamp,
        'title': data.heading,
        'body': data.body,
        'audioPath': data.audioPath,
      });
    } catch (e) {
      await SentryService.logString("Error scheduling alarm: $e");
    }
  }

  static Future cancelAlarm(int id) async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('cancelAlarm', {'id': id});
    } catch (e) {
      await SentryService.logString("Error cancelling alarm: $e");
    }
  }

  static Future cancelAllAlarms() async {
    if (!Platform.isAndroid) return;

    await SentryService.logString("Cancelling all alarms");

    try {
      await _channel.invokeMethod('cancelAllAlarms');
    } catch (e) {
      await SentryService.logString("Error cancelling all alarms: $e");
    }
  }

  static Future stopFiringAlarm() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('stopFiringAlarm');
    } catch (e) {
      await SentryService.logString("Error stopping firing alarm: $e");
    }
  }

  static Future snoozeFiringAlarm() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('snoozeFiringAlarm');
    } catch (e) {
      await SentryService.logString("Error snoozing firing alarm: $e");
    }
  }
}
