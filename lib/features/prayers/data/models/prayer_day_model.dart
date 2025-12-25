import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';

class PrayerDayModel {
  int timestamp;
  List<PrayerModel> prayers;

  PrayerDayModel({required this.timestamp, required this.prayers});

  static PrayerDayModel fromJson(Map<String, dynamic> item, String year) {
    // Extract timestamp using item['date'], month and year
    var format = DateFormat("d-MMM y");
    var timestamp = format
        .parse("${item["date"]} $year")
        .millisecondsSinceEpoch;
    List<PrayerModel> prayers = [];

    var itemFormat = DateFormat("h:mm a d-MMM y");

    for (var element in item.entries) {
      if (element.key.contains('date')) continue;

      var timestamp = itemFormat
          .parse("${element.value} ${item["date"]} $year")
          .millisecondsSinceEpoch;

      prayers.add(
        PrayerModel(PrayerNameEnum.values.byName(element.key), timestamp),
      );
    }

    return PrayerDayModel(timestamp: timestamp, prayers: prayers);
  }
}
