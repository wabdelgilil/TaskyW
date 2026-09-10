import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../data/models/financial_record_model.dart';
import '../controllers/financial_controller.dart';
import 'record_dialog.dart';

class FinancialRecordCard extends StatelessWidget {
  final FinancialRecordModel record;
  final FinancialController controller;

  const FinancialRecordCard({
    super.key,
    required this.record,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    IconData typeIcon;
    switch (record.type) {
      case 'income':
        badgeColor = Colors.green;
        typeIcon = Icons.arrow_downward_rounded;
        break;
      case 'transfer':
        badgeColor = Colors.blueAccent;
        typeIcon = Icons.swap_horiz_rounded;
        break;
      case 'expense':
      default:
        badgeColor = Colors.redAccent;
        typeIcon = Icons.arrow_upward_rounded;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isDark ? 0 : 0.8,
      color: AppColors.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: record.isPendingInvoice ? Colors.orange.withValues(alpha: 0.5) : AppColors.border(context),
          width: record.isPendingInvoice ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: badgeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.type == 'transfer'
                            ? l10n.transferFromTo(
                                record.fromAccount ?? l10n.notSpecified,
                                record.toAccount ?? l10n.notSpecified,
                              )
                            : (record.fromAccount != null ? l10n.viaAccount(record.fromAccount!) : l10n.generalTransaction),
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${record.amount.toStringAsFixed(2)} ${record.currency}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      '${record.transactionDate.year}-${record.transactionDate.month.toString().padLeft(2, '0')}-${record.transactionDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted(context)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (record.isPendingInvoice) ...[
                  InkWell(
                    onTap: () async {
                      await controller.markInvoiceReceived(record.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.invoiceReceivedToast)),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        l10n.invoicePendingTap,
                        style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (record.settlementType != 'none') ...[
                  InkWell(
                    onTap: () => controller.toggleSettlement(record.id),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (record.settlementStatus == 'settled'
                                ? Colors.blueGrey
                                : (record.isClaimFromWork ? Colors.green : Colors.redAccent))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.settlementStatus == 'settled'
                            ? l10n.settledToast
                            : (record.isClaimFromWork ? l10n.reimbursementRequired : l10n.owedByYou),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: record.settlementStatus == 'settled'
                              ? Colors.grey
                              : (record.isClaimFromWork ? Colors.green : Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  tooltip: l10n.editLabel,
                  splashRadius: 14,
                  onPressed: () => RecordDialog.show(context, controller: controller, record: record),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  tooltip: l10n.commonDelete,
                  splashRadius: 14,
                  onPressed: () async {
                    final confirmed = await ConfirmDeleteDialog.show(
                      context,
                      title: l10n.deleteTransaction,
                      message: l10n.deleteTransactionConfirm(record.title),
                    );
                    if (confirmed) {
                      await controller.deleteRecord(record.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
