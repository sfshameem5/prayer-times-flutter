import 'package:mmkv/mmkv.dart';

class CityInfo {
  final String slug;
  final String displayName;
  final double latitude;
  final double longitude;

  const CityInfo({
    required this.slug,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static const String _selectedCityKey = 'selected_city';
  static const String _defaultCity = 'colombo';

  static const List<CityInfo> cities = [
    CityInfo(
      slug: 'colombo',
      displayName: 'Colombo, Gampaha, Kalutara',
      latitude: 6.9271,
      longitude: 79.8612,
    ),
    CityInfo(
      slug: 'jaffna',
      displayName: 'Jaffna, Nallur',
      latitude: 9.6615,
      longitude: 80.0255,
    ),
    CityInfo(
      slug: 'mullaitivu',
      displayName: 'Mullaitivu, Kilinochchi, Vavuniya',
      latitude: 9.2671,
      longitude: 80.5881,
    ),
    CityInfo(
      slug: 'mannar',
      displayName: 'Mannar, Puttalam',
      latitude: 8.9810,
      longitude: 79.9044,
    ),
    CityInfo(
      slug: 'anuradhapura',
      displayName: 'Anuradhapura, Polonnaruwa',
      latitude: 8.3114,
      longitude: 80.4037,
    ),
    CityInfo(
      slug: 'kurunegala',
      displayName: 'Kurunegala',
      latitude: 7.4863,
      longitude: 80.3647,
    ),
    CityInfo(
      slug: 'kandy',
      displayName: 'Kandy, Matale, Nuwara Eliya',
      latitude: 7.2906,
      longitude: 80.6337,
    ),
    CityInfo(
      slug: 'batticaloa',
      displayName: 'Batticaloa, Ampara',
      latitude: 7.7310,
      longitude: 81.6747,
    ),
    CityInfo(
      slug: 'trincomalee',
      displayName: 'Trincomalee',
      latitude: 8.5874,
      longitude: 81.2152,
    ),
    CityInfo(
      slug: 'badulla',
      displayName: 'Badulla, Monaragala',
      latitude: 6.9934,
      longitude: 81.0550,
    ),
    CityInfo(
      slug: 'ratnapura',
      displayName: 'Ratnapura, Kegalle',
      latitude: 6.6828,
      longitude: 80.3992,
    ),
    CityInfo(
      slug: 'galle',
      displayName: 'Galle, Matara',
      latitude: 6.0535,
      longitude: 80.2210,
    ),
    CityInfo(
      slug: 'hambantota',
      displayName: 'Hambantota',
      latitude: 6.1429,
      longitude: 81.1212,
    ),
  ];

  static String getSelectedCity() {
    final mmkv = MMKV.defaultMMKV();
    return mmkv.decodeString(_selectedCityKey) ?? _defaultCity;
  }

  static void setSelectedCity(String slug) {
    final mmkv = MMKV.defaultMMKV();
    mmkv.encodeString(_selectedCityKey, slug);
  }

  static String getDisplayName(String slug) {
    final city = cities.firstWhere(
      (c) => c.slug == slug,
      orElse: () => cities.first,
    );
    return city.displayName;
  }

  static String getShortDisplayName(String slug) {
    final city = cities.firstWhere(
      (c) => c.slug == slug,
      orElse: () => cities.first,
    );
    // Return just the first district name for compact display
    return city.displayName.split(',').first.trim();
  }

  static ({double latitude, double longitude}) getCoordinates(String slug) {
    final city = cities.firstWhere(
      (c) => c.slug == slug,
      orElse: () => cities.first,
    );
    return (latitude: city.latitude, longitude: city.longitude);
  }
}
