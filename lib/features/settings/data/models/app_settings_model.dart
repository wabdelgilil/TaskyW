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

  /// اتجاه تخطيط الواجهة: ltr (السايد بار يسار دائماً) أو auto (يتبع اللغة).
  ///
  /// مفصول عن اللغة كلياً: `ltr` يُبقي القائمة الجانبية والشريط العلوي والمحتوى
  /// بترتيب اليسار→يمين حتى لو كانت اللغة العربية، بينما `auto` يتبعه لاتجاه اللغة.
  final String layoutDirection;

  /// كثافة كروت المهام: comfortable (مريح، افتراضي) أو compact (مضغوط).
  final String taskCardDensity;

  /// مفتاح Google Gemini API الخاص بالمستخدم (BYOK).
  final String? geminiApiKey;

  /// تفعيل أو تعطيل مساعد الذكاء الاصطناعي.
  final bool aiEnabled;

  /// نموذج الذكاء الاصطناعي الافتراضي.
  final String aiModel;

  /// شخصية وصوت الذكاء الاصطناعي البشري التوليدي: Puck (حيوي)، Aoede (هادئ)، Kore (ودود)، Fenrir (رصين).
  final String aiVoice;

  const AppSettingsModel({
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 15,
    this.defaultCurrency = 'SAR',
    this.defaultViewMode = 'list',
    this.themeMode = 'light',
    this.languageCode = 'system',
    this.layoutDirection = 'ltr',
    this.taskCardDensity = 'comfortable',
    this.geminiApiKey,
    this.aiEnabled = true,
    this.aiModel = 'gemini-2.5-flash',
    this.aiVoice = 'Puck',
  });

  AppSettingsModel copyWith({
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    String? defaultCurrency,
    String? defaultViewMode,
    String? themeMode,
    String? languageCode,
    String? layoutDirection,
    String? taskCardDensity,
    String? geminiApiKey,
    bool clearGeminiApiKey = false,
    bool? aiEnabled,
    String? aiModel,
    String? aiVoice,
  }) {
    return AppSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      layoutDirection: layoutDirection ?? this.layoutDirection,
      taskCardDensity: taskCardDensity ?? this.taskCardDensity,
      geminiApiKey: clearGeminiApiKey ? null : (geminiApiKey ?? this.geminiApiKey),
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiModel: aiModel ?? this.aiModel,
      aiVoice: aiVoice ?? this.aiVoice,
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

  /// اتجاهات تخطيط الواجهة المدعومة (مفصولة عن اللغة).
  static const List<String> supportedLayoutDirections = ['ltr', 'auto'];

  /// خيارات كثافة كروت المهام المدعومة.
  static const List<String> supportedTaskCardDensities = [
    'comfortable',
    'compact',
  ];

  /// نماذج Gemini المدعومة.
  static const List<String> supportedAiModels = [
    'gemini-2.5-flash',
    'gemini-3.6-flash',
    'gemini-2.5-pro',
  ];

  /// أصوات الذكاء الاصطناعي التوليدي المدعومة من Gemini.
  static const List<String> supportedAiVoices = [
    'Puck',
    'Aoede',
    'Kore',
    'Fenrir',
  ];
}