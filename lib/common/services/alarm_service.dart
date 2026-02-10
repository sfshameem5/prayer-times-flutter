import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/services/sentry_service.dart';

class AlarmService {
  static Future scheduleAlarm(AlarmModel data) async {
    final alarmSettings = AlarmSettings(
      id: data.id,
      dateTime: DateTime.fromMillisecondsSinceEpoch(data.timestamp),
      assetAudioPath: 'assets/sounds/azaan_full.mp3',
      loopAudio: false,
      vibrate: true,
      warningNotificationOnKill: Platform.isAndroid,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: data.heading,
        body: data.body,
        stopButton: 'Stop the azaan',
        icon: 'ic_new',
      ),
    );

    SentryService.logString(
      "Scheduling alarm for prayer ${data.heading} with timestamp ${data.timestamp}",
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future cancelAllAlarms() async {
    await SentryService.logString("Cancelling all alarms");
    await Alarm.stopAll();
  }

  static Future<void> initWarningNotification() async {
    if (Platform.isAndroid) {
      await Alarm.setWarningNotificationOnKill(
        'Prayer Times',
        'Prayer alarms may not ring if the app is closed.',
      );
    }
  }
}
