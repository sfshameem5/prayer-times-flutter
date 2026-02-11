import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/data/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  late SettingsModel _settings;
  bool _isLoading = true;

  SettingsViewModel({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository() {
    _loadSettings();
  }

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  // bool get notificationsEnabled => _settings.notificationsEnabled;
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  Map<PrayerNameEnum, PrayerNotificationMode> get prayerNotificationModes =>
      _settings.prayerNotificationModes;

  PrayerNotificationMode getModeForPrayer(PrayerNameEnum prayer) =>
      _settings.getModeForPrayer(prayer);

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
    _settings = await _repository.getSettings();

    await _checkNotificationsEnabled();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateSettings() async {
    _settings = await _repository.getSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled && _notificationsEnabled) return;

    var notificationsSection = false;
    var batteryOptimization = true;

    if (enabled) {
      // check if notification permissions are granted
      // If is not and notifications are enabled
      var notificationResponse =
          await NotificationService.checkPermissionStatus();

      if (!notificationResponse) {
        var newResponse =
            await NotificationService.requestNotificationPermissions();

        notificationsSection = newResponse;
      } else {
        notificationsSection = true;
      }

      // check if battery optimization permissions are granted
      // save value and notify users

      var batteryOptimizationEnabled = await _repository
          .isBackgroundOptimizationEnabled();

      if (batteryOptimizationEnabled) {
        var newResponse = await _repository.requestBackgroundDisabling();

        batteryOptimization = !newResponse;
      } else {
        batteryOptimization = false;
      }

      if (!batteryOptimization && notificationsSection) {
        _notificationsEnabled = true;
        await _repository.requestAutoStartIfAvailable();
      } else {
        _notificationsEnabled = false;
      }
    }

    if (!enabled) {
      _notificationsEnabled = false;
      await NotificationService.cancelAllNotifications();
    }

    _settings = _settings.copyWith(notificationsEnabled: _notificationsEnabled);
    await _repository.saveSettings(_settings);

    await _updateSettings();

    if (enabled) {
      await PrayerTimesRepository.scheduleNotifications();
    }

    notifyListeners();
  }

  Future<void> setPrayerNotificationMode(
    PrayerNameEnum prayer,
    PrayerNotificationMode mode,
  ) async {
    // Sunrise can never be set to azaan
    if (prayer == PrayerNameEnum.sunrise &&
        mode == PrayerNotificationMode.azaan) {
      return;
    }

    final updatedModes = Map<PrayerNameEnum, PrayerNotificationMode>.from(
      _settings.prayerNotificationModes,
    );
    updatedModes[prayer] = mode;

    _settings = _settings.copyWith(prayerNotificationModes: updatedModes);
    await _repository.saveSettings(_settings);

    await _updateSettings();

    await SentryService.logString(
      "UI: change ${prayer.name} notification mode to $mode",
    );

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.saveSettings(_settings);

    await _updateSettings();

    notifyListeners();
  }

  Future _checkNotificationsEnabled() async {
    var batteryOptimization = await _repository
        .isBackgroundOptimizationEnabled();
    var notifications = await NotificationService.checkPermissionStatus();

    if (!batteryOptimization && notifications) {
      _notificationsEnabled = true;
    } else {
      _notificationsEnabled = false;
    }

    if (!notificationsEnabled) {
      await NotificationService.cancelAllNotifications();
      await AlarmService.cancelAllAlarms();
    }

    _settings = _settings.copyWith(notificationsEnabled: _notificationsEnabled);
    await _repository.saveSettings(settings);

    _updateSettings();
  }
}
