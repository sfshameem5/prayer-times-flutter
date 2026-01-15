import 'package:prayer_times/features/settings/services/settings_service.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class SettingsRepository {
  final SettingsService _settingsService;

  SettingsRepository({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService();

  Future<SettingsModel> getSettings() async {
    return _settingsService.getSettings();
  }

  Future saveSettings(SettingsModel settings) async {
    return _settingsService.saveSettings(settings);
  }
}
