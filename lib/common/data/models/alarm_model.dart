class AlarmModel {
  int id;
  String heading;
  String body;
  int timestamp;
  String audioPath;

  AlarmModel({
    required this.id,
    required this.heading,
    required this.body,
    required this.timestamp,
    required this.audioPath,
  });
}
