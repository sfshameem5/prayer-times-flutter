import 'package:flutter/material.dart';
import 'package:prayer_times/common/data/models/alarm_model.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
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

  static const int minTestAlarmSeconds = 1;
  static const int maxTestAlarmSeconds = 21600; // 6 hours

  SettingsViewModel({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository() {
    _loadSettings();
  }

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _alarmsEnabled = false;
  bool get alarmsEnabled => _alarmsEnabled;

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

  /// Schedule a test alarm in [seconds] with validation and unique test ID.
  Future<String?> scheduleTestAlarmInSeconds({
    required int seconds,
    String label = 'Test Alarm',
  }) async {
    if (!_alarmsEnabled) {
      return 'Please enable alarms first';
    }

    if (seconds < minTestAlarmSeconds) {
      return 'Please enter at least $minTestAlarmSeconds second';
    }

    if (seconds > maxTestAlarmSeconds) {
      return 'Please enter up to $maxTestAlarmSeconds seconds (max 6 hours)';
    }

    final generatedTestId =
        99990 +
        (DateTime.now().millisecondsSinceEpoch % 10000); // keep test IDs unique

    await SentryService.logString(
      'UI: schedule test alarm in $seconds seconds (id=$generatedTestId)',
    );

    return scheduleTestAlarm(
      delay: Duration(seconds: seconds),
      testId: generatedTestId,
      label: label,
    );
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
    _checkAlarmsEnabled();

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
          await PermissionService.requestFullNotificationPermissions(
            isAzaanMode: false,
          );

      if (granted) {
        _notificationsEnabled = true;
        await NotificationService.initialize();
      } else {
        _notificationsEnabled = false;
      }
    }

    if (!enabled) {
      _notificationsEnabled = false;

      // Disabling notifications must also disable alarms — alarms depend on notifications
      if (_alarmsEnabled) {
        _alarmsEnabled = false;
        await AlarmService.cancelAllAlarms();

        // Downgrade any azaan prayers to defaultSound
        final updatedModes = Map<PrayerNameEnum, PrayerNotificationMode>.from(
          _settings.prayerNotificationModes,
        );
        for (final prayer in updatedModes.keys.toList()) {
          if (updatedModes[prayer] == PrayerNotificationMode.azaan) {
            updatedModes[prayer] = PrayerNotificationMode.defaultSound;
          }
        }
        _settings = _settings.copyWith(
          prayerNotificationModes: updatedModes,
          alarmsEnabled: false,
        );
      }

      await NotificationService.cancelAllNotifications();
    }

    _settings = _settings.copyWith(notificationsEnabled: _notificationsEnabled);
    await _repository.saveSettings(_settings);

    await _updateSettings();

    if (enabled && _notificationsEnabled) {
      await PrayerTimesRepository.scheduleNotifications();
    }

    notifyListeners();
  }

  Future<void> setAlarmsEnabled(bool enabled) async {
    if (enabled && _alarmsEnabled) return;

    if (enabled) {
      // Alarms require notifications to be enabled first
      if (!_notificationsEnabled) {
        notifyListeners();
        return;
      }

      // Alarms require full azaan permissions: notification + battery + full-screen intent
      final granted =
          await PermissionService.requestFullNotificationPermissions(
            isAzaanMode: true,
          );

      if (granted) {
        _alarmsEnabled = true;
      } else {
        _alarmsEnabled = false;
        notifyListeners();
        return;
      }
    }

    if (!enabled) {
      _alarmsEnabled = false;
      await AlarmService.cancelAllAlarms();

      // Downgrade any azaan prayers to defaultSound
      final updatedModes = Map<PrayerNameEnum, PrayerNotificationMode>.from(
        _settings.prayerNotificationModes,
      );
      for (final prayer in updatedModes.keys.toList()) {
        if (updatedModes[prayer] == PrayerNotificationMode.azaan) {
          updatedModes[prayer] = PrayerNotificationMode.defaultSound;
        }
      }
      _settings = _settings.copyWith(prayerNotificationModes: updatedModes);
    }

    _settings = _settings.copyWith(alarmsEnabled: _alarmsEnabled);
    await _repository.saveSettings(_settings);
    await _updateSettings();

    // Reschedule with new alarm state
    if (_notificationsEnabled) {
      await NotificationService.cancelAllNotifications();
      await AlarmService.cancelAllAlarms();
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

    // Azaan mode requires alarms to be enabled
    if (mode == PrayerNotificationMode.azaan && !_alarmsEnabled) {
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

  bool get showAdvancedSettings => _settings.showAdvancedSettings;

  Future<void> setShowAdvancedSettings(bool value) async {
    _settings = _settings.copyWith(showAdvancedSettings: value);
    await _repository.saveSettings(_settings);
    await _updateSettings();
    notifyListeners();
  }

  /// Schedule a test alarm after [delay] using the production alarm pipeline.
  /// Always uses azaan_short — azaan_full and azaan_fajr are NEVER used for tests.
  /// [testId] must be unique per concurrent test to avoid overwriting real alarms.
  Future<String?> scheduleTestAlarm({
    required Duration delay,
    int testId = 99990,
    String label = 'Test Alarm',
  }) async {
    if (!_alarmsEnabled) {
      return 'Please enable alarms first';
    }

    try {
      final scheduledTime = DateTime.now().add(delay);

      final alarmData = AlarmModel(
        id: testId,
        heading: label,
        body: 'This is a test alarm from Prayer Times',
        timestamp: scheduledTime.millisecondsSinceEpoch,
        audioPath: 'short',
        isTest: true,
      );

      await AlarmService.scheduleAlarm(alarmData);

      await SentryService.logString(
        'Test alarm ($label) scheduled for ${scheduledTime.toIso8601String()} with audio=short',
      );

      return null;
    } catch (e) {
      await SentryService.logString('Error scheduling test alarm: $e');
      return 'Failed to schedule test alarm: $e';
    }
  }

  /// Send a test notification using flutter_local_notifications (no alarm/full-screen intent).
  /// If [delayed] is true, schedules 30 seconds from now; otherwise shows instantly.
  Future<String?> sendTestNotification({bool delayed = false}) async {
    if (!_notificationsEnabled) {
      return 'Please enable notifications first';
    }

    try {
      await NotificationService.initialize();

      final notification = NotificationModel(
        id: 99993,
        heading: 'Test Notification',
        body: 'This is a test notification from Prayer Times',
        timestamp: delayed
            ? DateTime.now()
                  .add(const Duration(seconds: 30))
                  .millisecondsSinceEpoch
            : null,
      );

      if (delayed) {
        await NotificationService.scheduleNotification(notification);
      } else {
        await NotificationService.showNotification(notification);
      }

      await SentryService.logString(
        'Test notification ${delayed ? "scheduled for 30s" : "sent instantly"}',
      );

      return null;
    } catch (e) {
      await SentryService.logString('Error sending test notification: $e');
      return 'Failed to send test notification: $e';
    }
  }

  Future _checkNotificationsEnabled() async {
    // Only check basic notification permission — do NOT check battery optimization
    // here. Battery optimization being re-enabled by OEM after an update should
    // not silently cancel all alarms and disable notifications.
    var notifications = await NotificationService.checkPermissionStatus();

    // Respect the user's saved preference, but reflect actual permission state
    _notificationsEnabled = _settings.notificationsEnabled && notifications;

    // Only update saved state if notification permission was explicitly revoked
    if (_settings.notificationsEnabled && !notifications) {
      _settings = _settings.copyWith(notificationsEnabled: false);
      await _repository.saveSettings(_settings);
      await NotificationService.cancelAllNotifications();
      await AlarmService.cancelAllAlarms();
    }
  }

  void _checkAlarmsEnabled() {
    // Alarms depend on notifications — if notifications are off, alarms must be off
    _alarmsEnabled = _settings.alarmsEnabled && _notificationsEnabled;
  }
}
