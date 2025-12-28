import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/reminders/data/models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTimeChanged,
  });

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminder.time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.appOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkCardGradient
            : AppTheme.lightCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: reminder.isEnabled
                      ? AppTheme.appOrange.withOpacity(0.15)
                      : (isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                ),
                child: Icon(
                  _getIconForReminder(reminder.id),
                  color: reminder.isEnabled
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white54 : Colors.black38),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reminder.frequency == ReminderFrequency.daily
                                ? 'Daily'
                                : 'Weekly',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black45,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: reminder.isEnabled,
                onChanged: onToggle,
                activeColor: AppTheme.appOrange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showTimePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder Time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    reminder.formattedTime,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.appOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForReminder(String id) {
    switch (id) {
      case 'friday_prayer':
        return Icons.mosque;
      case 'morning_adhkar':
        return Icons.wb_sunny_outlined;
      case 'evening_adhkar':
        return Icons.nights_stay_outlined;
      case 'tahajjud':
        return Icons.dark_mode_outlined;
      case 'quran_reading':
        return Icons.menu_book_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
