import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma('vem:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    tz.initializeTimeZones();

    await NotificationService.initialize();

    if (taskName == "prayer-notifications") {
      final repository = PrayerTimesRepository();
      repository.scheduleNotificationsForToday();
    }

    return Future.value(true);
  });
}
