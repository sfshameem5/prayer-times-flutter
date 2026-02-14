import 'dart:async';
import 'dart:math' as math;

import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times/features/qibla/data/repositories/qibla_repository.dart';

class QiblaViewModel extends ChangeNotifier {
  final QiblaRepository _repository;
  final Stream<CompassXEvent> _compassStream;

  static const double _alignmentThreshold = 3.0;

  double _qiblaDirection = 0;
  double _deviceHeading = 0;
  bool _hasCompassData = false;
  bool _isAligned = false;

  StreamSubscription<CompassXEvent>? _subscription;

  QiblaViewModel({
    QiblaRepository? repository,
    Stream<CompassXEvent>? compassStream,
  }) : _repository = repository ?? QiblaRepository(),
       _compassStream = compassStream ?? CompassX.events {
    _qiblaDirection = _repository.getQiblaDirection();
    _subscription = _compassStream.listen(_onCompassEvent);
  }

  double get qiblaDirection => _qiblaDirection;
  double get deviceHeading => _deviceHeading;
  bool get hasCompassData => _hasCompassData;
  bool get isAligned => _isAligned;
  String get locationName => _repository.locationName;

  double get rotationAngle {
    if (!_hasCompassData) return 0.0;
    return (_qiblaDirection - _deviceHeading) * math.pi / 180;
  }

  double get angleDifference {
    if (!_hasCompassData) return 0.0;
    double diff = _qiblaDirection - _deviceHeading;
    // Normalize to -180..180
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return diff;
  }

  String qiblaDirectionLabel(double bearing) {
    return _repository.getQiblaDirectionString(bearing);
  }

  void _onCompassEvent(CompassXEvent event) {
    _deviceHeading = event.heading;
    _hasCompassData = true;

    final wasAligned = _isAligned;
    final diff = (_qiblaDirection - _deviceHeading) % 360;
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    _isAligned = normalizedDiff <= _alignmentThreshold;

    if (_isAligned && !wasAligned) {
      HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
