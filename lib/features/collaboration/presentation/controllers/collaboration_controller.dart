import 'package:flutter/foundation.dart';

import '../../../../core/services/collaboration_service.dart';
import '../../../../core/services/permission_guard_service.dart';
import '../../data/models/entity_share_model.dart';

/// متحكم التعاون: إدارة الدعوات والصلاحيات والكيانات المشتركة مع المستخدم.
///
/// مسؤولية منطقية فقط (لا يحتوي أي واجهة)، يوفر حالة قابلة للمشاهدة
/// للواجهات عبر ChangeNotifier.
class CollaborationController extends ChangeNotifier {
  CollaborationController({CollaborationService? service})
      : _service = service ?? CollaborationService.instance();

  final CollaborationService _service;
  final PermissionGuardService _guard = PermissionGuardService();

  List<EntityShareModel> _shares = <EntityShareModel>[];
  List<Map<String, dynamic>> _sharedWithMe = <Map<String, dynamic>>[];
  bool _isLoading = false;
  String? _errorMessage;

  /// صلاحيات الكيانات محللة محلياً.
  PermissionGuardService get guard => _guard;

  List<EntityShareModel> get shares => List.unmodifiable(_shares);

  /// الكيانات التي شاركها الآخرون مع المستخدم الحالي.
  List<Map<String, dynamic>> get sharedWithMe => List.unmodifiable(_sharedWithMe);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// جلب مشاركات كيان من السحابة (مع كاش محلي عند انقطاع الشبكة).
  ///
  /// [parentEntityIds] قائمة معرّفات الأجداد (مشروع/مجال) تُحمَّل مشاركاتها
  /// في الحارس الداخلي دون عرضها في قائمة الأعضاء، لتمكين فحوصات الإدارة
  /// والوراثة الدقيقة (مهمة ← مشروع ← مجال).
  Future<void> loadEntityShares({
    required String entityType,
    required String entityId,
    List<String> parentEntityIds = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _shares = await _service.getEntityShares(
        entityType: entityType,
        entityId: entityId,
      );
      _guard.setCurrentUser(
        id: await _service.currentUserId,
        email: await _service.currentUserEmail,
      );
      // جلب مشاركات الأجداد لتغذية وراثة الحارس فقط
      final allShares = <EntityShareModel>[..._shares];
      for (final parentId in parentEntityIds) {
        final parentType = entityType == 'task' ? 'project' : 'area';
        try {
          allShares.addAll(await _service.getEntityShares(
            entityType: parentType,
            entityId: parentId,
          ));
        } catch (e) {
          debugPrint('[CollaborationController] load parent shares ($parentId): $e');
        }
      }
      _guard.loadShares(allShares);
    } catch (e) {
      _errorMessage = 'تعذر تحميل المشاركات';
      debugPrint('[CollaborationController] loadEntityShares: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// دعوة متعاون جديد بالبريد مع صلاحية.
  Future<bool> invite({
    required String entityType,
    required String entityId,
    required String email,
    String permissionLevel = 'viewer',
  }) async {
    _errorMessage = null;
    final share = await _service.inviteCollaborator(
      entityType: entityType,
      entityId: entityId,
      email: email,
      permissionLevel: permissionLevel,
    );
    if (share == null) {
      _errorMessage = 'تعذر إرسال الدعوة';
      notifyListeners();
      return false;
    }
    await loadEntityShares(entityType: entityType, entityId: entityId);
    return true;
  }

  /// تعديل صلاحية متعاون.
  Future<bool> updatePermission({
    required String shareId,
    required String newPermissionLevel,
  }) async {
    _errorMessage = null;
    final updated = await _service.updateCollaboratorPermission(
      shareId: shareId,
      newPermissionLevel: newPermissionLevel,
    );
    if (updated == null) {
      _errorMessage = 'تعذر تحديث الصلاحية';
      notifyListeners();
      return false;
    }
    final index = _shares.indexWhere((s) => s.id == shareId);
    if (index != -1) _shares[index] = updated;
    _guard.loadShares(_shares);
    notifyListeners();
    return true;
  }

  /// سحب مشاركة المتعاون.
  Future<bool> revoke({required String shareId}) async {
    _errorMessage = null;
    final ok = await _service.revokeShare(shareId: shareId);
    if (!ok) {
      _errorMessage = 'تعذر إبطال المشاركة';
    } else {
      _shares = _shares.where((s) => s.id != shareId).toList();
      _guard.loadShares(_shares);
    }
    notifyListeners();
    return ok;
  }

  /// جلب كل الكيانات المشتركة مع المستخدم من الآخرين.
  Future<void> loadSharedWithMe() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _sharedWithMe = await _service.fetchSharedWithMe();
      _guard.setCurrentUser(
        id: await _service.currentUserId,
        email: await _service.currentUserEmail,
      );
    } catch (e) {
      _errorMessage = 'تعذر جلب الكيانات المشتركة';
      debugPrint('[CollaborationController] loadSharedWithMe: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// فحص فوري قبل التعديل مع دعم الوراثة من الكيان الأب (مجال أو مشروع).
  bool canEdit(String entityId, {String? parentEntityId}) =>
      _guard.canEdit(entityId: entityId, parentEntityId: parentEntityId);

  /// فحص فوري قبل الحذف مع دعم الوراثة من الكيان الأب (مجال أو مشروع).
  bool canDelete(String entityId, {String? parentEntityId}) =>
      _guard.canDelete(entityId: entityId, parentEntityId: parentEntityId);

  bool isOwner(String entityId, {String? parentEntityId}) =>
      _guard.isOwner(entityId: entityId, parentEntityId: parentEntityId);

  /// هل يمكن للمستخدم الحالي إدارة المشاركات: الدعوة/تعديل الصلاحية/السحب؟
  ///
  /// متاح للمالك الأصلي والمسؤول (Admin) فقط، مع وراثة من الأجداد
  /// ([ancestorEntityIds] مثال: مهمة ← مشروع ← مجال).
  bool canManage(String entityId, {List<String> ancestorEntityIds = const []}) =>
      _guard.canManageInherited(
        entityId: entityId,
        ancestorEntityIds: ancestorEntityIds,
      );
}