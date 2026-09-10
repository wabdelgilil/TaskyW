import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';

/// شريط إضافة مهمة سريعة يظهر أسفل شاشة اليوم في وضع الموبايل.
///
/// يسمح بإضافة مهمة مختصرة بعنوان فقط وموعد نهاري (due date = اليوم).
class QuickAddTaskBar extends StatefulWidget {
  final ValueChanged<String> onQuickAdd;

  const QuickAddTaskBar({super.key, required this.onQuickAdd});

  @override
  State<QuickAddTaskBar> createState() => _QuickAddTaskBarState();
}

class _QuickAddTaskBarState extends State<QuickAddTaskBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onQuickAdd(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.border(context),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: context.l10n.quickAddHint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 13.5,
                ),
                prefixIcon: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: AppColors.textMuted(context),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.02),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.statusInProgress,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.statusInProgress,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _submit,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}