import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/services/collaboration_service.dart';
import 'package:tasky/core/services/permission_guard_service.dart';
import 'package:tasky/features/collaboration/data/models/entity_share_model.dart';
import 'package:tasky/features/collaboration/data/repositories/collaboration_repository.dart';
import 'package:tasky/features/collaboration/presentation/controllers/collaboration_controller.dart';
import 'package:tasky/features/collaboration/presentation/widgets/universal_share_dialog.dart';

/// واجهة سحابة صامتة (In-memory) لمحاكاة Supabase في الاختبارات.
class _FakeCloud implements CollaborationCloud {
  final Map<String, Map<String, dynamic>> shares = {};
  final Map<String, Map<String, dynamic>> entities = {};

  bool online = true;
  bool autoLinkOnInsert = false;
  String? currentUser;
  String? currentEmail;

  int _seq = 0;

  @override
  Future<bool> get isAuthenticated async => currentUser != null;

  @override
  Future<String?> get currentUserId async => currentUser;

  @override
  Future<String?> get currentUserEmail async => currentEmail;

  static String _k(
    String entityType,
    String entityId,
    String email,
  ) => '$entityType|$entityId|${email.toLowerCase()}';

  @override
  Future<List<Map<String, dynamic>>> fetchShares({
    required String entityType,
    required String entityId,
  }) async {
    if (!online) return [];
    return shares.entries
        .where((e) => e.value['entity_type'] == entityType && e.value['entity_id'] == entityId)
        .map((e) => Map<String, dynamic>.from(e.value))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> findShareByEmail({
    required String entityType,
    required String entityId,
    required String email,
  }) async {
    if (!online) return null;
    return shares[_k(entityType, entityId, email)];
  }

  @override
  Future<Map<String, dynamic>> insertShare(Map<String, dynamic> row) async {
    _seq++;
    final id = row['id'] ?? 'fake-$_seq';
    final insert = Map<String, dynamic>.from(row);
    insert['id'] = id;
    shares[_k(insert['entity_type'], insert['entity_id'], insert['collaborator_email'] as String)] = insert;
    return Map<String, dynamic>.from(insert);
  }

  @override
  Future<void> updateShare({
    required String shareId,
    required Map<String, dynamic> changes,
  }) async {
    final entry = shares.values.firstWhere((s) => s['id'] == shareId);
    entry.addAll(changes);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() async => [];

  @override
  Future<Map<String, dynamic>?> fetchEntityRow({
    required String entityType,
    required String entityId,
  }) async => entities['$entityType|$entityId'];
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    await AppDatabase.instance.database;
  });

  tearDownAll(() async {
    await AppDatabase.resetForTest();
  });

  // ─── PermissionGuardService ───────────────────────────────────────────────
  group('PermissionGuardService.canManageInherited', () {
    test('المالك الأصلي (لا يوجد سجل مشاركة) يمكنه إدارة المشاركات', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'u1', email: 'a@b.com');
      guard.loadShares([]);

      expect(guard.canManageInherited(entityId: 'task-1'), isTrue);
    });

    test('المسؤول (admin) يمكنه إدارة المشاركات', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'task',
          entityId: 'task-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'admin',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      expect(guard.canManageInherited(entityId: 'task-1'), isTrue);
    });

    test('المحرر (editor) لا يمكنه إدارة المشاركات', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'task',
          entityId: 'task-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'editor',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      expect(guard.canManageInherited(entityId: 'task-1'), isFalse);
    });

    test('المشاهد (viewer) لا يمكنه إدارة المشاركات', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'task',
          entityId: 'task-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'viewer',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      expect(guard.canManageInherited(entityId: 'task-1'), isFalse);
    });

    test('يورث الصلاحية من الأجداد: محرر على المشروع = محرر على المهمة', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'project',
          entityId: 'proj-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'editor',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      // المهمة لا لها سجل مباشر → ترث من المشروع الجد
      expect(
        guard.canManageInherited(entityId: 'task-1', ancestorEntityIds: ['proj-1']),
        isFalse,
      );
    });

    test('يورث الصلاحية: admin على المشروع = admin على المهمة', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'project',
          entityId: 'proj-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'admin',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      expect(
        guard.canManageInherited(entityId: 'task-1', ancestorEntityIds: ['proj-1']),
        isTrue,
      );
    });

    test('يوفق بين الكيان الجد والجد الأب: صلاحية على المجال تتفوق على الافتراضي', () {
      final guard = PermissionGuardService();
      guard.setCurrentUser(id: 'collab-1', email: 'collab@x.com');
      guard.loadShares([
        EntityShareModel(
          id: 's1',
          entityType: 'area',
          entityId: 'area-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'viewer',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
        EntityShareModel(
          id: 's2',
          entityType: 'project',
          entityId: 'proj-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@x.com',
          permissionLevel: 'admin',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      ]);

      // المهمة: لا لها سجل مباشر، المشروع الجد admin → يسمح
      expect(
        guard.canManageInherited(entityId: 'task-1', ancestorEntityIds: ['proj-1', 'area-1']),
        isTrue,
      );
    });
  });

  // ─── CollaborationService: حماية الخدمة ─────────────────────────────────
  group('CollaborationService - Admin-Only Re-sharing Guard', () {
    test('المحرر على كيان لا يستطيع دعوة متعاونين (inviteCollaborator يعيد null)', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'collab-1'
        ..currentEmail = 'collab@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      // المستخدم الحالي محرر على المشروع
      cloud.shares['project|proj-1|collab@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-1',
        'collaborator_email': 'collab@x.com',
        'permission_level': 'editor',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };

      final result = await service.inviteCollaborator(
        entityType: 'project',
        entityId: 'proj-1',
        email: 'newperson@x.com',
        permissionLevel: 'viewer',
      );

      expect(result, isNull);
    });

    test('المسؤول على كيان يستطيع دعوة متعاونين', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'collab-1'
        ..currentEmail = 'collab@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      // المستخدم الحالي مسؤول على المشروع
      cloud.shares['project|proj-1|collab@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-1',
        'collaborator_email': 'collab@x.com',
        'permission_level': 'admin',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };

      final result = await service.inviteCollaborator(
        entityType: 'project',
        entityId: 'proj-1',
        email: 'newperson@x.com',
        permissionLevel: 'viewer',
      );

      expect(result, isNotNull);
    });

    test('المحرر لا يستطيع تعديل صلاحية مشارك آخر', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'collab-1'
        ..currentEmail = 'collab@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      cloud.shares['project|proj-1|collab@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-1',
        'collaborator_email': 'collab@x.com',
        'permission_level': 'editor',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };

      // مشاركة أخرى: عميل مختلف البريد
      cloud.shares['project|proj-1|other@x.com'] = {
        'id': 's2',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-2',
        'collaborator_email': 'other@x.com',
        'permission_level': 'viewer',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };
      await service.repository.upsertShare(EntityShareModel(
        id: 's2',
        entityType: 'project',
        entityId: 'proj-1',
        ownerId: 'owner-1',
        collaboratorId: 'collab-2',
        collaboratorEmail: 'other@x.com',
        permissionLevel: 'viewer',
        status: 'active',
        createdAt: DateTime.utc(2026, 9, 8),
      ));

      final updated = await service.updateCollaboratorPermission(
        shareId: 's2',
        newPermissionLevel: 'admin',
      );

      expect(updated, isNull);
    });

    test('المحرر لا يستطيع سحب مشاركة شخص آخر', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'collab-1'
        ..currentEmail = 'collab@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      cloud.shares['project|proj-1|collab@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-1',
        'collaborator_email': 'collab@x.com',
        'permission_level': 'editor',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };
      cloud.shares['project|proj-1|other@x.com'] = {
        'id': 's2',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-2',
        'collaborator_email': 'other@x.com',
        'permission_level': 'viewer',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };
      await service.repository.upsertShare(EntityShareModel(
        id: 's2',
        entityType: 'project',
        entityId: 'proj-1',
        ownerId: 'owner-1',
        collaboratorId: 'collab-2',
        collaboratorEmail: 'other@x.com',
        permissionLevel: 'viewer',
        status: 'active',
        createdAt: DateTime.utc(2026, 9, 8),
      ));

      final ok = await service.revokeShare(shareId: 's2');

      expect(ok, isFalse);
    });
  });

  // ─── UniversalShareDialog: قفل الواجهة ──────────────────────────────────
  group('UniversalShareDialog - Admin-Only Lock', () {
    testWidgets('يعرض شاشة القفل للمشاهد ويمنع حقل الدعوة والأزرار', (tester) async {
      final cloud = _FakeCloud()
        ..currentUser = 'collab-1'
        ..currentEmail = 'collab@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );
      final controller = CollaborationController(service: service);

      // المستخدم الحالي مشاهد على المشروع
      cloud.shares['project|proj-1|collab@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'collab-1',
        'collaborator_email': 'collab@x.com',
        'permission_level': 'viewer',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };

      await tester.runAsync(() async {
        await controller.loadEntityShares(entityType: 'project', entityId: 'proj-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalShareDialog(
              entityType: 'project',
              entityId: 'proj-1',
              entityTitle: 'مشروعي',
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // وجود شاشة القفل
      expect(find.textContaining('صلاحيتك الحالية'), findsOneWidget);
      expect(find.textContaining('متاحة فقط للمالك'), findsOneWidget);

      // حقل البريد معطّل
      final emailField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'الدعوة غير متاحة لصلاحيتك'),
      );
      expect(emailField.enabled, isFalse);

      // زر الدعوة معطّل
      final inviteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'دعوة'),
      );
      expect(inviteButton.onPressed, isNull);

      // لا يوجد زر حذف (سحب) في صفوف الأعضاء
      expect(find.byIcon(Icons.delete_outline), findsNothing);

      controller.dispose();
    });

    testWidgets('يعرض الواجهة بشكل طبيعي للمسؤول مع أزرار تفاعلية', (tester) async {
      final cloud = _FakeCloud()
        ..currentUser = 'admin-1'
        ..currentEmail = 'admin@x.com';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );
      final controller = CollaborationController(service: service);

      // المستخدم الحالي مسؤول على المشروع
      cloud.shares['project|proj-1|admin@x.com'] = {
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'proj-1',
        'owner_id': 'owner-1',
        'collaborator_id': 'admin-1',
        'collaborator_email': 'admin@x.com',
        'permission_level': 'admin',
        'status': 'active',
        'created_at': DateTime.utc(2026, 9, 8).toIso8601String(),
      };

      await tester.runAsync(() async {
        await controller.loadEntityShares(entityType: 'project', entityId: 'proj-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalShareDialog(
              entityType: 'project',
              entityId: 'proj-1',
              entityTitle: 'مشروعي',
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // لا يوجد شاشة قفل
      expect(find.textContaining('صلاحيتك الحالية'), findsNothing);

      // حقل البريد مفعّل
      final emailField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'user@example.com'),
      );
      expect(emailField.enabled, isTrue);

      // زر الدعوة مفعّل
      final inviteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'دعوة'),
      );
      expect(inviteButton.onPressed, isNotNull);

      controller.dispose();
    });
  });
}

CollaborationRepositoryImpl repositoryOf(CollaborationService service) =>
    service.repository as CollaborationRepositoryImpl;