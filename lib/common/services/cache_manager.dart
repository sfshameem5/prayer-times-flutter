import 'dart:convert';

import 'package:mmkv/mmkv.dart';

class CacheManager {
  static MMKV? _instance;

  static Future<void> initialize() async {
    await MMKV.initialize();
    _instance = MMKV.defaultMMKV();
  }

  static String? getStringItem(String key) {
    // Check if the item exists
    var item = _instance!.decodeString("_cache$key");
    if (item == null) return null;

    // If there's no expires at we delete the item and return null
    var decoded = json.decode(item);
    if (decoded['expiresAt'] == null) {
      removeStringItem(key);
      return null;
    }

    // Check if the item hasn't expired
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    int expires = decoded['expiresAt'];

    // This means it has expired
    if (currentTimestamp > expires) {
      removeStringItem(key);
      return null;
    }

    return decoded["item"];
  }

  static void saveStringItem(String key, String value, int minutesFromNow) {
    var expires = DateTime.now()
        .add(Duration(minutes: minutesFromNow))
        .millisecondsSinceEpoch;

    var toEncode = {"item": value, "expiresAt": expires};

    _instance!.encodeString("_cache$key", json.encode(toEncode));
  }

  static void removeStringItem(String key) {
    _instance!.removeValue(key);
  }
}
