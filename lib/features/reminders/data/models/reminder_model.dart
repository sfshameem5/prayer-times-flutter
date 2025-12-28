import 'package:flutter/material.dart';

enum ReminderFrequency { daily, weekly }

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final ReminderFrequency frequency;
  final bool isEnabled;
  final TimeOfDay time;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    this.isEnabled = false,
    this.time = const TimeOfDay(hour: 8, minute: 0),
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderFrequency? frequency,
    bool? isEnabled,
    TimeOfDay? time,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency.name,
      'isEnabled': isEnabled,
      'timeHour': time.hour,
      'timeMinute': time.minute,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => ReminderFrequency.daily,
      ),
      isEnabled: json['isEnabled'] as bool? ?? false,
      time: TimeOfDay(
        hour: json['timeHour'] as int? ?? 8,
        minute: json['timeMinute'] as int? ?? 0,
      ),
    );
  }

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static List<ReminderModel> defaultReminders = const [
    ReminderModel(
      id: 'friday_prayer',
      title: 'Friday Prayer',
      description: 'Reminder for Jumu\'ah prayer',
      frequency: ReminderFrequency.weekly,
      time: TimeOfDay(hour: 12, minute: 0),
    ),
    ReminderModel(
      id: 'morning_adhkar',
      title: 'Morning Adhkar',
      description: 'Daily morning remembrance',
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 6, minute: 30),
    ),
    ReminderModel(
      id: 'evening_adhkar',
      title: 'Evening Adhkar',
      description: 'Daily evening remembrance',
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 18, minute: 0),
    ),
    ReminderModel(
      id: 'tahajjud',
      title: 'Tahajjud',
      description: 'Night prayer reminder',
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 4, minute: 0),
    ),
    ReminderModel(
      id: 'quran_reading',
      title: 'Quran Reading',
      description: 'Daily Quran recitation reminder',
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 20, minute: 0),
    ),
  ];
}
