import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/database/database_tables.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/features/settings/data/services/settings_service.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    SharedPreferences.setMockInitialValues({});
    await SettingsController.instance.load();
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('AppSettingsModel - Task Card Density', () {
    test('القيمة الافتراضية لكثافة كروت المهام هي comfortable', () {
      const model = AppSettingsModel();
      expect(model.taskCardDensity, 'comfortable');
    });

    test('دعم تحديث taskCardDensity عبر copyWith', () {
      const model = AppSettingsModel();
      final updated = model.copyWith(taskCardDensity: 'compact');
      expect(updated.taskCardDensity, 'compact');
      expect(updated.notificationsEnabled, model.notificationsEnabled);
      expect(updated.themeMode, model.themeMode);
    });

    test('قائمة supportedTaskCardDensities تحوي comfortable و compact', () {
      expect(
        AppSettingsModel.supportedTaskCardDensities,
        containsAll(['comfortable', 'compact']),
      );
      expect(AppSettingsModel.supportedTaskCardDensities.length, 2);
    });
  });

  group('SettingsService - Task Card Density Persistence', () {
    final service = SettingsService();

    test('حفظ واسترجاع taskCardDensity عبر SharedPreferences', () async {
      const model = AppSettingsModel(taskCardDensity: 'compact');
      await service.save(model);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.task_card_density'), 'compact');

      final loaded = await service.load();
      expect(loaded.taskCardDensity, 'compact');
    });

    test('عكس taskCardDensity إلى صف SQLite واسترجاعه عند غياب prefs', () async {
      const model = AppSettingsModel(taskCardDensity: 'compact');
      await service.save(model);

      // التحقق من التخزين في SQLite
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: ['default'],
      );
      expect(rows, isNotEmpty);
      expect(rows.first['task_card_density'], 'compact');

      // تفريغ SharedPreferences لمحاكاة جهاز جديد
      SharedPreferences.setMockInitialValues({});
      final restored = await service.load();
      expect(restored.taskCardDensity, 'compact');
    });

    test('مسح taskCardDensity عبر clear()', () async {
      const model = AppSettingsModel(taskCardDensity: 'compact');
      await service.save(model);

      await service.clear();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('settings.task_card_density'), isFalse);
    });
  });

  group('SettingsController - Task Card Density Logic', () {
    test('الحالة الافتراضية: comfortable و isCompactCards = false', () {
      final c = SettingsController.instance;
      expect(c.taskCardDensity, 'comfortable');
      expect(c.isCompactCards, isFalse);
    });

    test('setTaskCardDensity يحدّث القيمة ويبث إشعار التغيير', () async {
      final c = SettingsController.instance;
      var notified = false;
      void listener() => notified = true;
      c.addListener(listener);

      await c.setTaskCardDensity('compact');

      expect(c.taskCardDensity, 'compact');
      expect(c.isCompactCards, isTrue);
      expect(notified, isTrue);

      c.removeListener(listener);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings.task_card_density'), 'compact');
    });

    test('setTaskCardDensity يتجاهل القيم غير المدعومة', () async {
      final c = SettingsController.instance;
      await c.setTaskCardDensity('comfortable');

      await c.setTaskCardDensity('super_compact');

      expect(c.taskCardDensity, 'comfortable');
      expect(c.isCompactCards, isFalse);
    });

    test('toggleTaskCardDensity يبدل بين comfortable و compact بسلاسة', () async {
      final c = SettingsController.instance;
      await c.setTaskCardDensity('comfortable');
      expect(c.isCompactCards, isFalse);

      // تبديل 1: من comfortable إلى compact
      await c.toggleTaskCardDensity();
      expect(c.taskCardDensity, 'compact');
      expect(c.isCompactCards, isTrue);

      // تبديل 2: من compact إلى comfortable
      await c.toggleTaskCardDensity();
      expect(c.taskCardDensity, 'comfortable');
      expect(c.isCompactCards, isFalse);
    });

    test('load() يستعيد قيمة taskCardDensity المحفوظة', () async {
      SharedPreferences.setMockInitialValues({
        'settings.task_card_density': 'compact',
      });

      await SettingsController.instance.load();

      expect(SettingsController.instance.taskCardDensity, 'compact');
      expect(SettingsController.instance.isCompactCards, isTrue);
    });
  });
}
