import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';

class CountdownLabel extends StatelessWidget {
  const CountdownLabel({
    super.key,
    required this.label,
    required this.prayer,
    this.isHighlighted = false,
  });

  final String label;
  final String prayer;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          prayer,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isHighlighted
                ? AppTheme.appOrange
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
