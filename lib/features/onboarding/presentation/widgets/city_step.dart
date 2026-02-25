import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class CityStep extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCitySelected;
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  const CityStep({
    super.key,
    required this.selectedCity,
    required this.onCitySelected,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.mosque_outlined, size: 64, color: AppTheme.appOrange),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.onboardingGreeting,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(
            context,
            AppLocalizations.of(context)!.onboardingAppearance,
            isDark,
          ),
          const SizedBox(height: 8),
          _ThemePicker(
            strings: AppLocalizations.of(context)!,
            value: themeMode,
            onChanged: onThemeModeChanged,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _sectionLabel(
            context,
            AppLocalizations.of(context)!.onboardingRegion,
            isDark,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppTheme.darkCardGradient
                    : AppTheme.lightCardGradient,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: LocationService.cities.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final city = LocationService.cities[index];
                    final isSelected = city.slug == selectedCity;

                    return InkWell(
                      onTap: () => onCitySelected(city.slug),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.appOrange
                                      : (isDark
                                            ? Colors.white30
                                            : Colors.black26),
                                  width: isSelected ? 2 : 1.5,
                                ),
                                color: isSelected
                                    ? AppTheme.appOrange
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                city.displayName,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppTheme.appOrange
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDark ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;
  final bool isDark;
  final AppLocalizations strings;

  const _ThemePicker({
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.strings,
  });

  static IconData _icon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto_outlined;
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  String _label(AppThemeMode mode) {
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
    return Row(
      children: AppThemeMode.values.map((mode) {
        final isSelected = mode == value;
        final isLast = mode == AppThemeMode.values.last;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _ThemeTile(
              icon: _icon(mode),
              label: _label(mode),
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onChanged(mode),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? null
              : (isDark
                    ? AppTheme.darkCardGradient
                    : AppTheme.lightCardGradient),
          color: isSelected ? AppTheme.appOrange : null,
          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
          border: Border.all(
            color: isSelected
                ? AppTheme.appOrange
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.appOrange.withValues(
                      alpha: isDark ? 0.3 : 0.25,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
