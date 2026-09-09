import 'package:flutter/foundation.dart';

import '../../services/attachment_service.dart';
import '../../data/models/attachment_model.dart';

/// متحكم المرفقات الخاص بمهمة: تحميل وإضافة وحذف المرفقات (Offline-First).
class AttachmentsController extends ChangeNotifier {
  AttachmentsController({AttachmentService? service})
      : _service = service ?? AttachmentService();

  final AttachmentService _service;

  List<AttachmentModel> _attachments = <AttachmentModel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttachmentModel> get attachments => List.unmodifiable(_attachments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل مرفقات مهمة معيّنة.
  Future<void> load(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _attachments = await _service.getAttachments(taskId);
    } catch (e) {
      _errorMessage = 'تعذر تحميل المرفقات';
      debugPrint('[AttachmentsController] load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة مرفق (يُحفظ محلياً ثم يُزامَن لاحقاً).
  Future<AttachmentModel?> add({
    required String taskId,
    required String fileName,
    required List<int> bytes,
    String? mimeType,
  }) async {
    _errorMessage = null;
    try {
      final model = await _service.addAttachment(
        taskId: taskId,
        fileName: fileName,
        fileSize: bytes.length,
        mimeType: mimeType,
        bytes: bytes,
      );
      _attachments = [..._attachments, model];
      notifyListeners();
      return model;
    } catch (e) {
      _errorMessage = 'تعذر حفظ المرفق';
      debugPrint('[AttachmentsController] add: $e');
      notifyListeners();
      return null;
    }
  }

  /// حذف ناعم لمرفق.
  Future<bool> delete(String id) async {
    _errorMessage = null;
    try {
      await _service.deleteAttachment(id);
      _attachments = _attachments.where((a) => a.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذر حذف المرفق';
      debugPrint('[AttachmentsController] delete: $e');
      notifyListeners();
      return false;
    }
  }

  /// رابط تنزيل/فتح المرفق (موقّع من التخزين أو مسار محلي).
  Future<String?> downloadUrl(AttachmentModel attachment) =>
      _service.getDownloadUrl(attachment);
}