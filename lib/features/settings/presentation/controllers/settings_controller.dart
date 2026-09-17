import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/features/settings/data/services/settings_service.dart';

/// متحكم إعدادات التطبيق (Singleton عبر ChangeNotifier).
///
/// يُحمَّل عبر `load()` عند إقلاع التطبيق ويحفظ أي تغيير فوراً عبر
/// `SettingsService`. جميع القيم لها افتراضيات ثابتة لكي يظل التطبيق
/// قابلاً للعمل حتى قبل التحميل أو في الاختبارات.
class SettingsController extends ChangeNotifier {
  static final SettingsController instance = SettingsController._internal();

  final SettingsService _service = SettingsService();
  AppSettingsModel _settings = const AppSettingsModel();

  bool _loaded = false;

  SettingsController._internal();

  bool get isLoaded => _loaded;

  bool get notificationsEnabled => _settings.notificationsEnabled;
  int get defaultReminderMinutes => _settings.defaultReminderMinutes;
  String get defaultCurrency => _settings.defaultCurrency;
  String get defaultViewMode => _settings.defaultViewMode;
  String get themeMode => _settings.themeMode;
  String get languageCode => _settings.languageCode;

  // إعدادات الذكاء الاصطناعي (BYOK)
  String? get geminiApiKey => _settings.geminiApiKey;
  bool get aiEnabled => _settings.aiEnabled;
  String get aiModel => _settings.aiModel;
  String get aiVoice => _settings.aiVoice;
  bool get hasValidAiKey =>
      _settings.geminiApiKey != null && _settings.geminiApiKey!.trim().isNotEmpty;

  /// اتجاه تخطيط الواجهة: ltr (سايد بار يسار دائماً) أو auto (يتبع اللغة).
  String get layoutDirection => _settings.layoutDirection;

  /// هل الواجهة مُجبرة على الاتجاه الأيسر (LTR) بغض النظر عن اللغة؟
  bool get isForcedLtr => _settings.layoutDirection == 'ltr';

  /// كثافة كروت المهام: comfortable أو compact.
  String get taskCardDensity => _settings.taskCardDensity;

  /// هل العرض الحالي لكروت المهام مضغوط (compact)؟
  bool get isCompactCards => _settings.taskCardDensity == 'compact';

  /// اللغة النشطة: null = تلقائي (لغة الجهاز)، أو `Locale('ar')` / `Locale('en')`.
  Locale? get activeLocale {
    switch (_settings.languageCode) {
      case 'ar':
        return const Locale('ar');
      case 'en':
        return const Locale('en');
      case 'system':
      default:
        return null;
    }
  }

  static AppThemeStyle _themeStyleFromString(String mode) {
    switch (mode) {
      case 'dark':
        return AppThemeStyle.dark;
      case 'oled':
        return AppThemeStyle.oled;
      case 'light':
      default:
        return AppThemeStyle.light;
    }
  }

  static String _themeStyleToString(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.dark:
        return 'dark';
      case AppThemeStyle.oled:
        return 'oled';
      case AppThemeStyle.light:
        return 'light';
    }
  }

  /// تحميل الإعدادات المحفوظة وتطبيق الثيم المحفوظ على `ThemeController`.
  Future<void> load() async {
    _settings = await _service.load();
    if (_settings.aiModel == 'gemini-2.0-flash' || _settings.aiModel == 'gemini-1.5-flash') {
      _settings = _settings.copyWith(aiModel: 'gemini-2.5-flash');
      await _service.save(_settings);
    }
    _loaded = true;
    ThemeController.instance.setStyle(_themeStyleFromString(_settings.themeMode));
    notifyListeners();
  }

  /// التبديل العام للإشعارات (إيقاف/تفعيل كل التنبيهات).
  Future<void> setNotificationsEnabled(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// وقت التذكير الافتراضي قبل الموعد (بالدقائق).
  Future<void> setDefaultReminderMinutes(int minutes) async {
    _settings = _settings.copyWith(defaultReminderMinutes: minutes);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// العملة الافتراضية للتعاملات المالية.
  Future<void> setDefaultCurrency(String currency) async {
    _settings = _settings.copyWith(defaultCurrency: currency);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// وضع العرض الافتراضي للمهام (list / kanban).
  Future<void> setDefaultViewMode(String viewMode) async {
    _settings = _settings.copyWith(defaultViewMode: viewMode);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// وضع الثيم (light / dark / oled) مع تطبيقه فوراً.
  Future<void> setThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    ThemeController.instance.setStyle(_themeStyleFromString(mode));
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// تغيير لغة الواجهة (system / ar / en) مع بث التحديث لحظياً.
  Future<void> updateLanguage(String code) async {
    if (!AppSettingsModel.supportedLanguages.contains(code)) return;
    _settings = _settings.copyWith(languageCode: code);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// تغيير اتجاه تخطيط الواجهة (ltr / auto) — مستقل تماماً عن اللغة.
  Future<void> setLayoutDirection(String direction) async {
    if (!AppSettingsModel.supportedLayoutDirections.contains(direction)) {
      return;
    }
    _settings = _settings.copyWith(layoutDirection: direction);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

/// تغيير كثافة كروت المهام (comfortable / compact).
  Future<void> setTaskCardDensity(String density) async {
    if (!AppSettingsModel.supportedTaskCardDensities.contains(density)) {
      return;
    }
    _settings = _settings.copyWith(taskCardDensity: density);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// التبديل السريع بين الوضع العادي (comfortable) والمضغوط (compact).
  Future<void> toggleTaskCardDensity() async {
    final nextDensity = isCompactCards ? 'comfortable' : 'compact';
    await setTaskCardDensity(nextDensity);
  }

  // ─── دوال الذكاء الاصطناعي والمفتاح الشخصي (BYOK) ───────────────────────

  /// تعيين مفتاح Google Gemini API وحفظه.
  Future<void> setGeminiApiKey(String key) async {
    final trimmed = key.trim();
    _settings = _settings.copyWith(geminiApiKey: trimmed.isEmpty ? null : trimmed);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// مسح مفتاح الذكاء الاصطناعي.
  Future<void> clearGeminiApiKey() async {
    _settings = _settings.copyWith(clearGeminiApiKey: true);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// تفعيل أو تعطيل مساعد الذكاء الاصطناعي.
  Future<void> setAiEnabled(bool enabled) async {
    _settings = _settings.copyWith(aiEnabled: enabled);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// تعيين نموذج الذكاء الاصطناعي.
  Future<void> setAiModel(String model) async {
    _settings = _settings.copyWith(aiModel: model);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// تعيين شخصية وصوت الذكاء الاصطناعي (Puck / Aoede / Kore / Fenrir).
  Future<void> setAiVoice(String voice) async {
    if (!AppSettingsModel.supportedAiVoices.contains(voice)) return;
    _settings = _settings.copyWith(aiVoice: voice);
    await _service.save(_settings);
    unawaited(SyncService.instance.syncSettingsOnly());
    notifyListeners();
  }

  /// اختبار اتصال مفتاح الـ API والتحقق من صلاحيته وتحديد أفضل نموذج شغال تلقائياً.
  Future<({bool success, String? error, String? workingModel})> testGeminiApiKeyDetailed(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      return (success: false, error: 'يرجى إدخال مفتاح الـ API أولاً.', workingModel: null);
    }

    final candidateModels = <String>{
      _settings.aiModel,
      'gemini-2.5-flash',
      'gemini-3.6-flash',
      'gemini-2.5-pro',
    }.toList();

    String? lastError;

    for (final modelName in candidateModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: key,
        );
        final response = await model.generateContent([
          Content.text('Hello'),
        ]);
        if (response.text != null && response.text!.isNotEmpty) {
          if (_settings.aiModel != modelName) {
            await setAiModel(modelName);
          }
          return (success: true, error: null, workingModel: modelName);
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('[SettingsController] test failed for model $modelName: $e');
      }
    }

    String userFriendlyError = 'فشل التحقق من المفتاح';
    if (lastError != null) {
      if (lastError.contains('API_KEY_INVALID') || lastError.contains('400') || lastError.contains('invalid')) {
        userFriendlyError = 'مفتاح الـ API غير صالح، يرجى التأكد من نسخه بشكل صحيح من Google AI Studio';
      } else if (lastError.contains('Failed to fetch') || lastError.contains('Network') || lastError.contains('SocketException')) {
        userFriendlyError = 'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت';
      } else {
        userFriendlyError = lastError;
      }
    }

    return (success: false, error: userFriendlyError, workingModel: null);
  }

  /// اختبار اتصال مفتاح الـ API والتحقق من صلاحيته فورياً.
  Future<bool> testGeminiApiKey(String apiKey) async {
    final res = await testGeminiApiKeyDetailed(apiKey);
    return res.success;
  }

  /// استرجاع الوضع الحالي للثيم بصيغة نصية متوافقة مع الافتراضيات.
  String get effectiveThemeMode =>
      _themeStyleToString(ThemeController.instance.currentStyle);
}