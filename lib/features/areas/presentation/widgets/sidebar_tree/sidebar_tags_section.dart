import 'package:flutter/material.dart';

import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_smart_filters.dart';

/// قسم الوسوم والتصنيفات (Tags & Labels)
class SidebarTagsSection extends StatelessWidget {
  final List<TagModel> tags;
  final String? selectedTagId;
  final Map<String, int> tagTaskCounts;
  final ValueChanged<String?>? onSelectTag;
  final VoidCallback? onAddTag;

  const SidebarTagsSection({
    super.key,
    this.tags = const [],
    this.selectedTagId,
    this.tagTaskCounts = const {},
    this.onSelectTag,
    this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SidebarSectionHeader(l10n.tagsSection),
            if (onAddTag != null)
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                tooltip: l10n.createTagTooltip,
                splashRadius: 14,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onAddTag,
              ),
          ],
        ),
        if (tags.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              l10n.noTagsAdded,
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted(context)),
            ),
          )
        else
          ...tags.map((tag) {
            final isSelected = selectedTagId == tag.id;
            final rawTagColor = AppColors.fromHex(tag.colorHex);
            final tagColor = AppColors.adaptiveCustomColor(rawTagColor, isDark);
            final count = tagTaskCounts[tag.id] ?? 0;

            return InkWell(
              onTap: () {
                if (isSelected) {
                  onSelectTag?.call(null);
                } else {
                  onSelectTag?.call(tag.id);
                }
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                margin: const EdgeInsets.symmetric(vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? tagColor.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: tagColor.withOpacity(0.5), width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tagColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? tagColor : AppColors.textPrimary(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black38 : Colors.black.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}