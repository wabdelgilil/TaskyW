import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/attachment_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/attachment_model.dart';
import '../controllers/attachments_controller.dart';

/// ملف مُنتقى من أداة الاختيار.
class PickedAttachment {
  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  const PickedAttachment({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });
}

/// قسم المرفقات داخل درج تفاصيل المهمة.
///
/// يتيح إضافة ملف وحذفه وتنزيله/فتحه، مع حالة مزامنة لكل مرفق
/// (Offline-First) ورفع طرق الاختيار والفتح للحقن في الاختبارات.
class TaskAttachmentsSection extends StatefulWidget {
  final String taskId;
  final AttachmentService? service;
  final Future<PickedAttachment> Function()? pickFile;
  final Future<void> Function(String url)? openUrl;

  const TaskAttachmentsSection({
    super.key,
    required this.taskId,
    this.service,
    this.pickFile,
    this.openUrl,
  });

  @override
  State<TaskAttachmentsSection> createState() => _TaskAttachmentsSectionState();
}

class _TaskAttachmentsSectionState extends State<TaskAttachmentsSection> {
  late final AttachmentsController _controller;
  late String _taskId;

  @override
  void initState() {
    super.initState();
    _controller = AttachmentsController(service: widget.service);
    _taskId = widget.taskId;
    _controller.load(_taskId);
  }

  @override
  void didUpdateWidget(covariant TaskAttachmentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskId != widget.taskId) {
      _taskId = widget.taskId;
      _controller.load(_taskId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<PickedAttachment> _defaultPickFile() async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) {
      throw StateError('No file selected');
    }
    final file = files.single;
    final bytes = await file.readAsBytes();
    return PickedAttachment(
      fileName: file.name,
      mimeType: _guessMimeType(file.name),
      bytes: bytes,
    );
  }

  Future<void> _defaultOpenUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Cannot launch $url');
    }
  }

  Future<void> _handleAdd() async {
    final picker = widget.pickFile ?? _defaultPickFile;
    final PickedAttachment picked;
    try {
      picked = await picker();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم اختيار أي ملف'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final added = await _controller.add(
      taskId: _taskId,
      fileName: picked.fileName,
      bytes: picked.bytes,
      mimeType: picked.mimeType,
    );
    if (added == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'تعذر حفظ المرفق'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete(AttachmentModel attachment) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'حذف المرفق',
      message: 'هل أنت متأكد من حذف الملف "${attachment.fileName}"؟',
      confirmLabel: 'نعم، احذف',
    );
    if (confirmed != true || !mounted) return;
    await _controller.delete(attachment.id);
  }

  Future<void> _handleOpen(AttachmentModel attachment) async {
    final url = await _controller.downloadUrl(attachment);
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الملف غير مرفوع بعد؛ سيتوفر التنزيل بعد المزامنة'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final opener = widget.openUrl ?? _defaultOpenUrl;
    try {
      if (url.startsWith('file://')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الملف محفوظ محلياً: $url'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await opener(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الملف'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final attachments = _controller.attachments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'المرفقات (${attachments.length})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_controller.isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, size: 20),
                      tooltip: 'إضافة مرفق',
                      onPressed: _handleAdd,
                    ),
                  ],
                ),
              ],
            ),
            if (attachments.isEmpty && !_controller.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'لا توجد مرفقات بعد — يمكنك إرفاق مستندات وصور وملفات.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              )
            else
              ...attachments.map((attachment) {
                return _buildAttachmentTile(context, attachment);
              }),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentTile(BuildContext context, AttachmentModel attachment) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = attachment.syncStatus.startsWith('pending_');
    final isSynced = attachment.syncStatus == 'synced';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(
            _fileIcon(attachment.mimeType ?? attachment.fileName),
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      _formatSize(attachment.fileSize),
                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pending
                          ? '⏳ قيد المزامنة'
                          : (isSynced ? '✓ مزامن' : '—'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: pending
                            ? Colors.orange
                            : (isSynced ? Colors.green : AppColors.textSecondary(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 18),
            tooltip: 'فتح / تنزيل المرفق',
            onPressed: () => _handleOpen(attachment),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
            tooltip: 'حذف المرفق',
            onPressed: () => _handleDelete(attachment),
          ),
        ],
      ),
    );
  }

  IconData _fileIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return Icons.image_rounded;
    }
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (lower.contains('video')) return Icons.videocam_rounded;
    if (lower.contains('audio')) return Icons.music_note_rounded;
    return Icons.insert_drive_file_rounded;
  }

  static String _formatSize(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }

  static String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.zip')) return 'application/zip';
    return 'application/octet-stream';
  }
}