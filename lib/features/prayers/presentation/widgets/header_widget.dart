import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/common/widgets/city_picker_bottom_sheet.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerVm = context.watch<PrayerViewModel>();

    final localeCode = Localizations.localeOf(context).languageCode;
    final currentDate = prayerVm.currentDate(localeCode);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentDate,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Optionally show hijri date localized elsewhere
              ],
            ),
          ),
          Selector<SettingsViewModel, String>(
            selector: (_, model) => model.selectedCity,
            builder: (context, selectedCity, child) {
              return GestureDetector(
                onTap: () => _showCityPicker(context, selectedCity),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      LocationService.getShortDisplayName(selectedCity),
                      style: textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context, String currentCity) async {
    final selectedCity = await CityPickerBottomSheet.show(context, currentCity);
    if (selectedCity != null && selectedCity != currentCity) {
      if (!context.mounted) return;
      final settingsVm = context.read<SettingsViewModel>();
      await settingsVm.setSelectedCity(selectedCity);
      if (!context.mounted) return;
      await context.read<PrayerViewModel>().updatePrayers();
    }
  }
}
