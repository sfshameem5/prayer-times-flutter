import 'dart:convert';

import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<SettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return const SettingsModel();
    }

    final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
    return SettingsModel.fromJson(decoded);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, encoded);
  }
}
