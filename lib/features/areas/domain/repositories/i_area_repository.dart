import '../../data/models/area_model.dart';

abstract class IAreaRepository {
  Future<List<AreaModel>> getAllAreas();
  Future<AreaModel?> getAreaById(String id);
  Future<void> insertArea(AreaModel area);
  Future<void> updateArea(AreaModel area);
  Future<void> softDeleteArea(String id);
}
