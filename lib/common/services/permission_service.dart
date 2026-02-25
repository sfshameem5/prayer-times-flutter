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
  static const _notificationAskedKey = 'notification_permission_asked';

  /// Returns true if notification permission appears permanently denied.
  /// This happens when the user has denied the system popup and Android
  /// won't show it again.
  static Future<bool> isNotificationPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;
    final mmkv = MMKV.defaultMMKV();
    final askedBefore = mmkv.decodeBool(_notificationAskedKey);
    if (!askedBefore) return false;
    final granted = await NotificationService.checkPermissionStatus();
    return !granted;
  }

  /// Runs the permission flow based on the notification mode:
  /// - Default mode: only notification + exact alarm permissions
  /// - Azaan mode: notification + exact alarm + battery optimization + full-screen intent + auto-start
  /// Returns true only if all required permissions for the selected mode are granted.
  static Future<bool> requestFullNotificationPermissions({
    bool isAzaanMode = false,
  }) async {
    if (!Platform.isAndroid) return false;

    // Step 1: Notification + exact alarm permissions (always required)
    var notificationsGranted = false;
    var notificationStatus = await NotificationService.checkPermissionStatus();

    if (!notificationStatus) {
      var result = await NotificationService.requestNotificationPermissions();
      // Track that we've asked for notification permission
      final mmkv = MMKV.defaultMMKV();
      mmkv.encodeBool(_notificationAskedKey, true);
      notificationsGranted = result;
    } else {
      notificationsGranted = true;
    }

    // For Default mode, notification permission is all we need
    if (!isAzaanMode) {
      return notificationsGranted;
    }

    // --- Azaan mode: additional permissions ---

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

  /// Ensures basic alarm permissions (notification + exact alarm) are granted.
  /// Does NOT check or request full-screen intent — that is only done
  /// explicitly during onboarding or settings changes for Azaan mode.
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
  }

  /// Passive check: returns true if basic notification + exact alarm permissions are granted.
  static Future<bool> hasBasicNotificationPermissions() async {
    if (!Platform.isAndroid) return true;
    return await NotificationService.checkPermissionStatus();
  }

  /// Passive check: returns true if all Azaan-required permissions are granted
  /// (notification + exact alarm + battery optimization disabled + full-screen intent).
  static Future<bool> hasAllAzaanPermissions() async {
    if (!Platform.isAndroid) return true;

    final notifications = await NotificationService.checkPermissionStatus();
    if (!notifications) return false;

    final batteryOptEnabled =
        await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
    if (batteryOptEnabled) return false;

    final canUseFullScreen = await AlarmService.canUseFullScreenIntent();
    if (!canUseFullScreen) return false;

    return true;
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

  static Future<void> requestAllPermissions(
    BuildContext context, {
    bool isAzaanMode = false,
  }) async {
    if (!Platform.isAndroid) return;

    await ensureAlarmPermissions();
    if (!isAzaanMode) return;
    if (!context.mounted) return;
    await requestBatteryOptimization(context);
    if (!context.mounted) return;
    await requestAutoStart(context);
  }
}
