import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  static const _baseUrl = "prayer-times-api-nhqkb.ondigitalocean.app";
  static const _prayerTodayKey = "PRAYER_TIMES_TODAY";

  String getTodayHijriDateFormatted() {
    final hijriDate = HijriCalendar.fromDate(DateTime.now());
    final monthName = hijriDate.getLongMonthName();
    return "$monthName ${hijriDate.hDay}, ${hijriDate.hYear} AH";
  }

  Future<PrayerDayModel?> getPrayerTimesForTimestamp(int timestamp) async {
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

  Future prefetchPrayerTimes() async {
    var today = DateTime.now();
    List<int> dayTimestamps = [today.millisecondsSinceEpoch];

    for (int i = 0; i < 5; i += 1) {
      dayTimestamps.add(today.add(Duration(days: 1)).millisecondsSinceEpoch);
    }

    // For each day let's prefetch prayers
    for (var timestamp in dayTimestamps) {
      await getPrayerTimesForTimestamp(timestamp);
    }
  }
}
