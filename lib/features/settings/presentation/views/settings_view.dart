import 'package:flutter/material.dart';
import 'package:prayer_times/common/services/theme_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/features/settings/presentation/widgets/notification_mode_dropdown.dart';
import 'package:prayer_times/features/settings/presentation/widgets/settings_tile.dart';
import 'package:prayer_times/features/settings/presentation/widgets/theme_mode_selector.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: SafeArea(
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
                      children: [
                        SettingsTile(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          subtitle: _getThemeModeLabel(viewModel.themeMode),
                          trailing: ThemeModeSelector(
                            value: viewModel.themeMode,
                            onChanged: (mode) {
                              viewModel.setThemeMode(mode);
                              context.read<ThemeService>().setThemeMode(mode);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Enable Notifications',
                          subtitle: 'Receive prayer time notifications',
                          trailing: Switch.adaptive(
                            value: viewModel.notificationsEnabled,
                            onChanged: viewModel.setNotificationsEnabled,
                            activeThumbColor: AppTheme.appOrange,
                          ),
                        ),
                        // Enable after azaan foreground implementation
                        if (viewModel.notificationsEnabled) ...[
                          const SizedBox(height: 12),
                          SettingsTile(
                            icon: Icons.music_note_outlined,
                            title: 'Prayer Notification Mode',
                            subtitle:
                                viewModel.notificationMode ==
                                    PrayerNotificationMode.azaan
                                ? 'Azaan'
                                : 'Default Sound',
                            trailing: NotificationModeDropdown(
                              value: viewModel.notificationMode,
                              onChanged: (mode) {
                                if (mode != null) {
                                  viewModel.setNotificationMode(mode);
                                }
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
    }
  }
}
