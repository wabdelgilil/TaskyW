/// سجل مشاركة كيان (مجال / مشروع / مهمة) — مطابق لجدول السحابة `entity_shares`.
class EntityShareModel {
  final String id;
  final String entityType; // 'area' | 'project' | 'task'
  final String entityId;
  final String? userId;
  final String? email;
  final String? displayName;
  final String role; // 'viewer' | 'editor' | 'admin'
  final String? shareToken;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EntityShareModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.userId,
    this.email,
    this.displayName,
    this.role = 'viewer',
    this.shareToken,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory EntityShareModel.fromMap(Map<String, dynamic> map) => EntityShareModel(
    id: map['id'] as String,
    entityType: map['entity_type'] as String? ?? 'task',
    entityId: map['entity_id'] as String,
    userId: map['user_id'] as String?,
    email: map['email'] as String?,
    displayName: map['display_name'] as String?,
    role: map['permission'] as String? ?? map['role'] as String? ?? 'viewer',
    shareToken: map['share_token'] as String?,
    isPublic: (map['is_public'] as bool?) ?? false,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'entity_type': entityType,
    'entity_id': entityId,
    'user_id': userId,
    'email': email,
    'display_name': displayName,
    'permission': role,
    'share_token': shareToken,
    'is_public': isPublic,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

  /// هل هذه المشاركة بصلاحية عدّل أو تحكم كامل؟
  bool get canEdit => role == 'editor' || role == 'admin';

  /// هل هذه المشاركة بصلاحية تحكم كامل (حذف وتعديل)؟
  bool get canDelete => role == 'admin';

  /// هل هذه مشاركة عامة برابط قراءة فقط؟
  bool get isPublicLink => isPublic && shareToken != null;
}