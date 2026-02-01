import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:battery_optimization_helper/battery_optimization_helper_platform_interface.dart';
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

  Future<bool> isBackgroundOptimizationEnabled() async {
    return await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
  }

  Future<bool> requestBackgroundDisabling() async {
    return await BatteryOptimizationHelperPlatform.instance
        .requestDisableBatteryOptimizationWithResult();
  }
}
