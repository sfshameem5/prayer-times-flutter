import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/config/theme.dart';

class CityPickerBottomSheet extends StatelessWidget {
  final String currentCity;
  final ValueChanged<String> onCitySelected;

  const CityPickerBottomSheet({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
  });

  static Future<String?> show(BuildContext context, String currentCity) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityPickerBottomSheet(
        currentCity: currentCity,
        onCitySelected: (city) => Navigator.of(context).pop(city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navySurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.appOrange,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Location',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocationService.cities.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                final city = LocationService.cities[index];
                final isSelected = city.slug == currentCity;

                return InkWell(
                  onTap: () => onCitySelected(city.slug),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            city.displayName,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.appOrange
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.appOrange,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
