import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/presentation/views/prayer_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:prayer_times/core/background_executor.dart' as bg;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  NotificationService.initialize();

  await Workmanager().initialize(bg.callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    "prayer",
    "prayer-notifications",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: SafeArea(child: PrayerView()),
        backgroundColor: Colors.black,
      ),
    );
  }
}
