import 'dart:convert';

import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';

class PrayerMonthModel {
  String monthName;
  String countryName;
  String cityName;
  List<PrayerDayModel> dates;

  PrayerMonthModel({
    required this.monthName,
    required this.countryName,
    required this.cityName,
    required this.dates,
  });

  static PrayerMonthModel fromAPI(Map<String, dynamic> data, String year) {
    PrayerMonthModel finalData = PrayerMonthModel(
      monthName: data["monthName"],
      countryName: data["countryName"],
      cityName: data["cityName"],
      dates: [],
    );

    for (var item in data['dates']) {
      finalData.dates.add(PrayerDayModel.fromAPI(item, year)!);
    }

    return finalData;
  }

  static Map<String, dynamic> toJSON(PrayerMonthModel data) {
    // var datesData = data.dates.map((date) => PrayerDayModel.toJson(date));
    var datesJSON = data.dates
        .map((date) => PrayerDayModel.toJson(date))
        .toList();

    return {
      "monthName": data.monthName,
      "countryName": data.countryName,
      "cityName": data.cityName,
      "dates": json.encode(datesJSON),
    };
  }

  static PrayerMonthModel fromJSON(Map<String, dynamic> data) {
    var datesJSON = data["dates"];
    var dates = json.decode(datesJSON);

    List<PrayerDayModel> parsedDates = [];
    for (var date in dates) {
      parsedDates.add(PrayerDayModel.fromJson(date));
    }

    return PrayerMonthModel(
      monthName: data["monthName"],
      countryName: data["countryName"],
      cityName: data["cityName"],
      dates: parsedDates,
    );
  }
}
