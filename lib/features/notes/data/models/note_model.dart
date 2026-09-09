/// نموذج ملاحظة عامة (General Note) — موديول مستقل بنمط Offline-First
/// لا يرتبط بمهام ولا بمواعيد استحقاق.
class NoteModel {
  final String id;
  final String title;
  final String? content;
  final String? colorHex;
  final bool isPinned;
  final bool isArchived;
  final String? areaId;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const NoteModel({
    required this.id,
    required this.title,
    this.content,
    this.colorHex,
    this.isPinned = false,
    this.isArchived = false,
    this.areaId,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'color_hex': colorHex,
    'is_pinned': isPinned ? 1 : 0,
    'is_archived': isArchived ? 1 : 0,
    'area_id': areaId,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
    id: map['id'] as String,
    title: map['title'] as String,
    content: map['content'] as String?,
    colorHex: map['color_hex'] as String?,
    isPinned: (map['is_pinned'] as int? ?? 0) == 1,
    isArchived: (map['is_archived'] as int? ?? 0) == 1,
    areaId: map['area_id'] as String?,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null
        ? DateTime.parse(map['deleted_at'] as String)
        : null,
  );

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? colorHex,
    bool? isPinned,
    bool? isArchived,
    String? areaId,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => NoteModel(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    colorHex: colorHex ?? this.colorHex,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    areaId: areaId ?? this.areaId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}