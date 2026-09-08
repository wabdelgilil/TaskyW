import '../models/tag_model.dart';

abstract class ITagRepository {
  Future<List<TagModel>> getAllTags();
  Future<TagModel?> getTagById(String id);
  Future<void> insertTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
  Future<void> softDeleteTag(String id);

  Future<void> assignTagToTask(String taskId, String tagId);
  Future<void> removeTagFromTask(String taskId, String tagId);
  Future<List<TagModel>> getTagsForTask(String taskId);
  Future<List<String>> getTaskIdsForTag(String tagId);
}