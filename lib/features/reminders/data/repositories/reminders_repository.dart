import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times/features/reminders/data/models/reminder_model.dart';

class RemindersRepository {
  static const String _remindersKey = 'reminders';

  Future<List<ReminderModel>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_remindersKey);

    if (remindersJson == null) {
      // Return default reminders if none saved
      return ReminderModel.defaultReminders;
    }

    final List<dynamic> decoded = jsonDecode(remindersJson);
    return decoded.map((json) => ReminderModel.fromJson(json)).toList();
  }

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_remindersKey, encoded);
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    final reminders = await getReminders();
    final updatedReminders = reminders.map((r) {
      if (r.id == id) {
        return r.copyWith(isEnabled: isEnabled);
      }
      return r;
    }).toList();
    await saveReminders(updatedReminders);
  }
}
