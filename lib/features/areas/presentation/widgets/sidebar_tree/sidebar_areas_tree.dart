import 'package:flutter/material.dart';

import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_smart_filters.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';

/// شجرة المجالات والمشاريع المنسدلة (Areas & Projects Tree)
class SidebarAreasTree extends StatefulWidget {
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final String? selectedAreaId;
  final String? selectedProjectId;
  final Map<String, int> areaTaskCounts;
  final Map<String, int> projectTaskCounts;
  final VoidCallback? onAddNewArea;
  final void Function(String areaId)? onAddNewProject;
  final void Function(AreaModel area) onSelectArea;
  final void Function(ProjectModel project) onSelectProject;

  const SidebarAreasTree({
    super.key,
    required this.areas,
    required this.projects,
    this.selectedAreaId,
    this.selectedProjectId,
    this.areaTaskCounts = const {},
    this.projectTaskCounts = const {},
    this.onAddNewArea,
    this.onAddNewProject,
    required this.onSelectArea,
    required this.onSelectProject,
  });

  @override
  State<SidebarAreasTree> createState() => _SidebarAreasTreeState();
}

class _SidebarAreasTreeState extends State<SidebarAreasTree> {
  // تتبع المجالات المفتوحة في الشجرة (Expanded Areas)
  final Set<String> _expandedAreaIds = {};

  @override
  void initState() {
    super.initState();
    // فتح جميع المجالات افتراضياً لسهولة الرؤية
    for (final a in widget.areas) {
      _expandedAreaIds.add(a.id);
    }
  }

  void _toggleExpand(String areaId) {
    setState(() {
      if (_expandedAreaIds.contains(areaId)) {
        _expandedAreaIds.remove(areaId);
      } else {
        _expandedAreaIds.add(areaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SidebarSectionHeader('المجالات والمشاريع'),
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              tooltip: 'إضافة مجال جديد',
              splashRadius: 14,
              onPressed: widget.onAddNewArea,
            ),
          ],
        ),
        const SizedBox(height: 4),

        // تكرار المجالات
        ...widget.areas.map((area) {
          final isExpanded = _expandedAreaIds.contains(area.id);
          final areaProjects = widget.projects.where((p) => p.areaId == area.id).toList();
          final rawAreaColor = AppColors.fromHex(area.colorHex);
          final areaColor = AppColors.adaptiveCustomColor(rawAreaColor, isDark);
          final isAreaSelected = widget.selectedAreaId == area.id && widget.selectedProjectId == null;
          final taskCount = widget.areaTaskCounts[area.id] ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صف المجال (Area Item)
              InkWell(
                onTap: () => widget.onSelectArea(area),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: isAreaSelected
                        ? areaColor.withOpacity(0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // سهم الفتح والطي
                      InkWell(
                        onTap: () => _toggleExpand(area.id),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_left_rounded,
                            size: 18,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(area.iconEmoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          area.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isAreaSelected ? FontWeight.bold : FontWeight.w500,
                            color: isAreaSelected
                                ? areaColor
                                : AppColors.textPrimary(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (taskCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black38 : Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$taskCount',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // مشاريع المجال المنسدلة (Sub-Tree Projects)
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 22, top: 2, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...areaProjects.map((proj) {
                        final isProjSelected = widget.selectedProjectId == proj.id;
                        final rawProjColor = AppColors.fromHex(proj.colorHex);
                        final projColor = AppColors.adaptiveCustomColor(rawProjColor, isDark);
                        final pTaskCount = widget.projectTaskCounts[proj.id] ?? 0;

                        return InkWell(
                          onTap: () => widget.onSelectProject(proj),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            decoration: BoxDecoration(
                              color: isProjSelected
                                  ? projColor.withOpacity(0.18)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Text(proj.iconEmoji, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    proj.name,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isProjSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isProjSelected
                                          ? projColor
                                          : AppColors.textSecondary(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (pTaskCount > 0)
                                  Text(
                                    '$pTaskCount',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // زر إضافة مشروع سريع تحت هذا المجال
                      InkWell(
                        onTap: () => widget.onAddNewProject?.call(area.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 14, color: AppColors.textMuted(context)),
                              const SizedBox(width: 4),
                              Text(
                                'مشروع جديد...',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}