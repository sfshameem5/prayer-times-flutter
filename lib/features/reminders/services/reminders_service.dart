import 'package:prayer_times/features/reminders/data/models/reminder_model.dart';
import 'package:prayer_times/features/reminders/data/repositories/reminders_repository.dart';

class RemindersService {
  final RemindersRepository _repository;

  RemindersService({RemindersRepository? repository})
    : _repository = repository ?? RemindersRepository();

  Future<List<ReminderModel>> getReminders() {
    return _repository.getReminders();
  }

  Future<void> toggleReminder(String id, bool isEnabled) {
    return _repository.toggleReminder(id, isEnabled);
  }

  Future<void> saveReminders(List<ReminderModel> reminders) {
    return _repository.saveReminders(reminders);
  }
}
