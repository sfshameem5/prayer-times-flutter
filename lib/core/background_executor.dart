import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Colombo"));

    if (taskName == "prayer-notifications") {
      await SentryService.logString("Fetching prayer times data");

      await PrayerTimesService.prefetchPrayerTimes();
      await PrayerTimesService.scheduleFiveDayNotifications();
    }

    return Future.value(true);
  });
}
