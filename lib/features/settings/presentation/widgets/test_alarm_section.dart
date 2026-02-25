import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class TestAlarmSection extends StatefulWidget {
  const TestAlarmSection({super.key});

  @override
  State<TestAlarmSection> createState() => _TestAlarmSectionState();
}

class _TestAlarmSectionState extends State<TestAlarmSection> {
  String? _busyKey;
  final TextEditingController _secondsController = TextEditingController();
  String? _inputError;

  Future<void> _runTest(String key, Future<String?> Function() action) async {
    if (_busyKey != null) return;
    setState(() => _busyKey = key);

    final error = await action();

    if (!mounted) return;
    setState(() => _busyKey = null);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_successMessage(key)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  void dispose() {
    _secondsController.dispose();
    super.dispose();
  }

  String _successMessage(String key) {
    switch (key) {
      case 'alarm_30s':
        return 'Test alarm scheduled in 30 seconds';
      case 'alarm_1m':
        return 'Test alarm scheduled in 1 minute';
      case 'alarm_2m':
        return 'Test alarm scheduled in 2 minutes';
      case 'alarm_5m':
        return 'Test alarm scheduled in 5 minutes';
      case 'notif_instant':
        return 'Test notification sent';
      case 'notif_30s':
        return 'Test notification scheduled in 30 seconds';
      default:
        return 'Test scheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.read<SettingsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Test Alarm Section (only shown when alarms enabled) ---
          if (viewModel.alarmsEnabled) ...[
            _SectionTitle(
              icon: Icons.alarm_rounded,
              title: 'Test Alarm',
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule a test alarm to verify it fires on your device. '
              'Uses a short azaan clip for testing.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _secondsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter seconds',
                hintText: 'e.g. 30',
                errorText: _inputError,
                helperText: 'Uses short azaan. Min 1s, max 6h.',
              ),
              onChanged: (_) {
                if (_inputError != null) {
                  setState(() => _inputError = null);
                }
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: _busyKey == 'alarm_custom'
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: const Text('Schedule Test Alarm'),
                onPressed: _busyKey == null
                    ? () {
                        final seconds = int.tryParse(
                          _secondsController.text.trim(),
                        );
                        if (seconds == null) {
                          setState(
                            () =>
                                _inputError = 'Enter a valid number of seconds',
                          );
                          return;
                        }
                        _runTest('alarm_custom', () async {
                          final error = await viewModel
                              .scheduleTestAlarmInSeconds(seconds: seconds);
                          if (error == null) {
                            _secondsController.clear();
                          }
                          return error;
                        });
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // --- Test Notification Section (only shown when notifications enabled) ---
          if (viewModel.notificationsEnabled) ...[
            _SectionTitle(
              icon: Icons.notifications_outlined,
              title: 'Test Notification',
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            Text(
              'Test notification-only mode (no alarm or full-screen intent).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TestChip(
                  label: 'Instantly',
                  busyKey: _busyKey,
                  myKey: 'notif_instant',
                  onTap: () => _runTest(
                    'notif_instant',
                    () => viewModel.sendTestNotification(delayed: false),
                  ),
                ),
                _TestChip(
                  label: 'In 30 sec',
                  busyKey: _busyKey,
                  myKey: 'notif_30s',
                  onTap: () => _runTest(
                    'notif_30s',
                    () => viewModel.sendTestNotification(delayed: true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.appOrange, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TestChip extends StatelessWidget {
  final String label;
  final String? busyKey;
  final String myKey;
  final VoidCallback onTap;

  const _TestChip({
    required this.label,
    required this.busyKey,
    required this.myKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBusy = busyKey == myKey;
    final isDisabled = busyKey != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isBusy
                ? AppTheme.appOrange.withValues(alpha: 0.2)
                : AppTheme.appOrange.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBusy
                  ? AppTheme.appOrange
                  : AppTheme.appOrange.withValues(alpha: 0.3),
            ),
          ),
          child: isBusy
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.appOrange,
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDisabled
                        ? (isDark ? Colors.white30 : Colors.black26)
                        : AppTheme.appOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
