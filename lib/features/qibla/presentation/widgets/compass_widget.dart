import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/compass_painter.dart';

class CompassWidget extends StatelessWidget {
  final bool isDark;
  final double rotationAngle;
  final double qiblaDirection;
  final double deviceHeading;
  final bool hasCompassData;
  final bool isAligned;
  final double angleDifference;

  const CompassWidget({
    super.key,
    required this.isDark,
    this.rotationAngle = 0,
    this.qiblaDirection = 0,
    this.deviceHeading = 0,
    this.hasCompassData = false,
    this.isAligned = false,
    this.angleDifference = 0,
  });

  @override
  Widget build(BuildContext context) {
    final alignedColor = const Color(0xFF4CAF50);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isDark
            ? AppTheme.darkCardGradient
            : AppTheme.lightCardGradient,
        boxShadow: [
          BoxShadow(
            color: isAligned
                ? alignedColor.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: isAligned ? 30 : 20,
            spreadRadius: isAligned ? 4 : 0,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.navyDark : Colors.white,
              border: Border.all(
                color: isAligned
                    ? alignedColor.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isAligned
                      ? alignedColor.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: isAligned ? 15 : 10,
                  spreadRadius: isAligned ? 2 : 2,
                ),
              ],
            ),
            child: Center(child: _buildCenterContent(alignedColor)),
          ),
          Transform.rotate(
            angle: rotationAngle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.navigation,
                  color: isAligned ? alignedColor : AppTheme.appOrange,
                  size: 48,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent(Color alignedColor) {
    if (!hasCompassData) {
      return Text(
        'No compass',
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black26,
          fontSize: 12,
        ),
      );
    }

    if (isAligned) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: alignedColor, size: 32),
          const SizedBox(height: 4),
          Text(
            'Qibla Found',
            style: TextStyle(
              color: alignedColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final absAngle = angleDifference.abs();
    final direction = angleDifference > 0 ? 'right' : 'left';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${absAngle.toStringAsFixed(0)}°',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Turn $direction',
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
