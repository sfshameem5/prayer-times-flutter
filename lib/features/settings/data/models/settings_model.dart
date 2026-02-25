import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';

enum PrayerNotificationMode { azaan, defaultSound, silent }

enum AppThemeMode { system, light, dark }

class SettingsModel {
  final bool notificationsEnabled;
  final bool alarmsEnabled;
  final Map<PrayerNameEnum, PrayerNotificationMode> prayerNotificationModes;
  final AppThemeMode themeMode;
  final String selectedCity;
  final bool showAdvancedSettings;

  static const Map<PrayerNameEnum, PrayerNotificationMode> defaultPrayerModes =
      {
        PrayerNameEnum.fajr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.sunrise: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.dhuhr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.asr: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.maghrib: PrayerNotificationMode.defaultSound,
        PrayerNameEnum.isha: PrayerNotificationMode.defaultSound,
      };

  const SettingsModel({
    this.notificationsEnabled = false,
    this.alarmsEnabled = false,
    this.prayerNotificationModes = const {},
    this.themeMode = AppThemeMode.system,
    this.selectedCity = 'colombo',
    this.showAdvancedSettings = false,
  });

  PrayerNotificationMode getModeForPrayer(PrayerNameEnum prayer) {
    return prayerNotificationModes[prayer] ??
        defaultPrayerModes[prayer] ??
        PrayerNotificationMode.defaultSound;
  }

  SettingsModel copyWith({
    bool? notificationsEnabled,
    bool? alarmsEnabled,
    Map<PrayerNameEnum, PrayerNotificationMode>? prayerNotificationModes,
    AppThemeMode? themeMode,
    String? selectedCity,
    bool? showAdvancedSettings,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      alarmsEnabled: alarmsEnabled ?? this.alarmsEnabled,
      prayerNotificationModes:
          prayerNotificationModes ?? this.prayerNotificationModes,
      themeMode: themeMode ?? this.themeMode,
      selectedCity: selectedCity ?? this.selectedCity,
      showAdvancedSettings: showAdvancedSettings ?? this.showAdvancedSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'alarmsEnabled': alarmsEnabled,
      'prayerNotificationModes': prayerNotificationModes.map(
        (key, value) => MapEntry(key.name, value.name),
      ),
      'themeMode': themeMode.name,
      'selectedCity': selectedCity,
      'showAdvancedSettings': showAdvancedSettings,
    };
  }

  static PrayerNameEnum _safeParsePrayerName(String key) {
    switch (key) {
      case 'luhr':
        return PrayerNameEnum.dhuhr;
      case 'magrib':
        return PrayerNameEnum.maghrib;
      default:
        return PrayerNameEnum.values.firstWhere(
          (e) => e.name == key,
          orElse: () => PrayerNameEnum.fajr,
        );
    }
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    Map<PrayerNameEnum, PrayerNotificationMode> modes;

    if (json.containsKey('prayerNotificationModes') &&
        json['prayerNotificationModes'] is Map) {
      final rawModes = json['prayerNotificationModes'] as Map<String, dynamic>;
      modes = rawModes.map(
        (key, value) => MapEntry(
          _safeParsePrayerName(key),
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
      alarmsEnabled: json['alarmsEnabled'] as bool? ?? false,
      prayerNotificationModes: modes,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      selectedCity: json['selectedCity'] as String? ?? 'colombo',
      showAdvancedSettings: json['showAdvancedSettings'] as bool? ?? false,
    );
  }
}
