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
        'isTest': data.isTest,
        'localeCode': data.localeCode,
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

  static Future<bool> canUseFullScreenIntent() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>(
        'canUseFullScreenIntent',
      );
      return result ?? true;
    } catch (e) {
      await SentryService.logString("Error checking full screen intent: $e");
      return true;
    }
  }

  static Future<void> requestFullScreenIntentPermission() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('requestFullScreenIntentPermission');
    } catch (e) {
      await SentryService.logString(
        "Error requesting full screen intent permission: $e",
      );
    }
  }

  static Future<void> openLockScreenNotifications() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('openLockScreenNotifications');
    } catch (e) {
      await SentryService.logString(
        "Error opening lock screen notifications: $e",
      );
    }
  }
}
