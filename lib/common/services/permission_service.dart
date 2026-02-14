import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';

class PermissionService {
  static const _batteryOptKey = 'battery_optimization_prompted';
  static const _autoStartKey = 'auto_start_prompted';

  /// Runs the full permission flow matching the Settings notification toggle:
  /// 1. Request notification + exact alarm permissions
  /// 2. Check & request battery optimization disabling
  /// 3. Request auto-start if available
  /// Returns true only if notifications are granted AND battery optimization is disabled.
  static Future<bool> requestFullNotificationPermissions() async {
    if (!Platform.isAndroid) return false;

    // Step 1: Notification + exact alarm permissions
    var notificationsGranted = false;
    var notificationStatus = await NotificationService.checkPermissionStatus();

    if (!notificationStatus) {
      var result = await NotificationService.requestNotificationPermissions();
      notificationsGranted = result;
    } else {
      notificationsGranted = true;
    }

    // Step 2: Battery optimization
    var batteryOptimizationDisabled = true;
    var batteryOptEnabled =
        await BatteryOptimizationHelper.isBatteryOptimizationEnabled();

    if (batteryOptEnabled) {
      var result = await BatteryOptimizationHelperPlatform.instance
          .requestDisableBatteryOptimizationWithResult();
      batteryOptimizationDisabled = result;
    } else {
      batteryOptimizationDisabled = true;
    }

    // Step 3: Full-screen intent permission (Android 14+)
    // Required for the alarm to show as a full-screen activity on the lock screen
    final canUseFullScreen = await AlarmService.canUseFullScreenIntent();
    if (!canUseFullScreen) {
      await SentryService.logString(
        'Full-screen intent permission not granted, opening settings...',
      );
      await AlarmService.requestFullScreenIntentPermission();
    }

    // Step 4: Auto-start (best-effort, doesn't affect the result)
    if (notificationsGranted && batteryOptimizationDisabled) {
      try {
        final available = await isAutoStartAvailable ?? false;
        if (available) {
          await getAutoStartPermission();
        }
      } catch (_) {}
    }

    return notificationsGranted && batteryOptimizationDisabled;
  }

  static Future<void> ensureAlarmPermissions() async {
    if (!Platform.isAndroid) return;

    final androidImpl = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl == null) return;

    final canSchedule = await androidImpl.canScheduleExactNotifications();
    if (canSchedule != true) {
      await SentryService.logString(
        'Exact alarm permission not granted, requesting...',
      );
      await androidImpl.requestExactAlarmsPermission();
    }

    final notificationsEnabled = await androidImpl.areNotificationsEnabled();
    if (notificationsEnabled != true) {
      await SentryService.logString(
        'Notification permission not granted, requesting...',
      );
      await androidImpl.requestNotificationsPermission();
    }

    // Full-screen intent permission (Android 14+)
    final canUseFullScreen = await AlarmService.canUseFullScreenIntent();
    if (!canUseFullScreen) {
      await SentryService.logString(
        'Full-screen intent permission not granted, opening settings...',
      );
      await AlarmService.requestFullScreenIntentPermission();
    }
  }

  static Future<void> requestBatteryOptimization(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final mmkv = MMKV.defaultMMKV();
    final alreadyPrompted = mmkv.decodeBool(_batteryOptKey);
    if (alreadyPrompted) return;

    try {
      if (!context.mounted) return;

      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Battery Optimization'),
          content: const Text(
            'To ensure prayer alarms work reliably, please disable battery optimization for this app. '
            'This prevents the system from killing the app in the background.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
          openSettingsIfDirectRequestNotPossible: true,
        );
      }
    } catch (e) {
      await SentryService.logString(
        'Error requesting battery optimization: $e',
      );
    }

    mmkv.encodeBool(_batteryOptKey, true);
  }

  static Future<void> requestAutoStart(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final mmkv = MMKV.defaultMMKV();
    final alreadyPrompted = mmkv.decodeBool(_autoStartKey);
    if (alreadyPrompted) return;

    try {
      final available = await isAutoStartAvailable ?? false;

      if (available) {
        if (!context.mounted) return;

        final shouldRequest = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Auto-Start Permission'),
            content: const Text(
              'Your device may prevent prayer alarms from working in the background. '
              'Please enable auto-start for this app to ensure alarms ring on time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );

        if (shouldRequest == true) {
          await getAutoStartPermission();
        }
      }
    } catch (e) {
      await SentryService.logString('Error requesting auto-start: $e');
    }

    mmkv.encodeBool(_autoStartKey, true);
  }

  static Future<void> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;

    await ensureAlarmPermissions();
    if (!context.mounted) return;
    await requestBatteryOptimization(context);
    if (!context.mounted) return;
    await requestAutoStart(context);
  }
}
