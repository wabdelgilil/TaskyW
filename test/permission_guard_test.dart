import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/permission_guard_service.dart';
import 'package:tasky/features/collaboration/data/models/entity_share_model.dart';

EntityShareModel _share({
  required String id,
  required String entityId,
  String? ownerId,
  String? collaboratorId,
  String? email,
  String permissionLevel = 'viewer',
  String status = 'active',
}) => EntityShareModel(
  id: id,
  entityType: 'task',
  entityId: entityId,
  ownerId: ownerId,
  collaboratorId: collaboratorId,
  collaboratorEmail: email,
  permissionLevel: permissionLevel,
  status: status,
  createdAt: DateTime.utc(2026, 9, 8),
);

void main() {
  const userId = 'user-1';
  const otherUser = 'user-2';
  const email = 'collab@gmail.com';

  PermissionGuardService build() {
    final guard = PermissionGuardService();
    guard.setCurrentUser(id: userId, email: email);
    return guard;
  }

  group('PermissionGuardService', () {
    test('الكيان غير المشترك يعامل كملكية للمستخدم الحالي', () {
      final guard = build();
      expect(guard.getPermission(entityId: 'task-x'), GuardPermission.owner);
      expect(guard.isOwner(entityId: 'task-x'), isTrue);
      expect(guard.canEdit(entityId: 'task-x'), isTrue);
      expect(guard.canDelete(entityId: 'task-x'), isTrue);
    });

    test('loadShares يصنف المالك أولاً ثم المتعاون بالمعرّف', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's1',
          entityId: 'task-1',
          ownerId: userId,
          collaboratorId: otherUser,
          permissionLevel: 'viewer',
        ),
      ]);
      expect(guard.getPermission(entityId: 'task-1'), GuardPermission.owner);
      expect(guard.canEdit(entityId: 'task-1'), isTrue);
      expect(guard.canDelete(entityId: 'task-1'), isTrue);
    });

    test('viewer يقرأ فقط ولا يعدل ولا يحذف', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's1',
          entityId: 'task-1',
          ownerId: otherUser,
          collaboratorId: userId,
          permissionLevel: 'viewer',
        ),
      ]);
      expect(guard.getPermission(entityId: 'task-1'), 'viewer');
      expect(guard.canEdit(entityId: 'task-1'), isFalse);
      expect(guard.canDelete(entityId: 'task-1'), isFalse);
    });

    test('editor يعدل ولا يحذف', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's1',
          entityId: 'task-1',
          ownerId: otherUser,
          collaboratorId: userId,
          permissionLevel: 'editor',
        ),
      ]);
      expect(guard.canEdit(entityId: 'task-1'), isTrue);
      expect(guard.canDelete(entityId: 'task-1'), isFalse);
    });

    test('admin يعدل ويحذف', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's1',
          entityId: 'task-1',
          ownerId: otherUser,
          collaboratorId: userId,
          permissionLevel: 'admin',
        ),
      ]);
      expect(guard.canEdit(entityId: 'task-1'), isTrue);
      expect(guard.canDelete(entityId: 'task-1'), isTrue);
    });

    test('متعاون بالبريد يتم التعرف عليه عند غياب المعرّف', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's1',
          entityId: 'task-1',
          ownerId: otherUser,
          email: email,
          permissionLevel: 'admin',
        ),
      ]);
      expect(guard.getPermission(entityId: 'task-1'), 'admin');
      expect(guard.canDelete(entityId: 'task-1'), isTrue);
    });

    test('المشاركات المعلقة أو الملغاة لا تمنح صلاحيات', () {
      final guard = build();
      guard.loadShares([
        _share(
          id: 's-pending',
          entityId: 'task-1',
          ownerId: otherUser,
          collaboratorId: userId,
          permissionLevel: 'admin',
          status: 'pending',
        ),
        _share(
          id: 's-revoked',
          entityId: 'task-2',
          ownerId: otherUser,
          collaboratorId: userId,
          permissionLevel: 'admin',
          status: 'revoked',
        ),
      ]);
      expect(guard.getPermission(entityId: 'task-1'), 'none');
      expect(guard.getPermission(entityId: 'task-2'), 'none');
      expect(guard.canEdit(entityId: 'task-1'), isFalse);
      expect(guard.canDelete(entityId: 'task-2'), isFalse);
    });

    test('resolvePermissionForUser يعيد none لأي مستخدم آخر', () {
      final guard = build();
      final share = _share(
        id: 's1',
        entityId: 'task-1',
        ownerId: otherUser,
        collaboratorId: otherUser,
        permissionLevel: 'admin',
      );
      expect(guard.resolvePermissionForUser(share), GuardPermission.none);
    });
  });
}