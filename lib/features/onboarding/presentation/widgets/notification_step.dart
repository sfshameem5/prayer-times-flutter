import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/config/theme.dart';

enum NotificationChoice { notifications, azaan, none }

class NotificationStep extends StatelessWidget {
  final NotificationChoice selectedChoice;
  final ValueChanged<NotificationChoice> onChoiceSelected;

  const NotificationStep({
    super.key,
    required this.selectedChoice,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 64,
                    color: AppTheme.appOrange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.onboardingStayOnTime,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.onboardingReminderQuestion,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _ChoiceCard(
                    icon: Icons.notifications_outlined,
                    title: strings.onboardingChoiceNotifications,
                    description: strings.onboardingChoiceNotificationsDesc,
                    isSelected:
                        selectedChoice == NotificationChoice.notifications,
                    onTap: () =>
                        onChoiceSelected(NotificationChoice.notifications),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _ChoiceCard(
                    icon: Icons.volume_up_outlined,
                    title: strings.onboardingChoiceAzaan,
                    description: strings.onboardingChoiceAzaanDesc,
                    isSelected: selectedChoice == NotificationChoice.azaan,
                    onTap: () => onChoiceSelected(NotificationChoice.azaan),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _ChoiceCard(
                    icon: Icons.notifications_off_outlined,
                    title: strings.onboardingChoiceNone,
                    description: strings.onboardingChoiceNoneDesc,
                    isSelected: selectedChoice == NotificationChoice.none,
                    onTap: () => onChoiceSelected(NotificationChoice.none),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    strings.onboardingChoiceInfo,
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkCardGradient
              : AppTheme.lightCardGradient,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppTheme.appOrange
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.appOrange.withValues(alpha: isDark ? 0.2 : 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.appOrange.withValues(alpha: 0.15)
                    : (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.appOrange
                    : (isDark ? Colors.white54 : Colors.black45),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.appOrange : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white30 : Colors.black26),
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? AppTheme.appOrange : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
