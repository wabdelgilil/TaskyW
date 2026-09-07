import 'package:flutter/material.dart';

/// نافذة اختيار الإيموجي للمجالات والمشاريع
class EmojiPickerDialog extends StatefulWidget {
  final String initialEmoji;

  const EmojiPickerDialog({super.key, required this.initialEmoji});

  static Future<String?> show(BuildContext context, {required String initialEmoji}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => EmojiPickerDialog(initialEmoji: initialEmoji),
    );
  }

  @override
  State<EmojiPickerDialog> createState() => _EmojiPickerDialogState();
}

class _EmojiPickerDialogState extends State<EmojiPickerDialog> {
  late String _selectedEmoji;

  static const Map<String, List<String>> _emojiCategories = {
    'العمل والمشاريع': ['💼', '📁', '📊', '📈', '📋', '🎯', '🚀', '📌', '📑', '🖋️', '📅', '💡'],
    'الهندسة والأدوات': ['🏭', '⚙️', '🔧', '🔨', '⚡', '🏗️', '📐', '🔬', '💻', '🔌', '🛠️', '🧰'],
    'الشخصية والمنزل': ['🏠', '🚗', '🛒', '💳', '📚', '🏋️', '🍎', '✈️', '🎮', '☕', '🧘', '🌿'],
    'الحالات والتنبيه': ['🔥', '⭐', '⏳', '✅', '⚠️', '🚨', '💎', '🎉', '🔔', '🏷️', '📦', '🔑'],
  };

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.initialEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(_selectedEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Text('اختر أيقونة معبرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 360,
        height: 380,
        child: ListView(
          children: _emojiCategories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((emoji) {
                    final isSelected = emoji == _selectedEmoji;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedEmoji = emoji);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedEmoji),
          child: const Text('اختيار'),
        ),
      ],
    );
  }
}
