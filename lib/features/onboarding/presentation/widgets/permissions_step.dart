import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/notification_step.dart';
import 'package:prayer_times/l10n/app_localizations.dart';

class PermissionsStep extends StatelessWidget {
  final NotificationChoice selectedChoice;
  final bool permissionsGranted;
  final bool isRequesting;
  final Future<void> Function() onRequestPermissions;
  final VoidCallback onSkip;

  const PermissionsStep({
    super.key,
    required this.selectedChoice,
    required this.permissionsGranted,
    required this.isRequesting,
    required this.onRequestPermissions,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context)!;

    final isAzaan = selectedChoice == NotificationChoice.azaan;
    final isNone = selectedChoice == NotificationChoice.none;
    final isAllowed = permissionsGranted && !isNone;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    strings.onboardingPermissionsTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.onboardingPermissionsSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PermissionCard(
                    icon: Icons.notifications_outlined,
                    title: strings.onboardingPermissionsNotificationsTitle,
                    description: strings.onboardingPermissionsNotificationsDesc,
                    badgeLabel: isNone
                        ? strings.onboardingPermissionsStatusOff
                        : strings.onboardingPermissionsRequired,
                    badgeColor: isNone
                        ? (isDark ? Colors.white24 : Colors.black12)
                        : AppTheme.appOrange.withValues(alpha: 0.14),
                    badgeTextColor: isNone
                        ? (isDark ? Colors.white70 : Colors.black54)
                        : AppTheme.appOrange,
                    onPrimary: isNone || isRequesting || isAllowed
                        ? null
                        : onRequestPermissions,
                    primaryLabel: isAllowed
                        ? strings.onboardingPermissionsAllowed
                        : (isRequesting
                              ? strings.loading
                              : strings.onboardingPermissionsAllow),
                    primaryBusy: isRequesting,
                    onSecondary: isNone || isAllowed ? null : onSkip,
                    secondaryLabel: strings.onboardingPermissionsSkip,
                    info: strings.onboardingPermissionsInfoNotifications,
                    isDark: isDark,
                  ),
                  if (isAzaan) ...[
                    const SizedBox(height: 16),
                    _PermissionCard(
                      icon: Icons.volume_up_outlined,
                      title: strings.onboardingPermissionsAzaanTitle,
                      description: strings.onboardingPermissionsAzaanDesc,
                      badgeLabel: strings.onboardingPermissionsRequired,
                      badgeColor: AppTheme.appOrange.withValues(alpha: 0.14),
                      badgeTextColor: AppTheme.appOrange,
                      onPrimary: isRequesting || isAllowed
                          ? null
                          : onRequestPermissions,
                      primaryLabel: isAllowed
                          ? strings.onboardingPermissionsAllowed
                          : (isRequesting
                                ? strings.loading
                                : strings.onboardingPermissionsAllow),
                      primaryBusy: isRequesting,
                      onSecondary: isAllowed ? null : onSkip,
                      secondaryLabel: strings.onboardingPermissionsSkip,
                      info: strings.onboardingPermissionsInfoAzaan,
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.onboardingPermissionsTipXiaomi,
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final Future<void> Function()? onPrimary;
  final String primaryLabel;
  final bool primaryBusy;
  final VoidCallback? onSecondary;
  final String secondaryLabel;
  final String info;
  final bool isDark;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onPrimary,
    required this.primaryLabel,
    required this.primaryBusy,
    required this.onSecondary,
    required this.secondaryLabel,
    required this.info,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.appOrange.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.appOrange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeLabel,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info,
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimary == null
                      ? null
                      : () {
                          onPrimary?.call();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                  child: primaryBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              if (onSecondary != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
