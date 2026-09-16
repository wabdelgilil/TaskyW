import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/database/database_tables.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/features/settings/data/services/settings_service.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('User Settings Sync & Payload Tests', () {
    test('toCloudPayload يتضمن task_card_density ويزيل sync_status', () {
      final localRow = {
        'id': 'default',
        'notifications_enabled': 1,
        'default_reminder_minutes': 15,
        'default_currency': 'SAR',
        'default_view_mode': 'list',
        'theme_mode': 'light',
        'language_code': 'ar',
        'layout_direction': 'ltr',
        'task_card_density': 'compact',
        'sync_status': 'pending_update',
        'updated_at': '2026-09-16T12:00:00.000Z',
      };

      final payload = SyncService.toCloudPayload(localRow, 'test-user-id');

      expect(payload.containsKey('sync_status'), isFalse);
      expect(payload['user_id'], 'test-user-id');
      expect(payload['task_card_density'], 'compact');
      expect(payload['notifications_enabled'], isTrue);
      expect(payload['default_currency'], 'SAR');
    });

    test('toLocalRow يحتفظ بـ task_card_density ويضبط sync_status = synced', () {
      final cloudRow = {
        'user_id': 'test-user-id',
        'notifications_enabled': true,
        'default_reminder_minutes': 30,
        'default_currency': 'USD',
        'default_view_mode': 'kanban',
        'theme_mode': 'dark',
        'language_code': 'en',
        'layout_direction': 'auto',
        'task_card_density': 'compact',
        'updated_at': '2026-09-16T12:00:00.000Z',
        'ignored_field': 'hello',
      };

      final validColumns = [
        'id',
        'notifications_enabled',
        'default_reminder_minutes',
        'default_currency',
        'default_view_mode',
        'theme_mode',
        'language_code',
        'layout_direction',
        'task_card_density',
        'sync_status',
        'updated_at',
      ];

      final localRow = SyncService.toLocalRow(cloudRow, validColumns);

      expect(localRow.containsKey('user_id'), isFalse);
      expect(localRow.containsKey('ignored_field'), isFalse);
      expect(localRow['task_card_density'], 'compact');
      expect(localRow['sync_status'], 'synced');
      expect(localRow['default_currency'], 'USD');
      expect(localRow['notifications_enabled'], 1);
    });

    test('SettingsService._mirrorToDb يضبط sync_status على pending_update مع task_card_density', () async {
      final service = SettingsService();
      const model = AppSettingsModel(
        taskCardDensity: 'compact',
        defaultCurrency: 'EUR',
        themeMode: 'oled',
      );

      await service.save(model);

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: ['default'],
      );

      expect(rows, isNotEmpty);
      final row = rows.first;
      expect(row['sync_status'], 'pending_update');
      expect(row['task_card_density'], 'compact');
      expect(row['default_currency'], 'EUR');
      expect(row['theme_mode'], 'oled');
    });

    test('syncSettingsOnly يعود بـ false بأمان عند عدم وجود جلسة مستخدم مسجل', () async {
      final result = await SyncService.instance.syncSettingsOnly();
      expect(result, isFalse);
    });

    test('SettingsController يحدث الإعدادات ويستدعي المزامنة دون استثناءات', () async {
      final controller = SettingsController.instance;
      await controller.load();

      await controller.setTaskCardDensity('compact');
      expect(controller.taskCardDensity, 'compact');
      expect(controller.isCompactCards, isTrue);

      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: ['default'],
      );
      expect(rows, isNotEmpty);
      expect(rows.first['task_card_density'], 'compact');
      expect(rows.first['sync_status'], 'pending_update');

      await controller.setTaskCardDensity('comfortable');
      expect(controller.taskCardDensity, 'comfortable');
      expect(controller.isCompactCards, isFalse);

      final updatedRows = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: ['default'],
      );
      expect(updatedRows.first['task_card_density'], 'comfortable');
      expect(updatedRows.first['sync_status'], 'pending_update');
    });
  });
}
