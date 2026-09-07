import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/color_picker_dialog.dart';
import '../../../../core/widgets/emoji_picker_dialog.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../areas/presentation/screens/area_detail_screen.dart';
import '../../../areas/presentation/widgets/hierarchical_tree_sidebar.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../tasks/data/models/subtask_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/widgets/kanban_board_view.dart';
import '../../../tasks/presentation/widgets/task_detail_drawer.dart';
import '../../../tasks/presentation/widgets/task_list_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/auth_screen.dart';

/// الشاشة الهيكلية الرئيسية للتطبيق (Master Responsive Layout Screen)
/// تجمع بين الشجرة الهرمية الجانبية، شريط البحث المقيّد بالسياق، مساحة العمل، درج التفاصيل، والشريط السفلي
class MainLayoutScreen extends StatefulWidget {
  // البيانات المحملة من المستودعات / المتحكمات
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final List<TaskModel> tasks;
  final List<SubtaskModel> subtasks;

  // دوال العمليات التفاعلية (Callbacks)
  final Function(TaskModel task)? onSaveTask;
  final Function(String taskId)? onDeleteTask;
  final Function(TaskModel task, String newStatus)? onTaskStatusChanged;
  final Function(TaskModel task, bool isCompleted)? onToggleTaskCompleted;
  final Function(String taskId, String title)? onAddSubtask;
  final Function(SubtaskModel subtask, bool isCompleted)? onToggleSubtask;
  final Function(String subtaskId)? onDeleteSubtask;

  final Function(AreaModel area)? onSaveArea;
  final Function(String areaId)? onDeleteArea;
  final Function(ProjectModel project)? onSaveProject;
  final Function(String projectId)? onDeleteProject;

  final Function(String query, {String? areaId, String? projectId})? onSearch;

  const MainLayoutScreen({
    super.key,
    required this.areas,
    required this.projects,
    required this.tasks,
    this.subtasks = const [],
    this.onSaveTask,
    this.onDeleteTask,
    this.onTaskStatusChanged,
    this.onToggleTaskCompleted,
    this.onAddSubtask,
    this.onToggleSubtask,
    this.onDeleteSubtask,
    this.onSaveArea,
    this.onDeleteArea,
    this.onSaveProject,
    this.onDeleteProject,
    this.onSearch,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  // حالات التنقل
  String _activeFilter = 'today'; // 'today', 'upcoming', 'waiting', 'urgent', 'all'
  String? _selectedAreaId;
  String? _selectedProjectId;

  // طريقة العرض في مساحة العمل
  String _viewMode = 'list'; // 'list' أو 'kanban'

  // المهمة المفتوحة حالياً في درج التفاصيل
  TaskModel? _openedTask;

  // محرك البحث
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  List<TaskModel> _searchResults = [];
  bool _forceGlobalSearch = false;

  // فهرس الشريط السفلي
  int _bottomNavIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- تصفية المهام حسب السياق النشط ---
  List<TaskModel> get _contextTasks {
    if (_isSearchActive) return _searchResults;

    if (_selectedProjectId != null) {
      return widget.tasks.where((t) => t.projectId == _selectedProjectId).toList();
    }
    if (_selectedAreaId != null) {
      return widget.tasks.where((t) => t.areaId == _selectedAreaId).toList();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_activeFilter) {
      case 'today':
        return widget.tasks.where((t) {
          if (t.status == 'completed') return false;
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAtSameMomentAs(today) || d.isBefore(today);
        }).toList();
      case 'upcoming':
        return widget.tasks.where((t) {
          if (t.status == 'completed') return false;
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAfter(today);
        }).toList();
      case 'waiting':
        return widget.tasks.where((t) => t.status == 'waiting').toList();
      case 'urgent':
        return widget.tasks.where((t) => t.priority == 'urgent' && t.status != 'completed').toList();
      case 'all':
      default:
        return widget.tasks;
    }
  }

  // عنوان السياق الحالي
  String get _currentContextTitle {
    if (_selectedProjectId != null) {
      final p = widget.projects.firstWhere(
        (p) => p.id == _selectedProjectId,
        orElse: () => ProjectModel(id: '', areaId: '', name: 'مشروع', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      return '${p.iconEmoji} ${p.name}';
    }
    if (_selectedAreaId != null) {
      final a = widget.areas.firstWhere(
        (a) => a.id == _selectedAreaId,
        orElse: () => AreaModel(id: '', name: 'مجال', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      return '${a.iconEmoji} ${a.name}';
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

  // تلميح شريط البحث المقيّد بالسياق
  String get _searchHint {
    if (_forceGlobalSearch) return 'بحث شامل في كل المجالات والمشاريع...';
    if (_selectedProjectId != null) {
      return 'بحث في مشروع ($_currentContextTitle)...';
    }
    if (_selectedAreaId != null) {
      return 'بحث في مجال ($_currentContextTitle)...';
    }
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
        // فحص النطاق
        if (!_forceGlobalSearch) {
          if (_selectedProjectId != null && t.projectId != _selectedProjectId) return false;
          if (_selectedAreaId != null && t.areaId != _selectedAreaId) return false;
        }

        // فحص العنوان والوصف
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description?.toLowerCase().contains(q) ?? false;

        // فحص المهام الفرعية
        final matchSubtasks = widget.subtasks
            .where((s) => s.taskId == t.id)
            .any((s) => s.title.toLowerCase().contains(q));

        return matchTitle || matchDesc || matchSubtasks;
      }).toList();
    });
  }

  // نافذة إضافة مهمة سريعة
  void _showAddTaskDialog({String? defaultStatus}) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String status = defaultStatus ?? 'todo';
    String priority = 'medium';
    String? colorHex;
    String areaId = _selectedAreaId ?? (widget.areas.isNotEmpty ? widget.areas.first.id : 'area-work-main');
    String? projectId = _selectedProjectId;
    DateTime? dueDate = (_activeFilter == 'today') ? DateTime.now() : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final areaProjects = widget.projects.where((p) => p.areaId == areaId).toList();

          return AlertDialog(
            title: const Text('إضافة مهمة جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'عنوان المهمة *', hintText: 'ما الذي ترغب في إنجازه؟'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'ملاحظات أو وصف (اختياري)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'الحالة'),
                          items: const [
                            DropdownMenuItem(value: 'todo', child: Text('قيد الانتظار')),
                            DropdownMenuItem(value: 'in_progress', child: Text('جاري التنفيذ')),
                            DropdownMenuItem(value: 'waiting', child: Text('معلّقة')),
                            DropdownMenuItem(value: 'review', child: Text('مراجعة')),
                            DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => status = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: priority,
                          decoration: const InputDecoration(labelText: 'الأولوية'),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                            DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                            DropdownMenuItem(value: 'high', child: Text('عالية')),
                            DropdownMenuItem(value: 'urgent', child: Text('عاجل جداً')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => priority = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: areaId,
                          decoration: const InputDecoration(labelText: 'المجال'),
                          items: widget.areas.map((a) {
                            return DropdownMenuItem(value: a.id, child: Text('${a.iconEmoji} ${a.name}'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                areaId = val;
                                projectId = null;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: projectId,
                          decoration: const InputDecoration(labelText: 'المشروع'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('بدون مشروع')),
                            ...areaProjects.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.iconEmoji} ${p.name}'))),
                          ],
                          onChanged: (val) => setDialogState(() => projectId = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // زر تعيين الديدلاين
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(dueDate != null ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}' : 'تاريخ التسليم'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setDialogState(() => dueDate = picked);
                        },
                      ),
                      const Spacer(),
                      // زر اختيار لون المهمة
                      IconButton(
                        icon: Icon(Icons.palette_outlined, color: colorHex != null ? AppColors.fromHex(colorHex) : Colors.grey),
                        tooltip: 'لون مخصص للمهمة',
                        onPressed: () async {
                          final selected = await ColorPickerDialog.show(context, initialColorHex: colorHex ?? '#3B82F6');
                          if (selected != null) setDialogState(() => colorHex = selected);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  final text = titleCtrl.text.trim();
                  if (text.isNotEmpty) {
                    final newTask = TaskModel(
                      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                      areaId: areaId,
                      projectId: projectId,
                      title: text,
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      status: status,
                      priority: priority,
                      colorHex: colorHex,
                      dueDate: dueDate,
                      createdAt: DateTime.now().toUtc(),
                      updatedAt: DateTime.now().toUtc(),
                    );
                    widget.onSaveTask?.call(newTask);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('إضافة المهمة'),
              ),
            ],
          );
        },
      ),
    );
  }

  // نافذة إضافة مجال جديد
  void _showAddAreaDialog() {
    final nameCtrl = TextEditingController();
    String emoji = '💼';
    String colorHex = '#3B82F6';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final aColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: const Text('إضافة مجال مسؤولية جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final selected = await EmojiPickerDialog.show(context, initialEmoji: emoji);
                          if (selected != null) setDialogState(() => emoji = selected);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: aColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          final selected = await ColorPickerDialog.show(context, initialColorHex: colorHex);
                          if (selected != null) setDialogState(() => colorHex = selected);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                          child: Row(
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: aColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text('اللون', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المجال')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final newArea = AreaModel(
                      id: 'area-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                      createdAt: DateTime.now().toUtc(),
                      updatedAt: DateTime.now().toUtc(),
                    );
                    widget.onSaveArea?.call(newArea);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('إنشاء المجال'),
              ),
            ],
          );
        },
      ),
    );
  }

  // نافذة إضافة مشروع جديد
  void _showAddProjectDialog(String areaId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String emoji = '📋';
    String colorHex = '#10B981';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final pColor = AppColors.fromHex(colorHex);
          return AlertDialog(
            title: const Text('إضافة مشروع جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final selected = await EmojiPickerDialog.show(context, initialEmoji: emoji);
                          if (selected != null) setDialogState(() => emoji = selected);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: pColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () async {
                          final selected = await ColorPickerDialog.show(context, initialColorHex: colorHex);
                          if (selected != null) setDialogState(() => colorHex = selected);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                          child: Row(
                            children: [
                              Container(width: 16, height: 16, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text('اللون', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المشروع')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف المشروع (اختياري)')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final newProj = ProjectModel(
                      id: 'project-${DateTime.now().millisecondsSinceEpoch}',
                      areaId: areaId,
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      iconEmoji: emoji,
                      colorHex: colorHex,
                      createdAt: DateTime.now().toUtc(),
                      updatedAt: DateTime.now().toUtc(),
                    );
                    widget.onSaveProject?.call(newProj);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('إنشاء المشروع'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    // بناء الشجرة الجانبية
    final treeSidebar = HierarchicalTreeSidebar(
      areas: widget.areas,
      projects: widget.projects,
      selectedFilter: _selectedAreaId == null && _selectedProjectId == null ? _activeFilter : null,
      selectedAreaId: _selectedAreaId,
      selectedProjectId: _selectedProjectId,
      areaTaskCounts: areaTaskCounts,
      projectTaskCounts: projectTaskCounts,
      todayCount: todayCount,
      upcomingCount: upcomingCount,
      waitingCount: waitingCount,
      urgentCount: urgentCount,
      onSelectFilter: (filter) {
        setState(() {
          _activeFilter = filter;
          _selectedAreaId = null;
          _selectedProjectId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectArea: (area) {
        setState(() {
          _selectedAreaId = area.id;
          _selectedProjectId = null;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onSelectProject: (project) {
        setState(() {
          _selectedProjectId = project.id;
          _selectedAreaId = project.areaId;
          _isSearchActive = false;
          _searchController.clear();
        });
      },
      onAddNewArea: _showAddAreaDialog,
      onAddNewProject: _showAddProjectDialog,
    );

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: treeSidebar),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. العمود الأيسر: الشجرة الهرمية على الشاشات الكبيرة
          if (isDesktop) treeSidebar,

          // 2. مساحة العمل المركزية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // رأس الصفحة وشريط البحث
                _buildTopHeader(isDark, isDesktop),

                // المحتوى النشط لمساحة العمل
                Expanded(
                  child: _buildMainWorkspaceContent(),
                ),
              ],
            ),
          ),

          // 3. العمود الأيمن: درج التفاصيل المنزلق (Desktop)
          if (isDesktop && _openedTask != null)
            TaskDetailDrawer(
              task: _openedTask!,
              subtasks: widget.subtasks.where((s) => s.taskId == _openedTask!.id).toList(),
              areas: widget.areas,
              projects: widget.projects,
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

      // الشريط السفلي الموحد لجميع المنصات
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomNavIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _bottomNavIndex = idx;
            if (idx == 0) {
              _activeFilter = 'today';
              _selectedAreaId = null;
              _selectedProjectId = null;
            } else if (idx == 1) {
              _activeFilter = 'all';
              _viewMode = 'list';
              _selectedAreaId = null;
              _selectedProjectId = null;
            } else if (idx == 2) {
              _activeFilter = 'all';
              _viewMode = 'kanban';
              _selectedAreaId = null;
              _selectedProjectId = null;
            }
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), selectedIcon: Icon(Icons.wb_sunny), label: 'اليوم'),
          NavigationDestination(icon: Icon(Icons.view_list_outlined), selectedIcon: Icon(Icons.view_list), label: 'القوائم'),
          NavigationDestination(icon: Icon(Icons.view_kanban_outlined), selectedIcon: Icon(Icons.view_kanban), label: 'الكانبان'),
        ],
      ),
    );
  }

  // رأس الصفحة ومحرك البحث
  Widget _buildTopHeader(bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),

          // عنوان السياق الحالي
          Expanded(
            flex: 2,
            child: Text(
              _currentContextTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 12),

          // حقل البحث المقيّد بالسياق
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _searchHint,
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // زر توسيع البحث للنطاق الشامل عند التواجد داخل مشروع أو مجال
          if ((_selectedAreaId != null || _selectedProjectId != null) && _isSearchActive) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              icon: Icon(_forceGlobalSearch ? Icons.filter_alt_off : Icons.public, size: 16),
              label: Text(_forceGlobalSearch ? 'إلغاء الشامل' : 'بحث شامل'),
              onPressed: () {
                setState(() {
                  _forceGlobalSearch = !_forceGlobalSearch;
                  _onSearchChanged(_searchController.text);
                });
              },
            ),
          ],

          const SizedBox(width: 10),

          // أزرار التبديل السريع للعرض (List / Kanban)
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'list', icon: Icon(Icons.view_list_rounded, size: 16)),
              ButtonSegment(value: 'kanban', icon: Icon(Icons.view_kanban_rounded, size: 16)),
            ],
            selected: {_viewMode},
            onSelectionChanged: (set) => setState(() => _viewMode = set.first),
          ),

          const SizedBox(width: 10),

          // زر إضافة مهمة سريعة
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('مهمة جديدة'),
          ),

          const SizedBox(width: 10),

          // زر الحساب والمصادقة (Supabase Auth)
          ListenableBuilder(
            listenable: AuthController.instance,
            builder: (context, _) {
              final auth = AuthController.instance;
              if (auth.isAuthenticated) {
                return PopupMenuButton<String>(
                  tooltip: 'الملف الشخصي',
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
                          Text(auth.displayName ?? 'مستخدم Tasky', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(auth.userEmail ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'signout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (auth.displayName?.isNotEmpty == true ? auth.displayName![0] : 'U').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                );
              }

              return OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('تسجيل الدخول'),
              );
            },
          ),
        ],
      ),
    );
  }

  // المحتوى المعروض في مساحة العمل المركزية
  Widget _buildMainWorkspaceContent() {
    // 1. إذا كان المستخدم فاتحاً صفحة مشروع مخصصة
    if (_selectedProjectId != null && !_isSearchActive) {
      final project = widget.projects.firstWhere((p) => p.id == _selectedProjectId);
      return ProjectDetailScreen(
        project: project,
        projectTasks: _contextTasks,
        onUpdateProject: (up) => widget.onSaveProject?.call(up),
        onDeleteProject: (id) {
          widget.onDeleteProject?.call(id);
          setState(() => _selectedProjectId = null);
        },
        onTaskTap: (t) => setState(() => _openedTask = t),
        onToggleTaskCompleted: (t, isDone) {
          widget.onToggleTaskCompleted?.call(t, isDone);
        },
        onTaskStatusChanged: widget.onTaskStatusChanged,
        onAddNewTask: () => _showAddTaskDialog(),
      );
    }

    // 2. إذا كان المستخدم فاتحاً صفحة مجال مخصصة
    if (_selectedAreaId != null && !_isSearchActive) {
      final area = widget.areas.firstWhere((a) => a.id == _selectedAreaId);
      final areaProjects = widget.projects.where((p) => p.areaId == area.id).toList();

      return AreaDetailScreen(
        area: area,
        areaProjects: areaProjects,
        areaTasks: _contextTasks,
        onUpdateArea: (up) => widget.onSaveArea?.call(up),
        onDeleteArea: (id) {
          widget.onDeleteArea?.call(id);
          setState(() => _selectedAreaId = null);
        },
        onProjectTap: (p) => setState(() => _selectedProjectId = p.id),
        onTaskTap: (t) => setState(() => _openedTask = t),
        onToggleTaskCompleted: widget.onToggleTaskCompleted,
        onAddNewProject: () => _showAddProjectDialog(area.id),
        onAddNewTask: () => _showAddTaskDialog(),
      );
    }

    // 3. العرض الافتراضي (اليوم، القادمة، المعلقة، عاجل، أو نتائج البحث)
    final subtaskCounts = <String, int>{};
    final completedSubtaskCounts = <String, int>{};
    for (final s in widget.subtasks) {
      subtaskCounts[s.taskId] = (subtaskCounts[s.taskId] ?? 0) + 1;
      if (s.isCompleted) {
        completedSubtaskCounts[s.taskId] = (completedSubtaskCounts[s.taskId] ?? 0) + 1;
      }
    }

    if (_viewMode == 'kanban') {
      return KanbanBoardView(
        tasks: _contextTasks,
        subtaskCounts: subtaskCounts,
        completedSubtaskCounts: completedSubtaskCounts,
        onTaskTap: (t) => setState(() => _openedTask = t),
        onTaskStatusChanged: (task, status) => widget.onTaskStatusChanged?.call(task, status),
        onAddTaskInColumn: (status) => _showAddTaskDialog(defaultStatus: status),
      );
    }

    return TaskListView(
      tasks: _contextTasks,
      subtaskCounts: subtaskCounts,
      completedSubtaskCounts: completedSubtaskCounts,
      emptyMessage: _isSearchActive
          ? 'لم يتم العثور على أي نتائج تطابق "${_searchController.text}"'
          : 'لا توجد مهام في هذا القسم حالياً',
      onTaskTap: (t) => setState(() => _openedTask = t),
      onToggleCompleted: widget.onToggleTaskCompleted,
      onAddTask: () => _showAddTaskDialog(),
    );
  }
}
