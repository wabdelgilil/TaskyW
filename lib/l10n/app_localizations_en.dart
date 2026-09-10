// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TaskyW';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonToday => 'Today\'s Tasks';

  @override
  String taskCountRemaining(int count) {
    return '$count tasks remaining';
  }

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get sectionNotifications => 'Notifications & Alerts';

  @override
  String get sectionLanguage => 'Language & Region';

  @override
  String get sectionFinance => 'Finance & Currencies';

  @override
  String get sectionAppearance => 'Appearance & Theme';

  @override
  String get sectionData => 'App Data';

  @override
  String get settingsNotifications => 'App Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Turn all local notifications (task reminders) on or off';

  @override
  String get settingsReminderTime => 'Default reminder time';

  @override
  String settingsReminderMinutes(int minutes) {
    return '$minutes minutes before due';
  }

  @override
  String get settingsRequestPermission => 'Request notification permission';

  @override
  String get settingsRequestPermissionDesc =>
      'Confirm notification permission on Android/iOS';

  @override
  String get settingsPermissionGranted =>
      'Notification permission enabled successfully';

  @override
  String get settingsPermissionDenied => 'Notification permission was denied';

  @override
  String get settingsEnable => 'Enable';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get settingsLanguageDesc =>
      'Choose the interface language (default: device language)';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageSystemShort => 'System';

  @override
  String get languageArabic => 'العربية (RTL)';

  @override
  String get languageEnglish => 'English (LTR)';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String settingsCurrencyDesc(String currency) {
    return 'Currency used for new financial records: $currency';
  }

  @override
  String get settingsViewMode => 'View mode';

  @override
  String get viewModeList => 'List';

  @override
  String get viewModeKanban => 'Kanban';

  @override
  String get themeModeLabel => 'Theme mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get themeLightFull => 'Light mode';

  @override
  String get themeDarkFull => 'Dark mode';

  @override
  String get themeOledFull => 'Deep black (OLED)';

  @override
  String get appVersion => 'App version';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get accountStatus => 'Account status';

  @override
  String signedInAs(String email) {
    return 'Signed in: $email';
  }

  @override
  String get signedOut => 'Not signed in';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileEmail => 'Email address';

  @override
  String get navHome => 'Today';

  @override
  String get navProjects => 'Projects';

  @override
  String get navNotes => 'Notes';

  @override
  String get navFinance => 'Finance';

  @override
  String get navSettings => 'Settings';
}
