import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/models/countdown_model.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Consumer<PrayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const _CountdownSkeleton();
        }

        final nextPrayer = viewModel.nextPrayer(strings, localeCode);
        final isSunrise = viewModel.isSunrise;

        if (viewModel.offlineNoData) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            gradient: isDark
                ? AppTheme.darkCardGradient
                : AppTheme.lightCardGradient,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Text(
                  isSunrise
                      ? strings.nextEventLabel.toUpperCase()
                      : strings.nextPrayerLabel.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nextPrayer.name,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppTheme.appOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextPrayer.time,
                  style: textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        strings.timeRemaining,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RepaintBoundary(
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Selector<PrayerViewModel, CountdownModel>(
                            selector: (_, model) => model.countdownModel,
                            builder: (context, countdown, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  _buildTimeUnit(
                                    countdown.hours,
                                    strings.timeUnitHour,
                                    textTheme,
                                    isDark,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildTimeUnit(
                                    countdown.minutes,
                                    strings.timeUnitMinute,
                                    textTheme,
                                    isDark,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildTimeUnit(
                                    countdown.seconds,
                                    strings.timeUnitSecond,
                                    textTheme,
                                    isDark,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(
    String value,
    String label,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            textStyle: textTheme.displayMedium,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CountdownSkeleton extends StatefulWidget {
  const _CountdownSkeleton();

  @override
  State<_CountdownSkeleton> createState() => _CountdownSkeletonState();
}

class _CountdownSkeletonState extends State<_CountdownSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerColor = isDark
            ? Colors.white.withValues(alpha: 0.04 + 0.04 * _controller.value)
            : Colors.grey.withValues(alpha: 0.08 + 0.08 * _controller.value);

        return Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            gradient: isDark
                ? AppTheme.darkCardGradient
                : AppTheme.lightCardGradient,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 18,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
