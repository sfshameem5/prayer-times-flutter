import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class TestAlarmSection extends StatefulWidget {
  const TestAlarmSection({super.key});

  @override
  State<TestAlarmSection> createState() => _TestAlarmSectionState();
}

class _TestAlarmSectionState extends State<TestAlarmSection> {
  DateTime? _selectedDateTime;
  bool _isScheduling = false;

  DateTime _defaultTime() {
    return DateTime.now().add(const Duration(minutes: 1));
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.appOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(minutes: 2)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.appOrange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _scheduleTest() async {
    final dateTime = _selectedDateTime ?? _defaultTime();

    if (dateTime.isBefore(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time in the future'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isScheduling = true);

    final viewModel = context.read<SettingsViewModel>();
    final error = await viewModel.scheduleTestAlarm(dateTime);

    if (!mounted) return;
    setState(() => _isScheduling = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final formatted = DateFormat('MMM d, h:mm a').format(dateTime);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test alarm scheduled for $formatted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTime = _selectedDateTime ?? _defaultTime();
    final formatted = DateFormat('MMM d, yyyy – h:mm a').format(displayTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Alarm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Schedule a test notification and alarm to verify they work on your device.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: AppTheme.appOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateTime != null
                          ? formatted
                          : 'Tap to pick date & time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedDateTime != null
                            ? null
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isScheduling ? null : _scheduleTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppTheme.appOrange.withValues(
                  alpha: 0.4,
                ),
              ),
              child: _isScheduling
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Schedule Test Alarm',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
