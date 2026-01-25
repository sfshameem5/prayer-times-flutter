import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/countdown_timer.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/header_widget.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_list.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [HeaderWidget(), CountdownTimer(), PrayerList()],
          ),
        ),
      ),
    );
  }
}
