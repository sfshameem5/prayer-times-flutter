import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/common/services/location_service.dart';
import 'package:prayer_times/common/services/locale_service.dart';
import 'package:prayer_times/common/services/theme_service.dart';
import 'package:prayer_times/common/widgets/city_picker_bottom_sheet.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/features/settings/presentation/widgets/prayer_notification_settings.dart';
import 'package:prayer_times/features/settings/presentation/widgets/settings_tile.dart';
import 'package:prayer_times/features/settings/presentation/widgets/test_alarm_section.dart';
import 'package:prayer_times/features/settings/presentation/widgets/theme_mode_selector.dart';
import 'package:prayer_times/features/onboarding/services/onboarding_service.dart';
import 'package:prayer_times/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.settingsTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.settingsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Consumer<SettingsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        context,
                        AppLocalizations.of(context)!.settingsSectionLocation,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _sectionCard(
                        isDark: isDark,
                        child: InkWell(
                          onTap: () => _showCityPicker(context, viewModel),
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.appOrange,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.settingsPrayerRegion,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        LocationService.getDisplayName(
                                          viewModel.selectedCity,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black45,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionHeader(
                        context,
                        AppLocalizations.of(context)!.settingsSectionGeneral,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _sectionCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            SettingsTile(
                              title: AppLocalizations.of(
                                context,
                              )!.settingsTheme,
                              trailing: ThemeModeSelector(
                                value: viewModel.themeMode,
                                onChanged: (mode) {
                                  viewModel.setThemeMode(mode);
                                  context.read<ThemeService>().setThemeMode(
                                    mode,
                                  );
                                },
                              ),
                            ),
                            SettingsTile(
                              title: AppLocalizations.of(
                                context,
                              )!.settingsLanguage,
                              trailing: _LanguageSelector(isDark: isDark),
                            ),
                            SettingsTile(
                              title: AppLocalizations.of(
                                context,
                              )!.settingsNotifications,
                              trailing: Switch.adaptive(
                                value: viewModel.notificationsEnabled,
                                onChanged: viewModel.setNotificationsEnabled,
                                activeTrackColor: AppTheme.appOrange.withValues(
                                  alpha: 0.5,
                                ),
                                activeThumbColor: AppTheme.appOrange,
                              ),
                            ),
                            if (viewModel.notificationsEnabled)
                              SettingsTile(
                                title: AppLocalizations.of(
                                  context,
                                )!.settingsAlarms,
                                subtitle: AppLocalizations.of(
                                  context,
                                )!.settingsAlarmsSubtitle,
                                trailing: Switch.adaptive(
                                  value: viewModel.alarmsEnabled,
                                  onChanged: viewModel.setAlarmsEnabled,
                                  activeTrackColor: AppTheme.appOrange
                                      .withValues(alpha: 0.5),
                                  activeThumbColor: AppTheme.appOrange,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Prayer notification modes — only shown when notifications are enabled
                      if (viewModel.notificationsEnabled) ...[
                        const SizedBox(height: 24),
                        _sectionHeader(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.settingsSectionPrayerModes,
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _sectionCard(
                          isDark: isDark,
                          child: const PrayerNotificationSettings(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _sectionHeader(
                        context,
                        AppLocalizations.of(context)!.settingsSectionAdvanced,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _sectionCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.settingsShowAdvanced,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: viewModel.showAdvancedSettings,
                                    onChanged:
                                        viewModel.setShowAdvancedSettings,
                                    activeTrackColor: AppTheme.appOrange
                                        .withValues(alpha: 0.5),
                                    activeThumbColor: AppTheme.appOrange,
                                  ),
                                ],
                              ),
                            ),
                            if (viewModel.showAdvancedSettings) ...[
                              // Test sections — only shown when at least one feature is enabled
                              if (viewModel.notificationsEnabled ||
                                  viewModel.alarmsEnabled) ...[
                                Divider(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                                const TestAlarmSection(),
                              ],
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              _ResetAppTile(isDark: isDark),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              _sectionHeader(
                context,
                AppLocalizations.of(context)!.settingsSectionAbout,
                isDark,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppLocalizations.of(context)!.settingsAboutBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black45,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityPicker(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final selectedCity = await CityPickerBottomSheet.show(
      context,
      viewModel.selectedCity,
    );
    if (selectedCity != null && selectedCity != viewModel.selectedCity) {
      if (!context.mounted) return;
      await viewModel.setSelectedCity(selectedCity);
      if (!context.mounted) return;
      await context.read<PrayerViewModel>().updatePrayers();
    }
  }

  Widget _sectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDark ? Colors.white38 : Colors.black38,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _sectionCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkCardGradient
            : AppTheme.lightCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ResetAppTile extends StatelessWidget {
  final bool isDark;

  const _ResetAppTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showResetDialog(context),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settingsReset,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.settingsResetConfirm,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsReset),
        content: Text(AppLocalizations.of(context)!.settingsResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.settingsCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await OnboardingService.resetApp();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingView()),
                (route) => false,
              );
            },
            child: Text(
              AppLocalizations.of(context)!.settingsResetAction,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final bool isDark;

  const _LanguageSelector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final localeService = context.watch<LocaleService>();
    final currentCode = localeService.locale.languageCode;

    String labelFor(String code) {
      switch (code) {
        case 'ta':
          return 'தமிழ்';
        case 'si':
          return 'සිංහල';
        case 'en':
        default:
          return 'English';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.appOrange.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: currentCode,
        underline: const SizedBox(),
        isDense: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.appOrange,
          size: 20,
        ),
        dropdownColor: isDark ? AppTheme.navyLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.appOrange,
          fontWeight: FontWeight.w600,
        ),
        items: const ['en', 'ta', 'si']
            .map(
              (code) =>
                  DropdownMenuItem(value: code, child: Text(labelFor(code))),
            )
            .toList(),
        onChanged: (code) {
          if (code != null) {
            context.read<LocaleService>().setLocale(Locale(code));
          }
        },
      ),
    );
  }
}
