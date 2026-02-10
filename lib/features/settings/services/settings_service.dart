import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

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
    var data = await getSettings();

    final encoded = jsonEncode(settings.toJson());
    mmkv.encodeString(_settingsKey, encoded);

    if (!settings.notificationsEnabled) {
      await NotificationService.cancelAllNotifications();
    }

    final modesChanged = !const MapEquality<dynamic, dynamic>().equals(
      data.prayerNotificationModes,
      settings.prayerNotificationModes,
    );

    if (modesChanged) {
      await NotificationService.cancelAllNotifications();
      await PrayerTimesRepository.scheduleNotifications();
    }
  }
}
