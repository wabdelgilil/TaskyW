import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/collaboration/data/models/entity_share_model.dart';
import 'package:tasky/core/services/share_read_service.dart';

/// عقد تجريبي يملأ طريقة واحدة بسلوك محدد.
class _FakeSupabase implements SupabaseServiceLike {
  final Map<String, Map<String, dynamic>> entities;
  final Map<String, List<Map<String, dynamic>>> subtasksByToken;
  final Map<String, List<Map<String, dynamic>>> tasksByToken;
  final Map<String, List<Map<String, dynamic>>> projectsByToken;

  _FakeSupabase({
    this.entities = const {},
    this.subtasksByToken = const {},
    this.tasksByToken = const {},
    this.projectsByToken = const {},
  });

  @override
  Future<Map<String, dynamic>?> fetchSharedEntity(String shareToken) async {
    return entities[shareToken];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedSubtasks(
    String shareToken,
  ) async {
    return subtasksByToken[shareToken] ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedTasks(
    String shareToken,
  ) async {
    return tasksByToken[shareToken] ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedProjects(
    String shareToken,
  ) async {
    return projectsByToken[shareToken] ?? [];
  }
}

void main() {
  group('EntityShareModel', () {
    test('toMap/fromMap round-trip يحافظ على الحقول', () {
      final share = EntityShareModel(
        id: 'share-1',
        entityType: 'task',
        entityId: 'task-1',
        collaboratorEmail: 'collab@example.com',
        permissionLevel: 'editor',
        status: 'active',
        syncStatus: 'synced',
        createdAt: DateTime.utc(2026, 9, 8),
        updatedAt: DateTime.utc(2026, 9, 8, 10),
      );
      final map = share.toMap();
      final restored = EntityShareModel.fromMap(map);
      expect(restored.id, 'share-1');
      expect(restored.entityType, 'task');
      expect(restored.role, 'editor');
      expect(restored.permissionLevel, 'editor');
      expect(restored.collaboratorEmail, 'collab@example.com');
      expect(restored.isActive, isTrue);
    });

    test('fromMap يدعم مفتاح permission كاسم الدور', () {
      final share = EntityShareModel.fromMap({
        'id': 's1',
        'entity_type': 'project',
        'entity_id': 'p1',
        'permission': 'admin',
        'status': 'active',
        'created_at': '2026-09-08T00:00:00.000Z',
      });
      expect(share.role, 'admin');
      expect(share.canEdit, isTrue);
      expect(share.canDelete, isTrue);
    });

    test('الصلاحيات: viewer لا يعدّل، editor يعدّل بلا حذف، admin كامل', () {
      final viewer = EntityShareModel(
        id: 'a',
        entityType: 'task',
        entityId: 't',
        status: 'active',
        permissionLevel: 'viewer',
        createdAt: DateTime.utc(2026),
      );
      final editor = EntityShareModel(
        id: 'b',
        entityType: 'task',
        entityId: 't',
        status: 'active',
        permissionLevel: 'editor',
        createdAt: DateTime.utc(2026),
      );
      final admin = EntityShareModel(
        id: 'c',
        entityType: 'task',
        entityId: 't',
        status: 'active',
        permissionLevel: 'admin',
        createdAt: DateTime.utc(2026),
      );
      expect(viewer.canEdit, isFalse);
      expect(editor.canEdit, isTrue);
      expect(editor.canDelete, isFalse);
      expect(admin.canDelete, isTrue);
    });

    test('غير النشط (pending/revoked) لا يملك صلاحية التعديل أو الحذف', () {
      final pendingAdmin = EntityShareModel(
        id: 'p-adm',
        entityType: 'task',
        entityId: 't',
        status: 'pending',
        permissionLevel: 'admin',
        createdAt: DateTime.utc(2026),
      );
      expect(pendingAdmin.isActive, isFalse);
      expect(pendingAdmin.canEdit, isFalse);
      expect(pendingAdmin.canDelete, isFalse);
    });
  });

  group('ShareReadService', () {
    const taskRow = {
      'id': 'task-x',
      'title': 'مهمة عامة',
      'status': 'todo',
      'priority': 'high',
      'due_date': '2026-09-08T00:00:00.000Z',
      'reminder_time': null,
      'deleted_at': null,
    };
    const projectRow = {
      'id': 'project-y',
      'name': 'مشروع عام',
      'target_date': '2026-12-31T00:00:00.000Z',
      'deleted_at': null,
    };
    const areaRow = {
      'id': 'area-z',
      'name': 'مجال عام',
      'deleted_at': null,
    };

    test('رمز فارغ يعيد null دون اتصال', () async {
      final service = ShareReadService(supabase: _FakeSupabase());
      expect(await service.fetchPublicEntityByToken('   '), isNull);
      expect(await service.fetchPublicTaskWithSubtasks(''), isNull);
    });

    test('رمز غير موجود يعيد null', () async {
      final service = ShareReadService(supabase: _FakeSupabase());
      expect(await service.fetchPublicEntityByToken('missing-token'), isNull);
    });

    test('مهمة عامة تعيد المهمة مع مهامها الفرعية', () async {
      final fake = _FakeSupabase(
        entities: {'tok-task': Map.of(taskRow)},
        subtasksByToken: {
          'tok-task': [
            {'id': 'sub-1', 'task_id': 'task-x', 'title': 'خطوة أولى'},
          ],
        },
      );
      final service = ShareReadService(supabase: fake);
      final result = await service.fetchPublicEntityByToken('tok-task');

      expect(result, isNotNull);
      expect(result!.isTask, isTrue);
      expect(result.entity['id'], 'task-x');
      expect(result.children, hasLength(1));
    });

    test('مشروع عام يعيد المشروع مع مهامه', () async {
      final fake = _FakeSupabase(
        entities: {'tok-project': Map.of(projectRow)},
        tasksByToken: {
          'tok-project': [
            {'id': 'task-p1', 'project_id': 'project-y', 'title': 'مهمة المشروع'},
          ],
        },
      );
      final service = ShareReadService(supabase: fake);
      final result = await service.fetchPublicEntityByToken('tok-project');

      expect(result!.isProject, isTrue);
      expect(result.children, hasLength(1));
    });

    test('مجال عام يعيد المجال مع مشاريعه', () async {
      final fake = _FakeSupabase(
        entities: {'tok-area': Map.of(areaRow)},
        projectsByToken: {
          'tok-area': [
            {'id': 'project-a1', 'area_id': 'area-z', 'name': 'مشروع المجال'},
          ],
        },
      );
      final service = ShareReadService(supabase: fake);
      final result = await service.fetchPublicEntityByToken('tok-area');

      expect(result!.isArea, isTrue);
      expect(result.children, hasLength(1));
    });

    test('fetchPublicTaskWithSubtasks يعيد null لمشاركة مشروع', () async {
      final fake = _FakeSupabase(
        entities: {'tok-project': Map.of(projectRow)},
        tasksByToken: {'tok-project': []},
      );
      final service = ShareReadService(supabase: fake);
      expect(await service.fetchPublicTaskWithSubtasks('tok-project'), isNull);
    });

    test('خطأ في جلب المهام الفرعية لا يمنع إرجاع المهمة', () async {
      final errorSupabase = _ThrowingUntasksSupabase(taskRow);
      final service = ShareReadService(supabase: errorSupabase);
      final result = await service.fetchPublicEntityByToken('tok-task');
      expect(result, isNotNull);
      expect(result!.isTask, isTrue);
      expect(result.children, isEmpty);
    });
  });
}

class _ThrowingUntasksSupabase implements SupabaseServiceLike {
  final Map<String, dynamic> taskRow;
  _ThrowingUntasksSupabase(this.taskRow);

  @override
  Future<Map<String, dynamic>?> fetchSharedEntity(String shareToken) async {
    if (shareToken == 'tok-task') return Map.of(taskRow);
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedSubtasks(
    String shareToken,
  ) async {
    throw Exception('network down');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedTasks(
    String shareToken,
  ) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSharedProjects(
    String shareToken,
  ) async {
    return [];
  }
}