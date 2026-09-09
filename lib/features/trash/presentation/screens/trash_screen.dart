import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/repositories/note_repository_impl.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/controllers/tasks_controller.dart';

/// شاشة سلة المهملات (Global Trash Screen):
/// تعرض جميع العناصر المحذوفة ناعماً (مهام، مشاريع، ملاحظات) مع خيارات الاستعادة
/// أو الحذف النهائي الفردي أو الإفراغ الكامل للسلة.
class TrashScreen extends StatefulWidget {
  final TasksController? tasksController;
  final ProjectsController? projectsController;
  final NotesController? notesController;
  final INoteRepository? noteRepository;

  const TrashScreen({
    super.key,
    this.tasksController,
    this.projectsController,
    this.notesController,
    this.noteRepository,
  });

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen>
    with SingleTickerProviderStateMixin {
  late final TasksController _tasksController;
  late final ProjectsController _projectsController;
  late final NotesController _notesController;
  late final INoteRepository _noteRepository;
  late final bool _ownsTasksController;
  late final bool _ownsProjectsController;
  late final bool _ownsNotesController;

  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // سلة الملاحظات المحذوفة ناعماً
  List<NoteModel> _trashNotes = [];
  bool _isLoadingTrashNotes = false;

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

    _noteRepository = widget.noteRepository ?? NoteRepositoryImpl();

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _tasksController.loadTrashTasks(),
      _projectsController.loadTrashProjects(),
      _loadTrashNotes(),
    ]);
    if (mounted) setState(() {});
  }

  Future<void> _loadTrashNotes() async {
    setState(() => _isLoadingTrashNotes = true);
    try {
      final all = await _noteRepository.getNotes(includeArchived: true);
      if (mounted) {
        setState(() {
          _trashNotes = all.where((n) => n.deletedAt != null).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingTrashNotes = false);
    }
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

  int get _totalTrashCount =>
      _tasksController.trashCount +
      _projectsController.trashCount +
      _trashNotes.length;

  Future<void> _confirmEmptyTrash() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'إفراغ سلة المهملات بالكامل؟',
      message:
          'سيتم حذف جميع المهام والمشاريع الموجودة في سلة المهملات نهائياً وبلا رجعة. هل تريد الاستمرار؟',
      confirmLabel: 'إفراغ السلة نهائياً',
    );

    if (confirmed == true) {
      await _tasksController.emptyTrash();
      await _projectsController.emptyProjectTrash();
      await _loadData();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('تم إفراغ سلة المهملات بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // الرأس مع زر إفراغ السلة
            _buildHeader(context, isDark),

            // شريط البحث والتبويب
            _buildFilterAndTabs(context, isDark),

            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTrashTasksTab(isDark),
                  _buildTrashProjectsTab(isDark),
                  _buildTrashNotesTab(isDark),
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
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلة المهملات (Trash Bin)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'العناصر المحذوفة محفوظة هنا مؤقتاً؛ يمكنك استعادتها أو حذفها نهائياً لتوفير المساحة',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_totalTrashCount > 0)
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text('إفراغ السلة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: _confirmEmptyTrash,
            ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث سلة المهملات',
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
          // حقل البحث
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'البحث في سلة المهملات...',
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
            labelColor: Colors.redAccent,
            unselectedLabelColor: AppColors.textSecondary(context),
            indicatorColor: Colors.redAccent,
            tabs: [
              Tab(
                child: ListenableBuilder(
                  listenable: _tasksController,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.task_alt, size: 18),
                      const SizedBox(width: 6),
                      Text('المهام (${_tasksController.trashCount})'),
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
                      const Icon(Icons.folder_open_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('المشاريع (${_projectsController.trashCount})'),
                    ],
                  ),
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('الملاحظات (${_trashNotes.length})'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تبويب المهام في السلة
  Widget _buildTrashTasksTab(bool isDark) {
    return ListenableBuilder(
      listenable: _tasksController,
      builder: (context, _) {
        if (_tasksController.isLoadingTrash) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = _tasksController.trashTasks.where((t) {
          if (_searchQuery.isEmpty) return true;
          return t.title.toLowerCase().contains(_searchQuery) ||
              (t.description?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (tasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.delete_outline_rounded,
            title: _searchQuery.isEmpty ? 'سلة المهام فارغة' : 'لا توجد نتائج مطابقة',
            subtitle: _searchQuery.isEmpty
                ? 'أي مهمة يتم حذفها ستُحفظ هنا ويمكن استعادتها بأي وقت.'
                : 'جرّب البحث بكلمات أخرى.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTrashTaskCard(context, task, isDark);
          },
        );
      },
    );
  }

  Widget _buildTrashTaskCard(BuildContext context, TaskModel task, bool isDark) {
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
            const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
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
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
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
            // زر استعادة
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded, color: Colors.green, size: 22),
              tooltip: 'استعادة المهمة',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await _tasksController.restoreTask(task.id);
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
            // زر حذف نهائي
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
              tooltip: 'حذف نهائي',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final confirmed = await ConfirmDeleteDialog.show(
                  context,
                  title: 'حذف المهمة نهائياً؟',
                  message: 'لن تتمكن من استعادة المهمة "${task.title}" بعد الحذف النهائي.',
                );
                if (confirmed == true) {
                  await _tasksController.permanentlyDeleteTask(task.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('تم حذف المهمة نهائياً')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // تبويب المشاريع في السلة
  Widget _buildTrashProjectsTab(bool isDark) {
    return ListenableBuilder(
      listenable: _projectsController,
      builder: (context, _) {
        if (_projectsController.isLoadingTrash) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = _projectsController.trashProjects.where((p) {
          if (_searchQuery.isEmpty) return true;
          return p.name.toLowerCase().contains(_searchQuery) ||
              (p.description?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (projects.isEmpty) {
          return _buildEmptyState(
            icon: Icons.folder_delete_outlined,
            title: _searchQuery.isEmpty ? 'سلة المشاريع فارغة' : 'لا توجد نتائج مطابقة',
            subtitle: _searchQuery.isEmpty
                ? 'المشاريع المحذوفة تظهر هنا لحين استعادتها أو مسحها نهائياً.'
                : 'جرّب البحث بكلمات أخرى.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: projects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildTrashProjectCard(context, project, isDark);
          },
        );
      },
    );
  }

  Widget _buildTrashProjectCard(
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
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.description!,
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
            // زر استعادة
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded, color: Colors.green, size: 22),
              tooltip: 'استعادة المشروع',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await _projectsController.restoreProject(project.id);
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
            // زر حذف نهائي
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 22),
              tooltip: 'حذف نهائي',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final confirmed = await ConfirmDeleteDialog.show(
                  context,
                  title: 'حذف المشروع نهائياً؟',
                  message: 'لن تتمكن من استعادة المشروع "${project.name}" بعد الحذف النهائي.',
                );
                if (confirmed == true) {
                  await _projectsController.permanentlyDeleteProject(project.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('تم حذف المشروع نهائياً')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // تبويب الملاحظات في السلة
  Widget _buildTrashNotesTab(bool isDark) {
    if (_isLoadingTrashNotes) {
      return const Center(child: CircularProgressIndicator());
    }

    final notes = _trashNotes.where((n) {
      if (_searchQuery.isEmpty) return true;
      return n.title.toLowerCase().contains(_searchQuery) ||
          (n.content?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_alt_outlined,
        title: _searchQuery.isEmpty ? 'سلة الملاحظات فارغة' : 'لا توجد نتائج مطابقة',
        subtitle: _searchQuery.isEmpty
            ? 'الملاحظات المحذوفة ناعماً تظهر هنا.'
            : 'جرّب البحث بكلمات أخرى.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildTrashNoteCard(context, note, isDark);
      },
    );
  }

  Widget _buildTrashNoteCard(BuildContext context, NoteModel note, bool isDark) {
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
            const Icon(Icons.sticky_note_2_outlined, color: Colors.grey, size: 22),
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
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (note.content != null && note.content!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note.content!,
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
            // زر استعادة
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded, color: Colors.green, size: 22),
              tooltip: 'استعادة الملاحظة',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restored = note.copyWith(
                  deletedAt: null,
                  syncStatus: 'pending_update',
                  updatedAt: DateTime.now().toUtc(),
                );
                await _noteRepository.updateNote(restored);
                await _loadTrashNotes();
                if (mounted) {
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
