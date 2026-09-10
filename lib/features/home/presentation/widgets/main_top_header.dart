import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/sync_status_button.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tasky/features/auth/presentation/screens/auth_screen.dart';

/// ويدجت شريط الرأس العلوي ومحرك البحث المتجاوب مع أحجام الشاشات المختلفة
class MainTopHeader extends StatelessWidget {
  final String currentContextTitle;
  final String searchHint;
  final TextEditingController searchController;
  final bool isSearchActive;
  final bool isMobileSearchOpen;
  final bool forceGlobalSearch;
  final bool isAreaOrProjectSelected;
  final String viewMode;
  final Future<void> Function()? onSyncRequested;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCloseMobileSearch;
  final VoidCallback onOpenMobileSearch;
  final VoidCallback onToggleGlobalSearch;
  final ValueChanged<String> onViewModeChanged;
  final VoidCallback onExportCsv;
  final VoidCallback onAddTask;

  const MainTopHeader({
    super.key,
    required this.currentContextTitle,
    required this.searchHint,
    required this.searchController,
    required this.isSearchActive,
    required this.isMobileSearchOpen,
    required this.forceGlobalSearch,
    required this.isAreaOrProjectSelected,
    required this.viewMode,
    this.onSyncRequested,
    required this.onSearchChanged,
    required this.onCloseMobileSearch,
    required this.onOpenMobileSearch,
    required this.onToggleGlobalSearch,
    required this.onViewModeChanged,
    required this.onExportCsv,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 900;
        final isMobile = screenWidth < 600;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final headerDecoration = BoxDecoration(
          color: AppColors.surface(context),
          border: Border(
            bottom: BorderSide(
              color: AppColors.border(context),
              width: 1.2,
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        );

        // 1. وضع البحث الممتد بالكامل على شاشات الموبايل
        if (isMobile && isMobileSearchOpen) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: headerDecoration,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: context.l10n.closeSearch,
                  onPressed: onCloseMobileSearch,
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (isAreaOrProjectSelected && isSearchActive) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(forceGlobalSearch ? Icons.filter_alt_off : Icons.public, size: 20),
                    tooltip: forceGlobalSearch ? context.l10n.cancelGlobalSearch : context.l10n.globalSearchInApp,
                    onPressed: onToggleGlobalSearch,
                  ),
                ],
              ],
            ),
          );
        }

        // 2. الهيدر المدمج لشاشات الموبايل (< 600px)
        if (isMobile) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: headerDecoration,
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    tooltip: context.l10n.sidebarMenu,
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                Expanded(
                  child: Text(
                    currentContextTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  tooltip: context.l10n.commonSearch,
                  onPressed: onOpenMobileSearch,
                ),
                IconButton(
                  icon: Icon(
                    viewMode == 'list'
                        ? Icons.view_kanban_rounded
                        : viewMode == 'kanban'
                            ? Icons.table_chart_rounded
                            : Icons.view_list_rounded,
                    size: 20,
                  ),
                  tooltip: viewMode == 'list'
                      ? context.l10n.viewKanban
                      : viewMode == 'kanban'
                          ? context.l10n.viewTable
                          : context.l10n.viewList,
                  onPressed: () {
                    if (viewMode == 'list') {
                      onViewModeChanged('kanban');
                    } else if (viewMode == 'kanban') {
                      onViewModeChanged('table');
                    } else {
                      onViewModeChanged('list');
                    }
                  },
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  tooltip: context.l10n.exportCsvTooltip,
                  onPressed: onExportCsv,
                ),
                const SizedBox(width: 2),
                SyncStatusButton(
                  onTriggerSync: onSyncRequested,
                  compact: true,
                ),
                const SizedBox(width: 4),
                _buildAuthButton(context, isCompact: true),
              ],
            ),
          );
        }

        // 3. الهيدر للتابلت والشاشات الكبيرة (Desktop & Tablet)
        final bool isWide = screenWidth >= 800;
        final bool isMedium = screenWidth >= 550;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: headerDecoration,
          child: Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Expanded(
                flex: isWide ? 2 : 3,
                child: Text(
                  currentContextTitle,
                  style: TextStyle(fontSize: isWide ? 18 : 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: isWide ? 3 : 4,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              if (isAreaOrProjectSelected && isSearchActive) ...[
                const SizedBox(width: 6),
                isWide
                    ? TextButton.icon(
                        icon: Icon(forceGlobalSearch ? Icons.filter_alt_off : Icons.public, size: 16),
                        label: Text(forceGlobalSearch ? context.l10n.cancelGlobalShort : context.l10n.globalSearch),
                        onPressed: onToggleGlobalSearch,
                      )
                    : IconButton(
                        icon: Icon(forceGlobalSearch ? Icons.filter_alt_off : Icons.public, size: 18),
                        tooltip: forceGlobalSearch ? context.l10n.cancelGlobalShort : context.l10n.globalSearch,
                        onPressed: onToggleGlobalSearch,
                      ),
              ],
              const SizedBox(width: 8),
              if (isMedium)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'list', icon: Icon(Icons.view_list_rounded, size: 16)),
                    ButtonSegment(value: 'kanban', icon: Icon(Icons.view_kanban_rounded, size: 16)),
                    ButtonSegment(value: 'table', icon: Icon(Icons.table_chart_rounded, size: 16)),
                  ],
                  selected: {viewMode},
                  onSelectionChanged: (set) => onViewModeChanged(set.first),
                )
              else
                IconButton(
                  icon: Icon(
                    viewMode == 'list'
                        ? Icons.view_kanban_rounded
                        : viewMode == 'kanban'
                            ? Icons.table_chart_rounded
                            : Icons.view_list_rounded,
                    size: 20,
                  ),
                  tooltip: viewMode == 'list'
                      ? context.l10n.viewKanban
                      : viewMode == 'kanban'
                          ? context.l10n.viewTable
                          : context.l10n.viewList,
                  onPressed: () {
                    if (viewMode == 'list') {
                      onViewModeChanged('kanban');
                    } else if (viewMode == 'kanban') {
                      onViewModeChanged('table');
                    } else {
                      onViewModeChanged('list');
                    }
                  },
                ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.download_rounded, size: 20),
                tooltip: context.l10n.exportCsvCurrentTooltip,
                onPressed: onExportCsv,
              ),
              const SizedBox(width: 4),
              SyncStatusButton(
                onTriggerSync: onSyncRequested,
                compact: !isWide,
              ),
              const SizedBox(width: 6),
              if (isWide)
                ElevatedButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.newTask),
                )
              else
                IconButton.filled(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: context.l10n.newTask,
                ),
              const SizedBox(width: 6),
              _buildAuthButton(context, isCompact: !isWide),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthButton(BuildContext context, {bool isCompact = false}) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        if (auth.isAuthenticated) {
          return PopupMenuButton<String>(
            tooltip: context.l10n.profileTitle,
            onSelected: (val) {
              if (val == 'signout') {
                auth.signOut();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.displayName ?? context.l10n.taskyUser, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(context.l10n.signOut, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: isCompact ? 14 : 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (auth.displayName?.isNotEmpty == true ? auth.displayName![0] : 'U').toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 11 : 13,
                ),
              ),
            ),
          );
        }

        if (isCompact) {
          return IconButton(
            icon: const Icon(Icons.person_outline, size: 22),
            tooltip: context.l10n.signIn,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          );
        }

        return OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
          },
          icon: const Icon(Icons.person_outline, size: 18),
          label: Text(context.l10n.signIn),
        );
      },
    );
  }
}
