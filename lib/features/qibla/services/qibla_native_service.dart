import 'dart:async';

import 'package:flutter/services.dart';

class QiblaNativeEvent {
  final double? heading;
  final double? qiblaBearing;
  final String fallbackMode;
  final double? locationAccuracy;
  final String? provider;
  final String locationName;
  final bool needsCalibration;

  QiblaNativeEvent({
    required this.heading,
    required this.qiblaBearing,
    required this.fallbackMode,
    required this.locationAccuracy,
    required this.provider,
    required this.locationName,
    required this.needsCalibration,
  });

  factory QiblaNativeEvent.fromMap(Map<dynamic, dynamic> map) {
    return QiblaNativeEvent(
      heading: (map['heading'] as num?)?.toDouble(),
      qiblaBearing: (map['qiblaBearing'] as num?)?.toDouble(),
      fallbackMode: map['fallbackMode'] as String? ?? 'stored_city',
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      provider: map['provider'] as String?,
      locationName: map['locationName'] as String? ?? '',
      needsCalibration: map['needsCalibration'] as bool? ?? false,
    );
  }
}

/// Bridge to native Qibla provider (sensors + GPS/network + stored city fallbacks).
class QiblaNativeService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.prayer_times/qibla',
  );
  static const EventChannel _events = EventChannel(
    'com.example.prayer_times/qibla/events',
  );

  Stream<QiblaNativeEvent> get events => _events.receiveBroadcastStream().map(
    (event) => QiblaNativeEvent.fromMap(event),
  );

  /// Example usage:
  ///
  /// ```dart
  /// final service = QiblaNativeService();
  /// service.events.listen((event) {
  ///   // heading may be null on devices without compass; UI can fall back to bearing only
  ///   debugPrint('heading=${event.heading}, bearing=${event.qiblaBearing}, '
  ///       'mode=${event.fallbackMode}, accuracy=${event.locationAccuracy}, provider=${event.provider}, '
  ///       'needsCalibration=${event.needsCalibration}');
  /// });
  /// service.start(storedLat: 24.86, storedLng: 67.01, storedName: 'Karachi');
  /// ```

  Future<void> start({
    required double storedLat,
    required double storedLng,
    required String storedName,
    bool requestLocationPermission = false,
  }) async {
    await _channel.invokeMethod('start', {
      'storedLat': storedLat,
      'storedLng': storedLng,
      'storedName': storedName,
      'requestLocation': requestLocationPermission,
    });
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
