import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/views/prayer_view.dart';
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
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CountdownLabel(
                      label: "Current",
                      prayer: data.currentPrayer,
                      isHighlighted: false,
                    ),
                    CountdownLabel(
                      label: "Next",
                      prayer: data.nextPrayer,
                      isHighlighted: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Time to next prayer:',
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: RepaintBoundary(
                    child: Selector<PrayerViewModel, String>(
                      selector: (_, model) => model.countdown,
                      builder: (context, countdownString, _) {
                        return Text(
                          countdownString,
                          textAlign: TextAlign.center,
                          style: textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        );
                      },
                    ),
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
