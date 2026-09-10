import 'package:flutter/material.dart';

import '../../../../core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/repositories/note_repository_impl.dart';
import '../../../notes/presentation/controllers/notes_controller.dart';
import '../../../projects/presentation/controllers/projects_controller.dart';
import '../../../tasks/presentation/controllers/tasks_controller.dart';
import '../widgets/trash_item_card.dart';

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
      title: context.l10n.emptyTrashConfirmTitle,
      message: context.l10n.emptyTrashConfirmBody,
      confirmLabel: context.l10n.emptyTrashConfirmAction,
    );

    if (confirmed == true) {
      await _tasksController.emptyTrash();
      await _projectsController.emptyProjectTrash();
      await _loadData();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.trashEmptiedToast)),
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
              color: Colors.redAccent.withValues(alpha: 0.12),
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
                  context.l10n.trashTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.trashSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // زر إفراغ السلة بالكامل
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red),
            label: Text(context.l10n.emptyTrash, style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: _totalTrashCount > 0 ? _confirmEmptyTrash : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.l10n.refreshTrash,
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
              hintText: context.l10n.trashSearchHint,
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
                      Text(context.l10n.tabsTasks(_tasksController.trashCount)),
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
                      const Icon(Icons.folder_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(context.l10n.tabsProjects(_projectsController.trashCount)),
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
                    Text(context.l10n.tabsNotes(_trashNotes.length)),
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
          return EmptyStateView(
            icon: Icons.delete_outline_rounded,
            title: _searchQuery.isEmpty ? context.l10n.trashTasksEmpty : context.l10n.noMatchingResults,
            subtitle: _searchQuery.isEmpty
                ? context.l10n.trashTasksEmptyDesc
                : context.l10n.tryOtherKeywords,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TrashItemCard(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 22),
              title: task.title,
              subtitle: task.description,
              restoreTooltip: context.l10n.restoreTask,
              deleteTooltip: context.l10n.deletePermanent,
              onRestore: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restoredMsg = context.l10n.restoredTaskToast(task.title);
                final success = await _tasksController.restoreTask(task.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(restoredMsg),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onPermanentDelete: () async {
                final messenger = ScaffoldMessenger.of(context);
                final deletedToast = context.l10n.taskDeletedPermanentToast;
                final confirmed = await ConfirmDeleteDialog.show(
                  context,
                  title: context.l10n.deleteTaskPermanentConfirm,
                  message: context.l10n.cannotRestoreTaskMsg(task.title),
                );
                if (confirmed == true) {
                  await _tasksController.permanentlyDeleteTask(task.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(deletedToast)),
                    );
                  }
                }
              },
            );
          },
        );
      },
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
          return EmptyStateView(
            icon: Icons.folder_delete_outlined,
            title: _searchQuery.isEmpty ? context.l10n.trashProjectsEmpty : context.l10n.noMatchingResults,
            subtitle: _searchQuery.isEmpty
                ? context.l10n.trashProjectsEmptyDesc
                : context.l10n.tryOtherKeywords,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: projects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final project = projects[index];
            return TrashItemCard(
              leading: Text(project.iconEmoji, style: const TextStyle(fontSize: 22)),
              title: project.name,
              subtitle: project.description,
              restoreTooltip: context.l10n.restoreProject,
              deleteTooltip: context.l10n.deletePermanent,
              onRestore: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restoredMsg = context.l10n.restoredProjectToast(project.name);
                final success = await _projectsController.restoreProject(project.id);
                if (mounted && success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(restoredMsg),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onPermanentDelete: () async {
                final messenger = ScaffoldMessenger.of(context);
                final deletedToast = context.l10n.projectDeletedPermanentToast;
                final confirmed = await ConfirmDeleteDialog.show(
                  context,
                  title: context.l10n.deleteProjectPermanentConfirm,
                  message: context.l10n.cannotRestoreProjectMsg(project.name),
                );
                if (confirmed == true) {
                  await _projectsController.permanentlyDeleteProject(project.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(deletedToast)),
                    );
                  }
                }
              },
            );
          },
        );
      },
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
      return EmptyStateView(
        icon: Icons.note_alt_outlined,
        title: _searchQuery.isEmpty ? context.l10n.trashNotesEmpty : context.l10n.noMatchingResults,
        subtitle: _searchQuery.isEmpty
            ? context.l10n.trashNotesEmptyDesc
            : context.l10n.tryOtherKeywords,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = notes[index];
        return TrashItemCard(
          leading: const Icon(Icons.sticky_note_2_outlined, color: Colors.grey, size: 22),
          title: note.title,
          subtitle: note.content,
          restoreTooltip: context.l10n.restoreNote,
          onRestore: () async {
            final messenger = ScaffoldMessenger.of(context);
            final restoredMsg = context.l10n.restoredNoteToast(note.title);
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
                  content: Text(restoredMsg),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}
