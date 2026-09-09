/// نموذج مرفق ملف مرتبط بمهمة (Offline-First).
///
/// يحمل بيانات الملف محلياً ([filePath]) ومسار التخزين السحابي ([fileUrl])
/// وحالة المزامنة، عبر الحقول المحلية والسحابية الموحدة.
class AttachmentModel {
  final String id;
  final String taskId;
  final String fileName;
  final String? filePath;
  final int fileSize;
  final String? mimeType;
  final String? fileUrl;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AttachmentModel({
    required this.id,
    required this.taskId,
    required this.fileName,
    this.filePath,
    this.fileSize = 0,
    this.mimeType,
    this.fileUrl,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'task_id': taskId,
    'file_name': fileName,
    'file_path': filePath,
    'file_size': fileSize,
    'mime_type': mimeType,
    'file_url': fileUrl,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory AttachmentModel.fromMap(Map<String, dynamic> map) => AttachmentModel(
    id: map['id'] as String,
    taskId: map['task_id'] as String,
    fileName: map['file_name'] as String,
    filePath: map['file_path'] as String?,
    fileSize: map['file_size'] as int? ?? 0,
    mimeType: map['mime_type'] as String?,
    fileUrl: map['file_url'] as String?,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  AttachmentModel copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    String? fileUrl,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => AttachmentModel(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    fileSize: fileSize ?? this.fileSize,
    mimeType: mimeType ?? this.mimeType,
    fileUrl: fileUrl ?? this.fileUrl,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}