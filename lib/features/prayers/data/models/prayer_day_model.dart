import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';

class PrayerDayModel {
  int timestamp;
  List<PrayerModel> prayers;

  PrayerDayModel({required this.timestamp, required this.prayers});

  static PrayerDayModel? fromAPI(Map<String, dynamic> item, String year) {
    var dayMonth = item['dayMonth'];
    List<dynamic> prayers = item['prayers'];

    var dayFormatter = DateFormat("d-MMM y");
    var dayTimestamp = dayFormatter
        .parse("$dayMonth $year")
        .millisecondsSinceEpoch;

    List<PrayerModel> prayersWithTimestamp = [];

    for (var prayer in prayers) {
      var prayerFormatter = DateFormat("H:m d-MMM y");
      var displayTime = prayer['displayTime'];

      var timestamp = prayerFormatter
          .parse("$displayTime $dayMonth $year")
          .millisecondsSinceEpoch;

      prayersWithTimestamp.add(
        PrayerModel(PrayerNameEnum.values.byName(prayer["name"]), timestamp),
      );
    }

    return PrayerDayModel(
      timestamp: dayTimestamp,
      prayers: prayersWithTimestamp,
    );
  }

  static PrayerDayModel fromJson(Map<String, dynamic> item) {
    return PrayerDayModel(
      timestamp: item['timestamp'],
      prayers: (item['prayers'] as List<dynamic>)
          .map((x) => PrayerModel.fromJSON(x))
          .toList(),
    );
  }

  static Map<String, dynamic> toJson(PrayerDayModel item) {
    return {
      "timestamp": item.timestamp,
      "prayers": item.prayers.map((x) => PrayerModel.toJSON(x)).toList(),
    };
  }

  // static Map<String, dynamic> toJsonMonth(List<PrayerDayModel> prayers) {
  //   var prayers = [];
  // }
}
