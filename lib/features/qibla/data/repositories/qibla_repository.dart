import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/features/qibla/services/qibla_service.dart';

class QiblaRepository {
  final QiblaService _service;
  final String _citySlug;

  QiblaRepository({QiblaService? service, String? citySlug})
    : _service = service ?? QiblaService(),
      _citySlug = citySlug ?? LocationService.getSelectedCity();

  double getQiblaDirection() {
    final coords = LocationService.getCoordinates(_citySlug);
    return _service.calculateQiblaDirection(
      userLat: coords.latitude,
      userLng: coords.longitude,
    );
  }

  String getQiblaDirectionString(double bearing) {
    return _service.getQiblaDirectionString(bearing);
  }

  String get locationName => LocationService.getShortDisplayName(_citySlug);
}
