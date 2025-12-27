import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.name,
    required this.time,
    this.isActive = false,
    this.icon,
  });

  final String name;
  final String time;
  final bool isActive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark
            ? (isActive ? AppTheme.navyLight : AppTheme.navySurface)
            : (isActive ? AppTheme.appOrange.withOpacity(0.08) : Colors.white),
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        border: isActive
            ? Border.all(color: AppTheme.appOrange, width: 1.5)
            : Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                width: 1,
              ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: AppTheme.appOrange.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.appOrange.withOpacity(0.15)
                      : (isDark ? Colors.white10 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white70 : Colors.grey.shade600),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? AppTheme.appOrange
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              time,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppTheme.appOrange
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
