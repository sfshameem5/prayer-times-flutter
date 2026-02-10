import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class PrayerNotificationSettings extends StatelessWidget {
  const PrayerNotificationSettings({super.key});

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

  static String modeLabel(PrayerNotificationMode mode) {
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
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: PrayerNameEnum.values
              .map(
                (prayer) => _PrayerModeRow(
                  prayer: prayer,
                  displayName: _prayerDisplayName(prayer),
                  currentMode: viewModel.getModeForPrayer(prayer),
                  isSunrise: prayer == PrayerNameEnum.sunrise,
                  onChanged: (mode) {
                    if (mode != null) {
                      viewModel.setPrayerNotificationMode(prayer, mode);
                    }
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PrayerModeRow extends StatelessWidget {
  final PrayerNameEnum prayer;
  final String displayName;
  final PrayerNotificationMode currentMode;
  final bool isSunrise;
  final ValueChanged<PrayerNotificationMode?> onChanged;

  const _PrayerModeRow({
    required this.prayer,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.appOrange.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<PrayerNotificationMode>(
              value: currentMode,
              underline: const SizedBox(),
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.appOrange,
                size: 20,
              ),
              dropdownColor: isDark ? AppTheme.navyLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.appOrange,
                fontWeight: FontWeight.w600,
              ),
              items: availableModes
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(PrayerNotificationSettings.modeLabel(mode)),
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
