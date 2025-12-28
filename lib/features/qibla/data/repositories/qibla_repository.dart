import 'package:prayer_times/features/qibla/services/qibla_service.dart';

class QiblaRepository {
  final QiblaService _service;

  static const double _colomboLatitude = 6.9271;
  static const double _colomboLongitude = 79.8612;

  QiblaRepository({QiblaService? service})
    : _service = service ?? QiblaService();

  double getQiblaDirection() {
    return _service.calculateQiblaDirection(
      userLat: _colomboLatitude,
      userLng: _colomboLongitude,
    );
  }

  String getQiblaDirectionString(double bearing) {
    return _service.getQiblaDirectionString(bearing);
  }

  String get locationName => 'Colombo, Sri Lanka';
}
