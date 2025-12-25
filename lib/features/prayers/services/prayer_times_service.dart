import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';

class PrayerTimesService {
  Future<PrayerDayModel?> getPrayerTimesForTimestamp(int timestamp) async {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    var month = DateFormat('MMMM').format(date).toLowerCase();
    var year = DateFormat('y').format(date).toString();
    var finalPath = "assets/prayer-times/$month$year.json";

    String currentMonthJSON;

    try {
      currentMonthJSON = await rootBundle.loadString(finalPath);
    } catch (e) {
      return null;
    }

    var currentMonthData = jsonDecode(currentMonthJSON) as List<dynamic>;

    if (currentMonthJSON.isEmpty) return null;

    var displayDate = DateFormat('d').format(date).toString();
    var displayMonth = DateFormat('MMM').format(date).toString();

    var todayTimes = currentMonthData.firstWhere((item) {
      return item['date'] == "$displayDate-$displayMonth";
    });

    if (todayTimes == null) return null;

    return PrayerDayModel.fromJson(todayTimes, year);
  }
}
