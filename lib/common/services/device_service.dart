import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  DeviceService._();

  static final _deviceInfo = DeviceInfoPlugin();
  static bool? _cachedIsXiaomiFamily;

  static Future<bool> isXiaomiFamily() async {
    if (_cachedIsXiaomiFamily != null) return _cachedIsXiaomiFamily!;

    if (!Platform.isAndroid) {
      _cachedIsXiaomiFamily = false;
      return false;
    }

    final info = await _deviceInfo.androidInfo;
    final brand = info.brand.toLowerCase();
    final manufacturer = info.manufacturer.toLowerCase();

    const candidates = ['xiaomi', 'redmi', 'poco'];
    final isMatch = candidates.any(
      (key) => brand.startsWith(key) || manufacturer.startsWith(key),
    );

    _cachedIsXiaomiFamily = isMatch;
    return isMatch;
  }
}
