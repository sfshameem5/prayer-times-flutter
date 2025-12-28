import 'package:flutter/material.dart';
import 'package:prayer_times/features/reminders/data/models/reminder_model.dart';
import 'package:prayer_times/features/reminders/data/repositories/reminders_repository.dart';

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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
      notifyListeners();
      await _repository.toggleReminder(id, isEnabled);
    }
  }

  Future<void> updateReminderTime(String id, TimeOfDay time) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(time: time);
      notifyListeners();
      await _repository.saveReminders(_reminders);
    }
  }
}
