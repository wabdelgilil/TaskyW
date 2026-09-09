import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:tasky/features/tags/data/models/tag_model.dart';
import 'package:tasky/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:tasky/features/tags/domain/repositories/i_tag_repository.dart';
import '../../../tasks/data/models/task_model.dart';

/// إدارة حالة الوسوم: إنشاؤها، تعديلها، حذفها، وإسنادها للمهام.
class TagsController extends ChangeNotifier {
  TagsController({ITagRepository? repository})
      : _repository = repository ?? TagRepositoryImpl();

  final ITagRepository _repository;
  List<TagModel> _tags = <TagModel>[];
  String? _selectedTagId;
  bool _isLoading = false;

  /// معرفات المهام المرتبطة بالوسم المحدد حالياً (إن وُجد).
  Set<String> _activeTagTaskIds = <String>{};

  List<TagModel> get tags => List.unmodifiable(_tags);
  String? get selectedTagId => _selectedTagId;
  bool get isLoading => _isLoading;

  TagModel? get selectedTag {
    final id = _selectedTagId;
    if (id == null) return null;
    for (final tag in _tags) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  /// [true] عند وجود وسم نشط للفلترة.
  bool get hasActiveTagFilter => _selectedTagId != null;

  /// يرجع المهام المرشحة حسب الوسم النشط (كلها إن لم يُحدد وسم).
  List<TaskModel> filterTasksByActiveTag(List<TaskModel> tasks) {
    if (!hasActiveTagFilter) return tasks;
    return tasks.where((t) => _activeTagTaskIds.contains(t.id)).toList();
  }

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tags = await _repository.getAllTags();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTag(String? id) {
    if (_selectedTagId == id) return;
    _selectedTagId = id;
    notifyListeners();
  }

  /// مسح فلترة الوسم النشط.
  void clearTagFilter() {
    _selectedTagId = null;
    _activeTagTaskIds = <String>{};
    notifyListeners();
  }

  Future<void> createTag({required String name, String colorHex = '#64748B'}) async {
    var maxOrder = 0;
    for (final tag in _tags) {
      if (tag.orderIndex >= maxOrder) maxOrder = tag.orderIndex + 1;
    }
    final now = DateTime.now().toUtc();
    final tag = TagModel(
      id: const Uuid().v4(),
      name: name.trim(),
      colorHex: colorHex,
      orderIndex: maxOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertTag(tag);
    await loadTags();
  }

  Future<void> updateTag(TagModel tag) async {
    await _repository.updateTag(tag);
    await loadTags();
  }

  Future<void> deleteTag(String id) async {
    await _repository.softDeleteTag(id);
    if (_selectedTagId == id) {
      _selectedTagId = null;
      _activeTagTaskIds = <String>{};
    }
    await loadTags();
  }

  /// إسناد وسم إلى مهمة وتحديث الفلترة الحية.
  Future<void> assignTagToTask(String taskId, String tagId) async {
    await _repository.assignTagToTask(taskId, tagId);
    if (_selectedTagId == tagId) {
      _activeTagTaskIds.add(taskId);
      notifyListeners();
    }
  }

  /// فك وسم من مهمة.
  Future<void> removeTagFromTask(String taskId, String tagId) async {
    await _repository.removeTagFromTask(taskId, tagId);
    if (_selectedTagId == tagId) {
      _activeTagTaskIds.remove(taskId);
      notifyListeners();
    }
  }

  Future<List<TagModel>> getTagsForTask(String taskId) async {
    return await _repository.getTagsForTask(taskId);
  }

  /// تحميل معرفات المهام الخاصة بالوسم النشط.
  Future<void> refreshActiveTagTaskIds() async {
    final id = _selectedTagId;
    if (id == null) return;
    _activeTagTaskIds = (await _repository.getTaskIdsForTag(id)).toSet();
    notifyListeners();
  }
}