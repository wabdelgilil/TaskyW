import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasky/core/services/export_service.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/presentation/widgets/hierarchical_tree_sidebar.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/screens/settings_screen.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/features/tasks/data/models/subtask_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_detail_bottom_sheet.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_detail_drawer.dart';
import '../widgets/dialogs/add_area_dialog.dart';
import '../widgets/dialogs/add_project_dialog.dart';
import '../widgets/dialogs/add_task_dialog.dart';
import '../widgets/dialogs/create_tag_dialog.dart';
import '../widgets/dialogs/export_tasks_dialog.dart';
import '../widgets/main_top_header.dart';
import '../widgets/main_workspace_content.dart';
import '../widgets/quick_add_task_bar.dart';

/// الشاشة الهيكلية الرئيسية للتطبيق (Master Responsive Layout Screen)
/// تجمع بين الشجرة الهرمية الجانبية، شريط البحث المقيّد بالسياق، مساحة العمل، درج التفاصيل، والشريط السفلي
class MainLayoutScreen extends StatefulWidget {
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final List<TaskModel> tasks;
  final List<SubtaskModel> subtasks;
  final List<TagModel> tags;
  final Map<String, List<TagModel>> taskTags;

  final Future<void> Function()? onSyncRequested;
  final Function(TaskModel task)? onSaveTask;
  final Function(String taskId)? onDeleteTask;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, String newPriority)? onTaskPriorityChanged;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(String taskId, String title)? onAddSubtask;
  final Function(SubtaskModel subtask, bool isCompleted)? onToggleSubtask;
  final Function(String subtaskId)? onDeleteSubtask;

  final Function(AreaModel area)? onSaveArea;
  final Function(String areaId)? onDeleteArea;
  final Function(ProjectModel project)? onSaveProject;
  final Function(String projectId)? onDeleteProject;

  final Function(TaskModel task, TagModel tag)? onAssignTag;
  final Function(TaskModel task, TagModel tag)? onRemoveTag;
  final Function(String name, String colorHex)? onCreateTag;
  final Function(TagModel tag)? onDeleteTag;

  final Function(String query, {String? areaId, String? projectId})? onSearch;

  final Function(String taskId)? onRestoreTask;

  const MainLayoutScreen({
    super.key,
    required this.areas,
    required this.projects,
    required this.tasks,
    this.subtasks = const [],
    this.tags = const [],
    this.taskTags = const {},
    this.onSyncRequested,
    this.onSaveTask,
    this.onDeleteTask,
    this.onTaskStatusChanged,
    this.onTaskPriorityChanged,
    this.onToggleTaskCompleted,
    this.onAddSubtask,
    this.onToggleSubtask,
    this.onDeleteSubtask,
    this.onSaveArea,
    this.onDeleteArea,
    this.onSaveProject,
    this.onDeleteProject,
    this.onAssignTag,
    this.onRemoveTag,
    this.onCreateTag,
    this.onDeleteTag,
    this.onSearch,
    this.onRestoreTask,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  // حالات التنقل
  String _activeFilter = 'today';
  String? _selectedAreaId;
  String? _selectedProjectId;
  String? _selectedTagId;
  String? _selectedSharedTitle;
  bool _showNotes = false;
  bool _showFinance = false;
  bool _showArchive = false;
  bool _showTrash = false;

  // طريقة العرض في مساحة العمل
  String _viewMode = 'list';

  // المهمة المفتوحة حالياً في درج التفاصيل
  TaskModel? _openedTask;

  // محرك البحث
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  List<TaskModel> _searchResults = [];
  bool _forceGlobalSearch = false;
  bool _isMobileSearchOpen = false;

  // فهرس الشريط السفلي
  int _bottomNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // تصفية المهام حسب السياق النشط
  List<TaskModel> get _contextTasks {
    List<TaskModel> baseTasks;
    if (_isSearchActive) {
      baseTasks = _searchResults;
    } else if (_selectedProjectId != null) {
      baseTasks = widget.tasks.where((t) => t.projectId == _selectedProjectId).toList();
    } else if (_selectedAreaId != null) {
      final areaProjectIds = widget.projects
          .where((p) => p.areaId == _selectedAreaId)
          .map((p) => p.id)
          .toSet();
      baseTasks = widget.tasks.where((t) {
        return t.areaId == _selectedAreaId ||
            (t.projectId != null && areaProjectIds.contains(t.projectId));
      }).toList();
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_activeFilter) {
        case 'today':
          baseTasks = widget.tasks.where((t) {
            if (t.status == 'completed') return false;
            if (t.dueDate == null) return false;
            final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return d.isAtSameMomentAs(today) || d.isBefore(today);
          }).toList();
          break;
        case 'upcoming':
          baseTasks = widget.tasks.where((t) {
            if (t.status == 'completed') return false;
            if (t.dueDate == null) return false;
            final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return d.isAfter(today);
          }).toList();
          break;
        case 'waiting':
          baseTasks = widget.tasks.where((t) => t.status == 'waiting').toList();
          break;
        case 'urgent':
          baseTasks = widget.tasks.where((t) => t.priority == 'urgent' && t.status != 'completed').toList();
          break;
        case 'all':
        default:
          baseTasks = widget.tasks;
          break;
      }
    }

    if (_selectedTagId != null) {
      return baseTasks.where((t) {
        final tags = widget.taskTags[t.id] ?? const [];
        return tags.any((tag) => tag.id == _selectedTagId);
      }).toList();
    }

    return baseTasks;
  }

  // عنوان السياق الحالي
  String get _currentContextTitle {
    if (_showNotes) return '📚 الملاحظات ومستودع المعرفة (Knowledge Vault)';
    if (_showFinance) return '💰 السجل المالي والتسويات';
    if (_showArchive) return '🗄️ الأرشيف العام (Global Archive)';
    if (_showTrash) return '🗑️ سلة المهملات (Trash Bin)';
    if (_selectedTagId != null) {
      final tag = widget.tags.firstWhere(
        (t) => t.id == _selectedTagId,
        orElse: () => TagModel(id: '', name: 'وسم', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      return '🏷️ وسم: ${tag.name}';
    }
    if (_selectedProjectId != null) {
      final p = widget.projects.where((p) => p.id == _selectedProjectId).firstOrNull;
      if (p != null) return '${p.iconEmoji} ${p.name}';
      return _selectedSharedTitle ?? '💼 مشروع مشترك';
    }
    if (_selectedAreaId != null) {
      final a = widget.areas.where((a) => a.id == _selectedAreaId).firstOrNull;
      if (a != null) return '${a.iconEmoji} ${a.name}';
      return _selectedSharedTitle ?? '📁 مجال مشترك';
    }

    switch (_activeFilter) {
      case 'today':
        return '☀️ مهام اليوم';
      case 'upcoming':
        return '📅 المهام القادمة';
      case 'waiting':
        return '⏳ المهام المعلّقة (Waiting)';
      case 'urgent':
        return '🔥 المهام العاجلة (Urgent)';
      case 'all':
      default:
        return '📋 جميع المهام';
    }
  }

  String get _searchHint {
    if (_forceGlobalSearch) return 'بحث شامل في كل المجالات والمشاريع...';
    if (_selectedProjectId != null) return 'بحث في مشروع ($_currentContextTitle)...';
    if (_selectedAreaId != null) return 'بحث في مجال ($_currentContextTitle)...';
    return 'بحث في المهام...';
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearchActive = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearchActive = true;
      final q = query.toLowerCase();

      _searchResults = widget.tasks.where((t) {
        if (!_forceGlobalSearch) {
          if (_selectedProjectId != null && t.projectId != _selectedProjectId) return false;
          if (_selectedAreaId != null && t.areaId != _selectedAreaId) return false;
        }

        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description?.toLowerCase().contains(q) ?? false;
        final matchSubtasks = widget.subtasks
            .where((s) => s.taskId == t.id)
            .any((s) => s.title.toLowerCase().contains(q));

        return matchTitle || matchDesc || matchSubtasks;
      }).toList();
    });
  }

  void _showAddTaskDialog({String? defaultStatus}) {
    AddTaskDialog.show(
      context,
      areas: widget.areas,
      projects: widget.projects,
      defaultStatus: defaultStatus,
      initialAreaId: _selectedAreaId,
      initialProjectId: _selectedProjectId,
      isTodayFilter: _activeFilter == 'today',
      onSaveTask: (newTask) => widget.onSaveTask?.call(newTask),
      onNeedArea: _showAddAreaDialog,
    );
  }

  void _showAddAreaDialog() {
    AddAreaDialog.show(
      context,
      onSaveArea: (newArea) => widget.onSaveArea?.call(newArea),
    );
  }

  void _showAddProjectDialog(String areaId) {
    AddProjectDialog.show(
      context,
      areaId: areaId,
      onSaveProject: (newProj) => widget.onSaveProject?.call(newProj),
    );
  }

  void _showCreateTagDialog() {
    CreateTagDialog.show(
      context,
      onCreateTag: (name, hex) => widget.onCreateTag?.call(name, hex),
    );
  }

  void _exportCurrentTasksToCsv() {
    final tasksToExport = _contextTasks;
    if (tasksToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مهام لتصديرها في العرض الحالي')),
      );
      return;
    }

    final pMap = {for (final p in widget.projects) p.id: p.name};
    final aMap = {for (final a in widget.areas) a.id: a.name};
    final csv = ExportService.exportTasksToCsv(
      tasks: tasksToExport,
      projectNames: pMap,
      areaNames: aMap,
    );

    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير ${tasksToExport.length} مهمة ونسخ CSV إلى الحافظة بنجاح!'),
        action: SnackBarAction(
          label: 'معاينة',
          onPressed: () => ExportTasksDialog.show(context, csvContent: csv),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // حساب العدادات
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayCount = widget.tasks.where((t) {
      if (t.status == 'completed' || t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d.isAtSameMomentAs(today) || d.isBefore(today);
    }).length;
    final upcomingCount = widget.tasks.where((t) {
      if (t.status == 'completed' || t.dueDate == null) return false;
      return DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isAfter(today);
    }).length;
    final waitingCount = widget.tasks.where((t) => t.status == 'waiting').length;
    final urgentCount = widget.tasks.where((t) => t.priority == 'urgent' && t.status != 'completed').length;

    final areaTaskCounts = <String, int>{};
    for (final t in widget.tasks) {
      if (t.status != 'completed') {
        areaTaskCounts[t.areaId] = (areaTaskCounts[t.areaId] ?? 0) + 1;
      }
    }

    final projectTaskCounts = <String, int>{};
    for (final t in widget.tasks) {
      if (t.projectId != null && t.status != 'completed') {
        projectTaskCounts[t.projectId!] = (projectTaskCounts[t.projectId!] ?? 0) + 1;
      }
    }

    final tagTaskCounts = <String, int>{};
    for (final entry in widget.taskTags.entries) {
      final task = widget.tasks.firstWhere(
        (t) => t.id == entry.key,
        orElse: () => TaskModel(id: '', areaId: '', title: '', status: 'completed', priority: 'low', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      if (task.id.isNotEmpty && task.status != 'completed') {
        for (final tag in entry.value) {
          tagTaskCounts[tag.id] = (tagTaskCounts[tag.id] ?? 0) + 1;
        }
      }
    }

    // بناء الشجرة الجانبية
    final treeSidebar = HierarchicalTreeSidebar(
      areas: widget.areas,
      projects: widget.projects,
      tags: widget.tags,
      selectedFilter: _selectedAreaId == null && _selectedProjectId == null && _selectedTagId == null ? _activeFilter : null,
      selectedAreaId: _selectedAreaId,
      selectedProjectId: _selectedProjectId,
      selectedTagId: _selectedTagId,
      notesSelected: _showNotes,
      financeSelected: _showFinance,
      archiveSelected: _showArchive,
      trashSelected: _showTrash,
      areaTaskCounts: areaTaskCounts,
      projectTaskCounts: projectTaskCounts,
      tagTaskCounts: tagTaskCounts,
      todayCount: todayCount,
      upcomingCount: upcomingCount,
      waitingCount: waitingCount,
      urgentCount: urgentCount,
      onSelectFilter: (filter) {
        setState(() {
          _activeFilter = filter;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _selectedTagId = null;
          _showNotes = false;
          _showFinance = false;
          _showArchive = false;
          _showTrash = false;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectArea: (area) {
        setState(() {
          _selectedAreaId = area.id;
          _selectedProjectId = null;
          _selectedTagId = null;
          _showNotes = false;
          _showFinance = false;
          _showArchive = false;
          _showTrash = false;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectProject: (project) {
        setState(() {
          _selectedProjectId = project.id;
          _selectedAreaId = project.areaId;
          _selectedTagId = null;
          _showNotes = false;
          _showFinance = false;
          _showArchive = false;
          _showTrash = false;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectTag: (tagId) {
        setState(() {
          _selectedTagId = tagId;
          if (tagId != null) {
            _selectedAreaId = null;
            _selectedProjectId = null;
          }
          _showNotes = false;
          _showFinance = false;
          _showArchive = false;
          _showTrash = false;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onAddNewArea: _showAddAreaDialog,
      onAddNewProject: _showAddProjectDialog,
      onAddTag: _showCreateTagDialog,
      onSelectNotes: () {
        setState(() {
          _showNotes = true;
          _showFinance = false;
          _showArchive = false;
          _showTrash = false;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _selectedTagId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectFinance: () {
        setState(() {
          _showFinance = true;
          _showNotes = false;
          _showArchive = false;
          _showTrash = false;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _selectedTagId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectArchive: () {
        setState(() {
          _showArchive = true;
          _showTrash = false;
          _showNotes = false;
          _showFinance = false;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _selectedTagId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectTrash: () {
        setState(() {
          _showTrash = true;
          _showArchive = false;
          _showNotes = false;
          _showFinance = false;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _selectedTagId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectSharedEntity: (entity) {
        final entityType = entity['_entity_type'];
        final id = entity['id'];
        final entityTitle = entity['name'] ?? entity['title'] ?? 'عنصر مشترك';

        if (entityType == 'project') {
          final foundProj = widget.projects.where((p) => p.id == id).firstOrNull;
          setState(() {
            _selectedProjectId = id;
            _selectedAreaId = foundProj?.areaId ?? (entity['area_id'] as String?);
            _selectedTagId = null;
            _selectedSharedTitle = '💼 $entityTitle';
            _isSearchActive = false;
            _searchController.clear();
          });
        } else if (entityType == 'area') {
          setState(() {
            _selectedAreaId = id;
            _selectedProjectId = null;
            _selectedTagId = null;
            _selectedSharedTitle = '📁 $entityTitle';
            _isSearchActive = false;
            _searchController.clear();
          });
        } else if (entityType == 'task') {
          final foundTask = widget.tasks.where((t) => t.id == id).firstOrNull;
          if (foundTask != null) {
            setState(() => _openedTask = foundTask);
          }
        }
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : Drawer(child: SafeArea(child: treeSidebar)),
      floatingActionButton: isDesktop || _showNotes || _showFinance || _showArchive || _showTrash
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddTaskDialog(),
              tooltip: 'مهمة جديدة',
              child: const Icon(Icons.add, size: 26),
            ),
      body: SafeArea(
        top: !isDesktop,
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDesktop) treeSidebar,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MainTopHeader(
                    currentContextTitle: _currentContextTitle,
                    searchHint: _searchHint,
                    searchController: _searchController,
                    isSearchActive: _isSearchActive,
                    isMobileSearchOpen: _isMobileSearchOpen,
                    forceGlobalSearch: _forceGlobalSearch,
                    isAreaOrProjectSelected: _selectedAreaId != null || _selectedProjectId != null,
                    viewMode: _viewMode,
                    onSyncRequested: widget.onSyncRequested,
                    onSearchChanged: _onSearchChanged,
                    onCloseMobileSearch: () {
                      setState(() {
                        _isMobileSearchOpen = false;
                        _searchController.clear();
                        _onSearchChanged('');
                      });
                    },
                    onOpenMobileSearch: () => setState(() => _isMobileSearchOpen = true),
                    onToggleGlobalSearch: () {
                      setState(() {
                        _forceGlobalSearch = !_forceGlobalSearch;
                        _onSearchChanged(_searchController.text);
                      });
                    },
                    onViewModeChanged: (newMode) => setState(() => _viewMode = newMode),
                    onExportCsv: _exportCurrentTasksToCsv,
                    onAddTask: () => _showAddTaskDialog(),
                  ),
Expanded(
                  child: MainWorkspaceContent(
                      showNotes: _showNotes,
                      showFinance: _showFinance,
                      showArchive: _showArchive,
                      showTrash: _showTrash,
                      selectedProjectId: _selectedProjectId,
                      selectedAreaId: _selectedAreaId,
                      isSearchActive: _isSearchActive,
                      searchText: _searchController.text,
                      viewMode: _viewMode,
                      contextTasks: _contextTasks,
                      projects: widget.projects,
                      areas: widget.areas,
                      subtasks: widget.subtasks,
                      taskTags: widget.taskTags,
                      onSaveProject: widget.onSaveProject,
                      onDeleteProject: (id) {
                        widget.onDeleteProject?.call(id);
                        setState(() => _selectedProjectId = null);
                      },
                      onSaveArea: widget.onSaveArea,
                      onDeleteArea: (id) {
                        widget.onDeleteArea?.call(id);
                        setState(() => _selectedAreaId = null);
                      },
                      onTaskTap: (t) {
                        if (isDesktop) {
                          setState(() => _openedTask = t);
                        } else {
                          showTaskDetailBottomSheet(
                            context,
                            task: t,
                            subtasks: widget.subtasks.where((s) => s.taskId == t.id).toList(),
                            areas: widget.areas,
                            projects: widget.projects,
                            availableTags: widget.tags,
                            taskTags: widget.taskTags[t.id] ?? const [],
                            onAssignTag: (tag) => widget.onAssignTag?.call(t, tag),
                            onRemoveTag: (tag) => widget.onRemoveTag?.call(t, tag),
                            onCreateTag: widget.onCreateTag != null
                                ? (n, c) => widget.onCreateTag!.call(n, c)
                                : (n, c) {},
                            onSaveTask: widget.onSaveTask?.call ?? (_) {},
                            onDeleteTask: (id) => widget.onDeleteTask?.call(id),
                            onAddSubtask: (title) => widget.onAddSubtask?.call(t.id, title),
                            onToggleSubtask: (sub, done) => widget.onToggleSubtask?.call(sub, done),
                            onDeleteSubtask: (subId) => widget.onDeleteSubtask?.call(subId),
                          );
                        }
                      },
                      onToggleTaskCompleted: widget.onToggleTaskCompleted,
                      onTaskStatusChanged: widget.onTaskStatusChanged,
                      onTaskPriorityChanged: widget.onTaskPriorityChanged,
                      onAddNewProject: (areaId) => _showAddProjectDialog(areaId),
                      onAddNewTask: (defaultStatus) => _showAddTaskDialog(defaultStatus: defaultStatus),
                      onSelectProjectId: (id) => setState(() => _selectedProjectId = id),
                      onDeleteTask: widget.onDeleteTask,
                      onRestoreTask: widget.onRestoreTask,
                    ),
                ),
                if (!isDesktop &&
                    _activeFilter == 'today' &&
                    _selectedProjectId == null &&
                    _selectedAreaId == null &&
                    _selectedTagId == null &&
                    !_isSearchActive &&
                    !_showNotes &&
                    !_showFinance &&
                    !_showArchive &&
                    !_showTrash)
                  QuickAddTaskBar(
                    onQuickAdd: (title) {
                      if (title.trim().isEmpty || widget.onSaveTask == null) return;
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final task = TaskModel(
                        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                        areaId: widget.areas.isNotEmpty ? widget.areas.first.id : '',
                        title: title.trim(),
                        dueDate: today,
                        status: 'todo',
                        priority: 'medium',
                        createdAt: now.toUtc(),
                        updatedAt: now.toUtc(),
                      );
                      widget.onSaveTask!(task);
                    },
                  ),
                ],
              ),
            ),
            if (isDesktop && _openedTask != null)
              TaskDetailDrawer(
                task: _openedTask!,
                subtasks: widget.subtasks.where((s) => s.taskId == _openedTask!.id).toList(),
                areas: widget.areas,
                projects: widget.projects,
                availableTags: widget.tags,
                taskTags: widget.taskTags[_openedTask!.id] ?? const [],
                onAssignTag: (tag) => widget.onAssignTag?.call(_openedTask!, tag),
                onRemoveTag: (tag) => widget.onRemoveTag?.call(_openedTask!, tag),
                onCreateTag: widget.onCreateTag,
                onClose: () => setState(() => _openedTask = null),
                onSaveTask: (updated) {
                  widget.onSaveTask?.call(updated);
                  setState(() => _openedTask = updated);
                },
                onDeleteTask: widget.onDeleteTask,
                onAddSubtask: (title) => widget.onAddSubtask?.call(_openedTask!.id, title),
                onToggleSubtask: (subtask, isDone) => widget.onToggleSubtask?.call(subtask, isDone),
                onDeleteSubtask: (subId) => widget.onDeleteSubtask?.call(subId),
              ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _bottomNavIndex,
              onDestinationSelected: (idx) {
                if (idx == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  return;
                }
                if (idx == 1) {
                  _scaffoldKey.currentState?.openDrawer();
                  setState(() {
                    _bottomNavIndex = idx;
                  });
                  return;
                }
                setState(() {
                  _bottomNavIndex = idx;
                  if (idx == 0) {
                    _activeFilter = 'today';
                  } else if (idx == 2) {
                    _activeFilter = 'all';
                  } else if (idx == 3) {
                    _showFinance = true;
                    _showNotes = false;
                    _showArchive = false;
                    _showTrash = false;
                  }
                  _selectedAreaId = null;
                  _selectedProjectId = null;
                  _selectedTagId = null;
                  if (idx != 3) {
                    _showNotes = false;
                    _showFinance = false;
                    _showArchive = false;
                    _showTrash = false;
                  }
                });
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: 'اليوم'),
                NavigationDestination(icon: Icon(Icons.folder_open_outlined), selectedIcon: Icon(Icons.folder), label: 'المشاريع'),
                NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'الملاحظات'),
                NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'المالية'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'الإعدادات'),
              ],
            ),
    );
  }
}
