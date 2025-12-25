import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_card.dart';
import 'package:provider/provider.dart';

class PrayerList extends StatelessWidget {
  PrayerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerViewModel>(builder: (context, model, widget) {
      return  Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text('Prayer Times', style: Theme.of(context).textTheme.bodyMedium),
                for (var prayer in model.prayers) ...[
                  const SizedBox(height: 20),
                  PrayerCard(
                      name: prayer.name,
                      time: prayer.time
                  ),
                ],
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      );
    });
  }
}
