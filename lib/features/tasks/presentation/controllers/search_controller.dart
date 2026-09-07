import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/i_task_repository.dart';

/// نطاق البحث المقيّد بالسياق.
enum SearchScope {
  /// البحث في النظام كاملاً.
  global,

  /// البحث داخل مجال محدد فقط.
  area,

  /// البحث داخل مشروع محدد فقط.
  project,
}

/// إدارة البحث اللحظي المقيّد بالسياق مع Debounce.
class SearchController extends ChangeNotifier {
  SearchController({
    ITaskRepository? repository,
    this.debounceDuration = const Duration(milliseconds: 300),
  }) : _repository = repository ?? TaskRepositoryImpl();

  final ITaskRepository _repository;
  final Duration debounceDuration;

  String _query = '';
  SearchScope _scope = SearchScope.global;
  String? _activeScopeId;
  List<TaskModel> _searchResults = <TaskModel>[];
  bool _isSearching = false;
  Timer? _debounce;

  String get query => _query;
  SearchScope get scope => _scope;
  String? get activeScopeId => _activeScopeId;
  List<TaskModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  bool get isEmpty => _query.trim().isEmpty;

  /// تعيين نص البحث مع تجهيز نطاق البحث الحالي تلقائياً.
  void searchIn(String value) {
    if (_query == value) return;
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, executeSearch);
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    _debounce?.cancel();
    _searchResults = <TaskModel>[];
    _isSearching = false;
    notifyListeners();
  }

  /// تعيين نطاق البحث الحالي (global / area / project).
  void setScope(SearchScope scope, String? activeScopeId) {
    if (_scope == scope && _activeScopeId == activeScopeId) return;
    _scope = scope;
    _activeScopeId = activeScopeId;
    if (!isEmpty) {
      _debounce?.cancel();
      _debounce = Timer(debounceDuration, executeSearch);
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  /// تنفيذ البحث الفوري النهائي حسب النطاق الحالي.
  Future<void> executeSearch() async {
    _debounce?.cancel();
    final value = _query.trim();
    if (value.isEmpty) {
      _searchResults = <TaskModel>[];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _searchResults = await _repository.searchTasks(
      value,
      areaId: _scope == SearchScope.area ? _activeScopeId : null,
      projectId: _scope == SearchScope.project ? _activeScopeId : null,
    );
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}