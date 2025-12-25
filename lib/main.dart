import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/presentation/views/prayer_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.purple)),
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Scaffold(body: SafeArea(child: PrayerView()), backgroundColor: Colors.black),
    );
  }
}
