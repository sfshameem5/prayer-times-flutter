import 'dart:async';

import 'package:intl/intl.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';

class PrayerTimesRepository {
  static String getTodayHijriDateFormatted() {
    return PrayerTimesService.getTodayHijriDateFormatted();
  }

  static Future<List<PrayerModel>> getPrayerTimesForToday() async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var data = await PrayerTimesService.getPrayerTimesForTimestamp(timestamp);

    if (data == null) return [];

    return data.prayers;
  }

  static Future<List<PrayerModel>> getPrayerTimesForTomorrow() async {
    var timestamp = DateTime.now()
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;

    var data = await PrayerTimesService.getPrayerTimesForTimestamp(timestamp);

    if (data == null) return [];

    return data.prayers;
  }

  static Future<PrayerModel?> getCurrentPrayer() async {
    var prayerTimesToday = await getPrayerTimesForToday();
    var prayerTimesTomorrow = await getPrayerTimesForTomorrow();

    if (prayerTimesToday.isEmpty) return null;

    List<PrayerModel> allPrayers = [
      ...prayerTimesToday,
      ...prayerTimesTomorrow,
    ];

    allPrayers.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    var currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    PrayerModel? closestPrayer;

    for (var prayer in allPrayers) {
      if (prayer.timestamp < currentTimestamp) {
        closestPrayer = prayer;
        break;
      }
    }

    return closestPrayer;
  }

  static Future<PrayerModel?> getNextPrayer() async {
    var prayerTimesToday = await getPrayerTimesForToday();
    var prayerTimesTomorrow = await getPrayerTimesForTomorrow();

    if (prayerTimesToday.isEmpty) return null;

    List<PrayerModel> allPrayers = [
      ...prayerTimesToday,
      ...prayerTimesTomorrow,
    ];

    allPrayers.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    var currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    PrayerModel? closestPrayer;

    for (var prayer in allPrayers) {
      if (prayer.timestamp > currentTimestamp) {
        closestPrayer = prayer;
        break;
      }
    }

    return closestPrayer;
  }

  static int _generateUniquePrayerId(PrayerModel prayer) {
    var date = DateTime.fromMillisecondsSinceEpoch(prayer.timestamp);
    return (date.day * 100) + (date.month * 10) + prayer.name.index;
  }

  static Future scheduleNotifications() async {
    var settings = await SettingsService().getSettings();

    SentryService.logString("Scheduling prayer notifications");
    SentryService.logString(
      "Notifications are ${settings.notificationsEnabled ? 'enabled ' : 'disabled'} ${settings.notificationMode}",
    );

    if (!settings.notificationsEnabled) return;

    // For each prayer use timestamp as ID and schedule notifications
    var todayDate = DateTime.now();
    List<PrayerDayModel> prayerDays = [];

    for (var i = 0; i < 3; i += 1) {
      var prayerDay = await PrayerTimesService.getPrayerTimesForTimestamp(
        todayDate.millisecondsSinceEpoch,
      );
      if (prayerDay != null) prayerDays.add(prayerDay);

      todayDate = todayDate.add(Duration(days: 1));
    }

    if (prayerDays.isEmpty) return;

    List<PrayerModel> prayers = [];
    for (var day in prayerDays) {
      prayers.addAll(day.prayers);
    }

    var currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    for (var prayer in prayers) {
      if (currentTimestamp > prayer.timestamp) {
        continue;
      }

      var date = DateTime.fromMillisecondsSinceEpoch(prayer.timestamp);
      var displayTime = DateFormat.jm().format(date);

      final notification = NotificationModel(
        id: _generateUniquePrayerId(prayer),
        heading: "Time for ${prayer.name.name}",
        body: "${prayer.name.name} at $displayTime",
        timestamp: prayer.timestamp,
      );

      final alarmData = AlarmModel(
        id: notification.id,
        heading: notification.heading,
        body: notification.body,
        timestamp: notification.timestamp!,
        audioPath: "assets/sounds/azaan_full.mp3",
      );

      if (settings.notificationMode == PrayerNotificationMode.azaan) {
        await AlarmService.scheduleAlarm(alarmData);
      } else {
        await NotificationService.scheduleNotification(notification);
      }
    }
  }
}
