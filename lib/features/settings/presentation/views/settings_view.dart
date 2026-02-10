import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/theme_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/features/settings/presentation/widgets/prayer_notification_settings.dart';
import 'package:prayer_times/features/settings/presentation/widgets/settings_tile.dart';
import 'package:prayer_times/features/settings/presentation/widgets/theme_mode_selector.dart';
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
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your app preferences',
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
                      _sectionHeader(context, 'General', isDark),
                      const SizedBox(height: 8),
                      _sectionCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            SettingsTile(
                              title: 'Theme',
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
                              title: 'Notifications',
                              trailing: Switch.adaptive(
                                value: viewModel.notificationsEnabled,
                                onChanged: viewModel.setNotificationsEnabled,
                                activeTrackColor: AppTheme.appOrange.withValues(
                                  alpha: 0.5,
                                ),
                                activeThumbColor: AppTheme.appOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (viewModel.notificationsEnabled) ...[
                        const SizedBox(height: 24),
                        _sectionHeader(
                          context,
                          'Prayer Notification Modes',
                          isDark,
                        ),
                        const SizedBox(height: 8),
                        _sectionCard(
                          isDark: isDark,
                          child: const PrayerNotificationSettings(),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
