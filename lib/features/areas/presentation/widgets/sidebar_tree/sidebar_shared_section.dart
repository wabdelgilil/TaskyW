import 'package:flutter/material.dart';

import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_smart_filters.dart';
import 'package:tasky/features/collaboration/presentation/controllers/collaboration_controller.dart';

/// قسم الكيانات والمشاريع المشتركة معي (Shared with Me)
class SidebarSharedSection extends StatefulWidget {
  final void Function(Map<String, dynamic> entity)? onSelectSharedEntity;

  const SidebarSharedSection({super.key, this.onSelectSharedEntity});

  @override
  State<SidebarSharedSection> createState() => _SidebarSharedSectionState();
}

class _SidebarSharedSectionState extends State<SidebarSharedSection> {
  late final CollaborationController _collabController;

  @override
  void initState() {
    super.initState();
    _collabController = CollaborationController();
    _collabController.loadSharedWithMe();
  }

  @override
  void dispose() {
    _collabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _collabController,
      builder: (context, _) {
        final sharedItems = _collabController.sharedWithMe;
        if (sharedItems.isEmpty && !_collabController.isLoading) {
          return const SizedBox.shrink();
        }
        final l10n = context.l10n;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SidebarSectionHeader(l10n.sharedWithMeHeader),
                if (_collabController.isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 15),
                    tooltip: l10n.refreshSharedTooltip,
                    splashRadius: 14,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _collabController.loadSharedWithMe(),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ...sharedItems.map((item) {
              final title = item['name'] ?? item['title'] ?? l10n.sharedEntityDefault;
              final entityType = item['_entity_type'] ?? 'project';
              final perm = item['_permission_level'] ?? 'viewer';
              final iconEmoji = item['icon_emoji'] as String?;

              IconData defaultIcon;
              switch (entityType) {
                case 'area':
                  defaultIcon = Icons.folder_shared_outlined;
                  break;
                case 'project':
                  defaultIcon = Icons.work_outline_rounded;
                  break;
                case 'task':
                default:
                  defaultIcon = Icons.task_alt_rounded;
                  break;
              }

              return InkWell(
                onTap: () {
                  widget.onSelectSharedEntity?.call(item);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      if (iconEmoji != null && iconEmoji.isNotEmpty)
                        Text(iconEmoji, style: const TextStyle(fontSize: 14))
                      else
                        Icon(defaultIcon, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // شارة الصلاحية
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: perm == 'admin'
                              ? Colors.red.withValues(alpha: 0.12)
                              : perm == 'editor'
                                  ? Colors.blue.withValues(alpha: 0.12)
                                  : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          perm == 'admin'
                              ? l10n.permissionAdmin
                              : perm == 'editor'
                                  ? l10n.permissionEditor
                                  : l10n.permissionViewer,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: perm == 'admin'
                                ? Colors.redAccent
                                : perm == 'editor'
                                    ? Colors.blue
                                    : AppColors.textSecondary(context),
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
      },
    );
  }
}