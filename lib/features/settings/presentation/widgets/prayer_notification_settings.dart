import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class PrayerNotificationSettings extends StatelessWidget {
  const PrayerNotificationSettings({super.key});

  static const Map<PrayerNameEnum, IconData> _prayerIcons = {
    PrayerNameEnum.fajr: Icons.nightlight_round,
    PrayerNameEnum.sunrise: Icons.wb_twilight,
    PrayerNameEnum.luhr: Icons.wb_sunny,
    PrayerNameEnum.asr: Icons.wb_sunny_outlined,
    PrayerNameEnum.magrib: Icons.nights_stay_outlined,
    PrayerNameEnum.isha: Icons.dark_mode,
  };

  static String _prayerDisplayName(PrayerNameEnum prayer) {
    switch (prayer) {
      case PrayerNameEnum.fajr:
        return 'Fajr';
      case PrayerNameEnum.sunrise:
        return 'Sunrise';
      case PrayerNameEnum.luhr:
        return 'Dhuhr';
      case PrayerNameEnum.asr:
        return 'Asr';
      case PrayerNameEnum.magrib:
        return 'Maghrib';
      case PrayerNameEnum.isha:
        return 'Isha';
    }
  }

  static String _modeLabel(PrayerNotificationMode mode) {
    switch (mode) {
      case PrayerNotificationMode.azaan:
        return 'Azaan';
      case PrayerNotificationMode.defaultSound:
        return 'Default';
      case PrayerNotificationMode.silent:
        return 'Silent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            gradient:
                isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.appOrange
                            .withValues(alpha: isDark ? 0.3 : 0.08),
                        borderRadius:
                            BorderRadius.circular(AppTheme.smallRadius),
                      ),
                      child: const Icon(Icons.tune,
                          color: AppTheme.appOrange, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prayer Notification Modes',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Set notification mode for each prayer',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black45,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...PrayerNameEnum.values.map(
                (prayer) => _PrayerModeRow(
                  prayer: prayer,
                  icon: _prayerIcons[prayer] ?? Icons.access_time,
                  displayName: _prayerDisplayName(prayer),
                  currentMode: viewModel.getModeForPrayer(prayer),
                  isSunrise: prayer == PrayerNameEnum.sunrise,
                  onChanged: (mode) {
                    if (mode != null) {
                      viewModel.setPrayerNotificationMode(prayer, mode);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrayerModeRow extends StatelessWidget {
  final PrayerNameEnum prayer;
  final IconData icon;
  final String displayName;
  final PrayerNotificationMode currentMode;
  final bool isSunrise;
  final ValueChanged<PrayerNotificationMode?> onChanged;

  const _PrayerModeRow({
    required this.prayer,
    required this.icon,
    required this.displayName,
    required this.currentMode,
    required this.isSunrise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sunrise only gets defaultSound and silent (no azaan)
    final availableModes = isSunrise
        ? [PrayerNotificationMode.defaultSound, PrayerNotificationMode.silent]
        : PrayerNotificationMode.values;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.appOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<PrayerNotificationMode>(
              value: currentMode,
              underline: const SizedBox(),
              isDense: true,
              dropdownColor: isDark ? AppTheme.navySurface : Colors.white,
              style: Theme.of(context).textTheme.bodySmall,
              items: availableModes
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(PrayerNotificationSettings._modeLabel(mode)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
