import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
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

  Future<void> requestAutoStartIfAvailable() async {
    if (!Platform.isAndroid) return;

    try {
      final available = await isAutoStartAvailable ?? false;
      if (available) {
        await getAutoStartPermission();
      }
    } catch (_) {
      // Auto-start may not be available on all devices
    }
  }
}
