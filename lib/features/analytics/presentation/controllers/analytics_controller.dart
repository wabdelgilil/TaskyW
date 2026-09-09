import 'package:flutter/foundation.dart';

import '../../../areas/data/repositories/area_repository_impl.dart';
import '../../../areas/domain/repositories/i_area_repository.dart';
import '../../../projects/data/repositories/project_repository_impl.dart';
import '../../../projects/domain/repositories/i_project_repository.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../../data/productivity_analytics.dart';

class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    ITaskRepository? taskRepository,
    IAreaRepository? areaRepository,
    IProjectRepository? projectRepository,
  })  : _taskRepo = taskRepository ?? TaskRepositoryImpl(),
        _areaRepo = areaRepository ?? AreaRepositoryImpl(),
        _projectRepo = projectRepository ?? ProjectRepositoryImpl();

  final ITaskRepository _taskRepo;
  final IAreaRepository _areaRepo;
  final IProjectRepository _projectRepo;

  ProductivityReport? _report;
  bool _isLoading = false;
  String _range = 'weekly'; // 'weekly' | 'monthly'

  ProductivityReport? get report => _report;
  bool get isLoading => _isLoading;
  String get range => _range;

  List<CompletionPoint> get currentSeries =>
      _range == 'weekly' ? _report?.weeklySeries ?? [] : _report?.monthlySeries ?? [];

  void setRange(String r) {
    if (_range == r) return;
    _range = r;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _taskRepo.getTasks(),
        _areaRepo.getAllAreas(),
        _projectRepo.getAllProjects(),
      ]);
      final tasks = results[0] as List<dynamic>;
      final areas = results[1] as List<dynamic>;
      final projects = results[2] as List<dynamic>;
      _report = ProductivityAnalytics.buildReport(
        tasks: tasks.cast(),
        areas: areas.cast(),
        projects: projects.cast(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}