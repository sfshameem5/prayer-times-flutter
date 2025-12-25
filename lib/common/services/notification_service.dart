import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  static Future initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    var initialized = await _localNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (initialized == false) return;

    await Future.delayed(const Duration(milliseconds: 500));
    await NotificationService._requestNotificationPermissions();
  }

  static Future scheduleNotification(NotificationModel data) async {
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

    final location = tz.getLocation("Asia/Colombo");

    final scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
      location,
      data.timestamp,
    );

    await _localNotificationsPlugin.zonedSchedule(
      data.id,
      data.heading,
      data.body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }
}
