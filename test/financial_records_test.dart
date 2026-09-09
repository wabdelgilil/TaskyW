import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/services/sync_service.dart';
import 'package:tasky/features/finance/data/models/financial_record_model.dart';
import 'package:tasky/features/finance/data/repositories/financial_repository_impl.dart';
import 'package:tasky/features/finance/presentation/controllers/financial_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppDatabase.inMemory = true;
  });

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('FinancialRecordModel', () {
    test('toMap and fromMap round-trip preserving all fields', () {
      final now = DateTime.utc(2026, 9, 9, 12, 0, 0);
      final record = FinancialRecordModel(
        id: 'fin-1',
        type: 'expense',
        amount: 450.50,
        currency: 'EGP',
        category: 'work_expense',
        title: 'شراء كابلات وسويتش للشبكة',
        notes: 'دفعت من حسابي الشخصي ومطلوب استردادها من الشركة',
        transactionDate: now,
        fromAccount: 'البنك الأهلي',
        toAccount: null,
        settlementType: 'claim_from_work',
        settlementStatus: 'pending',
        status: 'pending_invoice',
        receiptPath: '/local/receipt.jpg',
        syncStatus: 'synced',
        createdAt: now,
        updatedAt: now,
      );

      final map = record.toMap();
      final restored = FinancialRecordModel.fromMap(map);

      expect(restored.id, 'fin-1');
      expect(restored.type, 'expense');
      expect(restored.amount, 450.50);
      expect(restored.currency, 'EGP');
      expect(restored.category, 'work_expense');
      expect(restored.title, 'شراء كابلات وسويتش للشبكة');
      expect(restored.notes, 'دفعت من حسابي الشخصي ومطلوب استردادها من الشركة');
      expect(restored.fromAccount, 'البنك الأهلي');
      expect(restored.toAccount, isNull);
      expect(restored.settlementType, 'claim_from_work');
      expect(restored.settlementStatus, 'pending');
      expect(restored.status, 'pending_invoice');
      expect(restored.isPendingInvoice, isTrue);
      expect(restored.receiptPath, '/local/receipt.jpg');
      expect(restored.syncStatus, 'synced');
      expect(restored.isClaimFromWork, isTrue);
      expect(restored.isOweToWork, isFalse);
    });

    test('Default values when optional fields are null or missing', () {
      final now = DateTime.utc(2026, 9, 9, 10, 0, 0);
      final record = FinancialRecordModel.fromMap({
        'id': 'fin-2',
        'title': 'مصروف بسيط',
        'amount': 100,
        'transaction_date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      expect(record.type, 'expense');
      expect(record.amount, 100.0);
      expect(record.currency, 'EGP');
      expect(record.settlementType, 'none');
      expect(record.settlementStatus, 'none');
      expect(record.isPendingInvoice, isFalse);
      expect(record.syncStatus, 'pending_insert');
    });

    test('copyWith updates specified fields only', () {
      final now = DateTime.utc(2026, 9, 9, 10, 0, 0);
      final record = FinancialRecordModel(
        id: 'fin-3',
        type: 'expense',
        amount: 200,
        currency: 'EGP',
        category: 'office',
        title: 'فاتورة سابقة',
        transactionDate: now,
        status: 'pending_invoice',
        createdAt: now,
        updatedAt: now,
      );

      final updated = record.copyWith(
        status: 'completed',
        amount: 250,
      );

      expect(updated.id, 'fin-3');
      expect(updated.title, 'فاتورة سابقة');
      expect(updated.isPendingInvoice, isFalse);
      expect(updated.amount, 250);
    });
  });

  group('FinancialRepositoryImpl (SQLite)', () {
    test('insert, retrieve, and filter financial records', () async {
      final repo = FinancialRepositoryImpl();
      final now = DateTime.utc(2026, 9, 9, 11, 0, 0);

      final record1 = FinancialRecordModel(
        id: 'rec-1',
        type: 'expense',
        amount: 300,
        currency: 'EGP',
        category: 'work',
        title: 'شراء ورق وطابعات',
        transactionDate: now,
        settlementType: 'claim_from_work',
        settlementStatus: 'pending',
        status: 'pending_invoice',
        createdAt: now,
        updatedAt: now,
      );

      final record2 = FinancialRecordModel(
        id: 'rec-2',
        type: 'expense',
        amount: 150,
        currency: 'EGP',
        category: 'personal',
        title: 'قهوة وفطور شخصي ببطاقة الشغل',
        transactionDate: now,
        settlementType: 'owe_to_work',
        settlementStatus: 'pending',
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      await repo.insertRecord(record1);
      await repo.insertRecord(record2);

      final allRecords = await repo.getAllRecords();
      expect(allRecords.length, 2);

      final pendingInvoices = allRecords.where((r) => r.isPendingInvoice).toList();
      expect(pendingInvoices.length, 1);
      expect(pendingInvoices.first.id, 'rec-1');

      final pendingSettlements = allRecords.where((r) => r.isSettlementPending).toList();
      expect(pendingSettlements.length, 2);

      // Update settlement status
      await repo.updateSettlementStatus('rec-1', 'settled');
      final updatedRec1 = await repo.getRecordById('rec-1');
      expect(updatedRec1!.settlementStatus, 'settled');

      final refreshedRecords = await repo.getAllRecords();
      final pendingAfterSettlement = refreshedRecords.where((r) => r.isSettlementPending).toList();
      expect(pendingAfterSettlement.length, 1);
      expect(pendingAfterSettlement.first.id, 'rec-2');

      // Update invoice status
      await repo.updateStatus('rec-1', 'completed');
      final updatedInvoice = await repo.getRecordById('rec-1');
      expect(updatedInvoice!.isPendingInvoice, isFalse);

      // Soft delete
      await repo.softDeleteRecord('rec-2');
      final remaining = await repo.getAllRecords();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'rec-1');
    });
  });

  group('FinancialController logic & calculations', () {
    test('calculates pending invoice count and net settlement balance accurately', () async {
      final repo = FinancialRepositoryImpl();
      final controller = FinancialController(repository: repo);
      await controller.load();

      final now = DateTime.utc(2026, 9, 9, 9, 0, 0);

      // 1. Personal spent for work: 1000 EGP (Company owes me 1000)
      await controller.addRecord(
        type: 'expense',
        amount: 1000,
        currency: 'EGP',
        category: 'it_tools',
        title: 'شراء ماوس وشاشة للمكتب',
        transactionDate: now,
        settlementType: 'claim_from_work',
        status: 'pending_invoice',
      );

      // 2. Work petty cash spent for personal: 200 EGP (I owe company 200)
      await controller.addRecord(
        type: 'expense',
        amount: 200,
        currency: 'EGP',
        category: 'lunch',
        title: 'وجبة غداء شخصية من عهدة العمل',
        transactionDate: now,
        settlementType: 'owe_to_work',
        status: 'completed',
      );

      // 3. Regular expense: 50 EGP (no settlement)
      await controller.addRecord(
        type: 'expense',
        amount: 50,
        currency: 'EGP',
        category: 'transport',
        title: 'تاكسي',
        transactionDate: now,
        settlementType: 'none',
        status: 'pending_invoice',
      );

      expect(controller.pendingInvoicesCount, 2); // items 1 and 3
      expect(controller.totalClaimsFromWork, 1000.0);
      expect(controller.totalOwedToWork, 200.0);
      expect(controller.netSettlementBalance, 800.0); // 1000 - 200 = 800 (Company owes me)

      // Test filtering
      controller.setFilter('pending_invoices');
      expect(controller.visibleRecords.length, 2);

      controller.setFilter('claim_from_work');
      expect(controller.visibleRecords.length, 1);
      expect(controller.visibleRecords.first.title, 'شراء ماوس وشاشة للمكتب');

      controller.setFilter('owe_to_work');
      expect(controller.visibleRecords.length, 1);
      expect(controller.visibleRecords.first.title, 'وجبة غداء شخصية من عهدة العمل');

      controller.setFilter('all');
      controller.setSearchQuery('شاشة');
      expect(controller.visibleRecords.length, 1);

      controller.setSearchQuery('');
      expect(controller.visibleRecords.length, 3);

      // Test toggle settlement
      final claimRecord = controller.allRecords.firstWhere((r) => r.isClaimFromWork);
      await controller.toggleSettlement(claimRecord.id);
      expect(controller.totalClaimsFromWork, 0.0);
      expect(controller.netSettlementBalance, -200.0); // Now I owe 200

      // Test mark invoice received
      final invoiceRecord = controller.allRecords.firstWhere((r) => r.isPendingInvoice);
      await controller.markInvoiceReceived(invoiceRecord.id);
      expect(controller.pendingInvoicesCount, 1);

      // Test CSV export content
      final csv = controller.exportToCsv();
      expect(csv.startsWith('\uFEFF'), isTrue); // Has UTF-8 BOM
      expect(csv.contains('التاريخ,البيان,النوع,المبلغ,العملة'), isTrue);
      expect(csv.contains('وجبة غداء شخصية من عهدة العمل'), isTrue);
    });
  });

  group('SyncService & Schema v7 integration', () {
    test('toLocalRow correctly strips user_id and maintains sync_status', () {
      const validColumns = [
        'id', 'type', 'amount', 'currency', 'category', 'title',
        'status', 'from_account', 'to_account',
        'settlement_type', 'settlement_status',
        'sync_status', 'created_at', 'updated_at', 'deleted_at',
      ];

      final cloudRow = {
        'id': 'cloud-fin-1',
        'user_id': 'user-123',
        'type': 'expense',
        'amount': 500,
        'currency': 'EGP',
        'category': 'tools',
        'title': 'سحابة',
        'status': 'pending_invoice',
        'from_account': 'محفظة',
        'to_account': null,
        'settlement_type': 'none',
        'settlement_status': 'none',
        'created_at': '2026-09-09T00:00:00.000Z',
        'updated_at': '2026-09-09T00:00:00.000Z',
        'deleted_at': null,
      };

      final localRow = SyncService.toLocalRow(cloudRow, validColumns);
      expect(localRow.containsKey('user_id'), isFalse);
      expect(localRow['sync_status'], 'synced');
    });

    test('toCloudPayload includes user_id and excludes sync_status & receipt_path', () {
      final now = DateTime.utc(2026, 9, 9, 0, 0, 0);
      final record = FinancialRecordModel(
        id: 'fin-local-1',
        type: 'expense',
        amount: 250,
        currency: 'EGP',
        category: 'services',
        title: 'استضافة',
        transactionDate: now,
        receiptPath: 'C:\\local\\receipt.png',
        createdAt: now,
        updatedAt: now,
      );

      final row = record.toMap();
      final payload = SyncService.toCloudPayload(row, 'user-999');

      expect(payload['user_id'], 'user-999');
      expect(payload.containsKey('sync_status'), isFalse);
      expect(payload['amount'], 250);
    });

    test('v6 -> v7 DB upgrade creates financial_records table', () async {
      final tempDir = await Directory.systemTemp.createTemp('tasky_db_upgrade_v7');
      try {
        final dbPath = p.join(tempDir.path, 'old_v6.db');
        AppDatabase.databasePathOverride = dbPath;

        // Open an older v6 database
        final oldDb = await databaseFactory.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 6,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE IF NOT EXISTS areas (
                  id TEXT PRIMARY KEY,
                  name TEXT NOT NULL,
                  created_at TEXT NOT NULL,
                  updated_at TEXT NOT NULL
                );
              ''');
            },
          ),
        );
        await oldDb.close();

        // Now open via AppDatabase (which is at v7)
        final upgradedDb = await AppDatabase.instance.database;
        final tables = await upgradedDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name = 'financial_records'",
        );
        expect(tables, hasLength(1));

        final columns = await upgradedDb.rawQuery('PRAGMA table_info(financial_records)');
        final columnNames = columns.map((c) => c['name']).toSet();
        expect(columnNames, containsAll([
          'id',
          'type',
          'amount',
          'currency',
          'category',
          'title',
          'settlement_type',
          'settlement_status',
          'status',
          'receipt_path',
        ]));
      } finally {
        await AppDatabase.resetForTest();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });
  });
}
