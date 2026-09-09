import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/color_picker_dialog.dart';
import 'package:tasky/core/widgets/emoji_picker_dialog.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';

/// نافذة إضافة مجال مسؤولية جديد مع اختيار الإيموجي واللون
class AddAreaDialog extends StatefulWidget {
  final Function(AreaModel area) onSaveArea;

  const AddAreaDialog({super.key, required this.onSaveArea});

  static Future<void> show(
    BuildContext context, {
    required Function(AreaModel area) onSaveArea,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddAreaDialog(onSaveArea: onSaveArea),
    );
  }

  @override
  State<AddAreaDialog> createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends State<AddAreaDialog> {
  late final TextEditingController _nameCtrl;
  String _emoji = '💼';
  String _colorHex = '#3B82F6';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aColor = AppColors.fromHex(_colorHex);

    return AlertDialog(
      title: const Text('إضافة مجال مسؤولية جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 360,
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
                    decoration: BoxDecoration(color: aColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
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
                        Container(width: 16, height: 16, decoration: BoxDecoration(color: aColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text('اللون', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'اسم المجال')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isNotEmpty) {
              final newArea = AreaModel(
                id: 'area-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameCtrl.text.trim(),
                iconEmoji: _emoji,
                colorHex: _colorHex,
                createdAt: DateTime.now().toUtc(),
                updatedAt: DateTime.now().toUtc(),
              );
              widget.onSaveArea(newArea);
              Navigator.of(context).pop();
            }
          },
          child: const Text('إنشاء المجال'),
        ),
      ],
    );
  }
}
