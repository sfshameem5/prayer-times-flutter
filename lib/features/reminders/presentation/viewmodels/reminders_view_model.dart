import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prayer_times/common/data/models/notification_model.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/features/reminders/data/models/reminder_model.dart';
import 'package:prayer_times/features/reminders/data/repositories/reminders_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class RemindersViewModel extends ChangeNotifier {
  final RemindersRepository _repository;
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  RemindersViewModel({RemindersRepository? repository})
    : _repository = repository ?? RemindersRepository() {
    _loadReminders();
  }

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  Future<void> _loadReminders() async {
    _isLoading = true;
    notifyListeners();

    _reminders = List.from(await _repository.getReminders());

    //  reschedule enabled reminders
    for (final reminder in _reminders.where((r) => r.isEnabled)) {
      await _scheduleReminder(reminder);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
      notifyListeners();
      await _repository.toggleReminder(id, isEnabled);

      await _rescheduleReminder(_reminders[index]);
    }
  }

  Future<void> updateReminderTime(String id, TimeOfDay time) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(time: time);
      notifyListeners();
      await _repository.saveReminders(_reminders);

      await _rescheduleReminder(_reminders[index]);
    }
  }

  Future<void> _rescheduleReminder(ReminderModel reminder) async {
    // Always cancel any pending notification for this reminder to prevent duplicates
    await NotificationService.cancelNotification(
      _notificationIdFromReminder(reminder),
    );

    // Only schedule if the reminder is enabled
    if (reminder.isEnabled) {
      await _scheduleReminder(reminder);
    }
  }

  Future<void> _scheduleReminder(ReminderModel reminder) async {
    final notificationId = _notificationIdFromReminder(reminder);
    final nextInstance = _nextInstance(reminder);

    if (nextInstance == null) return;

    final notification = NotificationModel(
      id: notificationId,
      heading: reminder.title,
      body: reminder.description,
      timestamp: nextInstance.millisecondsSinceEpoch,
      matchDateTimeComponents: reminder.frequency == ReminderFrequency.daily
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );

    await NotificationService.scheduleNotification(notification);
  }

  int _notificationIdFromReminder(ReminderModel reminder) {
    // Stable, positive ID derived deterministically from the reminder title
    return _stableIdFromTitle(reminder.title);
  }

  tz.TZDateTime? _nextInstance(ReminderModel reminder) {
    final now = tz.TZDateTime.now(tz.local);
    final time = reminder.time;

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (reminder.frequency == ReminderFrequency.daily) {
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    // Weekly: schedule for next Friday (weekday = 5)
    const friday = DateTime.friday;
    while (scheduled.weekday != friday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _stableIdFromTitle(String title) {
    // FNV-1a 32-bit hash over normalized title for cross-run stability
    const int fnvOffset = 0x811C9DC5;
    const int fnvPrime = 0x01000193;
    int hash = fnvOffset;

    final normalized = title.trim().toLowerCase();
    for (final codeUnit in normalized.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }

    return hash & 0x7FFFFFFF;
  }
}
