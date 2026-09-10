import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'TaskyW'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get commonSettings;

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonToday.
  ///
  /// In ar, this message translates to:
  /// **'مهام اليوم'**
  String get commonToday;

  /// عدد المهام المتبقية في مجموعة ما.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {count} مهام'**
  String taskCountRemaining(int count);

  /// ترحيب ترحيبي بالمستخدم باسمه.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {name}'**
  String welcomeUser(String name);

  /// No description provided for @sectionNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات والتنبيهات'**
  String get sectionNotifications;

  /// No description provided for @sectionLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة والمنطقة'**
  String get sectionLanguage;

  /// No description provided for @sectionFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية والعملات'**
  String get sectionFinance;

  /// No description provided for @sectionAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر والثيم'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات التطبيق'**
  String get sectionData;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات التطبيق'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsReminderTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير الافتراضي'**
  String get settingsReminderTime;

  /// تذكير افتراضي قبل الموعد بالدقائق.
  ///
  /// In ar, this message translates to:
  /// **'قبل الموعد بـ {minutes} دقيقة'**
  String settingsReminderMinutes(int minutes);

  /// No description provided for @settingsRequestPermission.
  ///
  /// In ar, this message translates to:
  /// **'طلب صلاحية التنبيهات'**
  String get settingsRequestPermission;

  /// No description provided for @settingsRequestPermissionDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد صلاحية التنبيهات على الأندرويد/IOS'**
  String get settingsRequestPermissionDesc;

  /// No description provided for @settingsPermissionGranted.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل صلاحية التنبيهات بنجاح'**
  String get settingsPermissionGranted;

  /// No description provided for @settingsPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب الصلاحية'**
  String get settingsPermissionDenied;

  /// No description provided for @settingsEnable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get settingsEnable;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In ar, this message translates to:
  /// **'اختيار لغة الواجهات (الافتراضي: لغة الجهاز)'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (لغة الجهاز)'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemShort.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsLanguageSystemShort;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية (RTL)'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English (LTR)'**
  String get languageEnglish;

  /// No description provided for @settingsCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة الافتراضية'**
  String get settingsCurrency;

  /// وصف العملة الافتراضية الحالية.
  ///
  /// In ar, this message translates to:
  /// **'العملة المستخدمة في السجلات المالية الجديدة: {currency}'**
  String settingsCurrencyDesc(String currency);

  /// No description provided for @settingsViewMode.
  ///
  /// In ar, this message translates to:
  /// **'طريقة العرض'**
  String get settingsViewMode;

  /// No description provided for @viewModeList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get viewModeList;

  /// No description provided for @viewModeKanban.
  ///
  /// In ar, this message translates to:
  /// **'كانبان'**
  String get viewModeKanban;

  /// No description provided for @themeModeLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع المظهر'**
  String get themeModeLabel;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In ar, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @themeLightFull.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري (Light)'**
  String get themeLightFull;

  /// No description provided for @themeDarkFull.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي (Dark)'**
  String get themeDarkFull;

  /// No description provided for @themeOledFull.
  ///
  /// In ar, this message translates to:
  /// **'السواد العميق (OLED)'**
  String get themeOledFull;

  /// No description provided for @appVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get appVersion;

  /// رقم إصدار التطبيق الحالي.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @accountStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الحساب'**
  String get accountStatus;

  /// حالة تسجيل الدخول مع البريد.
  ///
  /// In ar, this message translates to:
  /// **'مسجل الدخول: {email}'**
  String signedInAs(String email);

  /// No description provided for @signedOut.
  ///
  /// In ar, this message translates to:
  /// **'غير مسجل الدخول'**
  String get signedOut;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get profileDisplayName;

  /// No description provided for @profileEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profileEmail;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get navHome;

  /// No description provided for @navProjects.
  ///
  /// In ar, this message translates to:
  /// **'المشاريع'**
  String get navProjects;

  /// No description provided for @navNotes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get navNotes;

  /// No description provided for @navFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get navFinance;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
