import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_card.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatelessWidget {
  const PrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final strings = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    final viewModel = context.watch<PrayerViewModel>();
    if (viewModel.isLoading) {
      return const _PrayerListSkeleton();
    }

    final prayers = viewModel.prayers(strings, localeCode);
    final current = viewModel.currentPrayer(strings, localeCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.prayerTimesTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prayer = prayers[index];
            final isActive = prayer.name == current.name;

            return PrayerCard(
              name: prayer.name,
              time: prayer.time,
              isActive: isActive,
              isPassed: prayer.isPassed,
              icon: prayer.icon,
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PrayerListSkeleton extends StatefulWidget {
  const _PrayerListSkeleton();

  @override
  State<_PrayerListSkeleton> createState() => _PrayerListSkeletonState();
}

class _PrayerListSkeletonState extends State<_PrayerListSkeleton>
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 120,
              height: 22,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 6; i++) ...[
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              if (i < 5) const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
