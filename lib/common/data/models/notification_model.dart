import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  int id;
  String heading;
  String body;
  int? timestamp;
  bool? playSound;
  DateTimeComponents? matchDateTimeComponents;

  NotificationModel({
    required this.id,
    required this.heading,
    required this.body,
    this.timestamp,
    this.playSound,
    this.matchDateTimeComponents,
  });
}
