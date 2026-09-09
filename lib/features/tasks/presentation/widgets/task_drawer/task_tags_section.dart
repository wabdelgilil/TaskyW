import 'package:flutter/material.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/core/theme/app_colors.dart';

/// مكون قسم الوسوم وقائمة رقائق الوسوم ومودال إضافة وسم
class TaskTagsSection extends StatelessWidget {
  final List<TagModel> taskTags;
  final List<TagModel> availableTags;
  final Function(TagModel tag)? onAssignTag;
  final Function(TagModel tag)? onRemoveTag;
  final Function(String name, String colorHex)? onCreateTag;

  const TaskTagsSection({
    super.key,
    required this.taskTags,
    required this.availableTags,
    this.onAssignTag,
    this.onRemoveTag,
    this.onCreateTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الوسوم والتصنيفات (Tags)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddTagDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('إضافة وسم', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (taskTags.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context), width: 0.8),
            ),
            child: Text(
              'لا توجد وسوم مرتبطة بهذه المهمة. اضغط "إضافة وسم" للتصنيف.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: taskTags.map((tag) {
              final rawColor = AppColors.fromHex(tag.colorHex);
              final tagColor = AppColors.adaptiveCustomColor(rawColor, isDark);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rawColor.withOpacity(isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rawColor.withOpacity(isDark ? 0.6 : 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: rawColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => onRemoveTag?.call(tag),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.close, size: 14, color: tagColor.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final available = availableTags.where((t) => !taskTags.any((assigned) => assigned.id == t.id)).toList();
    final newTagController = TextEditingController();
    String selectedHex = '#3B82F6';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final palette = [
              '#3B82F6', '#10B981', '#8B5CF6', '#F59E0B', '#EF4444', '#EC4899', '#06B6D4', '#64748B',
            ];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة وسم للمهمة',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // الوسوم المتاحة للاختيار السريع
                  if (available.isNotEmpty) ...[
                    const Text('الوسوم المتاحة:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: available.map((tag) {
                        final rawColor = AppColors.fromHex(tag.colorHex);
                        final tagColor = AppColors.adaptiveCustomColor(rawColor, isDark);

                        return ActionChip(
                          avatar: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: rawColor, shape: BoxShape.circle),
                          ),
                          label: Text(tag.name, style: TextStyle(fontSize: 12, color: tagColor, fontWeight: FontWeight.w600)),
                          backgroundColor: rawColor.withOpacity(isDark ? 0.2 : 0.1),
                          side: BorderSide(color: rawColor.withOpacity(0.4)),
                          onPressed: () {
                            onAssignTag?.call(tag);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // إنشاء وسم جديد
                  const Text('أو إنشاء وسم جديد:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newTagController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'اسم الوسم (مثلاً: عاجل، قطع_غيار...)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // باليت الألوان
                  Row(
                    children: [
                      const Text('اللون: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: palette.map((hex) {
                              final isPicked = selectedHex == hex;
                              final c = AppColors.fromHex(hex);
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedHex = hex),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: isPicked ? Border.all(color: Colors.white, width: 2) : null,
                                    boxShadow: isPicked
                                        ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)]
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final name = newTagController.text.trim();
                      if (name.isNotEmpty) {
                        onCreateTag?.call(name, selectedHex);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('إنشاء وإضافة الوسم'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
