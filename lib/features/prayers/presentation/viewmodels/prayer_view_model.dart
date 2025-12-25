import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/countdown_model.dart';
import 'package:prayer_times/features/prayers/data/models/display_prayer_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';

class PrayerViewModel extends ChangeNotifier {
  final _prayerTimesRepository = PrayerTimesRepository();

  PrayerModel? _currentPrayer;
  PrayerModel? _nextPrayer;
  List<PrayerModel> _prayersList = [];

  Timer? _timer;
  CountdownModel _countdown = CountdownModel(
    hours: "0",
    minutes: "0",
    seconds: "0",
  );

  PrayerViewModel() {
    _init();
    _prayerTimesRepository.scheduleNotificationsForToday();
    // _prayerTimesRepository.sendPrayerNotification();
  }

  Future<void> _init() async {
    await updatePrayers();
    updateCountdown();
  }

  Future updatePrayers() async {
    _currentPrayer = await _prayerTimesRepository.getCurrentPrayer();
    _nextPrayer = await _prayerTimesRepository.getNextPrayer();
    _prayersList = await _prayerTimesRepository.getPrayerTimesForToday();

    notifyListeners();
  }

  void updateCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      calculateTimeRemaining();
    });
  }

  void calculateTimeRemaining() {
    if (_nextPrayer == null) return;

    final target = DateTime.fromMillisecondsSinceEpoch(_nextPrayer!.timestamp);
    final now = DateTime.now();
    final difference = target.difference(now);

    if (difference.isNegative) {
      updatePrayers();
      return;
    }

    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    _countdown = CountdownModel(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );

    notifyListeners();
  }

  DisplayPrayerModel get currentPrayer {
    final prayer = _currentPrayer;
    if (prayer == null) {
      return DisplayPrayerModel(name: "Loading", time: "Loading");
    }

    return DisplayPrayerModel.fromPrayerModel(prayer);
  }

  DisplayPrayerModel get nextPrayer {
    final prayer = _nextPrayer;
    if (prayer == null) {
      return DisplayPrayerModel(name: "Loading", time: "Loading");
    }

    return DisplayPrayerModel.fromPrayerModel(prayer);
  }

  List<DisplayPrayerModel> get prayers {
    return _prayersList
        .map((element) => DisplayPrayerModel.fromPrayerModel(element))
        .toList();
  }

  String get currentDate {
    return DateFormat("d MMMM yyyy").format(DateTime.now());
  }

  String get countdown {
    return "${_countdown.hours}H ${_countdown.minutes}M ${_countdown.seconds}S";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
