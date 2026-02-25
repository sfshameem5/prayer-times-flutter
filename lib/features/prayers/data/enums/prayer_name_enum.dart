enum PrayerNameEnum { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// Safely parses a prayer name string to enum, handling legacy names.
/// Maps old "luhr" → dhuhr, "magrib" → maghrib.
PrayerNameEnum parsePrayerName(String name) {
  switch (name) {
    case 'luhr':
      return PrayerNameEnum.dhuhr;
    case 'magrib':
      return PrayerNameEnum.maghrib;
    default:
      return PrayerNameEnum.values.byName(name);
  }
}
