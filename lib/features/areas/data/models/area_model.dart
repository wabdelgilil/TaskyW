class AreaModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String colorHex;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AreaModel({
    required this.id,
    required this.name,
    this.iconEmoji = '📁',
    this.colorHex = '#3B82F6',
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon_emoji': iconEmoji,
    'color_hex': colorHex,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory AreaModel.fromMap(Map<String, dynamic> map) => AreaModel(
    id: map['id'] as String,
    name: map['name'] as String,
    iconEmoji: map['icon_emoji'] as String? ?? '📁',
    colorHex: map['color_hex'] as String? ?? '#3B82F6',
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  AreaModel copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    String? colorHex,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => AreaModel(
    id: id ?? this.id,
    name: name ?? this.name,
    iconEmoji: iconEmoji ?? this.iconEmoji,
    colorHex: colorHex ?? this.colorHex,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
