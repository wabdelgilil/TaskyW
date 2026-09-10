import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../l10n/app_localizations.dart';

/// نافذة اختيار الإيموجي للمجالات والمشاريع
/// تتيح الاختيار من القائمة أو الإدخال الحر باللصق أو كتابة الكود (Unicode/HEX/Name)
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
  late TextEditingController _customInputController;
  String? _parseError;

  static const Map<String, List<String>> _emojiCategories = {
    'work': ['💼', '📁', '📊', '📈', '📋', '🎯', '🚀', '📌', '📑', '🖋️', '📅', '💡'],
    'tools': ['🏭', '⚙️', '🔧', '🔨', '⚡', '🏗️', '📐', '🔬', '💻', '🔌', '🛠️', '🧰'],
    'personal': ['🏠', '🚗', '🛒', '💳', '📚', '🏋️', '🍎', '✈️', '🎮', '☕', '🧘', '🌿'],
    'status': ['🔥', '⭐', '⏳', '✅', '⚠️', '🚨', '💎', '🎉', '🔔', '🏷️', '📦', '🔑'],
  };

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.initialEmoji;
    _customInputController = TextEditingController(text: widget.initialEmoji);
  }

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  /// تحويل كود الإيموجي (مثل U+1F680 أو 1F680 أو 0x1F680 أو &#128640;) أو النص المباشر إلى رمز تعبيري
  String? _tryParseCustomEmoji(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // 1. إذا كان المدخل إيموجي أو رمزاً مباشراً تم لصقه
    // الرموز التعبيرية المعقدة (مع ألوان البشرة أو Zero-Width Joiner) قد يكون طول runes > 1
    if (trimmed.runes.isNotEmpty) {
      // فحص إذا كان يبدو ككود يونيكود أم رمزاً
      final isHexPattern = RegExp(r'^(?:U\+|0x|\\u|\&\#x?)?([0-9a-fA-F]{4,6})\;?$').firstMatch(trimmed);
      if (isHexPattern != null) {
        final hexStr = isHexPattern.group(1);
        if (hexStr != null) {
          try {
            final codePoint = int.parse(hexStr, radix: 16);
            if (codePoint > 0 && codePoint <= 0x10FFFF) {
              return String.fromCharCode(codePoint);
            }
          } catch (_) {}
        }
      }

      // إذا كان كوداً عشرياً مثل HTML Entity: &#128640; أو 128640
      final isDecPattern = RegExp(r'^(?:\&\#)?(\d{4,7})\;?$').firstMatch(trimmed);
      if (isDecPattern != null && !trimmed.contains(RegExp(r'[^\d\&\#\;]'))) {
        final decStr = isDecPattern.group(1);
        if (decStr != null) {
          try {
            final codePoint = int.parse(decStr);
            if (codePoint > 0 && codePoint <= 0x10FFFF) {
              return String.fromCharCode(codePoint);
            }
          } catch (_) {}
        }
      }

      // إذا كان رمزاً أو إيموجي تم لصقه مباشرة
      return trimmed;
    }

    return null;
  }

  void _applyCustomInput(String val) {
    if (val.trim().isEmpty) {
      setState(() {
        _parseError = null;
      });
      return;
    }

    final parsed = _tryParseCustomEmoji(val);
    if (parsed != null && parsed.isNotEmpty) {
      setState(() {
        _selectedEmoji = parsed;
        _parseError = null;
      });
    } else {
      setState(() {
        _parseError = 'invalidEmojiCode';
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _customInputController.text = data.text!.trim();
      _applyCustomInput(data.text!);
    }
  }

  String _categoryLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'work':
        return l10n.emojiCategoryWork;
      case 'tools':
        return l10n.emojiCategoryTools;
      case 'personal':
        return l10n.emojiCategoryPersonal;
      case 'status':
        return l10n.emojiCategoryStatus;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              _selectedEmoji.isNotEmpty ? _selectedEmoji : '❓',
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.chooseIconTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  l10n.chooseIconSubtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حقل الإدخال واللصق الحر
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _parseError != null
                      ? Colors.redAccent
                      : (isDark ? Colors.white12 : Colors.black12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.customEmojiInput,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tooltip(
                        message: l10n.pasteFromClipboard,
                        child: InkWell(
                          onTap: _pasteFromClipboard,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.paste_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.paste,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customInputController,
                    decoration: InputDecoration(
                      hintText: l10n.pasteEmojiHint,
                      hintStyle: const TextStyle(fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      suffixIcon: _customInputController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _customInputController.clear();
                                setState(() {
                                  _parseError = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: _applyCustomInput,
                  ),
                  if (_parseError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.invalidEmojiCode,
                      style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // قائمة الإيموجيز المقترحة والمصنفة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.quickEmojis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: ListView(
                children: _emojiCategories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _categoryLabel(entry.key, l10n),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((emoji) {
                          final isSelected = emoji == _selectedEmoji;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedEmoji = emoji;
                                _customInputController.text = emoji;
                                _parseError = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 22)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_customInputController.text.trim().isNotEmpty) {
              final custom = _tryParseCustomEmoji(_customInputController.text);
              if (custom != null && custom.isNotEmpty) {
                Navigator.of(context).pop(custom);
                return;
              }
            }
            Navigator.of(context).pop(_selectedEmoji);
          },
          child: Text(l10n.choose),
        ),
      ],
    );
  }
}
