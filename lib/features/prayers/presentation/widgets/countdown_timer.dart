import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:provider/provider.dart';

class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;
    TextStyle? currentPrayer = Theme.of(context).textTheme.bodyMedium;
    TextStyle? nextPrayer = Theme.of(context).textTheme.bodyMedium;
    TextStyle? timer = Theme.of(context).textTheme.displaySmall;

    return Consumer<PrayerViewModel>(
      builder: (context, model, widget) {
        return Container(
          margin: EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Expanded(
                child: FractionallySizedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Current prayer: ${model.currentPrayer.name}',
                          style: currentPrayer,
                        ),
                        SizedBox(height: 10),
                        Text('Time to next prayer:', style: nextPrayer),
                        SizedBox(height: 10),
                        Text(model.countdown, style: timer),
                        SizedBox(height: 10),
                        Text(
                          'Next Prayer: ${model.nextPrayer.name}',
                          style: textStyle,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
