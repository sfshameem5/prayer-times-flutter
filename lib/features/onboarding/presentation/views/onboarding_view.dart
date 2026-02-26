import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/common/services/locale_service.dart';
import 'package:prayer_times/common/services/permission_service.dart';
import 'package:prayer_times/common/services/theme_service.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/settings/data/models/settings_model.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/city_step.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/language_step.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/completion_step.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/notification_step.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/permissions_step.dart';
import 'package:prayer_times/features/onboarding/presentation/widgets/permission_warning_sheet.dart';
import 'package:prayer_times/features/onboarding/services/onboarding_service.dart';
import 'package:prayer_times/features/prayers/presentation/viewmodels/prayer_view_model.dart';
import 'package:prayer_times/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:prayer_times/main.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Locale _selectedLocale = const Locale('en');
  String _selectedCity = 'colombo';
  AppThemeMode _selectedThemeMode = AppThemeMode.system;
  NotificationChoice _notificationChoice = NotificationChoice.notifications;
  bool _isCompleting = false;
  bool _permissionsGranted = false;
  bool _isRequestingPermissions = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    // Skip permissions step entirely when user chose no notifications
    if (_currentPage == 2 && _notificationChoice == NotificationChoice.none) {
      setState(() {
        _permissionsGranted = false;
      });
      _pageController.animateToPage(
        4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // If leaving permissions step without grants, fall back to "No notifications"
    if (_currentPage == 3 && !_permissionsGranted) {
      setState(() {
        _notificationChoice = NotificationChoice.none;
      });
    }

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage == 4 && _notificationChoice == NotificationChoice.none) {
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _requestPermissions() async {
    if (_isRequestingPermissions) return;

    if (_notificationChoice == NotificationChoice.none) {
      setState(() => _permissionsGranted = false);
      return;
    }

    if (!Platform.isAndroid) {
      setState(() => _permissionsGranted = true);
      return;
    }

    setState(() => _isRequestingPermissions = true);

    final isAzaan = _notificationChoice == NotificationChoice.azaan;
    final granted = await PermissionService.requestFullNotificationPermissions(
      isAzaanMode: isAzaan,
    );

    if (!mounted) {
      setState(() => _isRequestingPermissions = false);
      return;
    }

    if (!granted) {
      // Check if notification permission is permanently denied by the system
      final isPermanent =
          await PermissionService.isNotificationPermanentlyDenied();

      if (!mounted) {
        setState(() => _isRequestingPermissions = false);
        return;
      }

      final action = await PermissionWarningSheet.show(
        context,
        isAzaanMode: isAzaan,
        isPermanentlyDenied: isPermanent,
      );

      setState(() => _isRequestingPermissions = false);

      if (action == PermissionWarningAction.tryAgain ||
          action == PermissionWarningAction.openSettings) {
        // User either wants to retry or has returned from app settings
        await _requestPermissions();
        return;
      }

      // Dismissed or skipped — fall back to no notifications
      setState(() {
        _permissionsGranted = false;
        _notificationChoice = NotificationChoice.none;
      });
      return;
    }

    setState(() {
      _permissionsGranted = true;
      _isRequestingPermissions = false;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      await OnboardingService.completeOnboarding(
        selectedCity: _selectedCity,
        useAzaan: _notificationChoice == NotificationChoice.azaan,
        disableAllNotifications: _notificationChoice == NotificationChoice.none,
        themeMode: _selectedThemeMode,
        notificationsEnabled: _permissionsGranted,
        languageCode: _selectedLocale.languageCode,
      );

      // Persist locale immediately so the rest of the app updates
      await context.read<LocaleService>().setLocale(_selectedLocale);

      if (!mounted) return;

      // Reload settings and prayers in existing providers
      context.read<SettingsViewModel>().reload();
      await context.read<PrayerViewModel>().updatePrayers();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  LanguageStep(
                    selectedLocale: _selectedLocale,
                    onLocaleSelected: (locale) {
                      setState(() => _selectedLocale = locale);
                      context.read<LocaleService>().setLocale(locale);
                    },
                  ),
                  CityStep(
                    selectedCity: _selectedCity,
                    onCitySelected: (city) {
                      setState(() => _selectedCity = city);
                    },
                    themeMode: _selectedThemeMode,
                    onThemeModeChanged: (mode) {
                      setState(() => _selectedThemeMode = mode);
                      context.read<ThemeService>().setThemeMode(mode);
                    },
                  ),
                  NotificationStep(
                    selectedChoice: _notificationChoice,
                    onChoiceSelected: (choice) {
                      setState(() {
                        _notificationChoice = choice;
                        _permissionsGranted = false;
                        if (choice == NotificationChoice.none) {
                          _permissionsGranted = false;
                        }
                      });
                    },
                  ),
                  PermissionsStep(
                    selectedChoice: _notificationChoice,
                    permissionsGranted: _permissionsGranted,
                    isRequesting: _isRequestingPermissions,
                    onRequestPermissions: _requestPermissions,
                    onSkip: () {
                      setState(() {
                        _notificationChoice = NotificationChoice.none;
                        _permissionsGranted = false;
                      });
                    },
                  ),
                  CompletionStep(
                    selectedCity: _selectedCity,
                    notificationChoice: _notificationChoice,
                    themeMode: _selectedThemeMode,
                    permissionsGranted: _permissionsGranted,
                  ),
                ],
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: 5,
            effect: WormEffect(
              dotWidth: 8,
              dotHeight: 8,
              spacing: 8,
              activeDotColor: AppTheme.appOrange,
              dotColor: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      AppLocalizations.of(context)!.back,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: _currentPage > 0 ? 2 : 1,
                child: ElevatedButton(
                  onPressed: _isCompleting
                      ? null
                      : (_currentPage == 4 ? _completeOnboarding : _nextPage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                  ),
                  child: _isCompleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage == 4
                              ? AppLocalizations.of(context)!.getStarted
                              : AppLocalizations.of(context)!.next,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
