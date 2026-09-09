import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// ويدجت موحدة لعرض بطاقة عنصر في سلة المهملات مع خياري استعادة وحذف نهائي
class TrashItemCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onRestore;
  final VoidCallback? onPermanentDelete;
  final String restoreTooltip;
  final String deleteTooltip;

  const TrashItemCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onRestore,
    this.onPermanentDelete,
    this.restoreTooltip = 'استعادة',
    this.deleteTooltip = 'حذف نهائي',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded, color: Colors.green, size: 22),
              tooltip: restoreTooltip,
              onPressed: onRestore,
            ),
            if (onPermanentDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
                tooltip: deleteTooltip,
                onPressed: onPermanentDelete,
              ),
          ],
        ),
      ),
    );
  }
}
