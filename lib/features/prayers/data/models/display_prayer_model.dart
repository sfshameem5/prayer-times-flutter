import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';

class DisplayPrayerModel {
  String name;
  String time;

  DisplayPrayerModel({required this.name, required this.time});

  static DisplayPrayerModel fromPrayerModel(PrayerModel item) {
    var date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    var name = item.name.name;
    var capitalizedName = name[0].toUpperCase() + name.substring(1);

    return DisplayPrayerModel(
      name: capitalizedName,
      time: DateFormat.jm().format(date).toString(),
    );
  }
}
