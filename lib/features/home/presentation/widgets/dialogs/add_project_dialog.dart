import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/color_picker_dialog.dart';
import 'package:tasky/core/widgets/emoji_picker_dialog.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';

/// نافذة إضافة مشروع جديد تحت مجال محدد مع اختيار الإيموجي واللون والوصف
class AddProjectDialog extends StatefulWidget {
  final String areaId;
  final Function(ProjectModel project) onSaveProject;

  const AddProjectDialog({
    super.key,
    required this.areaId,
    required this.onSaveProject,
  });

  static Future<void> show(
    BuildContext context, {
    required String areaId,
    required Function(ProjectModel project) onSaveProject,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddProjectDialog(
        areaId: areaId,
        onSaveProject: onSaveProject,
      ),
    );
  }

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _emoji = '📋';
  String _colorHex = '#10B981';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pColor = AppColors.fromHex(_colorHex);

    return AlertDialog(
      title: const Text('إضافة مشروع جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final selected = await EmojiPickerDialog.show(context, initialEmoji: _emoji);
                    if (selected != null) setState(() => _emoji = selected);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: pColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(_emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    final selected = await ColorPickerDialog.show(context, initialColorHex: _colorHex);
                    if (selected != null) setState(() => _colorHex = selected);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                    child: Row(
                      children: [
                        Container(width: 16, height: 16, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('اللون', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'اسم المشروع')),
            const SizedBox(height: 10),
            TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف المشروع (اختياري)')),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('إشعارات هذا المشروع'),
              subtitle: const Text('تفعيل التذكيرات المحلية لمهام هذا المشروع'),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isNotEmpty) {
              final newProj = ProjectModel(
                id: 'project-${DateTime.now().millisecondsSinceEpoch}',
                areaId: widget.areaId,
                name: _nameCtrl.text.trim(),
                description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                iconEmoji: _emoji,
                colorHex: _colorHex,
                notificationsEnabled: _notificationsEnabled,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              );
              widget.onSaveProject(newProj);
              Navigator.of(context).pop();
            }
          },
          child: const Text('إنشاء المشروع'),
        ),
      ],
    );
  }
}
