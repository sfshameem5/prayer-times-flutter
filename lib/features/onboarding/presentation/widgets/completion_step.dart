import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/notification_step.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class CompletionStep extends StatelessWidget {
  final String selectedCity;
  final NotificationChoice notificationChoice;
  final AppThemeMode themeMode;
  final bool permissionsGranted;

  const CompletionStep({
    super.key,
    required this.selectedCity,
    required this.notificationChoice,
    required this.themeMode,
    required this.permissionsGranted,
  });

  static String _themeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context)!;

    final cityName = LocationService.getShortDisplayName(selectedCity);
    final modeName = permissionsGranted
        ? (notificationChoice == NotificationChoice.azaan
              ? strings.onboardingAlertModeAzaan
              : strings.onboardingAlertModeNotifications)
        : strings.onboardingAlertModeDisabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.appOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 52,
              color: AppTheme.appOrange,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            strings.onboardingAllSet,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.onboardingReady,
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          if (!permissionsGranted) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.onboardingNotificationsDisabled,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.location_on_outlined,
                  label: strings.onboardingSummaryRegion,
                  value: cityName,
                  isDark: isDark,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                _SummaryRow(
                  icon: permissionsGranted
                      ? (notificationChoice == NotificationChoice.azaan
                            ? Icons.volume_up_outlined
                            : Icons.notifications_outlined)
                      : Icons.notifications_off_outlined,
                  label: strings.onboardingSummaryAlertMode,
                  value: modeName,
                  isDark: isDark,
                  valueColor: permissionsGranted ? null : Colors.amber,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                _SummaryRow(
                  icon: Icons.brightness_6_outlined,
                  label: strings.onboardingSummaryTheme,
                  value: _themeName(themeMode) == 'system'
                      ? strings.onboardingThemeSystem
                      : _themeName(themeMode) == 'light'
                      ? strings.onboardingThemeLight
                      : strings.onboardingThemeDark,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppTheme.appOrange, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.appOrange,
          ),
        ),
      ],
    );
  }
}
