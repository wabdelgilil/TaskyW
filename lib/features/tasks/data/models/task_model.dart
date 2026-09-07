class TaskModel {
  final String id;
  final String areaId;
  final String? projectId;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? colorHex;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final String? shareToken;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TaskModel({
    required this.id,
    required this.areaId,
    this.projectId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.colorHex,
    this.dueDate,
    this.reminderTime,
    this.shareToken,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'area_id': areaId,
    'project_id': projectId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'color_hex': colorHex,
    'due_date': dueDate?.toUtc().toIso8601String(),
    'reminder_time': reminderTime?.toUtc().toIso8601String(),
    'share_token': shareToken,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as String,
    areaId: map['area_id'] as String,
    projectId: map['project_id'] as String?,
    title: map['title'] as String,
    description: map['description'] as String?,
    status: map['status'] as String? ?? 'todo',
    priority: map['priority'] as String? ?? 'medium',
    colorHex: map['color_hex'] as String?,
    dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
    reminderTime: map['reminder_time'] != null ? DateTime.parse(map['reminder_time'] as String) : null,
    shareToken: map['share_token'] as String?,
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  TaskModel copyWith({
    String? id,
    String? areaId,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? colorHex,
    DateTime? dueDate,
    DateTime? reminderTime,
    String? shareToken,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => TaskModel(
    id: id ?? this.id,
    areaId: areaId ?? this.areaId,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    colorHex: colorHex ?? this.colorHex,
    dueDate: dueDate ?? this.dueDate,
    reminderTime: reminderTime ?? this.reminderTime,
    shareToken: shareToken ?? this.shareToken,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
