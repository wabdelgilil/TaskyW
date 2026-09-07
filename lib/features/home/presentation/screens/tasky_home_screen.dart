import 'package:flutter/material.dart';
import '../../../areas/data/models/area_model.dart';
import '../../../areas/data/repositories/area_repository_impl.dart';
import '../../../projects/data/models/project_model.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
import '../../../tasks/data/models/subtask_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/data/repositories/subtask_repository_impl.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import 'main_layout_screen.dart';

/// الشاشة الأم الحاضنة التي تربط المستودعات (Repositories) بواجهات المستخدم المتطورة
class TaskyHomeScreen extends StatefulWidget {
  const TaskyHomeScreen({super.key});

  @override
  State<TaskyHomeScreen> createState() => _TaskyHomeScreenState();
}

class _TaskyHomeScreenState extends State<TaskyHomeScreen> {
  final AreaRepositoryImpl _areaRepo = AreaRepositoryImpl();
  final ProjectRepositoryImpl _projectRepo = ProjectRepositoryImpl();
  final TaskRepositoryImpl _taskRepo = TaskRepositoryImpl();
  final SubtaskRepositoryImpl _subtaskRepo = SubtaskRepositoryImpl();

  bool _isLoading = true;
  List<AreaModel> _areas = [];
  List<ProjectModel> _projects = [];
  List<TaskModel> _tasks = [];
  List<SubtaskModel> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final areas = await _areaRepo.getAllAreas();
      final projects = await _projectRepo.getAllProjects();
      final tasks = await _taskRepo.getTasks();

      final allSubtasks = <SubtaskModel>[];
      for (final t in tasks) {
        final subs = await _subtaskRepo.getSubtasksForTask(t.id);
        allSubtasks.addAll(subs);
      }

      if (mounted) {
        setState(() {
          _areas = areas;
          _projects = projects;
          _tasks = tasks;
          _subtasks = allSubtasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // عمليات المهام
  Future<void> _handleSaveTask(TaskModel task) async {
    final existingIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex >= 0) {
      await _taskRepo.updateTask(task);
    } else {
      await _taskRepo.insertTask(task);
    }
    await _loadAllData();
  }

  Future<void> _handleDeleteTask(String taskId) async {
    await _taskRepo.softDeleteTask(taskId);
    await _loadAllData();
  }

  Future<void> _handleTaskStatusChanged(TaskModel task, String newStatus) async {
    await _taskRepo.updateTaskStatus(task.id, newStatus);
    await _loadAllData();
  }

  Future<void> _handleToggleTaskCompleted(TaskModel task, bool isCompleted) async {
    final newStatus = isCompleted ? 'completed' : 'todo';
    await _taskRepo.updateTaskStatus(task.id, newStatus);
    await _loadAllData();
  }

  // عمليات المهام الفرعية
  Future<void> _handleAddSubtask(String taskId, String title) async {
    final newSubtask = SubtaskModel(
      id: 'subtask-${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      title: title,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await _subtaskRepo.insertSubtask(newSubtask);
    await _loadAllData();
  }

  Future<void> _handleToggleSubtask(SubtaskModel subtask, bool isCompleted) async {
    await _subtaskRepo.toggleSubtaskCompletion(subtask.id, isCompleted);
    await _loadAllData();
  }

  Future<void> _handleDeleteSubtask(String subtaskId) async {
    await _subtaskRepo.softDeleteSubtask(subtaskId);
    await _loadAllData();
  }

  // عمليات المجالات والمشاريع
  Future<void> _handleSaveArea(AreaModel area) async {
    final existing = _areas.any((a) => a.id == area.id);
    if (existing) {
      await _areaRepo.updateArea(area);
    } else {
      await _areaRepo.insertArea(area);
    }
    await _loadAllData();
  }

  Future<void> _handleDeleteArea(String areaId) async {
    await _areaRepo.softDeleteArea(areaId);
    await _loadAllData();
  }

  Future<void> _handleSaveProject(ProjectModel project) async {
    final existing = _projects.any((p) => p.id == project.id);
    if (existing) {
      await _projectRepo.updateProject(project);
    } else {
      await _projectRepo.insertProject(project);
    }
    await _loadAllData();
  }

  Future<void> _handleDeleteProject(String projectId) async {
    await _projectRepo.softDeleteProject(projectId);
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainLayoutScreen(
      areas: _areas,
      projects: _projects,
      tasks: _tasks,
      subtasks: _subtasks,
      onSaveTask: _handleSaveTask,
      onDeleteTask: _handleDeleteTask,
      onTaskStatusChanged: _handleTaskStatusChanged,
      onToggleTaskCompleted: _handleToggleTaskCompleted,
      onAddSubtask: _handleAddSubtask,
      onToggleSubtask: _handleToggleSubtask,
      onDeleteSubtask: _handleDeleteSubtask,
      onSaveArea: _handleSaveArea,
      onDeleteArea: _handleDeleteArea,
      onSaveProject: _handleSaveProject,
      onDeleteProject: _handleDeleteProject,
    );
  }
}
