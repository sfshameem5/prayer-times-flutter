import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class NotificationModeDropdown extends StatelessWidget {
  final PrayerNotificationMode value;
  final ValueChanged<PrayerNotificationMode?> onChanged;

  const NotificationModeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<PrayerNotificationMode>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        dropdownColor: isDark ? AppTheme.navySurface : Colors.white,
        items: const [
          DropdownMenuItem(
            value: PrayerNotificationMode.defaultSound,
            child: Text('Default'),
          ),
          DropdownMenuItem(
            value: PrayerNotificationMode.azaan,
            child: Text('Azaan'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
