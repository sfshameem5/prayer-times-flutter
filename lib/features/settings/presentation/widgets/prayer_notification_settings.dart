import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PrayerNotificationSettings extends StatelessWidget {
  const PrayerNotificationSettings({super.key});

  static String _prayerDisplayName(
    PrayerNameEnum prayer,
    AppLocalizations strings,
  ) {
    switch (prayer) {
      case PrayerNameEnum.fajr:
        return strings.prayerFajr;
      case PrayerNameEnum.sunrise:
        return strings.prayerSunrise;
      case PrayerNameEnum.dhuhr:
        return strings.prayerDhuhr;
      case PrayerNameEnum.asr:
        return strings.prayerAsr;
      case PrayerNameEnum.maghrib:
        return strings.prayerMaghrib;
      case PrayerNameEnum.isha:
        return strings.prayerIsha;
    }
  }

  static String modeLabel(
    PrayerNotificationMode mode,
    AppLocalizations strings,
  ) {
    switch (mode) {
      case PrayerNotificationMode.azaan:
        return strings.modeAzaan;
      case PrayerNotificationMode.defaultSound:
        return strings.modeDefault;
      case PrayerNotificationMode.silent:
        return strings.modeSilent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: PrayerNameEnum.values
              .map(
                (prayer) => _PrayerModeRow(
                  prayer: prayer,
                  displayName: _prayerDisplayName(prayer, strings),
                  currentMode: viewModel.getModeForPrayer(prayer),
                  isSunrise: prayer == PrayerNameEnum.sunrise,
                  alarmsEnabled: viewModel.alarmsEnabled,
                  strings: strings,
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
  final bool alarmsEnabled;
  final AppLocalizations strings;
  final ValueChanged<PrayerNotificationMode?> onChanged;

  const _PrayerModeRow({
    required this.prayer,
    required this.displayName,
    required this.currentMode,
    required this.isSunrise,
    required this.alarmsEnabled,
    required this.strings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sunrise only gets defaultSound and silent (no azaan)
    // If alarms are disabled, azaan is not available for any prayer
    final List<PrayerNotificationMode> availableModes;
    if (isSunrise || !alarmsEnabled) {
      availableModes = [
        PrayerNotificationMode.defaultSound,
        PrayerNotificationMode.silent,
      ];
    } else {
      availableModes = PrayerNotificationMode.values;
    }

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
                      child: Text(
                        PrayerNotificationSettings.modeLabel(mode, strings),
                      ),
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
