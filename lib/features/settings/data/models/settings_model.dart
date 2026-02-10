import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';

enum PrayerNotificationMode { azaan, defaultSound, silent }

enum AppThemeMode { system, light, dark }

class SettingsModel {
  final bool notificationsEnabled;
  final Map<PrayerNameEnum, PrayerNotificationMode> prayerNotificationModes;
  final AppThemeMode themeMode;

  static const Map<PrayerNameEnum, PrayerNotificationMode> defaultPrayerModes =
      {
        PrayerNameEnum.fajr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.sunrise: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.luhr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.asr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.magrib: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.isha: PrayerNotificationMode.defaultSound,
      };

  const SettingsModel({
    this.notificationsEnabled = false,
    this.prayerNotificationModes = const {},
    this.themeMode = AppThemeMode.system,
  });

  PrayerNotificationMode getModeForPrayer(PrayerNameEnum prayer) {
    return prayerNotificationModes[prayer] ??
        defaultPrayerModes[prayer] ??
        PrayerNotificationMode.defaultSound;
  }

  SettingsModel copyWith({
    bool? notificationsEnabled,
    Map<PrayerNameEnum, PrayerNotificationMode>? prayerNotificationModes,
    AppThemeMode? themeMode,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prayerNotificationModes:
          prayerNotificationModes ?? this.prayerNotificationModes,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'prayerNotificationModes': prayerNotificationModes.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'themeMode': themeMode.name,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    Map<PrayerNameEnum, PrayerNotificationMode> modes;

    if (json.containsKey('prayerNotificationModes') &&
        json['prayerNotificationModes'] is Map) {
      final rawModes = json['prayerNotificationModes'] as Map<String, dynamic>;
      modes = rawModes.map(
        (key, value) => MapEntry(
          PrayerNameEnum.values.firstWhere(
            (e) => e.name == key,
            orElse: () => PrayerNameEnum.fajr,
          ),
          PrayerNotificationMode.values.firstWhere(
            (e) => e.name == value,
            orElse: () => PrayerNotificationMode.defaultSound,
          ),
        ),
      );
    } else {
      // Backward compatibility: migrate old single notificationMode
      final legacyMode = PrayerNotificationMode.values.firstWhere(
        (e) => e.name == json['notificationMode'],
        orElse: () => PrayerNotificationMode.defaultSound,
      );
      modes = {
        for (final prayer in PrayerNameEnum.values)
          prayer: prayer == PrayerNameEnum.sunrise
              ? (legacyMode == PrayerNotificationMode.azaan
                    ? PrayerNotificationMode.defaultSound
                    : legacyMode)
              : legacyMode,
      };
    }

    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      prayerNotificationModes: modes,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
    );
  }
}
