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
}