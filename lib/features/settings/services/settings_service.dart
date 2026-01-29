import 'dart:convert';

import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  final _prayerRepository = PrayerTimesRepository();

  Future<SettingsModel> getSettings() async {
    var mkkv = MMKV.defaultMMKV();
    final settingsJson = mkkv.decodeString(_settingsKey);

    if (settingsJson == null) {
      return const SettingsModel();
    }

    final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
    return SettingsModel.fromJson(decoded);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final mmkv = MMKV.defaultMMKV();

    // if (settings.notificationsEnabled) {
    //   await _prayerRepository.initiateAzaanService();
    // } else {
    //   _prayerRepository.stopAzaanService();
    // }

    final encoded = jsonEncode(settings.toJson());
    mmkv.encodeString(_settingsKey, encoded);
  }
}
