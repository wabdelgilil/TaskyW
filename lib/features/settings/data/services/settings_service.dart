import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';

/// خدمة التخزين المحلي لإعدادات التطبيق عبر `shared_preferences`.
///
/// جميع مفاتيح التخزين تبدأ بـ `settings.` لتجنب التعارض مع أي بيانات أخرى.
class SettingsService {
  static const String _keyNotifications = 'settings.notifications_enabled';
  static const String _keyReminderMinutes = 'settings.default_reminder_minutes';
  static const String _keyCurrency = 'settings.default_currency';
  static const String _keyViewMode = 'settings.default_view_mode';
  static const String _keyThemeMode = 'settings.theme_mode';

  Future<AppSettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsModel(
      notificationsEnabled:
          prefs.getBool(_keyNotifications) ?? true,
      defaultReminderMinutes: prefs.getInt(_keyReminderMinutes) ?? 15,
      defaultCurrency:
          prefs.getString(_keyCurrency) ?? 'SAR',
      defaultViewMode: prefs.getString(_keyViewMode) ?? 'list',
      themeMode: prefs.getString(_keyThemeMode) ?? 'light',
    );
  }

  Future<void> save(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, settings.notificationsEnabled);
    await prefs.setInt(_keyReminderMinutes, settings.defaultReminderMinutes);
    await prefs.setString(_keyCurrency, settings.defaultCurrency);
    await prefs.setString(_keyViewMode, settings.defaultViewMode);
    await prefs.setString(_keyThemeMode, settings.themeMode);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyReminderMinutes);
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyViewMode);
    await prefs.remove(_keyThemeMode);
  }
}