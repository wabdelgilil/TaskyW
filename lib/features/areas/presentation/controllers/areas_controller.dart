import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/area_model.dart';
import '../../data/repositories/area_repository_impl.dart';
import '../../domain/repositories/i_area_repository.dart';

/// إدارة حالة المجالات: تحميلها، اختيارها، إنشاؤها، تعديلها وحذفها.
class AreasController extends ChangeNotifier {
  AreasController({IAreaRepository? repository})
      : _repository = repository ?? AreaRepositoryImpl();

  final IAreaRepository _repository;
  List<AreaModel> _areas = <AreaModel>[];
  String? _selectedAreaId;
  bool _isLoading = false;

  List<AreaModel> get areas => List.unmodifiable(_areas);
  String? get selectedAreaId => _selectedAreaId;
  bool get isLoading => _isLoading;

  AreaModel? get selectedArea {
    final id = _selectedAreaId;
    if (id == null) return null;
    for (final area in _areas) {
      if (area.id == id) return area;
    }
    return null;
  }

  Future<void> loadAreas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _areas = await _repository.getAllAreas();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectArea(String? id) {
    if (_selectedAreaId == id) return;
    _selectedAreaId = id;
    notifyListeners();
  }

  Future<void> createArea({
    required String name,
    String iconEmoji = '📁',
    String colorHex = '#3B82F6',
  }) async {
    var maxOrder = 0;
    for (final area in _areas) {
      if (area.orderIndex >= maxOrder) maxOrder = area.orderIndex + 1;
    }
    final now = DateTime.now().toUtc();
    final area = AreaModel(
      id: const Uuid().v4(),
      name: name.trim(),
      iconEmoji: iconEmoji,
      colorHex: colorHex,
      orderIndex: maxOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertArea(area);
    await loadAreas();
  }

  Future<void> updateArea(AreaModel area) async {
    await _repository.updateArea(area);
    await loadAreas();
  }

  Future<void> deleteArea(String id) async {
    await _repository.softDeleteArea(id);
    if (_selectedAreaId == id) {
      _selectedAreaId = null;
    }
    await loadAreas();
  }
}