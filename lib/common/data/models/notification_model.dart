import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  int id;
  String heading;
  String body;
  int timestamp;
  DateTimeComponents? matchDateTimeComponents;

  NotificationModel({
    required this.id,
    required this.heading,
    required this.body,
    required this.timestamp,
    this.matchDateTimeComponents,
  });
}
