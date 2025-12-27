import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static var _notificationsInitialized = false;

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
    if (_notificationsInitialized) return;

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

    // test notifiation in the background
    var data = NotificationModel(
      id: 11223,
      heading:
          'Initializiing notification ${isBackground ? 'Background' : 'Foreground'}',
      body: 'Notification has been initialized',
      timestamp: DateTime.now()
          .add(Duration(seconds: 30))
          .millisecondsSinceEpoch,
    );

    await scheduleNotification(data);
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
