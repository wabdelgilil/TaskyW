import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';

/// نافذة إنشاء وسم جديد مع اختيار اللون من باليتة الألوان
class CreateTagDialog extends StatefulWidget {
  final Function(String name, String colorHex) onCreateTag;

  const CreateTagDialog({super.key, required this.onCreateTag});

  static Future<void> show(
    BuildContext context, {
    required Function(String name, String colorHex) onCreateTag,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateTagDialog(onCreateTag: onCreateTag),
    );
  }

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  late final TextEditingController _nameCtrl;
  String _selectedHex = '#3B82F6';

  static const List<String> _palette = [
    '#3B82F6', '#10B981', '#8B5CF6', '#F59E0B', '#EF4444', '#EC4899', '#06B6D4', '#64748B',
  ];

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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.createNewTag, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.tagName,
                hintText: l10n.tagNameHint,
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.chooseTagColor, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _palette.map((hex) {
                final isPicked = _selectedHex == hex;
                final c = AppColors.fromHex(hex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedHex = hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isPicked ? Border.all(color: Colors.white, width: 2.5) : null,
                      boxShadow: isPicked
                          ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 4, spreadRadius: 1)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        ElevatedButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isNotEmpty) {
              widget.onCreateTag(name, _selectedHex);
              Navigator.pop(context);
            }
          },
          child: Text(l10n.createAction),
        ),
      ],
    );
  }
}
