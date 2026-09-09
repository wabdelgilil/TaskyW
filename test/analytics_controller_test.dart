import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/areas/domain/repositories/i_area_repository.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/domain/repositories/i_project_repository.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/domain/repositories/i_task_repository.dart';

class _FakeTaskRepo implements ITaskRepository {
  final List<TaskModel> _tasks;
  _FakeTaskRepo(this._tasks);

  @override
  Future<List<TaskModel>> getTasks({
    String? areaId,
    String? projectId,
    String? status,
    String? priority,
    DateTime? dueBefore,
  }) async =>
      _tasks.where((t) => t.deletedAt == null).toList();

  @override
  Future<TaskModel?> getTaskById(String id) async => null;

  @override
  Future<void> insertTask(TaskModel task) async {}

  @override
  Future<void> updateTask(TaskModel task) async {}

  @override
  Future<void> updateTaskStatus(String id, String status) async {}

  @override
  Future<void> softDeleteTask(String id) async {}

  @override
  Future<List<TaskModel>> searchTasks(String query,
          {String? areaId, String? projectId}) async =>
      [];

  @override
  Future<List<TaskModel>> getArchivedTasks({String? areaId, String? projectId}) async =>
      [];

  @override
  Future<List<TaskModel>> getTrashTasks() async => [];

  @override
  Future<void> archiveTask(String id) async {}

  @override
  Future<void> unarchiveTask(String id, {String targetStatus = 'todo'}) async {}

  @override
  Future<void> restoreTaskFromTrash(String id) async {}

  @override
  Future<void> permanentlyDeleteTask(String id) async {}

  @override
  Future<void> emptyTrash() async {}
}

class _FakeAreaRepo implements IAreaRepository {
  final List<AreaModel> _areas;
  _FakeAreaRepo(this._areas);

  @override
  Future<List<AreaModel>> getAllAreas() async => _areas;

  @override
  Future<AreaModel?> getAreaById(String id) async => null;

  @override
  Future<void> insertArea(AreaModel area) async {}

  @override
  Future<void> updateArea(AreaModel area) async {}

  @override
  Future<void> softDeleteArea(String id) async {}
}

class _FakeProjectRepo implements IProjectRepository {
  final List<ProjectModel> _projects;
  _FakeProjectRepo(this._projects);

  @override
  Future<List<ProjectModel>> getAllProjects() async => _projects;

  @override
  Future<List<ProjectModel>> getProjectsByArea(String areaId) async => [];

  @override
  Future<ProjectModel?> getProjectById(String id) async => null;

  @override
  Future<void> insertProject(ProjectModel project) async {}

  @override
  Future<void> updateProject(ProjectModel project) async {}

  @override
  Future<void> softDeleteProject(String id) async {}

  @override
  Future<List<ProjectModel>> getArchivedProjects() async => [];

  @override
  Future<List<ProjectModel>> getTrashProjects() async => [];

  @override
  Future<void> archiveProject(String id) async {}

  @override
  Future<void> unarchiveProject(String id) async {}

  @override
  Future<void> restoreProjectFromTrash(String id) async {}

  @override
  Future<void> permanentlyDeleteProject(String id) async {}

  @override
  Future<void> emptyProjectTrash() async {}
}

void main() {
  final now = DateTime.now().toUtc();

  TaskModel buildTask({
    required String id,
    required String areaId,
    String? projectId,
    required String status,
    required String priority,
  }) =>
      TaskModel(
        id: id,
        areaId: areaId,
        projectId: projectId,
        title: id,
        status: status,
        priority: priority,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      );

  test('load يجلب ويحسب التقرير من المستودعات', () async {
    final controller = AnalyticsController(
      taskRepository: _FakeTaskRepo([
        buildTask(id: 't1', areaId: 'a1', projectId: 'p1', status: 'completed', priority: 'high'),
        buildTask(id: 't2', areaId: 'a1', projectId: 'p1', status: 'todo', priority: 'medium'),
      ]),
      areaRepository: _FakeAreaRepo([
        AreaModel(id: 'a1', name: 'العمل', createdAt: now, updatedAt: now),
      ]),
      projectRepository: _FakeProjectRepo([
        ProjectModel(id: 'p1', areaId: 'a1', name: 'تطبيق', createdAt: now, updatedAt: now),
      ]),
    );

    await controller.load();

    final report = controller.report!;
    expect(report.totalTasks, 2);
    expect(report.completedTasks, 1);
    expect(report.completionRate, 0.5);
    expect(report.areas.single.name, 'العمل');
    expect(report.projects.single.name, 'تطبيق');
  });

  test('setRange يبدّل بين weekly وmonthly ويُعلم المستمعين', () async {
    final controller = AnalyticsController(
      taskRepository: _FakeTaskRepo([]),
      areaRepository: _FakeAreaRepo([]),
      projectRepository: _FakeProjectRepo([]),
    );
    var notified = 0;
    controller.addListener(() => notified++);

    expect(controller.range, 'weekly');
    controller.setRange('monthly');
    expect(controller.range, 'monthly');
    expect(notified, 1);

    // نفس القيمة لا تعيد التنبيه
    controller.setRange('monthly');
    expect(notified, 1);
  });

  test('currentSeries يعكس النطاق المختار', () async {
    final controller = AnalyticsController(
      taskRepository: _FakeTaskRepo([]),
      areaRepository: _FakeAreaRepo([]),
      projectRepository: _FakeProjectRepo([]),
    );
    await controller.load();

    expect(controller.range, 'weekly');
    expect(controller.currentSeries.length, 8);

    controller.setRange('monthly');
    expect(controller.currentSeries.length, 6);
  });

  test('isLoading يكون صحيحاً أثناء التحميل ثم خاطئاً بعدها', () async {
    final controller = AnalyticsController(
      taskRepository: _FakeTaskRepo([]),
      areaRepository: _FakeAreaRepo([]),
      projectRepository: _FakeProjectRepo([]),
    );
    expect(controller.isLoading, isFalse);

    final future = controller.load();
    // load يستدعي notifyListeners مع isLoading=true قبل await
    expect(controller.isLoading, isTrue);

    await future;
    expect(controller.isLoading, isFalse);
  });
}