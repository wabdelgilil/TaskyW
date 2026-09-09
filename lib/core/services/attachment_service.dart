import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/tasks/data/models/attachment_model.dart';
import '../../features/tasks/data/repositories/attachment_repository_impl.dart';
import 'supabase_service.dart';

/// واجهة التخزين السحابي للمرفقات (قابلة للاختبار دون Supabase).
abstract class AttachmentStorageCloud {
  Future<String> upload({
    required String path,
    required List<int> bytes,
    String? contentType,
  });

  Future<void> delete(String path);

  Future<String?> signedUrl(String path);
}

/// تنفيذ حقيقي عبر Supabase Storage (باكت tasky-attachments).
class SupabaseAttachmentStorage implements AttachmentStorageCloud {
  SupabaseClient? get _client {
    try {
      if (!SupabaseService.isInitialized) return null;
      return SupabaseService.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> upload({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    final client = _client;
    if (client == null) throw StateError('Attachment storage requires login.');
    await client.storage.from(AttachmentService.bucketName).uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: FileOptions(contentType: contentType),
    );
    return path;
  }

  @override
  Future<void> delete(String path) async {
    final client = _client;
    if (client == null) return;
    await client.storage.from(AttachmentService.bucketName).remove([path]);
  }

  @override
  Future<String?> signedUrl(String path) async {
    final client = _client;
    if (client == null || path.isEmpty) return null;
    try {
      final result = await client.storage
          .from(AttachmentService.bucketName)
          .createSignedUrl(path, 3600);
      return result;
    } catch (e) {
      debugPrint('[AttachmentStorage] signedUrl failed: $e');
      return null;
    }
  }
}

/// خدمة المرفقات (Offline-First): حفظ مرفق محلياً، حذفه ناعماً،
/// وتوليد روابط التنزيل عبر التخزين السحابي.
class AttachmentService {
  static const String bucketName = 'tasky-attachments';

  final IAttachmentRepository _repository;
  final AttachmentStorageCloud _storage;
  final bool _isWeb;
  final Uuid _uuid = const Uuid();

  AttachmentService({
    IAttachmentRepository? repository,
    AttachmentStorageCloud? storage,
    bool? isWeb,
  }) : _repository = repository ?? AttachmentRepositoryImpl(),
       _storage = storage ?? SupabaseAttachmentStorage(),
       _isWeb = isWeb ?? kIsWeb;

  /// مرفقات مهمة محددة.
  Future<List<AttachmentModel>> getAttachments(String taskId) =>
      _repository.getAttachmentsByTask(taskId);

  /// إضافة مرفق محلي (لم يُرفع بعد — pending_insert).
  ///
  /// [bytes] يُحفظ كملف محلي على الأجهزة المكتبية/الموبايل؛ وعلى الويب
  /// تبقى الحالة معلقة ليُرفع الملف لاحقاً في دورة المزامنة إذا توفر مسار.
  Future<AttachmentModel> addAttachment({
    required String taskId,
    required String fileName,
    required int fileSize,
    String? mimeType,
    List<int>? bytes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    String? localPath;
    if (bytes != null && !_isWeb) {
      try {
        final dir = Directory(
          '${Directory.systemTemp.path}${Platform.pathSeparator}tasky_attachments',
        );
        await dir.create(recursive: true);
        final file = File(
          '${dir.path}${Platform.pathSeparator}$id${_safeFileName(fileName)}',
        );
        await file.writeAsBytes(bytes, flush: true);
        localPath = file.path;
      } catch (e) {
        debugPrint('[AttachmentService] save local file failed: $e');
      }
    }

    final model = AttachmentModel(
      id: id,
      taskId: taskId,
      fileName: fileName,
      filePath: localPath,
      fileSize: fileSize,
      mimeType: mimeType,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.insertAttachment(model);
    return model;
  }

  /// حذف ناعم لمرفق (يُزامَن كحذف للميتاداتا + كائن التخزين لاحقاً).
  Future<void> deleteAttachment(String id) =>
      _repository.softDeleteAttachment(id);

  /// رابط تنزيل المرفق: رابط موقّع من التخزين عند وجود [fileUrl]،
  /// أو المسار المحلي إذا كان الملف غير مرفوع بعد.
  Future<String?> getDownloadUrl(AttachmentModel attachment) async {
    final url = attachment.fileUrl;
    if (url != null && url.isNotEmpty) {
      return _storage.signedUrl(url);
    }
    final path = attachment.filePath;
    if (path != null && path.isNotEmpty) {
      try {
        if (await File(path).exists()) return 'file://$path';
      } catch (_) {}
    }
    return null;
  }

  String _safeFileName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return sanitized.isEmpty ? 'attachment' : sanitized;
  }
}