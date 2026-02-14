import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/common/services/alarm_service.dart';
import 'package:prayer_times/config/theme.dart';

class AlarmScreen extends StatefulWidget {
  final String title;
  final String body;
  final int timestamp;

  const AlarmScreen({
    super.key,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasSnoozed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _prayerName => widget.title;

  String get _prayerTime {
    return DateFormat.jm().format(
      DateTime.fromMillisecondsSinceEpoch(widget.timestamp),
    );
  }

  IconData get _prayerIcon {
    final title = _prayerName.toLowerCase();
    if (title.contains('fajr')) return Icons.nightlight_round;
    if (title.contains('sunrise')) return Icons.wb_twilight;
    if (title.contains('luhr') || title.contains('dhuhr')) {
      return Icons.wb_sunny;
    }
    if (title.contains('asr')) return Icons.wb_sunny_outlined;
    if (title.contains('magrib') || title.contains('maghrib')) {
      return Icons.nights_stay_outlined;
    }
    if (title.contains('isha')) return Icons.dark_mode;
    return Icons.access_time;
  }

  Future<void> _dismiss() async {
    await AlarmService.stopFiringAlarm();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    if (_hasSnoozed) return;

    setState(() => _hasSnoozed = true);

    await AlarmService.snoozeFiringAlarm();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppTheme.navyDark, Colors.black]
                  : [const Color(0xFFF8F9FA), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.appOrange.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      _prayerIcon,
                      size: 56,
                      color: AppTheme.appOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _prayerName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _prayerTime,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.appOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AlarmButton(
                          label: _hasSnoozed ? 'Snoozed' : 'Snooze',
                          sublabel: _hasSnoozed ? '' : '10 min',
                          icon: Icons.snooze,
                          color: isDark
                              ? AppTheme.navyLight
                              : const Color(0xFFE8E8E8),
                          textColor: isDark ? Colors.white : AppTheme.darkText,
                          onTap: _hasSnoozed ? null : _snooze,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _AlarmButton(
                          label: 'Dismiss',
                          sublabel: '',
                          icon: Icons.close,
                          color: AppTheme.appOrange,
                          textColor: Colors.white,
                          onTap: _dismiss,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlarmButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _AlarmButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sublabel.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
