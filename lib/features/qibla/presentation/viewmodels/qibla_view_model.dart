import 'dart:async';
import 'dart:math' as math;

import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/features/qibla/data/repositories/qibla_repository.dart';

class QiblaViewModel extends ChangeNotifier {
  final QiblaRepository _repository;
  final Stream<CompassXEvent> _compassStream;

  double _qiblaDirection = 0;
  double _deviceHeading = 0;
  bool _hasCompassData = false;

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
  String get locationName => _repository.locationName;

  double get rotationAngle {
    if (!_hasCompassData) return 0.0;
    return (_qiblaDirection - _deviceHeading) * math.pi / 180;
  }

  String qiblaDirectionLabel(double bearing) {
    return _repository.getQiblaDirectionString(bearing);
  }

  void _onCompassEvent(CompassXEvent event) {
    _deviceHeading = event.heading;
    _hasCompassData = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
