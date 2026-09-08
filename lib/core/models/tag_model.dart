class TagModel {
  final String id;
  final String name;
  final String colorHex;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TagModel({
    required this.id,
    required this.name,
    this.colorHex = '#64748B',
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color_hex': colorHex,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory TagModel.fromMap(Map<String, dynamic> map) => TagModel(
    id: map['id'] as String,
    name: map['name'] as String,
    colorHex: map['color_hex'] as String? ?? '#64748B',
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  TagModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => TagModel(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagModel &&
          id == other.id &&
          name == other.name &&
          colorHex == other.colorHex &&
          orderIndex == other.orderIndex &&
          syncStatus == other.syncStatus &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(id, name, colorHex, orderIndex, syncStatus, createdAt, updatedAt, deletedAt);
}