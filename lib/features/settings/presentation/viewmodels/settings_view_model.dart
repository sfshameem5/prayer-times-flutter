import 'package:flutter/material.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/data/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  SettingsModel _settings = const SettingsModel();
  bool _isLoading = true;

  SettingsViewModel({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository() {
    _loadSettings();
  }

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  PrayerNotificationMode get notificationMode => _settings.notificationMode;
  AppThemeMode get themeMode => _settings.themeMode;

  ThemeMode get flutterThemeMode {
    switch (_settings.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _repository.getSettings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _repository.saveSettings(_settings);

    notifyListeners();
  }

  Future<void> setNotificationMode(PrayerNotificationMode mode) async {
    _settings = _settings.copyWith(notificationMode: mode);
    await _repository.saveSettings(_settings);

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.saveSettings(_settings);

    notifyListeners();
  }
}
