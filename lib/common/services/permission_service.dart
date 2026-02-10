import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/common/services/sentry_service.dart';

class PermissionService {
  static const _batteryOptKey = 'battery_optimization_prompted';
  static const _autoStartKey = 'auto_start_prompted';

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
