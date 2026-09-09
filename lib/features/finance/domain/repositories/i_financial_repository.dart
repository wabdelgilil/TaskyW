import '../../data/models/financial_record_model.dart';

abstract class IFinancialRepository {
  Future<List<FinancialRecordModel>> getAllRecords();
  Future<FinancialRecordModel?> getRecordById(String id);
  Future<int> insertRecord(FinancialRecordModel record);
  Future<int> updateRecord(FinancialRecordModel record);
  Future<int> softDeleteRecord(String id);
  Future<int> updateStatus(String id, String newStatus);
  Future<int> updateSettlementStatus(String id, String newSettlementStatus);
}
