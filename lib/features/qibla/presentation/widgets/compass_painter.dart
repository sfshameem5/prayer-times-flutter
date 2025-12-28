import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';

class CompassPainter extends CustomPainter {
  final bool isDark;

  CompassPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = isDark ? Colors.white38 : Colors.black26
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = isDark ? Colors.white70 : Colors.black54
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 10) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 15.0 : 8.0;
      final angle = i * pi / 180;

      final start = Offset(
        center.dx + (radius - tickLength) * sin(angle),
        center.dy - (radius - tickLength) * cos(angle),
      );
      final end = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }

    final textStyle = TextStyle(
      color: isDark ? Colors.white : AppTheme.darkText,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0.0, 90.0, 180.0, 270.0];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: directions[i] == 'N'
              ? textStyle.copyWith(color: AppTheme.appOrange)
              : textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        center.dx + (radius - 30) * sin(angle) - textPainter.width / 2,
        center.dy - (radius - 30) * cos(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
