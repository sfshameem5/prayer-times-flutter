import 'package:flutter/material.dart';
import 'package:prayer_times/features/settings/data/repositories/settings_repository.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService({SettingsRepository? settingsRepository})
    : _repository = settingsRepository ?? SettingsRepository();

  final SettingsRepository _repository;
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  static const supportedLocales = [Locale('en'), Locale('ta'), Locale('si')];

  Future<void> load() async {
    final settings = await _repository.getSettings();
    _locale = Locale(settings.languageCode);
    Intl.defaultLocale = _locale.languageCode;
    await _syncToSharedPreferences(_locale.languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    Intl.defaultLocale = locale.languageCode;
    final settings = await _repository.getSettings();
    final updated = settings.copyWith(languageCode: locale.languageCode);
    await _repository.saveSettings(updated);
    await _syncToSharedPreferences(locale.languageCode);
    notifyListeners();
  }

  /// Sync locale to Android SharedPreferences so native alarm components
  /// (AlarmActivity, AlarmFiringService) can read it as a fallback.
  Future<void> _syncToSharedPreferences(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', code);
    } catch (_) {}
  }
}
