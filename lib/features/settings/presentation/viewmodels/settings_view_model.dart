import 'package:flutter/material.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/permission_service.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
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

  String get selectedCity => _settings.selectedCity;

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

  Future<void> reload() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    _settings = await _repository.getSettings();

    // Sync LocationService with persisted city
    LocationService.setSelectedCity(_settings.selectedCity);

    await _checkNotificationsEnabled();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateSettings() async {
    _settings = await _repository.getSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled && _notificationsEnabled) return;

    if (enabled) {
      final granted =
          await PermissionService.requestFullNotificationPermissions();

      if (granted) {
        _notificationsEnabled = true;
        await NotificationService.initialize();
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

  Future<void> setSelectedCity(String city) async {
    if (city == _settings.selectedCity) return;

    _settings = _settings.copyWith(selectedCity: city);
    LocationService.setSelectedCity(city);
    await _repository.saveSettings(_settings);

    await SentryService.logString("UI: changed city to $city");

    // Clear prayer cache so new city data is fetched
    PrayerTimesService.clearPrayerCache();

    // Cancel all existing notifications/alarms and reschedule
    await NotificationService.cancelAllNotifications();
    await AlarmService.cancelAllAlarms();

    if (_notificationsEnabled) {
      await PrayerTimesRepository.scheduleNotifications();
    }

    notifyListeners();
  }

  bool _advancedSettingsExpanded = false;
  bool get advancedSettingsExpanded => _advancedSettingsExpanded;

  void toggleAdvancedSettings() {
    _advancedSettingsExpanded = !_advancedSettingsExpanded;
    notifyListeners();
  }

  Future<String?> scheduleTestAlarm(DateTime scheduledTime) async {
    if (!_notificationsEnabled) {
      return 'Please enable notifications first';
    }

    if (scheduledTime.isBefore(DateTime.now())) {
      return 'Please select a time in the future';
    }

    try {
      // await NotificationService.initialize();

      // final notification = NotificationModel(
      //   id: 99999,
      //   heading: 'Test Alarm',
      //   body: 'This is a test notification from Prayer Times',
      //   timestamp: scheduledTime.millisecondsSinceEpoch,
      // );

      final alarmData = AlarmModel(
        id: 99998,
        heading: 'Test Alarm',
        body: 'This is a test alarm from Prayer Times',
        timestamp: scheduledTime.millisecondsSinceEpoch,
        audioPath: 'assets/sounds/azaan_short.mp3',
      );

      // Alarm screen will only be shown if all notificaitions are cleared
      // await NotificationService.scheduleNotification(notification);
      await AlarmService.scheduleAlarm(alarmData);

      await SentryService.logString(
        'Test alarm scheduled for ${scheduledTime.toIso8601String()}',
      );

      return null;
    } catch (e) {
      await SentryService.logString('Error scheduling test alarm: $e');
      return 'Failed to schedule test alarm: $e';
    }
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
