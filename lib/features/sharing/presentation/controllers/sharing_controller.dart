import 'package:flutter/foundation.dart';

import '../../../../core/models/entity_share_model.dart';
import '../../../../core/services/sharing_service.dart';

/// إدارة المشاركة والتعاون للكيانات (مجالات / مشاريع / مهام).
///
/// تجمع بين الرابط العام للمشاركة والدعوات بالبريد الإلكتروني،
/// مع الحفاظ على حالة المشاركات المحملة للكيان الحالي.
class SharingController extends ChangeNotifier {
  SharingController({SharingService? service})
      : _service = service ?? SharingService.instance;

  final SharingService _service;
  List<ShareModel> _shares = <ShareModel>[];
  String? _publicLink;
  bool _isLoading = false;
  String? _errorMessage;

  List<ShareModel> get shares => List.unmodifiable(_shares);
  String? get publicLink => _publicLink;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// هل توجد حصة عامة نشطة عرضاً؟
  bool get hasPublicLink => _publicLink != null;

  /// جلب جميع مشاركات كيان (رابط عام وأعضاء).
  Future<void> loadShares({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _shares = await _service.getSharesForEntity(
        entityType: entityType,
        entityId: entityId,
      );
      final public = _shares.firstWhere(
        (s) => s.isPublic,
        orElse: () => ShareModel(
          id: '',
          entityType: entityType,
          entityId: entityId,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      _publicLink = public.isPublic ? public.shareToken : null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تفعيل رابط عام جديد وإعادة تحميل الحصص.
  Future<bool> generatePublicLink({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final token = await _service.generatePublicLink(
      entityType: entityType,
      entityId: entityId,
    );
    _isLoading = false;
    if (token == null) {
      _errorMessage = 'تعذر إنشاء الرابط العام';
      notifyListeners();
      return false;
    }
    _publicLink = token;
    await loadShares(entityType: entityType, entityId: entityId);
    notifyListeners();
    return true;
  }

  /// تعطيل الرابط العام.
  Future<bool> revokePublicLink({
    required ShareEntityType entityType,
    required String entityId,
  }) async {
    final ok = await _service.revokePublicLink(
      entityType: entityType,
      entityId: entityId,
    );
    if (ok) _publicLink = null;
    await loadShares(entityType: entityType, entityId: entityId);
    notifyListeners();
    return ok;
  }

  /// دعوة متعاون جديد بالبريد الإلكتروني وصلاحية محددة.
  Future<bool> inviteCollaborator({
    required ShareEntityType entityType,
    required String entityId,
    required String email,
    String role = 'viewer',
  }) async {
    _errorMessage = null;
    final permission = SharePermission.fromValue(role) ?? SharePermission.viewer;
    final share = await _service.inviteCollaborator(
      entityType: entityType,
      entityId: entityId,
      email: email,
      permission: permission,
    );
    if (share == null) {
      _errorMessage = 'تعذر إرسال الدعوة';
      notifyListeners();
      return false;
    }
    await loadShares(entityType: entityType, entityId: entityId);
    return true;
  }

  /// تحديث صلاحية متعاون.
  Future<bool> updatePermission({
    required String shareId,
    required String role,
  }) async {
    _errorMessage = null;
    final permission = SharePermission.fromValue(role);
    if (permission == null) {
      _errorMessage = 'صلاحية غير معروفة';
      notifyListeners();
      return false;
    }
    final ok = await _service.updatePermission(
      shareId: shareId,
      permission: permission,
    );
    if (!ok) _errorMessage = 'تعذر تحديث الصلاحية';
    notifyListeners();
    return ok;
  }

  /// إزالة مشاركة.
  Future<bool> removeShare({required String shareId}) async {
    _errorMessage = null;
    final ok = await _service.removeShare(shareId: shareId);
    if (!ok) _errorMessage = 'تعذر إزالة المشاركة';
    notifyListeners();
    return ok;
  }

  /// تحويل سجل حصة إلى النموذج العام القابل للعرض في الواجهات.
  EntityShareModel toEntityShare(ShareModel share) => EntityShareModel(
    id: share.id,
    entityType: share.entityType.value,
    entityId: share.entityId,
    userId: share.userId,
    email: share.email,
    displayName: share.displayName,
    role: share.permission.value,
    shareToken: share.shareToken,
    isPublic: share.isPublic,
    createdAt: share.createdAt,
    updatedAt: share.updatedAt,
  );
}