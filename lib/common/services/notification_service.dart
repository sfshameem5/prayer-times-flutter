import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final settingsService = SettingsService();

  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static var _notificationsInitialized = false;

  static Future<void> _notifyBackgroundUsage() async {
    if (!_notificationsInitialized) return;

    await scheduleNotification(
      NotificationModel(
        id: 005,
        heading: "Running work manager",
        body: "Work manager is being run",
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Future<void> _requestNotificationPermissions() async {
    // Only handle it for android
    if (!Platform.isAndroid) return;

    final androidImplementation = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future initialize({bool isBackground = false}) async {
    if (_notificationsInitialized && isBackground) {
      await _notifyBackgroundUsage();
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/background');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    var initialized = await _localNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (initialized == false) return;

    _notificationsInitialized = true;

    // Only request permissions in the foreground
    if (!isBackground) {
      await NotificationService._requestNotificationPermissions();
      return;
    }

    // Inform the user that background task is being run
    if (isBackground) await _notifyBackgroundUsage();
  }

  static Future scheduleNotification(NotificationModel data) async {
    if (!_notificationsInitialized) return;

    // always check if notifications are enabled before scheduling one
    var settings = await SettingsService().getSettings();

    if (!settings.notificationsEnabled) {
      return;
    }

    const androidNotificationDetails = AndroidNotificationDetails(
      "sound",
      "Notifications",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      data.timestamp,
    );

    await _localNotificationsPlugin.zonedSchedule(
      data.id,
      data.heading,
      data.body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: data.matchDateTimeComponents,
    );
  }

  static Future cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }
}
