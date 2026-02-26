import 'package:flutter/material.dart';
import 'package:prayer_times/features/reminders/presentation/viewmodels/reminders_view_model.dart';
import 'package:prayer_times/features/reminders/presentation/widgets/reminder_tile.dart';
import 'package:provider/provider.dart';

class RemindersView extends StatelessWidget {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => RemindersViewModel(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Reminders',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Toggle reminders on or off',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer<RemindersViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: viewModel.reminders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final reminder = viewModel.reminders[index];
                        return ReminderTile(
                          reminder: reminder,
                          onToggle: (value) {
                            viewModel.toggleReminder(reminder.id, value);
                          },
                          onTimeChanged: (time) {
                            viewModel.updateReminderTime(reminder.id, time);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
