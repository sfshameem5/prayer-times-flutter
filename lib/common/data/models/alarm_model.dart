class AlarmModel {
  int id;
  String heading;
  String body;
  int timestamp;
  String audioPath;
  bool isTest;

  AlarmModel({
    required this.id,
    required this.heading,
    required this.body,
    required this.timestamp,
    required this.audioPath,
    this.isTest = false,
  });
}
