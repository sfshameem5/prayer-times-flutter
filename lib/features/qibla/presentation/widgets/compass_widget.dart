import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/compass_painter.dart';

class CompassWidget extends StatelessWidget {
  final bool isDark;
  final double rotationAngle;
  final double qiblaDirection;
  final double deviceHeading;
  final bool hasCompassData;

  const CompassWidget({
    super.key,
    required this.isDark,
    this.rotationAngle = 0,
    this.qiblaDirection = 0,
    this.deviceHeading = 0,
    this.hasCompassData = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDark
            ? AppTheme.darkCardGradient
            : AppTheme.lightCardGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: CompassPainter(isDark: isDark),
          ),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.navyDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: hasCompassData
                  ? Text(
                      '${deviceHeading.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      'No compass',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black26,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          Transform.rotate(
            angle: rotationAngle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.navigation, color: AppTheme.appOrange, size: 48),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.appOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'QIBLA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
