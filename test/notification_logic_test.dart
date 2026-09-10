import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsController.instance.load();
  });

  ProjectModel enabledProject() => ProjectModel(
        id: 'p1',
        areaId: 'a1',
        name: 'مشروع نشط',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        notificationsEnabled: true,
      );

  ProjectModel mutedProject() => ProjectModel(
        id: 'p2',
        areaId: 'a1',
        name: 'مشروع مكتوم',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        notificationsEnabled: false,
      );

  group('NotificationService.shouldNotifyFor - التحقق المزدوج', () {
    test('إشعار مسموح: عام مفعّل + مشروع مفعّل + موعد مستقبلي', () {
      final allowed = NotificationService.instance.shouldNotifyFor(
        project: enabledProject(),
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(allowed, isTrue);
    });

    test('ممنوع عند إيقاف الإشعارات العامة (حتى مع مشروع مفعّل)', () async {
      await SettingsController.instance.setNotificationsEnabled(false);
      final allowed = NotificationService.instance.shouldNotifyFor(
        project: enabledProject(),
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(allowed, isFalse);
    });

    test('ممنوع عند كتم إشعارات المشروع نفسه', () {
      final allowed = NotificationService.instance.shouldNotifyFor(
        project: mutedProject(),
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(allowed, isFalse);
    });

    test('ممنوع عند موعد في الماضي (لا نرسل تنبيهات متأخرة)', () {
      final allowed = NotificationService.instance.shouldNotifyFor(
        project: enabledProject(),
        scheduledDate: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(allowed, isFalse);
    });

    test('مشروع مؤمَّن (null) يعتمد على الإعدادات العامة فقط', () {
      final allowed = NotificationService.instance.shouldNotifyFor(
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(allowed, isTrue);
    });
  });

  group('ProjectModel - الحقل notifications_enabled', () {
    test('toMap يُخزّن الإشارة كرقم صحيح 0/1', () {
      expect(enabledProject().toMap()['notifications_enabled'], 1);
      expect(mutedProject().toMap()['notifications_enabled'], 0);
    });

    test('fromMap يقرأ رقمياً ومنطقياً معاً (توافق سحابي)', () {
      final fromInt = ProjectModel.fromMap({
        'id': 'x',
        'area_id': 'a',
        'name': 'n',
        'notifications_enabled': 0,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      });
      expect(fromInt.notificationsEnabled, isFalse);

      final fromBool = ProjectModel.fromMap({
        'id': 'x',
        'area_id': 'a',
        'name': 'n',
        'notifications_enabled': true,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      });
      expect(fromBool.notificationsEnabled, isTrue);

      final fromGone = ProjectModel.fromMap({
        'id': 'x',
        'area_id': 'a',
        'name': 'n',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      });
      expect(fromGone.notificationsEnabled, isTrue);
    });

    test('copyWith يسمح بكتم/تفعيل المشروع', () {
      final updated = enabledProject().copyWith(notificationsEnabled: false);
      expect(updated.notificationsEnabled, isFalse);
    });
  });
}
