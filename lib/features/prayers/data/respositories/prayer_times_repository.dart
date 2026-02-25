import 'dart:async';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';
import 'package:prayer_times/l10n/app_localizations.dart' as app_strings;

class PrayerTimesRepository {
  static String _localizedPrayerName(
    PrayerNameEnum name,
    app_strings.AppLocalizations strings,
  ) {
    switch (name) {
      case PrayerNameEnum.fajr:
        return strings.prayerFajr;
      case PrayerNameEnum.sunrise:
        return strings.prayerSunrise;
      case PrayerNameEnum.dhuhr:
        return strings.prayerDhuhr;
      case PrayerNameEnum.asr:
        return strings.prayerAsr;
      case PrayerNameEnum.maghrib:
        return strings.prayerMaghrib;
      case PrayerNameEnum.isha:
        return strings.prayerIsha;
    }
  }

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

  static Future<PrayerModel?> getNextPrayer({bool skipSunrise = false}) async {
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
        if (skipSunrise && prayer.name == PrayerNameEnum.sunrise) continue;
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

    final localeCode = settings.languageCode;
    final strings = app_strings.lookupAppLocalizations(Locale(localeCode));

    SentryService.logString("Scheduling prayer notifications");
    SentryService.logString(
      "Notifications: ${settings.notificationsEnabled ? 'ON' : 'OFF'}, "
      "Alarms: ${settings.alarmsEnabled ? 'ON' : 'OFF'}",
    );

    if (!settings.notificationsEnabled) return;

    // For each prayer use timestamp as ID and schedule notifications
    var todayDate = DateTime.now();
    List<PrayerDayModel> prayerDays = [];

    for (var i = 0; i < 5; i += 1) {
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
      var displayTime = DateFormat.jm(localeCode).format(date);

      final localizedName = _localizedPrayerName(prayer.name, strings);

      final notification = NotificationModel(
        id: _generateUniquePrayerId(prayer),
        heading: strings.nextPrayerLabel.replaceFirst(
          '{prayer}',
          localizedName,
        ),
        body: '$localizedName $displayTime',
        timestamp: prayer.timestamp,
      );

      final isFajr = prayer.name == PrayerNameEnum.fajr;
      final alarmData = AlarmModel(
        id: notification.id,
        heading: localizedName,
        body: notification.body,
        timestamp: notification.timestamp!,
        audioPath: isFajr ? "fajr" : "full",
        localeCode: localeCode,
      );

      final mode = settings.getModeForPrayer(prayer.name);

      // Sunrise should never get azaan; also gate on alarmsEnabled
      final effectiveMode =
          (prayer.name == PrayerNameEnum.sunrise &&
                  mode == PrayerNotificationMode.azaan) ||
              (mode == PrayerNotificationMode.azaan && !settings.alarmsEnabled)
          ? PrayerNotificationMode.defaultSound
          : mode;

      if (effectiveMode == PrayerNotificationMode.silent) {
        continue;
      } else if (effectiveMode == PrayerNotificationMode.azaan) {
        // Silently check if full-screen intent is available for azaan
        final canFullScreen = await AlarmService.canUseFullScreenIntent();
        if (canFullScreen) {
          await AlarmService.scheduleAlarm(alarmData);
        } else {
          // Fall back to default notification if full-screen intent is not granted
          await SentryService.logString(
            'Full-screen intent not available for ${prayer.name.name}, falling back to notification',
          );
          await NotificationService.scheduleNotification(notification);
        }
      } else {
        await NotificationService.scheduleNotification(notification);
      }
    }
  }
}
