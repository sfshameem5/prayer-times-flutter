import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:provider/provider.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodySmall;

    return Consumer<PrayerViewModel>(
      builder: (context, prayerModel, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayerModel.currentDate, style: textStyle),
                    SizedBox(height: 5),
                    Text("Jumada II 24, 1447 AH", style: textStyle),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Text("Colombo", style: textStyle)],
              ),
            ),
          ],
        );
      },
    );
  }
}
