import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/models/display_prayer_model.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/calendar_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/widgets/prayer_card.dart';
import 'package:provider/provider.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CalendarViewModel>();
      if (viewModel.selectedDayPrayers.isEmpty && !viewModel.isLoading) {
        viewModel.loadMonth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CalendarViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewModel.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadMonth,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _CalendarHeader(monthYear: viewModel.monthYearLabel),
                  const SizedBox(height: 20),
                  _MonthGrid(
                    daysInMonth: viewModel.daysInMonth,
                    firstWeekday: viewModel.firstWeekdayOfMonth,
                    selectedDay: viewModel.selectedDay,
                    today: viewModel.today,
                    onDayTap: viewModel.selectDay,
                  ),
                  const SizedBox(height: 24),
                  _SelectedDayPrayers(
                    selectedDay: viewModel.selectedDay,
                    month: viewModel.month,
                    year: viewModel.year,
                    prayers: viewModel.selectedDayPrayers,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String monthYear;

  const _CalendarHeader({required this.monthYear});

  @override
  Widget build(BuildContext context) {
    return Text(monthYear, style: Theme.of(context).textTheme.headlineMedium);
  }
}

class _MonthGrid extends StatelessWidget {
  final int daysInMonth;
  final int firstWeekday;
  final int selectedDay;
  final int today;
  final ValueChanged<int> onDayTap;

  const _MonthGrid({
    required this.daysInMonth,
    required this.firstWeekday,
    required this.selectedDay,
    required this.today,
    required this.onDayTap,
  });

  static const _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map(
                  (day) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: textTheme.labelSmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          ..._buildWeeks(context, isDark, textTheme),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(
    BuildContext context,
    bool isDark,
    TextTheme textTheme,
  ) {
    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = day == selectedDay;
      final isToday = day == today;

      currentWeek.add(
        GestureDetector(
          onTap: () => onDayTap(day),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.appOrange
                  : isToday
                  ? AppTheme.appOrange.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? AppTheme.appOrange
                      : isDark
                      ? Colors.white
                      : AppTheme.darkText,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );

      if (currentWeek.length == 7) {
        weeks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentWeek,
            ),
          ),
        );
        currentWeek = [];
      }
    }

    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(const SizedBox(width: 36, height: 36));
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: currentWeek,
          ),
        ),
      );
    }

    return weeks;
  }
}

class _SelectedDayPrayers extends StatelessWidget {
  final int selectedDay;
  final int month;
  final int year;
  final List<DisplayPrayerModel> prayers;

  const _SelectedDayPrayers({
    required this.selectedDay,
    required this.month,
    required this.year,
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final date = DateTime(year, month, selectedDay);
    final label = _formatDayLabel(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        if (prayers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No prayer times available',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prayers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              return PrayerCard(
                name: prayer.name,
                time: prayer.time,
                icon: prayer.icon,
              );
            },
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == todayDate) {
      return 'Today';
    } else if (selected == todayDate.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selected == todayDate.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${dayNames[date.weekday - 1]}, ${date.day}';
  }
}
