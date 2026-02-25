import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/l10n/app_localizations.dart';

class ThemeModeSelector extends StatelessWidget {
  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  const ThemeModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _label(AppThemeMode mode, AppLocalizations strings) {
    switch (mode) {
      case AppThemeMode.system:
        return strings.onboardingThemeSystem;
      case AppThemeMode.light:
        return strings.onboardingThemeLight;
      case AppThemeMode.dark:
        return strings.onboardingThemeDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.appOrange.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<AppThemeMode>(
        value: value,
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
        items: AppThemeMode.values
            .map(
              (mode) => DropdownMenuItem(
                value: mode,
                child: Text(_label(mode, strings)),
              ),
            )
            .toList(),
        onChanged: (mode) {
          if (mode != null) {
            onChanged(mode);
          }
        },
      ),
    );
  }
}
