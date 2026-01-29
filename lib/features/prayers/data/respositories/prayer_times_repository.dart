import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/audio_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
import 'package:prayer_times/features/prayers/services/azaan_task_service.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

@pragma('vm:entry-point')
void startAzaan() async {
  // await AudioService.playAudio("assets/sounds/azaan_short.mp3");
  FlutterForegroundTask.sendDataToTask({'play_azaan': true});
}

@pragma('vm:entry-point')
void stopAzaan() async {
  await AudioService.cancelAudio();
}

class PrayerTimesRepository {
  final _prayerTimesService = PrayerTimesService();

  static Timer? _azaanTimer;

  String getTodayHijriDateFormatted() {
    return _prayerTimesService.getTodayHijriDateFormatted();
  }

  Future<List<PrayerModel>> getPrayerTimesForToday() async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var data = await _prayerTimesService.getPrayerTimesForTimestamp(timestamp);

    if (data == null) return [];

    return data.prayers;
  }

  Future<List<PrayerModel>> getPrayerTimesForTomorrow() async {
    var timestamp = DateTime.now()
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;

    var data = await _prayerTimesService.getPrayerTimesForTimestamp(timestamp);

    if (data == null) return [];

    return data.prayers;
  }

  Future<PrayerModel?> getCurrentPrayer() async {
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

  Future<PrayerModel?> getNextPrayer() async {
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

  int _generateUniquePrayerId(PrayerModel prayer) {
    var date = DateTime.fromMillisecondsSinceEpoch(prayer.timestamp);
    return (date.day * 100) + (date.month * 10) + prayer.name.index;
  }

  Future initiateAzaanService() async {
    FlutterForegroundTask.init(
      iosNotificationOptions: IOSNotificationOptions(),
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sound',
        channelName: "sound",
      ),
      foregroundTaskOptions: ForegroundTaskOptions(eventAction: .nothing()),
    );

    var settings = await SettingsService().getSettings();

    await FlutterForegroundTask.startService(
      serviceId: 335,
      notificationTitle: "Prayer Times",
      notificationText: "Starting service",
      notificationIcon: NotificationIcon(
        metaDataName: "flutter_foreground_task.default_notification_icon",
      ),
      callback: startCallback,
    );

    // Let's have a periodic timer which runs every 30 seconds and checks for prayer notifications
    _azaanTimer?.cancel();
    // _azaanTimer = Timer.periodic(Duration(seconds: 30), (Timer timer) async {
    //   var prayerData = await PrayerTimesService().getPrayerTimesForTimestamp(
    //     DateTime.now().millisecondsSinceEpoch,
    //   );

    //   if (prayerData == null) return;

    //   var formatter = DateFormat.Hm();
    //   var currentDisplay = formatter.format(DateTime.now());

    //   String? matchedDisplay;
    //   PrayerModel? matchedPrayer;

    //   print("Current display prayer $currentDisplay");

    //   for (var prayer in prayerData.prayers) {
    //     var timestamp = prayer.timestamp;
    //     var displayPrayer = formatter.format(
    //       DateTime.fromMillisecondsSinceEpoch(timestamp),
    //     );

    //     print("current time $currentDisplay");
    //     print("next prayer $displayPrayer");

    //     if (currentDisplay == displayPrayer) {
    //       matchedDisplay = displayPrayer.toString();
    //       matchedPrayer = PrayerModel(prayer.name, prayer.timestamp);
    //       break;
    //     }
    //   }

    //   if (matchedDisplay == null || matchedPrayer == null) return;

    //   // You can trigger the azaan here
    //   var isPlaying = false;
    //   var settings = await SettingsService().getSettings();

    //   if (settings.notificationMode == PrayerNotificationMode.azaan) {
    //     isPlaying = await AudioService.playAudio(
    //       "assets/sounds/azaan_full.mp3",
    //     );
    //   } else {
    //     isPlaying = false;
    //   }

    //   if (isPlaying) return;

    //   var date = DateTime.fromMillisecondsSinceEpoch(matchedPrayer.timestamp);
    //   var displayTime = DateFormat.jm().format(date);

    //   final notification = NotificationModel(
    //     id: _generateUniquePrayerId(matchedPrayer),
    //     heading: "Time for ${matchedPrayer.name.name}",
    //     body: "${matchedPrayer.name.name} at $displayTime",
    //     timestamp: DateTime.fromMillisecondsSinceEpoch(
    //       matchedPrayer.timestamp,
    //     ).add(Duration(seconds: 2)).millisecondsSinceEpoch,
    //     playSound: false, // Doesn't do anything yet
    //   );

    //   await NotificationService.showNotification(notification);
    // });
  }

  Future stopAzaanService() async {
    _azaanTimer?.cancel();
    await AudioService.cancelAudio();
  }

  Future scheduleNotificationsForToday() async {
    // For each prayer use timestamp as ID and schedule notifications
    var prayers = await getPrayerTimesForToday();

    if (prayers.isEmpty) return;

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

      await AndroidAlarmManager.oneShotAt(
        DateTime.fromMillisecondsSinceEpoch(notification.timestamp!),
        notification.id,
        () {},
        exact: true,
        wakeup: true,
      );
      // await NotificationService.scheduleNotification(notification);
    }
  }
}
