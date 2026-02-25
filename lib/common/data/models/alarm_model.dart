class AlarmModel {
  int id;
  String heading;
  String body;
  int timestamp;
  String audioPath;
  bool isTest;
  String? localeCode;

  AlarmModel({
    required this.id,
    required this.heading,
    required this.body,
    required this.timestamp,
    required this.audioPath,
    this.isTest = false,
    this.localeCode,
  });
}
