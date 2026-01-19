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
            ? (isActive
                  ? AppTheme.appOrange.withValues(alpha: .12)
                  : AppTheme.navySurface)
            : (isActive
                  ? AppTheme.appOrange.withValues(alpha: .08)
                  : Colors.white),
        borderRadius: BorderRadius.circular(50),
        border: isActive
            ? Border.all(color: AppTheme.appOrange, width: 2)
            : null,
        boxShadow: [
          if (!isActive)
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: .2)
                  : Colors.black.withValues(alpha: .06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.appOrange.withValues(alpha: .2)
                      : (isDark ? Colors.white10 : Colors.grey.shade100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white70 : Colors.grey.shade600),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
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
