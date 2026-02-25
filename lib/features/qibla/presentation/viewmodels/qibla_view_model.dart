import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times/features/qibla/data/repositories/qibla_repository.dart';
import 'package:prayer_times/features/qibla/services/qibla_native_service.dart';

class QiblaViewModel extends ChangeNotifier {
  final QiblaRepository _repository;
  final QiblaNativeService _nativeService;

  static const double _alignmentThreshold = 3.0;

  double _qiblaDirection = 0;
  double _deviceHeading = 0;
  bool _hasCompassData = false;
  bool _isAligned = false;
  String _fallbackMode = 'stored_city';

  StreamSubscription<QiblaNativeEvent>? _subscription;

  QiblaViewModel({
    QiblaRepository? repository,
    QiblaNativeService? nativeService,
  }) : _repository = repository ?? QiblaRepository(),
       _nativeService = nativeService ?? QiblaNativeService() {
    _qiblaDirection = _repository.getQiblaDirection();
    _startNative();
  }

  double get qiblaDirection => _qiblaDirection;
  double get deviceHeading => _deviceHeading;
  bool get hasCompassData => _hasCompassData;
  bool get isAligned => _isAligned;
  String get locationName => _repository.locationName;
  String get fallbackMode => _fallbackMode;

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

  void _onNativeEvent(QiblaNativeEvent event) {
    _deviceHeading = event.heading ?? _deviceHeading;
    _hasCompassData = event.heading != null;
    _fallbackMode = event.fallbackMode;
    if (event.qiblaBearing != null) {
      _qiblaDirection = event.qiblaBearing!;
    }

    final wasAligned = _isAligned;
    final diff = (_qiblaDirection - _deviceHeading) % 360;
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    _isAligned = normalizedDiff <= _alignmentThreshold;

    if (_isAligned && !wasAligned) {
      HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }

  void _startNative() {
    final coords = _repository.storedCoordinates;
    _subscription = _nativeService.events.listen(_onNativeEvent);
    _nativeService.start(
      storedLat: coords.latitude,
      storedLng: coords.longitude,
      storedName: _repository.locationName,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _nativeService.stop();
    super.dispose();
  }
}
