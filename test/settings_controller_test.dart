import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsController.instance.load();
  });

  group('SettingsController - الافتراضيات', () {
    test('القيم الافتراضية سليمة قبل أي حفظ', () {
      final c = SettingsController.instance;
      expect(c.notificationsEnabled, isTrue);
      expect(c.defaultReminderMinutes, 15);
      expect(c.defaultCurrency, 'SAR');
      expect(c.defaultViewMode, 'list');
      expect(c.themeMode, 'light');
    });

    test('الإعدادات تُحمَّل من التخزين المحلي', () async {
      SharedPreferences.setMockInitialValues({
        'settings.notifications_enabled': false,
        'settings.default_reminder_minutes': 45,
        'settings.default_currency': 'USD',
        'settings.default_view_mode': 'kanban',
        'settings.theme_mode': 'oled',
      });
      await SettingsController.instance.load();

      final c = SettingsController.instance;
      expect(c.notificationsEnabled, isFalse);
      expect(c.defaultReminderMinutes, 45);
      expect(c.defaultCurrency, 'USD');
      expect(c.defaultViewMode, 'kanban');
      expect(c.themeMode, 'oled');
    });
  });

  group('SettingsController - الحفظ والتحديث', () {
    test('إيقاف الإشعارات يُحفظ في التخزين', () async {
      await SettingsController.instance.setNotificationsEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('settings.notifications_enabled'), isFalse);
      expect(SettingsController.instance.notificationsEnabled, isFalse);
    });

    test('تغيير العملة الافتراضية يُحفظ ويُحدَّث', () async {
      await SettingsController.instance.setDefaultCurrency('AED');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.default_currency'), 'AED');
      expect(SettingsController.instance.defaultCurrency, 'AED');
    });

    test('تغيير وضع العرض الافتراضي يُحفظ', () async {
      await SettingsController.instance.setDefaultViewMode('kanban');
      expect(SettingsController.instance.defaultViewMode, 'kanban');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.default_view_mode'), 'kanban');
    });

    test('تغيير وقت التذكير الافتراضي يُحفظ', () async {
      await SettingsController.instance.setDefaultReminderMinutes(30);
      expect(SettingsController.instance.defaultReminderMinutes, 30);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('settings.default_reminder_minutes'), 30);
    });

    test('تغيير وضع الثيم يطبِّق الثيم فعلياً ويُحفظ', () async {
      await SettingsController.instance.setThemeMode('oled');

      expect(ThemeController.instance.currentStyle, AppThemeStyle.oled);
      expect(SettingsController.instance.themeMode, 'oled');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.theme_mode'), 'oled');
    });

    test('التأكد من أن الثيم المحفوظ يطبَّق عند إعادة التحميل', () async {
      await SettingsController.instance.setThemeMode('dark');
      await SettingsController.instance.load();

      expect(ThemeController.instance.currentStyle, AppThemeStyle.dark);
    });
  });

  group('SettingsService - حدود القيم المدعومة', () {
    test('قوائم العملات وأوضاع العرض والثيم مدعومة وقابلة للاستخدام', () {
      expect(AppSettingsModel.supportedCurrencies, contains('SAR'));
      expect(AppSettingsModel.supportedCurrencies, contains('USD'));
      expect(AppSettingsModel.supportedViewModes, ['list', 'kanban']);
      expect(AppSettingsModel.supportedThemeModes, ['light', 'dark', 'oled']);
    });
  });
}