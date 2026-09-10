import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/database/database_tables.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/features/settings/data/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = SettingsService();

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  Future<Map<String, dynamic>?> dbRow(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      DatabaseTables.userSettingsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  group('SettingsService - التخزين في SQLite', () {
    test('save() يعكس الإعدادات إلى صف SQLite (user_settings)', () async {
      const model = AppSettingsModel(
        notificationsEnabled: false,
        defaultReminderMinutes: 45,
        defaultCurrency: 'USD',
        defaultViewMode: 'kanban',
        themeMode: 'oled',
        languageCode: 'en',
        layoutDirection: 'auto',
      );
      await service.save(model);

      final row = await dbRow('default');
      expect(row, isNotNull);
      expect(row!['notifications_enabled'], 0);
      expect(row['default_reminder_minutes'], 45);
      expect(row['default_currency'], 'USD');
      expect(row['default_view_mode'], 'kanban');
      expect(row['theme_mode'], 'oled');
      expect(row['language_code'], 'en');
      expect(row['layout_direction'], 'auto');
      expect(row['sync_status'], 'synced');
      expect(row['updated_at'], isNotEmpty);
    });

    test('load() يستعيد القيم من SQLite عندما تكون prefs فارغة (جهاز جديد)', () async {
      const model = AppSettingsModel(
        notificationsEnabled: false,
        defaultReminderMinutes: 30,
        defaultCurrency: 'AED',
        defaultViewMode: 'kanban',
        themeMode: 'dark',
        languageCode: 'ar',
        layoutDirection: 'ltr',
      );
      await service.save(model);

      // محاكاة جهاز جديد: المرآة السريعة فارغة لكن SQLite يحمل البيانات.
      SharedPreferences.setMockInitialValues({});

      final restored = await service.load();
      expect(restored.languageCode, 'ar');
      expect(restored.defaultCurrency, 'AED');
      expect(restored.themeMode, 'dark');
      expect(restored.defaultReminderMinutes, 30);

      // يُعاد ملء المرآة تلقائياً بعد الاسترجاع من SQLite.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.language_code'), 'ar');
    });

    test('save() يحدّث الصف بدل تكراره ويعطي updated_at جديداً', () async {
      await service.save(const AppSettingsModel());
      final first = await dbRow('default');

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await service.save(
        const AppSettingsModel(defaultCurrency: 'SAR', themeMode: 'oled'),
      );

      final rows = await AppDatabase.instance.database
        .then((db) => db.query(DatabaseTables.userSettingsTable));
      expect(rows.length, 1);

      final second = await dbRow('default');
      expect(second!['theme_mode'], 'oled');
      expect(second['updated_at'], isNot(first!['updated_at']));
    });

    test('load() يهاجر قيماً مخزنة مسبقاً من prefs إلى SQLite', () async {
      SharedPreferences.setMockInitialValues({
        'settings.notifications_enabled': false,
        'settings.default_currency': 'EGP',
        'settings.language_code': 'en',
      });

      final empty = await dbRow('default');
      expect(empty, isNull);

      final model = await service.load();
      expect(model.defaultCurrency, 'EGP');
      expect(model.languageCode, 'en');

      final row = await dbRow('default');
      expect(row, isNotNull);
      expect(row!['default_currency'], 'EGP');
    });

    test('clear() يحذف صف SQLite والمفاتيح في prefs', () async {
      await service.save(const AppSettingsModel(languageCode: 'en'));
      await service.clear();

      final row = await dbRow('default');
      expect(row, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.language_code'), isNull);
    });
  });
}