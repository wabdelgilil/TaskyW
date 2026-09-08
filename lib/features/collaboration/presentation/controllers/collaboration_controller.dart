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
  Future<void> loadEntityShares({
    required String entityType,
    required String entityId,
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
      _guard.loadShares(_shares);
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

  /// فحص فوري قبل التعديل.
  bool canEdit(String entityId) => _guard.canEdit(entityId: entityId);

  /// فحص فوري قبل الحذف.
  bool canDelete(String entityId) => _guard.canDelete(entityId: entityId);

  bool isOwner(String entityId) => _guard.isOwner(entityId: entityId);
}