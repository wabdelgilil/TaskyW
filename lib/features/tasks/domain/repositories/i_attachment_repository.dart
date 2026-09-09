import '../../data/models/attachment_model.dart';

/// واجهة مستودع المرفقات في طبقة المجال (Domain Layer Interface).
abstract class IAttachmentRepository {
  Future<List<AttachmentModel>> getAttachmentsByTask(String taskId);

  Future<AttachmentModel?> getAttachmentById(String id);

  Future<void> insertAttachment(AttachmentModel attachment);

  Future<void> updateAttachment(AttachmentModel attachment);

  Future<void> softDeleteAttachment(String id);

  Future<List<AttachmentModel>> getAttachmentsBySyncStatus(String syncStatus);
}
