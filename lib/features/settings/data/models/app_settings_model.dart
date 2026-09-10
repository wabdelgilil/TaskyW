/// نموذج إعدادات التطبيق المحفوظة محلياً عبر `shared_preferences`.
///
/// كل قيمة هنا لها افتراضي ثابت في الكود بحيث يعمل التطبيق حتى قبل
/// تحميل الإعدادات المحفوظة (Offline-First).
class AppSettingsModel {
  /// التبديل العام للإشعارات المحلية (شغّل/أوقف كل التنبيهات).
  final bool notificationsEnabled;

  /// الوقت الافتراضي (بالدقائق قبل الموعد) لجدولة تذكير مهمة بدون موعد محدد.
  final int defaultReminderMinutes;

  /// العملة الافتراضية في حساب المصاريف.
  final String defaultCurrency;

  /// وضع العرض الافتراضي للمهام (قائمة أو كانبان).
  final String defaultViewMode;

  /// الثيم المفضل: light / dark / oled.
  final String themeMode;

  /// كود اللغة المفضل: system / ar / en (`system` = لغة الجهاز تلقائياً).
  final String languageCode;

  const AppSettingsModel({
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 15,
    this.defaultCurrency = 'SAR',
    this.defaultViewMode = 'list',
    this.themeMode = 'light',
    this.languageCode = 'system',
  });

  AppSettingsModel copyWith({
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    String? defaultCurrency,
    String? defaultViewMode,
    String? themeMode,
    String? languageCode,
  }) {
    return AppSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  static const List<String> supportedCurrencies = [
    'SAR',
    'EGP',
    'USD',
    'AED',
    'KWD',
    'QAR',
    'BHD',
    'OMR',
    'EUR',
    'GBP',
  ];

  static const List<String> supportedViewModes = ['list', 'kanban'];

  static const List<String> supportedThemeModes = ['light', 'dark', 'oled'];

  /// أكواد اللغات المدعومة: الافتراضي يستخدم لغة الجهاز تلقائياً.
  static const List<String> supportedLanguages = ['system', 'ar', 'en'];
}