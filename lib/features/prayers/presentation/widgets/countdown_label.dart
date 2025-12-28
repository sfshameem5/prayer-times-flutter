import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';

class CountdownLabel extends StatelessWidget {
  const CountdownLabel({
    super.key,
    required this.label,
    required this.prayer,
    this.isHighlighted = false,
    this.alignEnd = false,
  });

  final String label;
  final String prayer;
  final bool isHighlighted;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          prayer,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isHighlighted
                ? AppTheme.appOrange
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
