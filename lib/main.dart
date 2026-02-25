import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayer_times/common/services/cache_manager.dart';
import 'package:prayer_times/common/services/locale_service.dart';
import 'package:prayer_times/common/services/notification_service.dart';
import 'package:prayer_times/common/services/theme_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/prayers/data/respositories/prayer_times_repository.dart';
import 'package:prayer_times/features/prayers/services/prayer_times_service.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/calendar_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/prayers/presentation/views/calendar_view.dart';
import 'package:prayer_times/features/prayers/presentation/views/prayer_view.dart';
import 'package:prayer_times/features/qibla/presentation/views/qibla_view.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/features/settings/presentation/views/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:prayer_times/core/background_executor.dart' as bg;
import 'package:prayer_times/features/onboarding/services/onboarding_service.dart';
import 'package:prayer_times/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:prayer_times/features/settings/services/settings_service.dart';
import 'package:prayer_times/l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

late final bool _onboardingCompleted;

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Only initialize the minimum required before the first frame.
  // MMKV/Cache is needed to read onboarding state; everything else is deferred.
  await CacheManager.initialize();
  _onboardingCompleted = OnboardingService.isOnboardingCompleted();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => PrayerViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleService()..load()),
      ],
      child: const MyApp(),
    ),
  );

  // Defer heavy work until after the first frame to unblock startup.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    StartupCoordinator.run(onboardingCompleted: _onboardingCompleted);
  });
}

/// Coordinates all heavy/IO-bound startup tasks off the critical path.
class StartupCoordinator {
  static bool _started = false;
  static bool _timezoneInitialized = false;
  static bool _workmanagerInitialized = false;

  static Future<void> run({required bool onboardingCompleted}) async {
    if (_started) return;
    _started = true;

    // Kick off independent tasks in parallel to reduce total wait time.
    final deferredTasks = <Future<void>>[_initTimezones(), _warmCaches()];

    if (Platform.isAndroid && onboardingCompleted) {
      deferredTasks.add(_initBackgroundSchedulers());
    }

    await Future.wait(deferredTasks);
  }

  static Future<void> _initTimezones() async {
    if (_timezoneInitialized) return;
    _timezoneInitialized = true;

    // Runs after first frame; still on main isolate but off the launch hot path.
    await Future<void>(() {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation("Asia/Colombo"));
    });
  }

  static Future<void> _initBackgroundSchedulers() async {
    if (_workmanagerInitialized) return;
    _workmanagerInitialized = true;

    // Ensure timezones are ready before scheduling alarms.
    await _initTimezones();

    await Workmanager().initialize(bg.callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      "prayer",
      "prayer-notifications",
      frequency: const Duration(days: 1),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    await NotificationService.initialize();
    await PrayerTimesRepository.scheduleNotifications();
  }

  static Future<void> _warmCaches() async {
    // Parallel lightweight warmups; ignore failures to avoid blocking UI.
    await Future.wait([
      // Prefetch upcoming prayer times into cache to avoid cold fetch later.
      PrayerTimesService.prefetchPrayerTimes(),
      // Touch settings to hydrate in-memory copy for subsequent reads.
      SettingsService().getSettings(),
    ]);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LocaleService>(
      builder: (context, themeService, localeService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: AppLocalizations.of(context)?.appTitle ?? 'Prayer Times',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          locale: localeService.locale,
          supportedLocales: LocaleService.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return supportedLocales.first;
          },
          home: _onboardingCompleted
              ? const MainScreen()
              : const OnboardingView(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      final viewModel = context.read<PrayerViewModel>();
      viewModel.updatePrayers();
      viewModel.updateCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navySurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: AppLocalizations.of(context)!.navPrayers,
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.compass_calibration_outlined,
                  activeIcon: Icons.compass_calibration,
                  label: AppLocalizations.of(context)!.navQibla,
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  label: AppLocalizations.of(context)!.navCalendar,
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: AppLocalizations.of(context)!.navSettings,
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const PrayerView();
      case 1:
        return const QiblaView();
      case 2:
        return ChangeNotifierProvider(
          key: const ValueKey('calendar-provider'),
          create: (_) => CalendarViewModel(),
          child: const CalendarView(),
        );
      case 3:
      default:
        return const SettingsView();
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.appOrange : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.appOrange : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
