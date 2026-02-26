import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/common/services/connectivity_service.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
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
  bool _isOnline = ConnectivityService.instance.isOnline;
  bool _offlineNoData = false;

  Timer? _timer;
  StreamSubscription<bool>? _connectivitySub;
  CountdownModel _countdown = CountdownModel(
    hours: "00",
    minutes: "00",
    seconds: "00",
  );

  PrayerViewModel() {
    _init();
    _connectivitySub = ConnectivityService.instance.onStatusChange.listen((
      isOnline,
    ) {
      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        if (isOnline) {
          updatePrayers();
        } else {
          notifyListeners();
        }
      }
    });
  }

  Future<void> _init() async {
    await updatePrayers();
    updateCountdown();
  }

  Future updatePrayers() async {
    if (_isUpdating) return;
    _isUpdating = true;

    final previousPrayers = List<PrayerModel>.from(_prayersList);
    final previousNext = _nextPrayer;

    _isLoading = _prayersList.isEmpty;
    if (_isLoading) notifyListeners();

    _nextPrayer = await PrayerTimesRepository.getNextPrayer();
    _prayersList = await PrayerTimesRepository.getPrayerTimesForToday();

    final hadDataBefore = previousPrayers.isNotEmpty;
    final gotData = _prayersList.isNotEmpty;
    final offline = !_isOnline;

    if (!gotData && offline && hadDataBefore) {
      // Keep previous data when offline fetch fails.
      _prayersList = previousPrayers;
      _nextPrayer = previousNext;
    }

    _offlineNoData = !gotData && !hadDataBefore && offline;

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
  bool get isOnline => _isOnline;
  bool get offlineNoData => _offlineNoData;

  bool get isSunrise =>
      _nextPrayer != null && _nextPrayer!.name == PrayerNameEnum.sunrise;

  DisplayPrayerModel nextPrayer(AppLocalizations strings, String localeCode) {
    final prayer = _nextPrayer;
    if (prayer == null) {
      return DisplayPrayerModel(name: strings.loading, time: strings.loading);
    }

    return DisplayPrayerModel.fromPrayerModel(prayer, strings, localeCode);
  }

  DisplayPrayerModel currentPrayer(
    AppLocalizations strings,
    String localeCode,
  ) {
    if (_prayersList.isEmpty) {
      return DisplayPrayerModel(name: strings.loading, time: strings.loading);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    // Pick the latest prayer whose time is not in the future; if all are in the future, fall back to the first.
    final current = _prayersList.lastWhere(
      (p) => p.timestamp <= now,
      orElse: () => _prayersList.first,
    );

    return DisplayPrayerModel.fromPrayerModel(current, strings, localeCode);
  }

  List<DisplayPrayerModel> prayers(
    AppLocalizations strings,
    String localeCode,
  ) {
    return _prayersList
        .map(
          (element) =>
              DisplayPrayerModel.fromPrayerModel(element, strings, localeCode),
        )
        .toList();
  }

  String currentDate(String localeCode) {
    return DateFormat("d MMMM yyyy", localeCode).format(DateTime.now());
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
    _connectivitySub?.cancel();
    super.dispose();
  }
}
