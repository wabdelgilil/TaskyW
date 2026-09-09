/// نموذج العملية المالية والتسوية والفاتورة المعلقة.
///
/// يدعم 3 أنواع رئيسية:
/// - xpense: مصروف / مشتريات.
/// - income: دخل / استرداد.
/// - 	ransfer: تحويل بين حسابين أو محفظتين.
///
/// ويدعم تتبع الفواتير المعلقة:
/// - status: 'completed' | 'pending_invoice'
///
/// وتتبع التسوية التبادلية بين الشغل والشخصي:
/// - settlement_type:
///   - 'none': لا تتطلب تسوية (معاملة عادية).
///   - 'claim_from_work': دفعت للشغل من جيبي الخاص (لي عند الشغل / Reimbursement).
///   - 'owe_to_work': دفعت لحاجة شخصية من عهدة/حساب الشغل (عليّ للشغل).
/// - settlement_status:
///   - 'none': غير مطلوبة.
///   - 'pending': معلقة وبانتظار التسوية.
///   - 'settled': تمت التسوية وسداد أو استرداد المبلغ.
class FinancialRecordModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String title;
  final String? category;
  final String status;
  final String? fromAccount;
  final String? toAccount;
  final String settlementType;
  final String settlementStatus;
  final String? receiptPath;
  final String? areaId;
  final DateTime transactionDate;
  final String? notes;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const FinancialRecordModel({
    required this.id,
    required this.type,
    required this.amount,
    this.currency = 'EGP',
    required this.title,
    this.category,
    this.status = 'completed',
    this.fromAccount,
    this.toAccount,
    this.settlementType = 'none',
    this.settlementStatus = 'none',
    this.receiptPath,
    this.areaId,
    required this.transactionDate,
    this.notes,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isPendingInvoice => status == 'pending_invoice';
  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get isTransfer => type == 'transfer';
  bool get isClaimFromWork => settlementType == 'claim_from_work';
  bool get isOweToWork => settlementType == 'owe_to_work';
  bool get isSettlementPending => settlementStatus == 'pending';

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'amount': amount,
    'currency': currency,
    'title': title,
    'category': category,
    'status': status,
    'from_account': fromAccount,
    'to_account': toAccount,
    'settlement_type': settlementType,
    'settlement_status': settlementStatus,
    'receipt_path': receiptPath,
    'area_id': areaId,
    'transaction_date': transactionDate.toUtc().toIso8601String(),
    'notes': notes,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory FinancialRecordModel.fromMap(Map<String, dynamic> map) {
    return FinancialRecordModel(
      id: map['id'] as String,
      type: (map['type'] as String?) ?? 'expense',
      amount: ((map['amount'] as num?) ?? 0).toDouble(),
      currency: (map['currency'] as String?) ?? 'EGP',
      title: (map['title'] as String?) ?? '',
      category: map['category'] as String?,
      status: (map['status'] as String?) ?? 'completed',
      fromAccount: map['from_account'] as String?,
      toAccount: map['to_account'] as String?,
      settlementType: (map['settlement_type'] as String?) ?? 'none',
      settlementStatus: (map['settlement_status'] as String?) ?? 'none',
      receiptPath: map['receipt_path'] as String?,
      areaId: map['area_id'] as String?,
      transactionDate: DateTime.parse(
        (map['transaction_date'] as String?) ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      notes: map['notes'] as String?,
      syncStatus: (map['sync_status'] as String?) ?? 'pending_insert',
      createdAt: DateTime.parse(
        (map['created_at'] as String?) ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] as String?) ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
    );
  }

  FinancialRecordModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? currency,
    String? title,
    String? category,
    String? status,
    String? fromAccount,
    String? toAccount,
    String? settlementType,
    String? settlementStatus,
    String? receiptPath,
    String? areaId,
    DateTime? transactionDate,
    String? notes,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return FinancialRecordModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      settlementType: settlementType ?? this.settlementType,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      receiptPath: receiptPath ?? this.receiptPath,
      areaId: areaId ?? this.areaId,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
