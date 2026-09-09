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
  final bool isRecurring;
  final String? recurrencePattern;
  final int recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final String? assignedTo;
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
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceInterval = 1,
    this.recurrenceEndDate,
    this.assignedTo,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// هل المهمة مؤرشفة (مخفية من مساحات العمل اليومية)؟
  bool get isArchived => status == 'archived';

  /// هل المهمة في سلة المهملات (محذوفة ناعماً)؟
  bool get isDeleted => deletedAt != null;

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
    'is_recurring': isRecurring ? 1 : 0,
    'recurrence_pattern': recurrencePattern,
    'recurrence_interval': recurrenceInterval,
    'recurrence_end_date': recurrenceEndDate?.toUtc().toIso8601String(),
    'assigned_to': assignedTo,
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
    isRecurring: (map['is_recurring'] as int? ?? 0) == 1,
    recurrencePattern: map['recurrence_pattern'] as String?,
    recurrenceInterval: map['recurrence_interval'] as int? ?? 1,
    recurrenceEndDate: map['recurrence_end_date'] != null
        ? DateTime.parse(map['recurrence_end_date'] as String)
        : null,
    assignedTo: map['assigned_to'] as String?,
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
    bool? isRecurring,
    String? recurrencePattern,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    String? assignedTo,
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
    isRecurring: isRecurring ?? this.isRecurring,
    recurrencePattern: recurrencePattern ?? this.recurrencePattern,
    recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
    assignedTo: assignedTo ?? this.assignedTo,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}