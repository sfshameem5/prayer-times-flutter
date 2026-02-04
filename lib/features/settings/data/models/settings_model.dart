enum PrayerNotificationMode { azaan, defaultSound }

enum AppThemeMode { system, light, dark }

class SettingsModel {
  final bool notificationsEnabled;
  final PrayerNotificationMode notificationMode;
  final AppThemeMode themeMode;

  const SettingsModel({
    this.notificationsEnabled = false,
    this.notificationMode = PrayerNotificationMode.defaultSound,
    this.themeMode = AppThemeMode.system,
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    PrayerNotificationMode? notificationMode,
    AppThemeMode? themeMode,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationMode: notificationMode ?? this.notificationMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'notificationMode': notificationMode.name,
      'themeMode': themeMode.name,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notificationMode: PrayerNotificationMode.values.firstWhere(
        (e) => e.name == json['notificationMode'],
        orElse: () => PrayerNotificationMode.defaultSound,
      ),
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
    );
  }
}
