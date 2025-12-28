import 'dart:math';

class QiblaService {
  // Kaaba coordinates (Mecca)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  // Hardcoded user location (Colombo, Sri Lanka - update this later with actual device location)
  static const double userLatitude = 6.9271;
  static const double userLongitude = 79.8612;

  /// Calculate Qibla direction from user's location to Kaaba
  /// Returns bearing in degrees (0-360, where 0 is North)
  double calculateQiblaDirection({
    double userLat = userLatitude,
    double userLng = userLongitude,
  }) {
    // Convert to radians
    final lat1 = userLat * pi / 180;
    final lat2 = kaabaLatitude * pi / 180;
    final deltaLng = (kaabaLongitude - userLng) * pi / 180;

    // Calculate bearing using the forward azimuth formula
    final y = sin(deltaLng);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(deltaLng);

    var bearing = atan2(y, x) * 180 / pi;

    // Normalize to 0-360
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Get the Qibla direction as a compass direction string
  String getQiblaDirectionString(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing >= 22.5 && bearing < 67.5) return 'NE';
    if (bearing >= 67.5 && bearing < 112.5) return 'E';
    if (bearing >= 112.5 && bearing < 157.5) return 'SE';
    if (bearing >= 157.5 && bearing < 202.5) return 'S';
    if (bearing >= 202.5 && bearing < 247.5) return 'SW';
    if (bearing >= 247.5 && bearing < 292.5) return 'W';
    return 'NW';
  }
}
