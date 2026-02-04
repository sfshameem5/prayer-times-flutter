import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';
import 'package:http/http.dart' as http;
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';

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

  static Future<List<PrayerDayModel>> _getPrayerTimesForMonth(
    int timestamp,
  ) async {
    // Check how the response is coming back.
    // Create a fromJSON and toJSON type for month
    // Maybe create a new model called PrayerDayMonth

    var url = Uri.https(_baseUrl, "/prayer/month", {
      "timestamp": timestamp.toString(),
    });

    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat("MMM y");
    var formattedKey = formatter.format(date);

    var mkkv = MMKV.defaultMMKV();

    var currentKey = "$_prayerMonthKey $formattedKey";
    var alreadyAvailable = mkkv.decodeString(currentKey);

    if (alreadyAvailable != null) {
      // Here it is a list of prayer models
      var items = json.decode(alreadyAvailable) as List<dynamic>;
      List<PrayerDayModel> prayers = [];

      for (var item in items) {
        prayers.add(PrayerDayModel.fromJson(item));
      }
      // var parsedItem = PrayerDayModel.fromJson(json.decode(alreadyAvailable));

      if (prayers.isNotEmpty) return prayers;
    }

    var year = DateFormat('y').format(date).toString();

    final response = await http.get(url);

    if (response.body.isNotEmpty) {
      var receivedResponse = json.decode(response.body) as List<dynamic>;
      var prayers = [];

      for (var item in receivedResponse) {
        prayers.add(PrayerDayModel.fromAPI(item, year));
      }
    }

    // if (responseToSend != null) {
    //   var toSave = PrayerDayModel.toJson(responseToSend);
    //   mkkv.encodeString(currentKey, json.encode(toSave));
    // }
    // return responseToSend;

    return [];
  }

  static Future<PrayerDayModel?> getPrayerTimesForTimestamp(
    int timestamp,
  ) async {
    var url = Uri.https(_baseUrl, "/prayer", {
      "timestamp": timestamp.toString(),
    });

    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat("d-MMM y");
    var formattedKey = formatter.format(date);

    var mkkv = MMKV.defaultMMKV();

    var currentKey = "$_prayerTodayKey $formattedKey";

    var alreadyAvailable = mkkv.decodeString(currentKey);

    if (alreadyAvailable != null) {
      var parsedItem = PrayerDayModel.fromJson(json.decode(alreadyAvailable));

      return parsedItem;
    }

    var year = DateFormat('y').format(date).toString();

    final response = await http.get(url);

    var responseToSend = PrayerDayModel.fromAPI(
      json.decode(response.body),
      year,
    );

    if (responseToSend != null) {
      var toSave = PrayerDayModel.toJson(responseToSend);
      mkkv.encodeString(currentKey, json.encode(toSave));
    }
    return responseToSend;
  }

  static Future prefetchPrayerTimes() async {
    await SentryService.logString("Prefetching prayer times");

    List<int> dayTimestamps = [];
    var updatedDate = DateTime.now();

    for (int i = 0; i < 5; i += 1) {
      updatedDate = updatedDate.add(Duration(days: 1));
      dayTimestamps.add(updatedDate.millisecondsSinceEpoch);
    }

    var timestampString = '';

    // For each day let's prefetch prayers
    for (var timestamp in dayTimestamps) {
      timestampString += "$timestamp ";
      await getPrayerTimesForTimestamp(timestamp);
    }

    await SentryService.logString(
      "Processing prefetch timestamps $timestampString",
    );
  }
}
