class ProjectModel {
  final String id;
  final String areaId;
  final String name;
  final String? description;
  final String iconEmoji;
  final String colorHex;
  final String status;
  final DateTime? targetDate;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProjectModel({
    required this.id,
    required this.areaId,
    required this.name,
    this.description,
    this.iconEmoji = '📋',
    this.colorHex = '#10B981',
    this.status = 'active',
    this.targetDate,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// هل المشروع مؤرشف (مخفى من مساحات العمل اليومية)؟
  bool get isArchived => status == 'archived';

  /// هل المشروع في سلة المهملات (محذوف ناعماً)؟
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'area_id': areaId,
    'name': name,
    'description': description,
    'icon_emoji': iconEmoji,
    'color_hex': colorHex,
    'status': status,
    'target_date': targetDate?.toUtc().toIso8601String(),
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['id'] as String,
    areaId: map['area_id'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
    iconEmoji: map['icon_emoji'] as String? ?? '📋',
    colorHex: map['color_hex'] as String? ?? '#10B981',
    status: map['status'] as String? ?? 'active',
    targetDate: map['target_date'] != null ? DateTime.parse(map['target_date'] as String) : null,
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  ProjectModel copyWith({
    String? id,
    String? areaId,
    String? name,
    String? description,
    String? iconEmoji,
    String? colorHex,
    String? status,
    DateTime? targetDate,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => ProjectModel(
    id: id ?? this.id,
    areaId: areaId ?? this.areaId,
    name: name ?? this.name,
    description: description ?? this.description,
    iconEmoji: iconEmoji ?? this.iconEmoji,
    colorHex: colorHex ?? this.colorHex,
    status: status ?? this.status,
    targetDate: targetDate ?? this.targetDate,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
