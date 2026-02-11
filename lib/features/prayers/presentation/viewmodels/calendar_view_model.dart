import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/features/prayers/data/models/display_prayer_model.dart';
import 'package:prayer_times/features/prayers/data/models/prayer_month_model.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';

class CalendarViewModel extends ChangeNotifier {
  PrayerMonthModel? _monthData;
  int _selectedDay = DateTime.now().day;
  bool _isLoading = false;
  String? _error;
  late DateTime _monthDate;

  CalendarViewModel() {
    _monthDate = DateTime.now();
  }

  Future<void> loadMonth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      _monthDate = DateTime(now.year, now.month, 1);
      _monthData = await PrayerTimesService.getPrayerTimesForMonth(
        now.millisecondsSinceEpoch,
      );
      _selectedDay = now.day;
    } catch (e) {
      _error = 'Failed to load prayer times';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDay(int day) {
    if (day >= 1 && day <= daysInMonth) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get monthYearLabel {
    return DateFormat('MMMM yyyy').format(_monthDate);
  }

  int get year => _monthDate.year;
  int get month => _monthDate.month;
  int get selectedDay => _selectedDay;
  int get today => DateTime.now().day;

  int get daysInMonth {
    return DateTime(_monthDate.year, _monthDate.month + 1, 0).day;
  }

  int get firstWeekdayOfMonth {
    return DateTime(_monthDate.year, _monthDate.month, 1).weekday % 7;
  }

  List<DisplayPrayerModel> get selectedDayPrayers {
    if (_monthData == null) return [];

    final formatter = DateFormat('d');

    for (var day in _monthData!.dates) {
      final date = DateTime.fromMillisecondsSinceEpoch(day.timestamp);
      if (int.parse(formatter.format(date)) == _selectedDay) {
        return day.prayers
            .map((p) => DisplayPrayerModel.fromPrayerModel(p))
            .toList();
      }
    }

    return [];
  }
}
