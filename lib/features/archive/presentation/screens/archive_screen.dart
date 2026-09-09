import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/controllers/tasks_controller.dart';

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
                  .withOpacity(0.15),
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
                  'الأرشيف العام (Global Archive)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'المهام والمشاريع والملاحظات المنتهية المحفوظة للرجوع إليها دون تشويش مساحات العمل اليومية',
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
            tooltip: 'تحديث الأرشيف',
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
              hintText: 'البحث في عناصر الأرشيف...',
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
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
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
                      Text('المهام (${_tasksController.archivedCount})'),
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
                      Text('المشاريع (${_projectsController.archivedCount})'),
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
                        Text('الملاحظات ($archivedNotesCount)'),
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
          return _buildEmptyState(
            icon: Icons.archive_outlined,
            title: _searchQuery.isEmpty ? 'لا توجد مهام مؤرشفة' : 'لا توجد نتائج مطابقة',
            subtitle: _searchQuery.isEmpty
                ? 'عند أرشفة أي مهمة ستظهر هنا للرجوع إليها مستقبلاً.'
                : 'جرّب البحث بكلمات أخرى.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskArchiveCard(context, task, isDark);
          },
        );
      },
    );
  }

  Widget _buildTaskArchiveCard(BuildContext context, TaskModel task, bool isDark) {
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
            Icon(
              Icons.inventory_2_outlined,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.unarchive_outlined, size: 16),
              label: const Text('استعادة للأعمال النشطة'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await _tasksController.unarchiveTask(task.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('تمت استعادة المهمة "${task.title}" بنجاح'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
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
          return _buildEmptyState(
            icon: Icons.folder_special_outlined,
            title: _searchQuery.isEmpty ? 'لا توجد مشاريع مؤرشفة' : 'لا توجد نتائج مطابقة',
            subtitle: _searchQuery.isEmpty
                ? 'المشاريع المنتهية أو المؤرشفة ستظهر هنا للحفظ المرجعي.'
                : 'جرّب البحث بكلمات أخرى.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: projects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildProjectArchiveCard(context, project, isDark);
          },
        );
      },
    );
  }

  Widget _buildProjectArchiveCard(
      BuildContext context, ProjectModel project, bool isDark) {
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
            Text(project.iconEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.unarchive_outlined, size: 16),
              label: const Text('استعادة المشروع'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success =
                    await _projectsController.unarchiveProject(project.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('تمت استعادة المشروع "${project.name}" بنجاح'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
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
          return _buildEmptyState(
            icon: Icons.note_alt_outlined,
            title: _searchQuery.isEmpty ? 'لا توجد ملاحظات مؤرشفة' : 'لا توجد نتائج مطابقة',
            subtitle: _searchQuery.isEmpty
                ? 'ملاحظات المعرفة والتوثيق المؤرشفة تظهر هنا.'
                : 'جرّب البحث بكلمات أخرى.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final note = notes[index];
            return _buildNoteArchiveCard(context, note, isDark);
          },
        );
      },
    );
  }

  Widget _buildNoteArchiveCard(BuildContext context, NoteModel note, bool isDark) {
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
            const Icon(Icons.sticky_note_2_outlined, color: Colors.amber, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  if (note.content != null && note.content!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note.content!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.unarchive_outlined, size: 16),
              label: const Text('إلغاء الأرشفة'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await _notesController.setArchived(note.id, false);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('تمت استعادة الملاحظة "${note.title}" بنجاح'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.textMuted(context)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
