import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/financial_record_model.dart';
import '../../data/repositories/financial_repository_impl.dart';
import '../../domain/repositories/i_financial_repository.dart';

/// وحدة التحكم وإدارة الحالة للعمليات المالية والتسويات والفواتير المعلقة.
class FinancialController extends ChangeNotifier {
  static const _uuid = Uuid();
  final IFinancialRepository _repo;

  FinancialController({IFinancialRepository? repository})
      : _repo = repository ?? FinancialRepositoryImpl();

  List<FinancialRecordModel> _records = [];
  bool _isLoading = false;
  String? _error;

  // فلاتر التصفية
  String _activeFilter = 'all'; // 'all', 'pending_invoices', 'claim_from_work', 'owe_to_work', 'transfers'
  String _searchQuery = '';

  List<FinancialRecordModel> get allRecords => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;

  // --- الإحصائيات المالية اللحظية ---
  int get pendingInvoicesCount =>
      _records.where((r) => r.isPendingInvoice).length;

  double get pendingInvoicesTotal => _records
      .where((r) => r.isPendingInvoice)
      .fold<double>(0.0, (sum, r) => sum + r.amount);

  /// إجمالي المبالغ المستحقة لي طرف الشغل (دفعتها من جيبي الخاص ولم تُسوَّ بعد).
  double get totalClaimsFromWork => _records
      .where((r) => r.isClaimFromWork && r.isSettlementPending)
      .fold<double>(0.0, (sum, r) => sum + r.amount);

  /// إجمالي المبالغ المستحقة عليّ للشغل (دفعتها شخصي من عهدة/حساب الشغل ولم تُسوَّ بعد).
  double get totalOwedToWork => _records
      .where((r) => r.isOweToWork && r.isSettlementPending)
      .fold<double>(0.0, (sum, r) => sum + r.amount);

  /// صافي التسوية:
  /// موجب (+) = لك عند الشغل (Company owes you).
  /// سالب (-) = عليك للشغل (You owe company).
  double get netSettlementBalance => totalClaimsFromWork - totalOwedToWork;

  /// القائمة المعروضة بعد تطبيق الفلتر والبحث
  List<FinancialRecordModel> get visibleRecords {
    List<FinancialRecordModel> filtered = _records;

    switch (_activeFilter) {
      case 'pending_invoices':
        filtered = filtered.where((r) => r.isPendingInvoice).toList();
        break;
      case 'claim_from_work':
        filtered = filtered.where((r) => r.isClaimFromWork).toList();
        break;
      case 'owe_to_work':
        filtered = filtered.where((r) => r.isOweToWork).toList();
        break;
      case 'transfers':
        filtered = filtered.where((r) => r.isTransfer).toList();
        break;
      case 'all':
      default:
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((r) {
        final matchTitle = r.title.toLowerCase().contains(q);
        final matchCategory = (r.category ?? '').toLowerCase().contains(q);
        final matchFrom = (r.fromAccount ?? '').toLowerCase().contains(q);
        final matchTo = (r.toAccount ?? '').toLowerCase().contains(q);
        final matchNotes = (r.notes ?? '').toLowerCase().contains(q);
        return matchTitle || matchCategory || matchFrom || matchTo || matchNotes;
      }).toList();
    }

    return filtered;
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repo.getAllRecords();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FinancialRecordModel?> addRecord({
    required String type,
    required double amount,
    String currency = 'SAR',
    required String title,
    String? category,
    String status = 'completed',
    String? fromAccount,
    String? toAccount,
    String settlementType = 'none',
    String settlementStatus = 'none',
    String? receiptPath,
    String? areaId,
    DateTime? transactionDate,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final newRecord = FinancialRecordModel(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      currency: currency,
      title: title,
      category: category,
      status: status,
      fromAccount: fromAccount,
      toAccount: toAccount,
      settlementType: settlementType,
      settlementStatus: settlementType != 'none' && settlementStatus == 'none'
          ? 'pending'
          : settlementStatus,
      receiptPath: receiptPath,
      areaId: areaId,
      transactionDate: transactionDate ?? now,
      notes: notes,
      syncStatus: 'pending_insert',
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repo.insertRecord(newRecord);
      _records.insert(0, newRecord);
      notifyListeners();
      return newRecord;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRecord(FinancialRecordModel record) async {
    try {
      await _repo.updateRecord(record);
      final idx = _records.indexWhere((r) => r.id == record.id);
      if (idx != -1) {
        _records[idx] = record;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      await _repo.softDeleteRecord(id);
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// تحويل حالة الفاتورة (مثلاً من 'pending_invoice' إلى 'completed' مع إمكانية إرفاق الإيصال).
  Future<bool> markInvoiceReceived(String id, {String? receiptPath}) async {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx == -1) return false;

    final current = _records[idx];
    final updated = current.copyWith(
      status: 'completed',
      receiptPath: receiptPath ?? current.receiptPath,
      updatedAt: DateTime.now().toUtc(),
    );

    return await updateRecord(updated);
  }

  /// تبديل حالة التسوية بين معلقة ومنتهية (settled vs pending).
  Future<bool> toggleSettlement(String id) async {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx == -1) return false;

    final current = _records[idx];
    if (current.settlementType == 'none') return false;

    final nextStatus = current.settlementStatus == 'settled' ? 'pending' : 'settled';
    final updated = current.copyWith(
      settlementStatus: nextStatus,
      updatedAt: DateTime.now().toUtc(),
    );

    return await updateRecord(updated);
  }

  /// تصدير كشف التسويات والعمليات إلى نص CSV متوافق مع Excel واللغة العربية (UTF-8 BOM).
  String exportToCsv() {
    const bom = '\uFEFF';
    final rows = <String>[
      'التاريخ,البيان,النوع,المبلغ,العملة,الحالة,من حساب,إلى حساب,نوع التسوية,حالة التسوية,الملاحظات',
    ];

    for (final r in visibleRecords) {
      final d = '${r.transactionDate.year}-${r.transactionDate.month.toString().padLeft(2, '0')}-${r.transactionDate.day.toString().padLeft(2, '0')}';
      String typeLabel;
      switch (r.type) {
        case 'income':
          typeLabel = 'دخل / استرداد';
          break;
        case 'transfer':
          typeLabel = 'تحويل بين حسابات';
          break;
        case 'expense':
        default:
          typeLabel = 'مصروف / شراء';
          break;
      }

      String statusLabel = r.isPendingInvoice ? 'بانتظار الفاتورة ⚠️' : 'مكتمل ومستلم';
      String settlementTypeLabel;
      switch (r.settlementType) {
        case 'claim_from_work':
          settlementTypeLabel = 'مستحق من العمل (Reimbursement)';
          break;
        case 'owe_to_work':
          settlementTypeLabel = 'مستحق للعمل (Personal from Work)';
          break;
        case 'none':
        default:
          settlementTypeLabel = 'غير مطلوب';
          break;
      }

      String settlementStatusLabel = r.settlementStatus == 'settled' ? 'تمت التسوية' : (r.settlementStatus == 'pending' ? 'معلق' : '-');

      String escape(String? val) {
        if (val == null) return '';
        final clean = val.replaceAll('"', '""');
        return '"$clean"';
      }

      rows.add([
        d,
        escape(r.title),
        typeLabel,
        r.amount.toStringAsFixed(2),
        r.currency,
        statusLabel,
        escape(r.fromAccount),
        escape(r.toAccount),
        settlementTypeLabel,
        settlementStatusLabel,
        escape(r.notes),
      ].join(','));
    }

    return '$bom${rows.join('\r\n')}\r\n';
  }
}
