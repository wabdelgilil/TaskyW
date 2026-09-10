// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'TaskyW';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSettings => 'الإعدادات';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonToday => 'مهام اليوم';

  @override
  String taskCountRemaining(int count) {
    return 'متبقي $count مهام';
  }

  @override
  String welcomeUser(String name) {
    return 'مرحباً $name';
  }

  @override
  String get sectionNotifications => 'الإشعارات والتنبيهات';

  @override
  String get sectionLanguage => 'اللغة والمنطقة';

  @override
  String get sectionFinance => 'المالية والعملات';

  @override
  String get sectionAppearance => 'المظهر والثيم';

  @override
  String get sectionData => 'بيانات التطبيق';

  @override
  String get settingsNotifications => 'إشعارات التطبيق';

  @override
  String get settingsNotificationsDesc =>
      'تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)';

  @override
  String get settingsReminderTime => 'وقت التذكير الافتراضي';

  @override
  String settingsReminderMinutes(int minutes) {
    return 'قبل الموعد بـ $minutes دقيقة';
  }

  @override
  String get settingsRequestPermission => 'طلب صلاحية التنبيهات';

  @override
  String get settingsRequestPermissionDesc =>
      'تأكيد صلاحية التنبيهات على الأندرويد/IOS';

  @override
  String get settingsPermissionGranted => 'تم تفعيل صلاحية التنبيهات بنجاح';

  @override
  String get settingsPermissionDenied => 'تم رفض طلب الصلاحية';

  @override
  String get settingsEnable => 'تفعيل';

  @override
  String get settingsLanguage => 'لغة التطبيق';

  @override
  String get settingsLanguageDesc =>
      'اختيار لغة الواجهات (الافتراضي: لغة الجهاز)';

  @override
  String get settingsLanguageSystem => 'تلقائي (لغة الجهاز)';

  @override
  String get settingsLanguageSystemShort => 'تلقائي';

  @override
  String get languageArabic => 'العربية (RTL)';

  @override
  String get languageEnglish => 'English (LTR)';

  @override
  String get settingsCurrency => 'العملة الافتراضية';

  @override
  String settingsCurrencyDesc(String currency) {
    return 'العملة المستخدمة في السجلات المالية الجديدة: $currency';
  }

  @override
  String get settingsViewMode => 'طريقة العرض';

  @override
  String get viewModeList => 'قائمة';

  @override
  String get viewModeKanban => 'كانبان';

  @override
  String get themeModeLabel => 'وضع المظهر';

  @override
  String get themeLight => 'نهاري';

  @override
  String get themeDark => 'ليلي';

  @override
  String get themeOled => 'OLED';

  @override
  String get themeLightFull => 'الوضع النهاري (Light)';

  @override
  String get themeDarkFull => 'الوضع الليلي (Dark)';

  @override
  String get themeOledFull => 'السواد العميق (OLED)';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String signedInAs(String email) {
    return 'مسجل الدخول: $email';
  }

  @override
  String get signedOut => 'غير مسجل الدخول';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileDisplayName => 'الاسم المعروض';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get navHome => 'اليوم';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navNotes => 'الملاحظات';

  @override
  String get navFinance => 'المالية';

  @override
  String get navSettings => 'الإعدادات';
}
