import 'package:flutter/material.dart';
import 'package:prayer_times/features/settings/data/repositories/settings_repository.dart';
import 'package:intl/intl.dart';

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
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    Intl.defaultLocale = locale.languageCode;
    final settings = await _repository.getSettings();
    final updated = settings.copyWith(languageCode: locale.languageCode);
    await _repository.saveSettings(updated);
    notifyListeners();
  }
}
