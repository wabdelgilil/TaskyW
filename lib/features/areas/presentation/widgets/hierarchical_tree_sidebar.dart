import 'package:flutter/material.dart';

import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/tasky_logo.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_areas_tree.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_shared_section.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_smart_filters.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_tags_section.dart';
import 'package:tasky/features/areas/presentation/widgets/sidebar_tree/sidebar_user_footer.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';

/// الشجرة الهرمية التفاعلية للقائمة الجانبية (Hierarchical Tree Sidebar)
class HierarchicalTreeSidebar extends StatelessWidget {
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final List<TagModel> tags;
  final String? selectedFilter; // 'today', 'upcoming', 'waiting', 'urgent', 'all'
  final String? selectedAreaId;
  final String? selectedProjectId;
  final String? selectedTagId;
  final bool notesSelected;
  final bool financeSelected;
  final bool archiveSelected;
  final bool trashSelected;
  final int pendingInvoicesCount;
  final int archivedCount;
  final int trashCount;
  final Map<String, int> areaTaskCounts;
  final Map<String, int> projectTaskCounts;
  final Map<String, int> tagTaskCounts;
  final int todayCount;
  final int upcomingCount;
  final int waitingCount;
  final int urgentCount;
  final Function(String filter) onSelectFilter;
  final Function(AreaModel area) onSelectArea;
  final Function(ProjectModel project) onSelectProject;
  final ValueChanged<String?>? onSelectTag;
  final VoidCallback? onAddNewArea;
  final Function(String areaId)? onAddNewProject;
  final VoidCallback? onAddTag;
  final Function(Map<String, dynamic> entity)? onSelectSharedEntity;
  final VoidCallback? onSelectNotes;
  final VoidCallback? onSelectFinance;
  final VoidCallback? onSelectArchive;
  final VoidCallback? onSelectTrash;

  const HierarchicalTreeSidebar({
    super.key,
    required this.areas,
    required this.projects,
    this.tags = const [],
    this.selectedFilter,
    this.selectedAreaId,
    this.selectedProjectId,
    this.selectedTagId,
    this.notesSelected = false,
    this.financeSelected = false,
    this.archiveSelected = false,
    this.trashSelected = false,
    this.pendingInvoicesCount = 0,
    this.archivedCount = 0,
    this.trashCount = 0,
    this.areaTaskCounts = const {},
    this.projectTaskCounts = const {},
    this.tagTaskCounts = const {},
    this.todayCount = 0,
    this.upcomingCount = 0,
    this.waitingCount = 0,
    this.urgentCount = 0,
    required this.onSelectFilter,
    required this.onSelectArea,
    required this.onSelectProject,
    this.onSelectTag,
    this.onAddNewArea,
    this.onAddNewProject,
    this.onAddTag,
    this.onSelectSharedEntity,
    this.onSelectNotes,
    this.onSelectFinance,
    this.onSelectArchive,
    this.onSelectTrash,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: BorderDirectional(
          end: BorderSide(
            color: AppColors.border(context),
            width: 1.2,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 6,
                  offset: const Offset(1, 0),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس القائمة الجانبية واللوجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const TaskyLogo.emblem(size: 32),
                const SizedBox(width: 10),
                Text(
                  'TaskyW',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : AppColors.brandDeep,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // قائمة التصفح الشجرية
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: [
                // 1. قسم الفلاتر الذكية (Smart Filters)
                SidebarSmartFilters(
                  selectedFilter: selectedFilter,
                  todayCount: todayCount,
                  upcomingCount: upcomingCount,
                  waitingCount: waitingCount,
                  urgentCount: urgentCount,
                  onSelectFilter: onSelectFilter,
                ),

                const SizedBox(height: 16),

                // 2. قسم شجرة المجالات والمشاريع (Areas & Projects Tree)
                SidebarAreasTree(
                  areas: areas,
                  projects: projects,
                  selectedAreaId: selectedAreaId,
                  selectedProjectId: selectedProjectId,
                  areaTaskCounts: areaTaskCounts,
                  projectTaskCounts: projectTaskCounts,
                  onAddNewArea: onAddNewArea,
                  onAddNewProject: onAddNewProject,
                  onSelectArea: onSelectArea,
                  onSelectProject: onSelectProject,
                ),

                const SizedBox(height: 16),

                // 3. قسم الوسوم والتصنيفات (Tags & Labels)
                SidebarTagsSection(
                  tags: tags,
                  selectedTagId: selectedTagId,
                  tagTaskCounts: tagTaskCounts,
                  onSelectTag: onSelectTag,
                  onAddTag: onAddTag,
                ),

                const SizedBox(height: 16),

                // 4. قسم الملاحظات العامة (Resources & Knowledge Vault)
                SidebarSectionHeader(l10n.sidebarNotesSection),
                SidebarFilterTile(
                  icon: Icons.auto_stories_outlined,
                  iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                  title: l10n.sidebarNotesTitle,
                  count: null,
                  isSelected: notesSelected,
                  onTap: () => onSelectNotes?.call(),
                ),

                const SizedBox(height: 16),

                // 5. قسم السجل المالي والتسويات (Financial Logs & Settlements)
                SidebarSectionHeader(l10n.sidebarFinanceSection),
                SidebarFilterTile(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  title: l10n.sidebarFinanceTitle,
                  count: pendingInvoicesCount > 0 ? pendingInvoicesCount : null,
                  isSelected: financeSelected,
                  onTap: () => onSelectFinance?.call(),
                ),

                const SizedBox(height: 16),

                // 6. قسم الكيانات والمشاريع المشتركة معي (Shared with Me)
                SidebarSharedSection(onSelectSharedEntity: onSelectSharedEntity),

                const SizedBox(height: 16),

                // 7. قسم الأرشيف وسلة المهملات (Archive & Trash Bin)
                SidebarSectionHeader(l10n.sidebarArchiveSection),
                SidebarFilterTile(
                  icon: Icons.archive_outlined,
                  iconColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                  title: l10n.sidebarArchiveTitle,
                  count: archivedCount > 0 ? archivedCount : null,
                  isSelected: archiveSelected,
                  onTap: () => onSelectArchive?.call(),
                ),
                SidebarFilterTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: Colors.redAccent,
                  title: l10n.sidebarTrashTitle,
                  count: trashCount > 0 ? trashCount : null,
                  isSelected: trashSelected,
                  onTap: () => onSelectTrash?.call(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // الجزء السفلي: مبدل الثيم وبطاقة الحساب
          const SidebarUserFooter(),
        ],
      ),
    );
  }
}