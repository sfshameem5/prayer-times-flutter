import 'dart:async';

import 'package:flutter/services.dart';

class QiblaNativeEvent {
  final double? heading;
  final double? qiblaBearing;
  final String fallbackMode;
  final double? locationAccuracy;
  final String? locationSource;
  final String locationName;

  QiblaNativeEvent({
    required this.heading,
    required this.qiblaBearing,
    required this.fallbackMode,
    required this.locationAccuracy,
    required this.locationSource,
    required this.locationName,
  });

  factory QiblaNativeEvent.fromMap(Map<dynamic, dynamic> map) {
    return QiblaNativeEvent(
      heading: (map['heading'] as num?)?.toDouble(),
      qiblaBearing: (map['qiblaBearing'] as num?)?.toDouble(),
      fallbackMode: map['fallbackMode'] as String? ?? 'stored_city',
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      locationSource: map['locationSource'] as String?,
      locationName: map['locationName'] as String? ?? '',
    );
  }
}

class QiblaNativeService {
  static const MethodChannel _channel = MethodChannel('com.example.prayer_times/qibla');
  static const EventChannel _events = EventChannel('com.example.prayer_times/qibla/events');

  Stream<QiblaNativeEvent> get events =>
      _events.receiveBroadcastStream().map((event) => QiblaNativeEvent.fromMap(event));

  Future<void> start({
    required double storedLat,
    required double storedLng,
    required String storedName,
  }) async {
    await _channel.invokeMethod('start', {
      'storedLat': storedLat,
      'storedLng': storedLng,
      'storedName': storedName,
    });
  }

  Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
