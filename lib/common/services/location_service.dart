import 'package:mmkv/mmkv.dart';

class CityInfo {
  final String slug;
  final String displayName;

  const CityInfo({required this.slug, required this.displayName});
}

class LocationService {
  static const String _selectedCityKey = 'selected_city';
  static const String _defaultCity = 'colombo';

  static const List<CityInfo> cities = [
    CityInfo(slug: 'colombo', displayName: 'Colombo, Gampaha, Kalutara'),
    CityInfo(slug: 'jaffna', displayName: 'Jaffna, Nallur'),
    CityInfo(
      slug: 'mullaitivu',
      displayName: 'Mullaitivu, Kilinochchi, Vavuniya',
    ),
    CityInfo(slug: 'mannar', displayName: 'Mannar, Puttalam'),
    CityInfo(slug: 'anuradhapura', displayName: 'Anuradhapura, Polonnaruwa'),
    CityInfo(slug: 'kurunegala', displayName: 'Kurunegala'),
    CityInfo(slug: 'kandy', displayName: 'Kandy, Matale, Nuwara Eliya'),
    CityInfo(slug: 'batticaloa', displayName: 'Batticaloa, Ampara'),
    CityInfo(slug: 'trincomalee', displayName: 'Trincomalee'),
    CityInfo(slug: 'badulla', displayName: 'Badulla, Monaragala'),
    CityInfo(slug: 'ratnapura', displayName: 'Ratnapura, Kegalle'),
    CityInfo(slug: 'galle', displayName: 'Galle, Matara'),
    CityInfo(slug: 'hambantota', displayName: 'Hambantota'),
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
}
