import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';

class DisplayPrayerModel {
  String name;
  String time;
  IconData icon;

  DisplayPrayerModel({
    required this.name,
    required this.time,
    this.icon = Icons.access_time,
  });

  static const Map<String, IconData> _prayerIcons = {
    'fajr': Icons.nightlight_round,
    'sunrise': Icons.wb_twilight,
    'luhr': Icons.wb_sunny,
    'dhuhr': Icons.wb_sunny,
    'asr': Icons.wb_sunny_outlined,
    'magrib': Icons.nights_stay_outlined,
    'maghrib': Icons.nights_stay_outlined,
    'isha': Icons.dark_mode,
  };

  static IconData _getIconForPrayer(String name) {
    return _prayerIcons[name.toLowerCase()] ?? Icons.access_time;
  }

  static DisplayPrayerModel fromPrayerModel(PrayerModel item) {
    var date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    var name = item.name.name;
    var capitalizedName = name[0].toUpperCase() + name.substring(1);

    return DisplayPrayerModel(
      name: capitalizedName,
      time: DateFormat.jm().format(date).toString(),
      icon: _getIconForPrayer(name),
    );
  }
}
