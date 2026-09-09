import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/financial_controller.dart';
import '../widgets/financial_record_card.dart';
import '../widgets/record_dialog.dart';

/// الشاشة المركزية المستقلة للسجل المالي والمصروفات وتسوية الحسابات.
class FinancialLogScreen extends StatefulWidget {
  final FinancialController? controller;

  const FinancialLogScreen({super.key, this.controller});

  @override
  State<FinancialLogScreen> createState() => _FinancialLogScreenState();
}

class _FinancialLogScreenState extends State<FinancialLogScreen> {
  late final FinancialController _controller;
  late final bool _ownsController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? FinancialController();
    _controller.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _exportFinancialsToCsv() {
    final csv = _controller.exportToCsv();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير ${_controller.visibleRecords.length} عملية ونسخ CSV إلى الحافظة!'),
        action: SnackBarAction(
          label: 'معاينة',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('كشف الحساب المُصدّر (CSV)'),
                content: SizedBox(
                  width: 500,
                  height: 300,
                  child: SingleChildScrollView(
                    child: SelectableText(csv, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading && _controller.allRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final visible = _controller.visibleRecords;
        final pendingInvoicesCount = _controller.pendingInvoicesCount;
        final netBalance = _controller.netSettlementBalance;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => RecordDialog.show(context, controller: _controller),
            icon: const Icon(Icons.add_rounded),
            label: const Text('عملية جديدة'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  border: Border(bottom: BorderSide(color: AppColors.border(context))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _controller.setFilter(
                          _controller.activeFilter == 'pending_invoices' ? 'all' : 'pending_invoices',
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _controller.activeFilter == 'pending_invoices'
                                  ? Colors.orange
                                  : Colors.orange.withOpacity(0.3),
                              width: _controller.activeFilter == 'pending_invoices' ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long_rounded, color: Colors.orange, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('فواتير معلقة', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                                    Text(
                                      '$pendingInvoicesCount فواتير (${_controller.pendingInvoicesTotal.toStringAsFixed(0)} SAR)',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary(context)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (netBalance >= 0 ? Colors.green : Colors.redAccent).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (netBalance >= 0 ? Colors.green : Colors.redAccent).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              netBalance >= 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: netBalance >= 0 ? Colors.green : Colors.redAccent,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    netBalance >= 0 ? 'لك عند الشغل (صافي)' : 'عليك للشغل (صافي)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: netBalance >= 0 ? Colors.green : Colors.redAccent,
                                    ),
                                  ),
                                  Text(
                                    '${netBalance.abs().toStringAsFixed(0)} SAR',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'بحث في العمليات، الحسابات، الملاحظات...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _controller.setSearchQuery('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (q) => _controller.setSearchQuery(q),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.download_rounded, size: 20),
                      tooltip: 'تصدير كشف الحساب إلى Excel / CSV',
                      onPressed: _exportFinancialsToCsv,
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: Row(
                  children: [
                    _buildFilterChip('الكل', 'all'),
                    _buildFilterChip('⚠️ بانتظار الفاتورة', 'pending_invoices'),
                    _buildFilterChip('💼 مستحق من الشغل', 'claim_from_work'),
                    _buildFilterChip('🏠 مدفوع للشغل', 'owe_to_work'),
                    _buildFilterChip('🔄 تحويلات', 'transfers'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted(context)),
                            const SizedBox(height: 10),
                            Text(
                              _controller.allRecords.isEmpty
                                  ? 'لا توجد أي عمليات مالية مسجلة بعد'
                                  : 'لا توجد نتائج مطابقة للفلتر المحدد',
                              style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 80),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final r = visible[index];
                          return FinancialRecordCard(record: r, controller: _controller);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _controller.activeFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        onSelected: (_) => _controller.setFilter(value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
