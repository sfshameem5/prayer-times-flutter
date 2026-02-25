import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';

enum PermissionWarningAction { tryAgain, openSettings }

class PermissionWarningSheet extends StatelessWidget {
  final bool isAzaanMode;
  final bool isPermanentlyDenied;

  const PermissionWarningSheet({
    super.key,
    this.isAzaanMode = false,
    this.isPermanentlyDenied = false,
  });

  static Future<PermissionWarningAction?> show(
    BuildContext context, {
    bool isAzaanMode = false,
    bool isPermanentlyDenied = false,
  }) {
    return showModalBottomSheet<PermissionWarningAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PermissionWarningSheet(
        isAzaanMode: isAzaanMode,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navySurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  size: 32,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPermanentlyDenied
                    ? 'Permission Blocked'
                    : 'Permissions Required',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPermanentlyDenied
                    ? 'It looks like notification permission was previously denied. '
                          'Android will not show the permission popup again.\n\n'
                          'To enable notifications, please open your phone\'s Settings '
                          'for this app and turn on Notifications manually.'
                    : isAzaanMode
                    ? 'All permissions (notifications, battery optimization, and '
                          'full-screen intent) are required for azaan alarms to work properly.'
                    : 'Notification permission is required for prayer reminders to work.',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (isPermanentlyDenied) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppSettings.openAppSettings(
                        type: AppSettingsType.notification,
                      );
                      Navigator.of(
                        context,
                      ).pop(PermissionWarningAction.openSettings);
                    },
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    label: const Text(
                      'Open App Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.appOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.smallRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'After enabling notifications in Settings, come back '
                  'and tap "Grant Permissions" to continue.',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(PermissionWarningAction.tryAgain),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.smallRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(PermissionWarningAction.tryAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.appOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.smallRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Grant Permissions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'You can go back to change your notification mode.',
                style: textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
