import '../../features/collaboration/data/models/entity_share_model.dart';

/// قيم الصلاحية المستخدمة في السياق الحالي.
class GuardPermission {
  static const String owner = 'owner';
  static const String admin = 'admin';
  static const String editor = 'editor';
  static const String viewer = 'viewer';
  static const String none = 'none';
}

/// حارس الصلاحيات (Permission Guard).
///
/// يوفر فحصاً فورياً ومتزامناً قبل أي إجراء (تعديل/حذف) على الكيانات.
/// يعتمد على خريطة داخلية تُغذّى من سجلات [EntityShareModel] المحلية.
class PermissionGuardService {
  String? _currentUserId;
  String? _currentUserEmail;

  /// معرف -> صلاحية ('owner' | 'editor' | 'admin' | 'viewer').
  final Map<String, String> _permissionsByEntity = {};

  PermissionGuardService();

  String get currentUserId => _currentUserId ?? '';

  void setCurrentUser({
    String? id,
    String? email,
  }) {
    _currentUserId = id;
    _currentUserEmail = email;
  }

  /// تعبئة الخريطة من سجلات المشاركات المحلية.
  void loadShares(List<EntityShareModel> shares) {
    _permissionsByEntity.clear();
    for (final share in shares) {
      final permission = resolvePermissionForUser(share);
      if (permission == GuardPermission.owner) {
        // المالك يحتفظ بحقوقه الكاملة مهما كانت حالة السجل.
        _permissionsByEntity[share.entityId] = GuardPermission.owner;
      } else if (permission != GuardPermission.none && share.isActive) {
        _permissionsByEntity[share.entityId] = permission;
      } else if (permission != GuardPermission.none) {
        // دعوة معلقة أو ملغاة تتعلق بهذا المستخدم => لا صلاحيات.
        _permissionsByEntity[share.entityId] = GuardPermission.none;
      }
    }
  }

  String resolvePermissionForUser(EntityShareModel share) {
    final myId = _currentUserId;
    final myEmail = _currentUserEmail;
    final ownerId = share.ownerId;
    final collaboratorId = share.collaboratorId;
    final collaboratorEmail = share.collaboratorEmail;
    if (ownerId != null && myId != null && ownerId == myId) {
      return GuardPermission.owner;
    }
    if (collaboratorId != null && myId != null && collaboratorId == myId) {
      return share.permissionLevel;
    }
    if (collaboratorEmail != null &&
        myEmail != null &&
        collaboratorEmail.toLowerCase() == myEmail.toLowerCase()) {
      return share.permissionLevel;
    }
    return GuardPermission.none;
  }

  /// صلاحية المستخدم لكيان: owner/editor/admin/viewer/none.
  ///
  /// الكيان غير الموجود في الخريطة يُفحص إن كان له كيان أب (parentEntityId)
  /// ليرث صلاحيته، وإلا يُعامل كملكية للمستخدم الحالي (owner).
  String getPermission({
    required String entityId,
    String? parentEntityId,
    String? currentUserId,
  }) {
    final permission = _permissionsByEntity[entityId];
    if (permission != null) return permission;

    if (parentEntityId != null) {
      final parentPerm = _permissionsByEntity[parentEntityId];
      if (parentPerm != null) return parentPerm;
    }

    return GuardPermission.owner;
  }

  bool canEdit({
    required String entityId,
    String? parentEntityId,
    String? currentUserId,
  }) {
    final p = getPermission(
      entityId: entityId,
      parentEntityId: parentEntityId,
      currentUserId: currentUserId,
    );
    return p == GuardPermission.owner ||
        p == GuardPermission.editor ||
        p == GuardPermission.admin;
  }

  bool canDelete({
    required String entityId,
    String? parentEntityId,
    String? currentUserId,
  }) {
    final p = getPermission(
      entityId: entityId,
      parentEntityId: parentEntityId,
      currentUserId: currentUserId,
    );
    return p == GuardPermission.owner || p == GuardPermission.admin;
  }

  bool isOwner({
    required String entityId,
    String? parentEntityId,
    String? currentUserId,
  }) {
    return getPermission(
          entityId: entityId,
          parentEntityId: parentEntityId,
          currentUserId: currentUserId,
        ) ==
        GuardPermission.owner;
  }

  /// صلاحية المستخدم مع توريث وراثي من قائمة أجداد مرتبة (مثال: مهمة ← مشروع ← مجال).
  ///
  /// الأولوية لسجل الكيان نفسه، ثم أجداده بالترتيب، ثم افتراض "مالك" إذا لم
  /// يُعثر على أي سجل (الكيان غير مشترك يعني أنه ملك للمستخدم الحالي).
  String getPermissionInherited({
    required String entityId,
    List<String> ancestorEntityIds = const [],
  }) {
    final direct = _permissionsByEntity[entityId];
    if (direct != null) return direct;
    for (final ancestorId in ancestorEntityIds) {
      final parentPerm = _permissionsByEntity[ancestorId];
      if (parentPerm != null) return parentPerm;
    }
    return GuardPermission.owner;
  }

  /// هل يستطيع المستخدم إدارة المشاركات (دعوة / تعديل صلاحية / سحب)؟
  ///
  /// متاح للمالك الأصلي والمسؤول (Admin) فقط، مع دعم التوريث من الأجداد.
  bool canManageInherited({
    required String entityId,
    List<String> ancestorEntityIds = const [],
  }) {
    final p = getPermissionInherited(
      entityId: entityId,
      ancestorEntityIds: ancestorEntityIds,
    );
    return p == GuardPermission.owner || p == GuardPermission.admin;
  }
}