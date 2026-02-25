import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';

class DisplayPrayerModel {
  final String name;
  final String time;
  final IconData icon;
  final bool isPassed;

  const DisplayPrayerModel({
    required this.name,
    required this.time,
    this.icon = Icons.access_time,
    this.isPassed = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayPrayerModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          time == other.time &&
          icon == other.icon &&
          isPassed == other.isPassed;

  @override
  int get hashCode => Object.hash(name, time, icon, isPassed);

  static const Map<String, IconData> _prayerIcons = {
    'fajr': Icons.nightlight_round,
    'sunrise': Icons.wb_twilight,
    'dhuhr': Icons.wb_sunny,
    'asr': Icons.wb_sunny_outlined,
    'maghrib': Icons.nights_stay_outlined,
    'isha': Icons.dark_mode,
  };

  static IconData _getIconForPrayer(String name) {
    return _prayerIcons[name.toLowerCase()] ?? Icons.access_time;
  }

  static String _localizedName(PrayerNameEnum name, AppLocalizations? strings) {
    if (strings == null) {
      return name.name[0].toUpperCase() + name.name.substring(1);
    }
    switch (name) {
      case PrayerNameEnum.fajr:
        return strings.prayerFajr;
      case PrayerNameEnum.sunrise:
        return strings.prayerSunrise;
      case PrayerNameEnum.dhuhr:
        return strings.prayerDhuhr;
      case PrayerNameEnum.asr:
        return strings.prayerAsr;
      case PrayerNameEnum.maghrib:
        return strings.prayerMaghrib;
      case PrayerNameEnum.isha:
        return strings.prayerIsha;
    }
  }

  static DisplayPrayerModel fromPrayerModel(
    PrayerModel item, [
    AppLocalizations? strings,
    String? localeCode,
  ]) {
    var date = DateTime.fromMillisecondsSinceEpoch(item.timestamp);
    var nameEnum = item.name;
    var localizedName = _localizedName(nameEnum, strings);
    var isPassed = DateTime.now().millisecondsSinceEpoch > item.timestamp;
    final fmtLocale = localeCode ?? Intl.getCurrentLocale();

    return DisplayPrayerModel(
      name: localizedName,
      time: DateFormat.jm(fmtLocale).format(date).toString(),
      icon: _getIconForPrayer(nameEnum.name),
      isPassed: isPassed,
    );
  }
}
