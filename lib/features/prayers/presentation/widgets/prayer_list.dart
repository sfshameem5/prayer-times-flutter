import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/data/models/display_prayer_model.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_card.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatelessWidget {
  const PrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Selector<
      PrayerViewModel,
      ({
        List<DisplayPrayerModel> prayers,
        DisplayPrayerModel nextPrayer,
        DisplayPrayerModel currentPrayer,
      })
    >(
      selector: (_, model) => (
        prayers: model.prayers,
        nextPrayer: model.nextPrayer,
        currentPrayer: model.currentPrayer,
      ),
      builder: (context, data, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Prayer Times',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.prayers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prayer = data.prayers[index];
                final isActive = prayer.name == data.currentPrayer.name;

                return PrayerCard(
                  name: prayer.name,
                  time: prayer.time,
                  isActive: isActive,
                  icon: prayer.icon,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
