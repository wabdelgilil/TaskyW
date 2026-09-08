import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/services/collaboration_service.dart';
import 'package:tasky/features/collaboration/data/models/entity_share_model.dart';
import 'package:tasky/features/collaboration/data/repositories/collaboration_repository.dart';

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
    _requireOnline();
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
    _requireOnline();
    return shares[_k(entityType, entityId, email)];
  }

  void _requireOnline() {
    if (!online) {
      throw StateError('network is offline');
    }
  }

  @override
  Future<Map<String, dynamic>> insertShare(Map<String, dynamic> row) async {
    _requireOnline();
    _seq++;
    final id = row['id'] ?? 'fake-$_seq';
    final insert = Map<String, dynamic>.from(row);
    insert['id'] = id;
    if (autoLinkOnInsert && currentEmail != null && insert['collaborator_email'] == currentEmail) {
      insert['status'] = CollaborationShareStatus.active.value;
      insert['collaborator_id'] = currentUser;
    }
    shares[_k(insert['entity_type'], insert['entity_id'], insert['collaborator_email'] as String)] = insert;
    return Map<String, dynamic>.from(insert);
  }

  @override
  Future<void> updateShare({
    required String shareId,
    required Map<String, dynamic> changes,
  }) async {
    _requireOnline();
    final entry = shares.values.firstWhere((s) => s['id'] == shareId);
    entry.addAll(changes);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedWithMe() async {
    _requireOnline();
    final myEmail = currentEmail?.toLowerCase();
    return shares.values
        .where((s) =>
            s['status'] == 'active' &&
            (currentUser != null && s['collaborator_id'] == currentUser ||
             myEmail != null && s['collaborator_email'] == myEmail))
        .map((s) => Map<String, dynamic>.from(s))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> fetchEntityRow({
    required String entityType,
    required String entityId,
  }) async {
    return entities['$entityType|$entityId'];
  }
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

  group('CollaborationService - دعوة متعاون', () {
    test('inviteCollaborator ينشئ دعوة pending ويخزنها محلياً', () async {
      final cloud = _FakeCloud()..currentUser = 'user-1';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      final share = await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-1',
        email: 'friend@gmail.com',
        permissionLevel: 'editor',
      );

      expect(share, isNotNull);
      expect(share!.status, 'pending');
      expect(share.permissionLevel, 'editor');
      expect(share.ownerId, 'user-1');
      expect(share.collaboratorEmail, 'friend@gmail.com');

      final cached = await service.getEntityShares(
        entityType: 'task',
        entityId: 'task-1',
      );
      expect(cached, hasLength(1));
      expect(cached.first.permissionLevel, 'editor');
    });

    test('invite لتاريخ متكرر يستبدل الصلاحية بدل الدفع', () async {
      final cloud = _FakeCloud()..currentUser = 'user-1';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-1',
        email: 'friend@gmail.com',
        permissionLevel: 'viewer',
      );
      final updated = await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-1',
        email: 'friend@gmail.com',
        permissionLevel: 'admin',
      );

      expect(updated, isNotNull);
      expect(updated!.permissionLevel, 'admin');
      expect(cloud.shares, hasLength(1));
    });

    test('updateCollaboratorPermission يحدّث السحابة والمحلي', () async {
      final cloud = _FakeCloud()..currentUser = 'user-1';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      final invited = await service.inviteCollaborator(
        entityType: 'project',
        entityId: 'proj-1',
        email: 'e@gmail.com',
        permissionLevel: 'viewer',
      );

      final updated = await service.updateCollaboratorPermission(
        shareId: invited!.id,
        newPermissionLevel: 'editor',
      );

      expect(updated, isNotNull);
      expect(updated!.permissionLevel, 'editor');
      expect(cloud.shares.values.first['permission_level'], 'editor');

      final local = await service.getEntityShares(
        entityType: 'project',
        entityId: 'proj-1',
      );
      expect(local.first.permissionLevel, 'editor');
    });

    test('revokeShare يبطل المشاركة في السحابة والمحلي', () async {
      final cloud = _FakeCloud()..currentUser = 'user-1';
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      final invited = await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-1',
        email: 'e@gmail.com',
        permissionLevel: 'admin',
      );

      final ok = await service.revokeShare(shareId: invited!.id);

      expect(ok, isTrue);
      expect(cloud.shares.values.first['status'], 'revoked');
      final local = await repositoryOf(service).getEntityShares(
        entityType: 'task',
        entityId: 'task-1',
      );
      expect(local, isEmpty); // محذوف محلياً.
    });
  });

  group('CollaborationService - Offline-First', () {
    test('عند انقطاع الشبكة تُرتجع النسخة المحلية المخزنة', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'user-1'
        ..autoLinkOnInsert = true;
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-1',
        email: 'me@gmail.com',
        permissionLevel: 'admin',
      );
      cloud.currentEmail = 'me@gmail.com';

      // افصل الشبكة.
      cloud.online = false;

      final cached = await service.getEntityShares(
        entityType: 'task',
        entityId: 'task-1',
      );
      expect(cached, isNotEmpty);
      expect(cached.first.permissionLevel, 'admin');
    });

    test('fetchSharedWithMe محلياً يعتمد على السجل المخزن دون اتصال', () async {
      final cloud = _FakeCloud()
        ..currentUser = 'user-1'
        ..currentEmail = 'me@gmail.com'
        ..autoLinkOnInsert = true;
      final service = CollaborationService(
        cloud: cloud,
        repository: CollaborationRepositoryImpl(),
      );

      await service.inviteCollaborator(
        entityType: 'task',
        entityId: 'task-shared',
        email: 'me@gmail.com',
        permissionLevel: 'viewer',
      );

      // ذاكرة السحابة فارغة: لا كيانات في fake.
      cloud.entities['task|task-shared'] = {
        'id': 'task-shared',
        'title': 'مهمتي المشتركة',
      };

      final withMe = await service.fetchSharedWithMe();

      expect(withMe, isNotEmpty);
      final first = withMe.first;
      expect(first['title'], 'مهمتي المشتركة');
      expect(first['_permission_level'], 'viewer');
    });
  });

  group('CollaborationRepository', () {
    test('getUserPermission يميز المالك والمتعاون النشط', () async {
      final repo = CollaborationRepositoryImpl();
      await repo.upsertShare(
        EntityShareModel(
          id: 's1',
          entityType: 'task',
          entityId: 'task-1',
          ownerId: 'owner-1',
          collaboratorId: 'collab-1',
          collaboratorEmail: 'collab@gmail.com',
          permissionLevel: 'editor',
          status: 'active',
          createdAt: DateTime.utc(2026, 9, 8),
        ),
      );

      expect(
        await repo.getUserPermission(entityId: 'task-1', currentUserId: 'owner-1'),
        'owner',
      );
      expect(
        await repo.getUserPermission(entityId: 'task-1', currentUserId: 'collab-1'),
        'editor',
      );
      // غريب لا يملك ولا مشترك => تعامل كمالك محلي (افتراضي Offline-First).
      expect(
        await repo.getUserPermission(entityId: 'task-1', currentUserId: 'stranger-9'),
        'owner',
      );
    });

    test('upsertتعيد استبدال نفس المعرف', () async {
      final repo = CollaborationRepositoryImpl();
      await repo.upsertShares([
        _sampleShare(id: 's1', entityId: 'task-1', status: 'pending'),
        _sampleShare(id: 's1', entityId: 'task-1', status: 'active'),
      ]);
      final rows = await repo.getEntityShares(entityType: 'task', entityId: 'task-1');
      expect(rows, hasLength(1));
      expect(rows.first.status, 'active');
    });
  });
}

CollaborationRepositoryImpl repositoryOf(CollaborationService service) =>
    service.repository as CollaborationRepositoryImpl;

EntityShareModel _sampleShare({
  required String id,
  required String entityId,
  required String status,
}) => EntityShareModel(
  id: id,
  entityType: 'task',
  entityId: entityId,
  collaboratorEmail: 'x@gmail.com',
  permissionLevel: 'viewer',
  status: status,
  createdAt: DateTime.utc(2026, 9, 8),
);