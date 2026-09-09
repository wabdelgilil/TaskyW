import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/archive/presentation/screens/archive_screen.dart';
import 'package:tasky/features/notes/data/models/note_model.dart';
import 'package:tasky/features/notes/data/repositories/note_repository_impl.dart';
import 'package:tasky/features/notes/presentation/controllers/notes_controller.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/projects/domain/repositories/i_project_repository.dart';
import 'package:tasky/features/projects/presentation/controllers/projects_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:tasky/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:tasky/features/trash/presentation/screens/trash_screen.dart';

class _FakeTaskRepo implements ITaskRepository {
  final List<TaskModel> tasks = [];

  @override
  Future<List<TaskModel>> getTasks({
    String? areaId,
    String? projectId,
    String? status,
    String? priority,
    DateTime? dueBefore,
  }) async {
    return tasks.where((t) => !t.isArchived && !t.isDeleted).toList();
  }

  @override
  Future<List<TaskModel>> getArchivedTasks({String? areaId, String? projectId}) async {
    return tasks.where((t) => t.isArchived && !t.isDeleted).toList();
  }

  @override
  Future<List<TaskModel>> getTrashTasks() async {
    return tasks.where((t) => t.isDeleted).toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertTask(TaskModel task) async => tasks.add(task);

  @override
  Future<void> updateTask(TaskModel task) async {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) tasks[idx] = task;
  }

  @override
  Future<void> updateTaskStatus(String id, String status) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx != -1) tasks[idx] = tasks[idx].copyWith(status: status);
  }

  @override
  Future<void> softDeleteTask(String id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      tasks[idx] = tasks[idx].copyWith(deletedAt: DateTime.now().toUtc());
    }
  }

  @override
  Future<List<TaskModel>> searchTasks(String query, {String? areaId, String? projectId}) async {
    return tasks.where((t) => t.title.contains(query)).toList();
  }

  @override
  Future<void> archiveTask(String id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx != -1) tasks[idx] = tasks[idx].copyWith(status: 'archived');
  }

  @override
  Future<void> unarchiveTask(String id, {String targetStatus = 'todo'}) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx != -1) tasks[idx] = tasks[idx].copyWith(status: targetStatus);
  }

  @override
  Future<void> restoreTaskFromTrash(String id) async {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx != -1) tasks[idx] = tasks[idx].copyWith(deletedAt: null);
  }

  @override
  Future<void> permanentlyDeleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> emptyTrash() async {
    tasks.removeWhere((t) => t.isDeleted);
  }
}

class _FakeProjectRepo implements IProjectRepository {
  final List<ProjectModel> projects = [];

  @override
  Future<List<ProjectModel>> getAllProjects() async {
    return projects.where((p) => !p.isArchived && !p.isDeleted).toList();
  }

  @override
  Future<List<ProjectModel>> getProjectsByArea(String areaId) async {
    return projects.where((p) => p.areaId == areaId && !p.isArchived && !p.isDeleted).toList();
  }

  @override
  Future<ProjectModel?> getProjectById(String id) async {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertProject(ProjectModel project) async => projects.add(project);

  @override
  Future<void> updateProject(ProjectModel project) async {
    final idx = projects.indexWhere((p) => p.id == project.id);
    if (idx != -1) projects[idx] = project;
  }

  @override
  Future<void> softDeleteProject(String id) async {
    final idx = projects.indexWhere((p) => p.id == id);
    if (idx != -1) {
      projects[idx] = projects[idx].copyWith(deletedAt: DateTime.now().toUtc());
    }
  }

  @override
  Future<List<ProjectModel>> getArchivedProjects() async {
    return projects.where((p) => p.isArchived && !p.isDeleted).toList();
  }

  @override
  Future<List<ProjectModel>> getTrashProjects() async {
    return projects.where((p) => p.isDeleted).toList();
  }

  @override
  Future<void> archiveProject(String id) async {
    final idx = projects.indexWhere((p) => p.id == id);
    if (idx != -1) projects[idx] = projects[idx].copyWith(status: 'archived');
  }

  @override
  Future<void> unarchiveProject(String id) async {
    final idx = projects.indexWhere((p) => p.id == id);
    if (idx != -1) projects[idx] = projects[idx].copyWith(status: 'active');
  }

  @override
  Future<void> restoreProjectFromTrash(String id) async {
    final idx = projects.indexWhere((p) => p.id == id);
    if (idx != -1) projects[idx] = projects[idx].copyWith(deletedAt: null);
  }

  @override
  Future<void> permanentlyDeleteProject(String id) async {
    projects.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> emptyProjectTrash() async {
    projects.removeWhere((p) => p.isDeleted);
  }
}

class _FakeNoteRepo implements INoteRepository {
  final List<NoteModel> notes = [];

  @override
  Future<List<NoteModel>> getNotes({bool includeArchived = false}) async {
    return notes.where((n) {
      if (n.deletedAt != null) return false;
      if (!includeArchived && n.isArchived) return false;
      return true;
    }).toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      return notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insertNote(NoteModel note) async => notes.add(note);

  @override
  Future<void> updateNote(NoteModel note) async {
    final idx = notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) notes[idx] = note;
  }

  @override
  Future<void> softDeleteNote(String id) async {
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notes[idx] = notes[idx].copyWith(deletedAt: DateTime.now().toUtc());
    }
  }

  @override
  Future<List<NoteModel>> getNotesBySyncStatus(String syncStatus) async {
    return notes.where((n) => n.syncStatus == syncStatus).toList();
  }
}

void main() {
  testWidgets('ArchiveScreen renders header, tabs, and archived items', (tester) async {
    final fakeTaskRepo = _FakeTaskRepo();
    final fakeProjRepo = _FakeProjectRepo();
    final fakeNoteRepo = _FakeNoteRepo();

    final now = DateTime.now().toUtc();
    fakeTaskRepo.tasks.add(
      TaskModel(
        id: 'task-arch',
        areaId: 'area-1',
        title: 'مهمة مؤرشفة للاختبار',
        status: 'archived',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final tasksCtrl = TasksController(repository: fakeTaskRepo);
    final projectsCtrl = ProjectsController(repository: fakeProjRepo);
    final notesCtrl = NotesController(repository: fakeNoteRepo);

    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArchiveScreen(
            tasksController: tasksCtrl,
            projectsController: projectsCtrl,
            notesController: notesCtrl,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('الأرشيف العام (Global Archive)'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'المهام (1)'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'المشاريع (0)'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'الملاحظات (0)'), findsOneWidget);
    expect(find.text('مهمة مؤرشفة للاختبار'), findsOneWidget);
  });

  testWidgets('TrashScreen renders header, tabs, and soft-deleted items', (tester) async {
    final fakeTaskRepo = _FakeTaskRepo();
    final fakeProjRepo = _FakeProjectRepo();
    final fakeNoteRepo = _FakeNoteRepo();

    final now = DateTime.now().toUtc();
    fakeTaskRepo.tasks.add(
      TaskModel(
        id: 'task-trash',
        areaId: 'area-1',
        title: 'مهمة في المهملات للاختبار',
        status: 'todo',
        createdAt: now,
        updatedAt: now,
        deletedAt: now,
      ),
    );

    final tasksCtrl = TasksController(repository: fakeTaskRepo);
    final projectsCtrl = ProjectsController(repository: fakeProjRepo);
    final notesCtrl = NotesController(repository: fakeNoteRepo);

    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrashScreen(
            tasksController: tasksCtrl,
            projectsController: projectsCtrl,
            notesController: notesCtrl,
            noteRepository: fakeNoteRepo,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('سلة المهملات (Trash Bin)'), findsOneWidget);
    expect(find.textContaining('المهام'), findsOneWidget);
    expect(find.textContaining('المشاريع'), findsOneWidget);
    expect(find.textContaining('الملاحظات'), findsOneWidget);
    expect(find.text('مهمة في المهملات للاختبار'), findsOneWidget);
    expect(find.text('إفراغ السلة'), findsOneWidget);
  });
}
