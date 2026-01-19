import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';

class ThemeModeSelector extends StatelessWidget {
  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  const ThemeModeSelector({
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
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<AppThemeMode>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        dropdownColor: isDark ? AppTheme.navySurface : Colors.white,
        items: const [
          DropdownMenuItem(value: AppThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: AppThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: AppThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (mode) {
          if (mode != null) {
            onChanged(mode);
          }
        },
      ),
    );
  }
}
