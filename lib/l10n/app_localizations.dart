import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
    Locale('si'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get appTitle;

  /// No description provided for @navPrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get navPrayers;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil (தமிழ்)'**
  String get languageTamil;

  /// No description provided for @languageSinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala (සිංහල)'**
  String get languageSinhala;

  /// No description provided for @onboardingGreeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum'**
  String get onboardingGreeting;

  /// No description provided for @onboardingAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get onboardingAppearance;

  /// No description provided for @onboardingRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get onboardingRegion;

  /// No description provided for @onboardingStayOnTime.
  ///
  /// In en, this message translates to:
  /// **'Stay on Time'**
  String get onboardingStayOnTime;

  /// No description provided for @onboardingReminderQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to be reminded for prayers?'**
  String get onboardingReminderQuestion;

  /// No description provided for @onboardingChoiceNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingChoiceNotifications;

  /// No description provided for @onboardingChoiceNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a notification reminder for each prayer'**
  String get onboardingChoiceNotificationsDesc;

  /// No description provided for @onboardingChoiceAzaan.
  ///
  /// In en, this message translates to:
  /// **'Azaan Alarm'**
  String get onboardingChoiceAzaan;

  /// No description provided for @onboardingChoiceAzaanDesc.
  ///
  /// In en, this message translates to:
  /// **'Play the Azaan sound as a full alarm for each prayer'**
  String get onboardingChoiceAzaanDesc;

  /// No description provided for @onboardingChoiceNone.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get onboardingChoiceNone;

  /// No description provided for @onboardingChoiceNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'I don\'t want any reminders. I\'ll enable them later in Settings.'**
  String get onboardingChoiceNoneDesc;

  /// No description provided for @onboardingChoiceInfo.
  ///
  /// In en, this message translates to:
  /// **'You can configure this per prayer later in Settings'**
  String get onboardingChoiceInfo;

  /// No description provided for @onboardingAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingAllSet;

  /// No description provided for @onboardingReady.
  ///
  /// In en, this message translates to:
  /// **'Your prayer times are ready'**
  String get onboardingReady;

  /// No description provided for @onboardingNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. You can enable them later in Settings.'**
  String get onboardingNotificationsDisabled;

  /// No description provided for @onboardingSummaryRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get onboardingSummaryRegion;

  /// No description provided for @onboardingSummaryAlertMode.
  ///
  /// In en, this message translates to:
  /// **'Alert Mode'**
  String get onboardingSummaryAlertMode;

  /// No description provided for @onboardingSummaryTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get onboardingSummaryTheme;

  /// No description provided for @onboardingAlertModeAzaan.
  ///
  /// In en, this message translates to:
  /// **'Azaan Alarm'**
  String get onboardingAlertModeAzaan;

  /// No description provided for @onboardingAlertModeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingAlertModeNotifications;

  /// No description provided for @onboardingAlertModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get onboardingAlertModeDisabled;

  /// No description provided for @onboardingThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get onboardingThemeSystem;

  /// No description provided for @onboardingThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get onboardingThemeLight;

  /// No description provided for @onboardingThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get onboardingThemeDark;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your app preferences'**
  String get settingsSubtitle;

  /// No description provided for @settingsSectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsSectionLocation;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionPrayerModes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Notification Modes'**
  String get settingsSectionPrayerModes;

  /// No description provided for @settingsSectionAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsSectionAdvanced;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsPrayerRegion.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times Region'**
  String get settingsPrayerRegion;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAlarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms (Azaan)'**
  String get settingsAlarms;

  /// No description provided for @settingsAlarmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable full-screen azaan alarms for prayers'**
  String get settingsAlarmsSubtitle;

  /// No description provided for @settingsShowAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Show Advanced Settings'**
  String get settingsShowAdvanced;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get settingsReset;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will clear all settings and restart the onboarding. Are you sure?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetAction;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'This app provides daily salah times for Muslims across Sri Lanka in a simple and easy-to-use format.\n\nPrayer times are based on data published by All Ceylon Jamiyyathul Ulama.\n\nThis app operates independently and has no official connection with ACJU.'**
  String get settingsAboutBody;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testAlarm.
  ///
  /// In en, this message translates to:
  /// **'Test Alarm'**
  String get testAlarm;

  /// No description provided for @pleaseEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications first'**
  String get pleaseEnableNotifications;

  /// No description provided for @pleaseEnableAlarms.
  ///
  /// In en, this message translates to:
  /// **'Please enable alarms first'**
  String get pleaseEnableAlarms;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification from Prayer Times'**
  String get testNotificationBody;

  /// No description provided for @testAlarmBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test alarm from Prayer Times'**
  String get testAlarmBody;

  /// No description provided for @testAlarmDescription.
  ///
  /// In en, this message translates to:
  /// **'Schedule a test alarm to verify it fires on your device. Uses a short azaan clip for testing.'**
  String get testAlarmDescription;

  /// No description provided for @testAlarmSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter seconds'**
  String get testAlarmSecondsLabel;

  /// No description provided for @testAlarmSecondsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30'**
  String get testAlarmSecondsHint;

  /// No description provided for @testAlarmHelper.
  ///
  /// In en, this message translates to:
  /// **'Uses short azaan. Min 1s, max 6h.'**
  String get testAlarmHelper;

  /// No description provided for @testAlarmInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of seconds'**
  String get testAlarmInvalid;

  /// No description provided for @testAlarmScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule Test Alarm'**
  String get testAlarmScheduleButton;

  /// No description provided for @testAlarmScheduled30s.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled in 30 seconds'**
  String get testAlarmScheduled30s;

  /// No description provided for @testAlarmScheduled1m.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled in 1 minute'**
  String get testAlarmScheduled1m;

  /// No description provided for @testAlarmScheduled2m.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled in 2 minutes'**
  String get testAlarmScheduled2m;

  /// No description provided for @testAlarmScheduled5m.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled in 5 minutes'**
  String get testAlarmScheduled5m;

  /// No description provided for @testAlarmScheduledCustom.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled'**
  String get testAlarmScheduledCustom;

  /// No description provided for @testNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Test notification-only mode (no alarm or full-screen intent).'**
  String get testNotificationDescription;

  /// No description provided for @testNotificationInstant.
  ///
  /// In en, this message translates to:
  /// **'Instantly'**
  String get testNotificationInstant;

  /// No description provided for @testNotification30s.
  ///
  /// In en, this message translates to:
  /// **'In 30 sec'**
  String get testNotification30s;

  /// No description provided for @snackTestNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get snackTestNotificationSent;

  /// No description provided for @snackTestNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test notification scheduled in 30 seconds'**
  String get snackTestNotificationScheduled;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaTitle;

  /// No description provided for @qiblaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your device towards the Qibla'**
  String get qiblaSubtitle;

  /// No description provided for @qiblaUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support compass functionality. Qibla direction is unavailable.'**
  String get qiblaUnsupported;

  /// No description provided for @qiblaLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get qiblaLocationLabel;

  /// No description provided for @qiblaBearingLabel.
  ///
  /// In en, this message translates to:
  /// **'Qibla Bearing'**
  String get qiblaBearingLabel;

  /// No description provided for @qiblaCalibrateNeeded.
  ///
  /// In en, this message translates to:
  /// **'Your compass needs calibration. Move your device in a gentle figure-8 motion.'**
  String get qiblaCalibrateNeeded;

  /// No description provided for @qiblaCalibrateGeneral.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy may be affected by nearby electronic devices or metal objects. Calibrate by moving your phone in a figure-8 pattern.'**
  String get qiblaCalibrateGeneral;

  /// No description provided for @prayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// No description provided for @languagePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerLabel;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @alertModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Alert Mode'**
  String get alertModeLabel;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayerLabel;

  /// No description provided for @nextEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Event'**
  String get nextEventLabel;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @timeUnitHour.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get timeUnitHour;

  /// No description provided for @timeUnitMinute.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get timeUnitMinute;

  /// No description provided for @timeUnitSecond.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get timeUnitSecond;

  /// No description provided for @modeAzaan.
  ///
  /// In en, this message translates to:
  /// **'Azaan'**
  String get modeAzaan;

  /// No description provided for @modeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get modeDefault;

  /// No description provided for @modeSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get modeSilent;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarTabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get calendarTabMonthly;

  /// No description provided for @calendarTabYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get calendarTabYearly;

  /// No description provided for @calendarNoData.
  ///
  /// In en, this message translates to:
  /// **'No calendar data available'**
  String get calendarNoData;

  /// No description provided for @calendarLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading calendar...'**
  String get calendarLoading;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Alarm'**
  String get testAlarmTitle;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @testAlarmScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled'**
  String get testAlarmScheduled;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @actionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSun;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdayShortSat;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
