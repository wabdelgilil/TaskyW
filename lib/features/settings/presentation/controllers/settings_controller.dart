import 'package:flutter/foundation.dart';
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
    _loaded = true;
    ThemeController.instance.setStyle(_themeStyleFromString(_settings.themeMode));
    notifyListeners();
  }

  /// التبديل العام للإشعارات (إيقاف/تفعيل كل التنبيهات).
  Future<void> setNotificationsEnabled(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _service.save(_settings);
    notifyListeners();
  }

  /// وقت التذكير الافتراضي قبل الموعد (بالدقائق).
  Future<void> setDefaultReminderMinutes(int minutes) async {
    _settings = _settings.copyWith(defaultReminderMinutes: minutes);
    await _service.save(_settings);
    notifyListeners();
  }

  /// العملة الافتراضية للتعاملات المالية.
  Future<void> setDefaultCurrency(String currency) async {
    _settings = _settings.copyWith(defaultCurrency: currency);
    await _service.save(_settings);
    notifyListeners();
  }

  /// وضع العرض الافتراضي للمهام (list / kanban).
  Future<void> setDefaultViewMode(String viewMode) async {
    _settings = _settings.copyWith(defaultViewMode: viewMode);
    await _service.save(_settings);
    notifyListeners();
  }

  /// وضع الثيم (light / dark / oled) مع تطبيقه فوراً.
  Future<void> setThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    ThemeController.instance.setStyle(_themeStyleFromString(mode));
    await _service.save(_settings);
    notifyListeners();
  }

  /// استرجاع الوضع الحالي للثيم بصيغة نصية متوافقة مع الافتراضيات.
  String get effectiveThemeMode =>
      _themeStyleToString(ThemeController.instance.currentStyle);
}