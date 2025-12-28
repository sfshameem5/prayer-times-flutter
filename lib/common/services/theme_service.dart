import 'package:flutter/material.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';

class ThemeService extends ChangeNotifier {
  final SettingsService _settingsService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final settings = await _settingsService.getSettings();
    _themeMode = _convertToFlutterThemeMode(settings.themeMode);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = _convertToFlutterThemeMode(mode);
    notifyListeners();

    final settings = await _settingsService.getSettings();
    await _settingsService.saveSettings(settings.copyWith(themeMode: mode));
  }

  ThemeMode _convertToFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
