import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// نافذة منبثقة تفاعلية لاختيار لون مخصص للمجال، المشروع، أو المهمة
class ColorPickerDialog extends StatefulWidget {
  final String initialColorHex;
  final String title;

  const ColorPickerDialog({
    super.key,
    required this.initialColorHex,
    this.title = 'اختر لوناً مخصصاً',
  });

  static Future<String?> show(BuildContext context, {required String initialColorHex, String? title}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => ColorPickerDialog(
        initialColorHex: initialColorHex,
        title: title ?? 'اختر لوناً مخصصاً',
      ),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late String _selectedHex;
  late TextEditingController _customHexController;

  @override
  void initState() {
    super.initState();
    _selectedHex = widget.initialColorHex;
    _customHexController = TextEditingController(text: _selectedHex);
  }

  @override
  void dispose() {
    _customHexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.fromHex(_selectedHex),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 10),
          Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الألوان المقترحة:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppColors.presetHexColors.map((hex) {
                final isSelected = hex.toLowerCase() == _selectedHex.toLowerCase();
                final color = AppColors.fromHex(hex);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedHex = hex;
                      _customHexController.text = hex;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'أو أدخل كود HEX مخصص:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customHexController,
              decoration: InputDecoration(
                prefixText: '# ',
                hintText: '3B82F6',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.palette_outlined, size: 20),
                  onPressed: () {
                    final text = _customHexController.text.trim();
                    final hex = text.startsWith('#') ? text : '#$text';
                    setState(() => _selectedHex = hex);
                  },
                ),
              ),
              onChanged: (val) {
                final hex = val.startsWith('#') ? val : '#$val';
                if (hex.length == 7) {
                  setState(() => _selectedHex = hex);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.fromHex(_selectedHex),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(_selectedHex),
          child: const Text('تأكيد الاختيار'),
        ),
      ],
    );
  }
}
