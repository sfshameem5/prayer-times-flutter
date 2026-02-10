import 'package:flutter/material.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/countdown_timer.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/header_widget.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_list.dart';
import 'package:provider/provider.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<PrayerViewModel>().updatePrayers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [HeaderWidget(), CountdownTimer(), PrayerList()],
            ),
          ),
        ),
      ),
    );
  }
}
