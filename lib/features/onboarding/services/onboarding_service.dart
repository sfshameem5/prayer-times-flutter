import 'dart:io';

import 'package:mmkv/mmkv.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:prayer_times/core/background_executor.dart' as bg;

class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static bool isOnboardingCompleted() {
    final mmkv = MMKV.defaultMMKV();
    return mmkv.decodeBool(_onboardingCompletedKey);
  }

  static Future<void> completeOnboarding({
    required String selectedCity,
    required bool useAzaan,
    required AppThemeMode themeMode,
    required bool notificationsEnabled,
  }) async {
    final settingsService = SettingsService();

    // Build per-prayer notification modes
    final Map<PrayerNameEnum, PrayerNotificationMode> modes = {};
    for (final prayer in PrayerNameEnum.values) {
      if (prayer == PrayerNameEnum.sunrise) {
        // Sunrise never gets azaan
        modes[prayer] = PrayerNotificationMode.defaultSound;
      } else {
        modes[prayer] = useAzaan
            ? PrayerNotificationMode.azaan
            : PrayerNotificationMode.defaultSound;
      }
    }

    // Save settings
    final settings = SettingsModel(
      notificationsEnabled: notificationsEnabled,
      prayerNotificationModes: modes,
      themeMode: themeMode,
      selectedCity: selectedCity,
    );

    await settingsService.saveSettings(settings);
    LocationService.setSelectedCity(selectedCity);

    if (notificationsEnabled) {
      // Initialize Workmanager for background scheduling (Android only)
      if (Platform.isAndroid) {
        await Workmanager().initialize(bg.callbackDispatcher);
        await Workmanager().registerPeriodicTask(
          "prayer",
          "prayer-notifications",
          frequency: const Duration(days: 1),
          existingWorkPolicy: ExistingWorkPolicy.keep,
        );
      }

      // Initialize notifications and schedule
      await NotificationService.initialize();
      await PrayerTimesRepository.scheduleNotifications();
    }

    // Mark onboarding as completed
    final mmkv = MMKV.defaultMMKV();
    mmkv.encodeBool(_onboardingCompletedKey, true);
  }

  static Future<void> resetApp() async {
    // Cancel all notifications and alarms
    await NotificationService.cancelAllNotifications();

    // Clear all MMKV storage (settings, onboarding flag, caches)
    final mmkv = MMKV.defaultMMKV();
    mmkv.clearAll();
  }
}
