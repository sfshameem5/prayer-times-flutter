import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static var _isInitialized = false;
  static final _deviceInfo = DeviceInfoPlugin();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Sentry.init((options) {
      options.dsn =
          'https://808ff539b9789943c63919c377972725@o4504744963145728.ingest.us.sentry.io/4510811150352384';
      options.enableLogs = true;
    });

    _isInitialized = true;
  }

  static Future<void> logString(String log) async {
    if (!_isInitialized) await initialize();

    var androidName = await _deviceInfo.androidInfo;

    var finalLog = "";

    if (Platform.isAndroid) {
      finalLog += "Log: ${androidName.model} $log";
    } else {
      finalLog += "Log: $log";
    }

    if (kDebugMode) {
      print(finalLog);
    }

    return await Sentry.logger.info(finalLog);
  }
}
