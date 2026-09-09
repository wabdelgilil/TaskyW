import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/note_model.dart';
import '../controllers/notes_controller.dart';

/// الشاشة: ألوان افتراضية لبطاقات الملاحظات (تُخلط مع النمط).
const List<String> _notePalette = [
  '#FFF3B0', // أصفر دافئ
  '#BDEFFF', // أزرق سماوي
  '#C8F7C5', // أخضر نعناعي
  '#F8C8DC', // وردي
  '#E7D9FF', // بنفسجي فاتح
  '#FFD8B8', // برتقالي فاتح
];

/// شاشة الملاحظات العامة (Resources & Knowledge Vault) بنمط Keep-like.
class NotesScreen extends StatefulWidget {
  final NotesController? controller;

  const NotesScreen({super.key, this.controller});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NotesController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? NotesController();
    _controller.load();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditor({NoteModel? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController =
        TextEditingController(text: (note?.content ?? ''));
    String? colorHex = note?.colorHex;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Color selectedColor = colorHex != null
                ? AppColors.fromHex(colorHex)
                : Colors.white;
            return AlertDialog(
              title: Text(note == null
                  ? 'ملاحظة جديدة'
                  : 'تعديل الملاحظة'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: note == null,
                        decoration: const InputDecoration(
                          labelText: 'العنوان',
                          hintText: 'عنوان الملاحظة...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentController,
                        minLines: 3,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'المحتوى',
                          hintText: 'اكتب أفكارك ومراجعك هنا...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'لون الملاحظة',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final presets in [..._notePalette, '#FFFFFF'])
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  colorHex = presets == '#FFFFFF'
                                      ? null
                                      : presets;
                                  selectedColor = presets == '#FFFFFF'
                                      ? Colors.white
                                      : AppColors.fromHex(presets);
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.fromHex(presets),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor ==
                                            AppColors.fromHex(presets)
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.border(context),
                                    width: selectedColor ==
                                            AppColors.fromHex(presets)
                                        ? 2.5
                                        : 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (note == null) {
                      _controller.add(
                        title: title,
                        content: contentController.text,
                        colorHex: colorHex,
                      );
                    } else {
                      _controller.update(
                        id: note.id,
                        title: title,
                        content: contentController.text,
                        colorHex: colorHex,
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(note == null ? 'إضافة' : 'حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(NoteModel note) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'حذف الملاحظة',
      message: 'هل أنت متأكد من حذف "${note.title}"؟',
      confirmLabel: 'نعم، احذف',
    );
    if (confirmed == true && mounted) {
      await _controller.remove(note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'الملاحظات ومستودع المعرفة (Knowledge Vault)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'المستودع المعرفي والمساحة الهادئة للأفكار، المراجع، الروابط وجهات الاتصال دون مواعيد أو قيود مهام.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: _controller.setQuery,
                  decoration: InputDecoration(
                    hintText: 'بحث لحظي في العناوين والمحتوى...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border(context)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final pinned = _controller.pinnedNotes;
                final normal = _controller.normalNotes;
                if (pinned.isEmpty && normal.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 48,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'لا توجد ملاحظات بعد',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        Text(
                          'اضغط + لإضافة أول ملاحظة...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                  children: [
                    if (pinned.isNotEmpty) ...[
                      _buildSectionLabel('المثبتة', Icons.push_pin_rounded),
                      const SizedBox(height: 8),
                      _buildNoteCards(pinned),
                      const SizedBox(height: 18),
                    ],
                    if (normal.isNotEmpty) ...[
                      _buildSectionLabel('ملاحظات', Icons.notes_rounded),
                      const SizedBox(height: 8),
                      _buildNoteCards(normal),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        tooltip: 'ملاحظة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.statusCompleted,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNoteCards(List<NoteModel> notes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 560
            ? constraints.maxWidth
            : constraints.maxWidth / 2 - 8;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: notes
              .map((note) => SizedBox(width: cardWidth, child: _NoteCard(
                    note: note,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    onEdit: () => _openEditor(note: note),
                    onTogglePin: () =>
                        _controller.setPinned(note.id, !note.isPinned),
                    onArchive: () =>
                        _controller.setArchived(note.id, true),
                    onDelete: () => _confirmDelete(note),
                  )))
              .toList(),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onTogglePin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.isDark,
    required this.onEdit,
    required this.onTogglePin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = note.colorHex != null
        ? AppColors.fromHex(note.colorHex!)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFF8E1));

    return Material(
      color: baseColor.withOpacity(isDark ? 0.22 : 0.9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin_rounded, size: 15),
                  PopupMenuButton<String>(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'pin':
                          onTogglePin();
                          break;
                        case 'archive':
                          onArchive();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(note.isPinned
                                ? Icons.push_pin_outlined
                                : Icons.push_pin_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(note.isPinned ? 'إلغاء التثبيت' : 'تثبيت'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('أرشفة'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.content != null && note.content!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    note.content!.trim(),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}