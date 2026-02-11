import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/common/services/sentry_service.dart';
import 'package:prayer_times/features/prayers/data/enums/prayer_name_enum.dart';
import 'package:prayer_times/features/prayers/data/models/countdown_model.dart';
import 'package:prayer_times/features/prayers/data/models/display_prayer_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_model.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';

class PrayerViewModel extends ChangeNotifier {
  PrayerModel? _nextPrayer;
  List<PrayerModel> _prayersList = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  Timer? _timer;
  CountdownModel _countdown = CountdownModel(
    hours: "00",
    minutes: "00",
    seconds: "00",
  );

  PrayerViewModel() {
    _init();
  }

  Future<void> _init() async {
    await updatePrayers();
    updateCountdown();
  }

  Future updatePrayers() async {
    if (_isUpdating) return;
    _isUpdating = true;

    _isLoading = _prayersList.isEmpty;
    if (_isLoading) notifyListeners();

    _nextPrayer = await PrayerTimesRepository.getNextPrayer();
    _prayersList = await PrayerTimesRepository.getPrayerTimesForToday();

    _isLoading = false;
    _isUpdating = false;

    await SentryService.logString(
      "UI: next prayer ${_nextPrayer?.name} ${_nextPrayer?.timestamp}",
    );

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

    final now = DateTime.now();

    final target = DateTime.fromMillisecondsSinceEpoch(_nextPrayer!.timestamp);
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

  bool get isLoading => _isLoading;

  bool get isSunrise =>
      _nextPrayer != null && _nextPrayer!.name == PrayerNameEnum.sunrise;

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

  String get currentHijriDate {
    return PrayerTimesRepository.getTodayHijriDateFormatted();
  }

  String get countdown {
    return "${_countdown.hours}H ${_countdown.minutes}M ${_countdown.seconds}S";
  }

  CountdownModel get countdownModel => _countdown;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
