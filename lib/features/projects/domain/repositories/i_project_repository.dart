import '../../data/models/project_model.dart';

abstract class IProjectRepository {
  Future<List<ProjectModel>> getAllProjects();
  Future<List<ProjectModel>> getProjectsByArea(String areaId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> insertProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> softDeleteProject(String id);

  // ─── الأرشفة وسلة المهملات (Archive & Trash System) ───────────────────
  Future<List<ProjectModel>> getArchivedProjects();
  Future<List<ProjectModel>> getTrashProjects();
  Future<void> archiveProject(String id);
  Future<void> unarchiveProject(String id);
  Future<void> restoreProjectFromTrash(String id);
  Future<void> permanentlyDeleteProject(String id);
  Future<void> emptyProjectTrash();
}
