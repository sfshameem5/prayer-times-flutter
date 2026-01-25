import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {}

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {}

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {}

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {}
}
