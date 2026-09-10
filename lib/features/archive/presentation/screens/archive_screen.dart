import 'package:flutter/material.dart';

import '../../../../core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../../../tasks/presentation/controllers/tasks_controller.dart';
import '../widgets/archive_item_card.dart';

/// شاشة الأرشيف العام (Global Archive View):
/// تعرض المهام والمشاريع والملاحظات المؤرشفة مع إمكانية استرجاعها بضغطة زر.
class ArchiveScreen extends StatefulWidget {
  final TasksController? tasksController;
  final ProjectsController? projectsController;
  final NotesController? notesController;

  const ArchiveScreen({
    super.key,
    this.tasksController,
    this.projectsController,
    this.notesController,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  late final TasksController _tasksController;
  late final ProjectsController _projectsController;
  late final NotesController _notesController;
  late final bool _ownsTasksController;
  late final bool _ownsProjectsController;
  late final bool _ownsNotesController;

  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _ownsTasksController = widget.tasksController == null;
    _tasksController = widget.tasksController ?? TasksController();

    _ownsProjectsController = widget.projectsController == null;
    _projectsController = widget.projectsController ?? ProjectsController();

    _ownsNotesController = widget.notesController == null;
    _notesController = widget.notesController ?? NotesController();

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _tasksController.loadArchivedTasks(),
      _projectsController.loadArchivedProjects(),
      _notesController.load(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    if (_ownsTasksController) _tasksController.dispose();
    if (_ownsProjectsController) _projectsController.dispose();
    if (_ownsNotesController) _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // شريط العنوان العلوي
            _buildHeader(context, isDark),

            // شريط البحث والتبويب
            _buildFilterAndTabs(context, isDark),

            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArchivedTasksTab(isDark),
                  _buildArchivedProjectsTab(isDark),
                  _buildArchivedNotesTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.archive_outlined,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.archiveGlobalTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.archiveGlobalSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.l10n.archiveRefresh,
            onPressed: _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndTabs(BuildContext context, bool isDark) {
    return Container(
      color: AppColors.surface(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // حقل البحث السريع
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: context.l10n.archiveSearchHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // تبويبات المهام، المشاريع، الملاحظات
          TabBar(
            controller: _tabController,
            labelColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            unselectedLabelColor: AppColors.textSecondary(context),
            indicatorColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            tabs: [
              Tab(
                child: ListenableBuilder(
                  listenable: _tasksController,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.task_alt, size: 18),
                      const SizedBox(width: 6),
                      Text(context.l10n.tabsTasks(_tasksController.archivedCount)),
                    ],
                  ),
                ),
              ),
              Tab(
                child: ListenableBuilder(
                  listenable: _projectsController,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_special_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(context.l10n.tabsProjects(_projectsController.archivedCount)),
                    ],
                  ),
                ),
              ),
              Tab(
                child: ListenableBuilder(
                  listenable: _notesController,
                  builder: (context, _) {
                    final archivedNotesCount =
                        _notesController.notes.where((n) => n.isArchived).length;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 18),
                        const SizedBox(width: 6),
                        Text(context.l10n.tabsNotes(archivedNotesCount)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تبويب المهام المؤرشفة
  Widget _buildArchivedTasksTab(bool isDark) {
    return ListenableBuilder(
      listenable: _tasksController,
      builder: (context, _) {
        if (_tasksController.isLoadingArchived) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = _tasksController.archivedTasks.where((t) {
          if (_searchQuery.isEmpty) return true;
          return t.title.toLowerCase().contains(_searchQuery) ||
              (t.description?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (tasks.isEmpty) {
          return EmptyStateView(
            icon: Icons.archive_outlined,
            title: _searchQuery.isEmpty ? context.l10n.archiveEmptyTasks : context.l10n.noMatchingResults,
            subtitle: _searchQuery.isEmpty
                ? context.l10n.archiveTasksEmptyDesc
                : context.l10n.tryOtherKeywords,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ArchiveItemCard(
              leading: Icon(
                Icons.inventory_2_outlined,
                color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
                size: 22,
              ),
              title: task.title,
              subtitle: task.description,
              actionLabel: context.l10n.archiveRestoreToActive,
              onAction: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restoredMsg = context.l10n.restoredTaskToast(task.title);
                final success = await _tasksController.unarchiveTask(task.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(restoredMsg),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // تبويب المشاريع المؤرشفة
  Widget _buildArchivedProjectsTab(bool isDark) {
    return ListenableBuilder(
      listenable: _projectsController,
      builder: (context, _) {
        if (_projectsController.isLoadingArchived) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = _projectsController.archivedProjects.where((p) {
          if (_searchQuery.isEmpty) return true;
          return p.name.toLowerCase().contains(_searchQuery) ||
              (p.description?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (projects.isEmpty) {
          return EmptyStateView(
            icon: Icons.folder_special_outlined,
            title: _searchQuery.isEmpty ? context.l10n.archiveEmptyProjects : context.l10n.noMatchingResults,
            subtitle: _searchQuery.isEmpty
                ? context.l10n.archiveProjectsEmptyDesc
                : context.l10n.tryOtherKeywords,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: projects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final project = projects[index];
            return ArchiveItemCard(
              leading: Text(project.iconEmoji, style: const TextStyle(fontSize: 22)),
              title: project.name,
              subtitle: project.description,
              actionLabel: context.l10n.restoreProject,
              onAction: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restoredMsg = context.l10n.restoredProjectToast(project.name);
                final success = await _projectsController.unarchiveProject(project.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(restoredMsg),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // تبويب الملاحظات المؤرشفة
  Widget _buildArchivedNotesTab(bool isDark) {
    return ListenableBuilder(
      listenable: _notesController,
      builder: (context, _) {
        if (_notesController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = _notesController.notes.where((n) {
          if (!n.isArchived) return false;
          if (_searchQuery.isEmpty) return true;
          return n.title.toLowerCase().contains(_searchQuery) ||
              (n.content?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (notes.isEmpty) {
          return EmptyStateView(
            icon: Icons.note_alt_outlined,
            title: _searchQuery.isEmpty ? context.l10n.archiveEmptyNotes : context.l10n.noMatchingResults,
            subtitle: _searchQuery.isEmpty
                ? context.l10n.archiveNotesEmptyDesc
                : context.l10n.tryOtherKeywords,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final note = notes[index];
            return ArchiveItemCard(
              leading: const Icon(Icons.sticky_note_2_outlined, color: Colors.amber, size: 22),
              title: note.title,
              subtitle: note.content,
              actionLabel: context.l10n.unarchive,
              onAction: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restoredMsg = context.l10n.restoredNoteToast(note.title);
                final success = await _notesController.setArchived(note.id, false);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(restoredMsg),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
