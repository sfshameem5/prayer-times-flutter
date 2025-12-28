import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/data/repositories/settings_repository.dart';

class SettingsService {
  final SettingsRepository _repository;

  SettingsService({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository();

  Future<SettingsModel> getSettings() {
    return _repository.getSettings();
  }

  Future<void> saveSettings(SettingsModel settings) {
    return _repository.saveSettings(settings);
  }
}
