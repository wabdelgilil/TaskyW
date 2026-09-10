import 'package:flutter/material.dart';

import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';

/// رأس موحّد لأقسام القائمة الجانبية (Section Header)
class SidebarSectionHeader extends StatelessWidget {
  final String title;

  const SidebarSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
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
}

/// عنصر تصفية موحّد يُستخدم في الفلاتر السريعة وبقية أقسام القائمة الجانبية
class SidebarFilterTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarFilterTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int? badgeCount = count;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
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
                      : AppColors.textPrimary(context),
                ),
              ),
            ),
            if (badgeCount != null && badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : (isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// قسم الفلاتر السريعة (Smart Filters): اليوم، القادمة، معلّقة، عاجل، جميع المهام
class SidebarSmartFilters extends StatelessWidget {
  final String? selectedFilter;
  final int todayCount;
  final int upcomingCount;
  final int waitingCount;
  final int urgentCount;
  final void Function(String filter) onSelectFilter;

  const SidebarSmartFilters({
    super.key,
    this.selectedFilter,
    this.todayCount = 0,
    this.upcomingCount = 0,
    this.waitingCount = 0,
    this.urgentCount = 0,
    required this.onSelectFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarSectionHeader(l10n.smartFiltersHeader),
        SidebarFilterTile(
          icon: Icons.wb_sunny_rounded,
          iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), // Amber 400 vs 600
          title: l10n.smartFilterToday,
          count: todayCount,
          isSelected: selectedFilter == 'today',
          onTap: () => onSelectFilter('today'),
        ),
        SidebarFilterTile(
          icon: Icons.calendar_month_rounded,
          iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7), // Sky 400 vs 600 (عالي التباين)
          title: l10n.smartFilterUpcoming,
          count: upcomingCount,
          isSelected: selectedFilter == 'upcoming',
          onTap: () => onSelectFilter('upcoming'),
        ),
        SidebarFilterTile(
          icon: Icons.pause_circle_filled_rounded,
          iconColor: AppColors.adaptiveStatusColor('waiting', isDark),
          title: l10n.smartFilterWaiting,
          count: waitingCount,
          isSelected: selectedFilter == 'waiting',
          onTap: () => onSelectFilter('waiting'),
        ),
        SidebarFilterTile(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColors.adaptivePriorityColor('urgent', isDark),
          title: l10n.smartFilterUrgent,
          count: urgentCount,
          isSelected: selectedFilter == 'urgent',
          onTap: () => onSelectFilter('urgent'),
        ),
        SidebarFilterTile(
          icon: Icons.all_inbox_rounded,
          iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF0D9488), // Teal/Emerald 400 vs 600
          title: l10n.smartFilterAll,
          count: null,
          isSelected: selectedFilter == 'all',
          onTap: () => onSelectFilter('all'),
        ),
      ],
    );
  }
}