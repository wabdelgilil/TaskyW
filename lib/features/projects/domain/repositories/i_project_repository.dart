import '../../data/models/project_model.dart';

abstract class IProjectRepository {
  Future<List<ProjectModel>> getAllProjects();
  Future<List<ProjectModel>> getProjectsByArea(String areaId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> insertProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> softDeleteProject(String id);
}
