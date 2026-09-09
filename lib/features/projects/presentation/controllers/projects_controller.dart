import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/i_project_repository.dart';

/// إدارة حالة المشاريع: تحميلها، اختيارها، إنشاؤها، تعديلها وحذفها.
class ProjectsController extends ChangeNotifier {
  ProjectsController({IProjectRepository? repository})
      : _repository = repository ?? ProjectRepositoryImpl();

  final IProjectRepository _repository;
  List<ProjectModel> _projects = <ProjectModel>[];
  String? _selectedProjectId;
  bool _isLoading = false;

  // قوائم الأرشفة وسلة المهملات
  List<ProjectModel> _archivedProjects = <ProjectModel>[];
  List<ProjectModel> _trashProjects = <ProjectModel>[];
  bool _isLoadingArchived = false;
  bool _isLoadingTrash = false;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  String? get selectedProjectId => _selectedProjectId;
  bool get isLoading => _isLoading;

  ProjectModel? get selectedProject {
    final id = _selectedProjectId;
    if (id == null) return null;
    for (final project in _projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  // ─── الأرشفة وسلة المهملات (Archive & Trash System) ───────────────────
  List<ProjectModel> get archivedProjects => List.unmodifiable(_archivedProjects);
  List<ProjectModel> get trashProjects => List.unmodifiable(_trashProjects);
  int get archivedCount => _archivedProjects.length;
  int get trashCount => _trashProjects.length;
  bool get isLoadingArchived => _isLoadingArchived;
  bool get isLoadingTrash => _isLoadingTrash;

  Future<void> loadProjects({String? areaId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = areaId != null
          ? await _repository.getProjectsByArea(areaId)
          : await _repository.getAllProjects();
      if (_selectedProjectId != null &&
          !_projects.any((p) => p.id == _selectedProjectId)) {
        _selectedProjectId = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArchivedProjects() async {
    _isLoadingArchived = true;
    notifyListeners();
    try {
      _archivedProjects = await _repository.getArchivedProjects();
    } finally {
      _isLoadingArchived = false;
      notifyListeners();
    }
  }

  Future<void> loadTrashProjects() async {
    _isLoadingTrash = true;
    notifyListeners();
    try {
      _trashProjects = await _repository.getTrashProjects();
    } finally {
      _isLoadingTrash = false;
      notifyListeners();
    }
  }

  Future<void> selectProject(String? id) async {
    if (_selectedProjectId == id) return;
    _selectedProjectId = id;
    notifyListeners();
  }

  List<ProjectModel> getProjectsForArea(String areaId) =>
      _projects.where((p) => p.areaId == areaId).toList();

  Future<void> createProject({
    required String areaId,
    required String name,
    String? description,
    String iconEmoji = '📋',
    String colorHex = '#10B981',
    DateTime? targetDate,
  }) async {
    var maxOrder = 0;
    for (final project in _projects) {
      if (project.orderIndex >= maxOrder) maxOrder = project.orderIndex + 1;
    }
    final now = DateTime.now().toUtc();
    final project = ProjectModel(
      id: const Uuid().v4(),
      areaId: areaId,
      name: name.trim(),
      description: description,
      iconEmoji: iconEmoji,
      colorHex: colorHex,
      targetDate: targetDate,
      orderIndex: maxOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertProject(project);
    await loadProjects();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _repository.updateProject(project);
    await loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await _repository.softDeleteProject(id);
    if (_selectedProjectId == id) {
      _selectedProjectId = null;
    }
    await loadProjects();
  }

  Future<bool> archiveProject(String id) async {
    try {
      await _repository.archiveProject(id);
      if (_selectedProjectId == id) {
        _selectedProjectId = null;
      }
      await loadProjects();
      await loadArchivedProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unarchiveProject(String id) async {
    try {
      await _repository.unarchiveProject(id);
      await loadProjects();
      await loadArchivedProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> restoreProject(String id) async {
    try {
      await _repository.restoreProjectFromTrash(id);
      await loadProjects();
      await loadTrashProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> permanentlyDeleteProject(String id) async {
    try {
      await _repository.permanentlyDeleteProject(id);
      await loadTrashProjects();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> emptyProjectTrash() async {
    try {
      await _repository.emptyProjectTrash();
      _trashProjects = <ProjectModel>[];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}