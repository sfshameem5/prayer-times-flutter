import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
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
        heading: "Fetching background data",

        body: "Prefetching prayer times",
        timestamp: DateTime.now()
            .add(Duration(seconds: 5))
            .millisecondsSinceEpoch,
      ),
    );
  }

  static Future<bool> requestNotificationPermissions() async {
    // Only handle it for android
    if (!Platform.isAndroid) return false;

    final androidImplementation = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    var notifications = await androidImplementation
        ?.requestNotificationsPermission();
    var alarm = await androidImplementation?.requestExactAlarmsPermission();

    return notifications! && alarm!;
  }

  static Future initialize({bool isBackground = false}) async {
    if (_notificationsInitialized && isBackground) {
      await _notifyBackgroundUsage();
      return;
    }
    await SentryService.logString(
      "Initializing ${isBackground ? "background" : ""} notification service",
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        // AndroidInitializationSettings('@drawable/background');
        AndroidInitializationSettings('ic_new');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    var initialized = await _localNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (initialized == false) return;

    _notificationsInitialized = true;

    // Only request permissions in the foreground
    if (!isBackground) {
      // await NotificationService.requestNotificationPermissions();
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

    if (data.timestamp == null) return;

    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      data.timestamp!,
    );

    await SentryService.logString(
      "Scheduling notification for ${data.heading} with timestamp ${data.timestamp}",
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

  static Future showNotification(NotificationModel data) async {
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

    await _localNotificationsPlugin.show(
      data.id,
      data.heading,
      data.body,
      notificationDetails,
    );
  }

  static Future cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }

  static Future cancelAllNotifications() async {
    await SentryService.logString("Cancelling all notifications");
    await _localNotificationsPlugin.cancelAll();
    await AlarmService.cancelAllAlarms();
  }

  static Future<bool> checkPermissionStatus() async {
    // Only handle it for android
    if (!Platform.isAndroid) return false;

    final androidImplementation = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    var notificationResponse = await androidImplementation
        ?.areNotificationsEnabled();
    var alarmResponse = await androidImplementation
        ?.canScheduleExactNotifications();

    return notificationResponse! && alarmResponse!;
  }
}
