import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/area_model.dart';
import '../../../projects/data/models/project_model.dart';

/// الشجرة الهرمية التفاعلية للقائمة الجانبية (Hierarchical Tree Sidebar)
class HierarchicalTreeSidebar extends StatefulWidget {
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final String? selectedFilter; // 'today', 'upcoming', 'waiting', 'urgent', 'all'
  final String? selectedAreaId;
  final String? selectedProjectId;
  final Map<String, int> areaTaskCounts;
  final Map<String, int> projectTaskCounts;
  final int todayCount;
  final int upcomingCount;
  final int waitingCount;
  final int urgentCount;
  final Function(String filter) onSelectFilter;
  final Function(AreaModel area) onSelectArea;
  final Function(ProjectModel project) onSelectProject;
  final VoidCallback? onAddNewArea;
  final Function(String areaId)? onAddNewProject;

  const HierarchicalTreeSidebar({
    super.key,
    required this.areas,
    required this.projects,
    this.selectedFilter,
    this.selectedAreaId,
    this.selectedProjectId,
    this.areaTaskCounts = const {},
    this.projectTaskCounts = const {},
    this.todayCount = 0,
    this.upcomingCount = 0,
    this.waitingCount = 0,
    this.urgentCount = 0,
    required this.onSelectFilter,
    required this.onSelectArea,
    required this.onSelectProject,
    this.onAddNewArea,
    this.onAddNewProject,
  });

  @override
  State<HierarchicalTreeSidebar> createState() => _HierarchicalTreeSidebarState();
}

class _HierarchicalTreeSidebarState extends State<HierarchicalTreeSidebar> {
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

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          left: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس القائمة الجانبية واللوجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tasky 3.0',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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
                _buildSectionHeader('الفلاتر السريعة'),
                _buildSmartFilterTile(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: Colors.amber,
                  title: 'اليوم',
                  count: widget.todayCount,
                  isSelected: widget.selectedFilter == 'today',
                  onTap: () => widget.onSelectFilter('today'),
                ),
                _buildSmartFilterTile(
                  icon: Icons.calendar_month_rounded,
                  iconColor: Colors.blueAccent,
                  title: 'القادمة',
                  count: widget.upcomingCount,
                  isSelected: widget.selectedFilter == 'upcoming',
                  onTap: () => widget.onSelectFilter('upcoming'),
                ),
                _buildSmartFilterTile(
                  icon: Icons.pause_circle_filled_rounded,
                  iconColor: AppColors.statusWaiting,
                  title: 'معلّقة (Waiting)',
                  count: widget.waitingCount,
                  isSelected: widget.selectedFilter == 'waiting',
                  onTap: () => widget.onSelectFilter('waiting'),
                ),
                _buildSmartFilterTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.priorityUrgent,
                  title: 'عاجل (Urgent)',
                  count: widget.urgentCount,
                  isSelected: widget.selectedFilter == 'urgent',
                  onTap: () => widget.onSelectFilter('urgent'),
                ),
                _buildSmartFilterTile(
                  icon: Icons.all_inbox_rounded,
                  iconColor: Colors.teal,
                  title: 'جميع المهام',
                  count: null,
                  isSelected: widget.selectedFilter == 'all',
                  onTap: () => widget.onSelectFilter('all'),
                ),

                const SizedBox(height: 16),

                // 2. قسم شجرة المجالات والمشاريع (Areas & Projects Tree)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('المجالات والمشاريع'),
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
                  final isAreaSelected = widget.selectedAreaId == area.id && widget.selectedProjectId == null;
                  final areaColor = AppColors.fromHex(area.colorHex);
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
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                                final projColor = AppColors.fromHex(proj.colorHex);
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
                                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (pTaskCount > 0)
                                          Text(
                                            '$pTaskCount',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                                      Icon(Icons.add, size: 14, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        'مشروع جديد...',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
            ),
          ),

          const Divider(height: 1),

          // 3. الجزء السفلي: مبدل الثيم والخيارات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ListenableBuilder(
                  listenable: ThemeController.instance,
                  builder: (context, _) {
                    final isDarkNow = ThemeController.instance.isDarkMode;
                    return IconButton(
                      icon: Icon(
                        isDarkNow ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                      ),
                      tooltip: isDarkNow ? 'الوضع النهاري' : 'الوضع الليلي',
                      onPressed: () => ThemeController.instance.toggleTheme(),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Text(
                  isDark ? 'الوضع الليلي' : 'الوضع النهاري',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSmartFilterTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: isSelected ? Theme.of(context).colorScheme.primary : iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
            if (count != null && count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : (isDark ? Colors.black38 : Colors.black.withOpacity(0.06)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
