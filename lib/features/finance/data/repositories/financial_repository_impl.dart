import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_financial_repository.dart';
import '../models/financial_record_model.dart';

class FinancialRepositoryImpl implements IFinancialRepository {
  final Database? dbOverride;

  FinancialRepositoryImpl({this.dbOverride});

  Future<Database> get _db async =>
      dbOverride ?? await AppDatabase.instance.database;

  @override
  Future<List<FinancialRecordModel>> getAllRecords() async {
    final db = await _db;
    final results = await db.query(
      DatabaseTables.financialRecordTable,
      where: 'deleted_at IS NULL',
      orderBy: 'transaction_date DESC',
    );
    return results.map((m) => FinancialRecordModel.fromMap(m)).toList();
  }

  @override
  Future<FinancialRecordModel?> getRecordById(String id) async {
    final db = await _db;
    final results = await db.query(
      DatabaseTables.financialRecordTable,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return FinancialRecordModel.fromMap(results.first);
  }

  @override
  Future<int> insertRecord(FinancialRecordModel record) async {
    final db = await _db;
    return await db.insert(
      DatabaseTables.financialRecordTable,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> updateRecord(FinancialRecordModel record) async {
    final db = await _db;
    final updated = record.copyWith(
      updatedAt: DateTime.now().toUtc(),
      syncStatus: record.syncStatus == 'synced' ? 'pending_update' : record.syncStatus,
    );
    return await db.update(
      DatabaseTables.financialRecordTable,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  @override
  Future<int> softDeleteRecord(String id) async {
    final db = await _db;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return await db.update(
      DatabaseTables.financialRecordTable,
      {
        'deleted_at': nowIso,
        'updated_at': nowIso,
        'sync_status': 'pending_delete',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> updateStatus(String id, String newStatus) async {
    final db = await _db;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return await db.update(
      DatabaseTables.financialRecordTable,
      {
        'status': newStatus,
        'updated_at': nowIso,
        'sync_status': 'pending_update',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> updateSettlementStatus(String id, String newSettlementStatus) async {
    final db = await _db;
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return await db.update(
      DatabaseTables.financialRecordTable,
      {
        'settlement_status': newSettlementStatus,
        'updated_at': nowIso,
        'sync_status': 'pending_update',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
