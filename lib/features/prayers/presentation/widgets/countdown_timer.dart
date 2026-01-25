import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/models/countdown_model.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/countdown_label.dart';
import 'package:provider/provider.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Selector<
      PrayerViewModel,
      ({String currentPrayer, String nextPrayer})
    >(
      selector: (_, model) => (
        currentPrayer: model.currentPrayer.name,
        nextPrayer: model.nextPrayer.name,
      ),
      builder: (context, data, child) {
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CountdownLabel(
                            label: "CURRENT",
                            prayer: data.currentPrayer,
                            isHighlighted: false,
                          ),
                          CountdownLabel(
                            label: "NEXT",
                            prayer: data.nextPrayer,
                            isHighlighted: true,
                            alignEnd: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Time to next prayer:',
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
                                    'H',
                                    textTheme,
                                    isDark,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildTimeUnit(
                                    countdown.minutes,
                                    'M',
                                    textTheme,
                                    isDark,
                                  ),
                                  const SizedBox(width: 4),
                                  _buildTimeUnit(
                                    countdown.seconds,
                                    'S',
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
          // style: textTheme.displayMedium?.copyWith(
          //   fontFeatures: const [FontFeature.tabularFigures()],
          // ),
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
