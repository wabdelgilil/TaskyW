/// صلاحيات المتعاون على الكيان المشترك.
enum CollaborationPermission {
  viewer('viewer'),
  editor('editor'),
  admin('admin');

  final String value;
  const CollaborationPermission(this.value);

  static CollaborationPermission? fromValue(String? value) {
    for (final p in CollaborationPermission.values) {
      if (p.value == value) return p;
    }
    return null;
  }
}

/// حالة المشاركة في دورة حياة الدعوة.
enum CollaborationShareStatus {
  pending('pending'),
  active('active'),
  revoked('revoked');

  final String value;
  const CollaborationShareStatus(this.value);

  static CollaborationShareStatus? fromValue(String? value) {
    for (final s in CollaborationShareStatus.values) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// نموذج مشاركة كيان (مجال / مشروع / مهمة) مع شخص آخر عبر البريد.
///
/// يطابق جدول `entity_shares` في السحابة ويُستخدم محلياً في وضع Offline-First.
class EntityShareModel {
  final String id;
  final String entityType; // 'area' | 'project' | 'task'
  final String entityId;
  final String? ownerId;
  final String? collaboratorId;
  final String? collaboratorEmail;
  final String permissionLevel; // 'viewer' | 'editor' | 'admin'
  final String status; // 'pending' | 'active' | 'revoked'
  final String syncStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  EntityShareModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.ownerId,
    this.collaboratorId,
    this.collaboratorEmail,
    this.permissionLevel = 'viewer',
    this.status = 'pending',
    this.syncStatus = 'synced',
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isActive => status == CollaborationShareStatus.active.value;

  bool get canEdit =>
      isActive &&
      (permissionLevel == CollaborationPermission.editor.value ||
          permissionLevel == CollaborationPermission.admin.value);

  bool get canDelete =>
      isActive && permissionLevel == CollaborationPermission.admin.value;

  factory EntityShareModel.fromMap(Map<String, dynamic> map) =>
      EntityShareModel(
        id: map['id'] as String,
        entityType: map['entity_type'] as String? ?? 'task',
        entityId: map['entity_id'] as String,
        ownerId: map['owner_id'] as String?,
        collaboratorId: map['collaborator_id'] as String?,
        collaboratorEmail: map['collaborator_email'] as String?,
        permissionLevel: map['permission_level'] as String? ?? 'viewer',
        status: map['status'] as String? ?? 'pending',
        syncStatus: map['sync_status'] as String? ?? 'synced',
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
        deletedAt: map['deleted_at'] != null
            ? DateTime.parse(map['deleted_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'entity_type': entityType,
    'entity_id': entityId,
    'owner_id': ownerId,
    'collaborator_id': collaboratorId,
    'collaborator_email': collaboratorEmail,
    'permission_level': permissionLevel,
    'status': status,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  EntityShareModel copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? ownerId,
    String? collaboratorId,
    String? collaboratorEmail,
    String? permissionLevel,
    String? status,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => EntityShareModel(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    ownerId: ownerId ?? this.ownerId,
    collaboratorId: collaboratorId ?? this.collaboratorId,
    collaboratorEmail: collaboratorEmail ?? this.collaboratorEmail,
    permissionLevel: permissionLevel ?? this.permissionLevel,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityShareModel &&
          id == other.id &&
          entityType == other.entityType &&
          entityId == other.entityId &&
          ownerId == other.ownerId &&
          collaboratorId == other.collaboratorId &&
          collaboratorEmail == other.collaboratorEmail &&
          permissionLevel == other.permissionLevel &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    ownerId,
    collaboratorId,
    collaboratorEmail,
    permissionLevel,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  );
}