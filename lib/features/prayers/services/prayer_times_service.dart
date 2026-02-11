import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:prayer_times/common/data/enums/cache_ttl.dart';
import 'package:prayer_times/common/services/cache_manager.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_month_model.dart';

class PrayerTimesService {
  static const _baseUrl = "prayer-times-api-nhqkb.ondigitalocean.app";
  static const _prayerTodayKey = "PRAYER_TIMES_TODAY";
  static const _prayerMonthKey = "PRAYER_TIMES_MONTH";

  static String getTodayHijriDateFormatted() {
    final hijriDate = HijriCalendar.fromDate(DateTime.now());
    final monthName = hijriDate.getLongMonthName();
    return "$monthName ${hijriDate.hDay}, ${hijriDate.hYear} AH";
  }

  static Future<PrayerDayModel?> getTestPrayersForTimestamp(
    int timestamp,
  ) async {
    // Five prayers each with 1 minute gap
    var date = DateTime.now();
    List<PrayerModel> prayers = [];
    var names = [
      PrayerNameEnum.fajr,
      PrayerNameEnum.sunrise,
      PrayerNameEnum.asr,
      PrayerNameEnum.magrib,
      PrayerNameEnum.isha,
    ];

    for (var i = 0; i < names.length; i += 1) {
      var name = names[i];
      var prayer = PrayerModel(
        name,
        date.add(Duration(minutes: 1 + i)).millisecondsSinceEpoch,
      );
      prayers.add(prayer);
    }

    return PrayerDayModel(timestamp: timestamp, prayers: prayers);
  }

  static Future<PrayerMonthModel?> getPrayerTimesForMonth(int timestamp) async {
    // Check how the response is coming back.
    // Create a fromJSON and toJSON type for month
    // Maybe create a new model called PrayerDayMonth

    var url = Uri.https(_baseUrl, "/prayer/month", {
      "timestamp": timestamp.toString(),
    });

    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat("MMM y");
    var formattedKey = formatter.format(date);

    var currentKey = "$_prayerMonthKey $formattedKey";
    // var alreadyAvailable = mkkv.decodeString(currentKey);
    var alreadyAvailable = CacheManager.getStringItem(currentKey);

    if (alreadyAvailable != null) {
      // Here it is a list of prayer models
      var jsonData = json.decode(alreadyAvailable) as Map<String, dynamic>;
      var monthData = PrayerMonthModel.fromJSON(jsonData);

      return monthData;
    }

    var year = DateFormat('y').format(date).toString();

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch prayer times: ${response.statusCode}');
    }

    if (response.body.isNotEmpty) {
      var receivedResponse = json.decode(response.body) as Map<String, dynamic>;

      var monthData = PrayerMonthModel.fromAPI(receivedResponse, year);
      var toEncode = PrayerMonthModel.toJSON(monthData);

      CacheManager.saveStringItem(
        currentKey,
        json.encode(toEncode),
        CacheTTL.ONE_WEEK,
      );

      return monthData;
    }

    return null;
  }

  static Future<PrayerDayModel?> getPrayerTimesForTimestamp(
    int timestamp,
  ) async {
    // Get today as d-MMM
    // Find the date which matches d-MMM and return
    var formatter = DateFormat("d-MMM");
    var todayDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

    var todayString = formatter.format(todayDate);

    // The date should be part of a month
    var monthData = await getPrayerTimesForMonth(timestamp);
    if (monthData == null) return null;

    for (var date in monthData.dates) {
      var itemDate = DateTime.fromMillisecondsSinceEpoch(date.timestamp);
      var itemString = formatter.format(itemDate);

      if (todayString == itemString) return date;
    }

    return null;
  }

  static Future prefetchPrayerTimes() async {
    var now = DateTime.now();
    var nextMonth = DateTime(now.year, now.month + 1, 1);

    var monthString = DateFormat("MMM y").format(nextMonth);

    await SentryService.logString("Prefetching prayer times for $monthString");

    await getPrayerTimesForMonth(nextMonth.millisecondsSinceEpoch);

    await SentryService.logString(
      "Prefetched timestamp ${nextMonth.millisecondsSinceEpoch}",
    );
  }
}
