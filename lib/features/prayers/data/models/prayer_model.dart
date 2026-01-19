import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_day_model.dart';

class PrayerModel {
  PrayerNameEnum name;
  int timestamp;

  PrayerModel(this.name, this.timestamp);

  static List<PrayerModel> fromPrayerDay(PrayerDayModel item) {
    List<PrayerModel> prayers = [];

    return prayers;
  }

  static Map<String, dynamic> toJSON(PrayerModel item) {
    return {"name": item.name.name.toString(), "timestamp": item.timestamp};
  }

  static PrayerModel fromJSON(Map<String, dynamic> item) {
    return PrayerModel(
      PrayerNameEnum.values.byName(item["name"]),
      item["timestamp"],
    );
  }
}
