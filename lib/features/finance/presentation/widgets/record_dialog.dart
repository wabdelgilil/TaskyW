import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../data/models/financial_record_model.dart';
import '../controllers/financial_controller.dart';

class RecordDialog {
  static Future<void> show(
    BuildContext context, {
    required FinancialController controller,
    FinancialRecordModel? record,
  }) async {
    final l10n = context.l10n;
    final titleCtrl = TextEditingController(text: record?.title ?? '');
    final amountCtrl = TextEditingController(
      text: record != null ? record.amount.toString() : '',
    );
    final categoryCtrl = TextEditingController(text: record?.category ?? '');
    final fromAccountCtrl = TextEditingController(text: record?.fromAccount ?? l10n.cashOption);
    final toAccountCtrl = TextEditingController(text: record?.toAccount ?? '');
    final notesCtrl = TextEditingController(text: record?.notes ?? '');

    final settingsCurrency = SettingsController.instance.defaultCurrency;
    String type = record?.type ?? 'expense';
    String currency = record?.currency ?? settingsCurrency;
    bool isPendingInvoice = record?.isPendingInvoice ?? false;
    String settlementType = record?.settlementType ?? 'none';
    DateTime txDate = record?.transactionDate ?? DateTime.now();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card(context),
              title: Text(
                record == null ? l10n.newTransactionTitle : l10n.editTransactionTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'expense',
                            label: Text(l10n.expenseOption, style: TextStyle(fontSize: 12)),
                            icon: Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.redAccent),
                          ),
                          ButtonSegment(
                            value: 'income',
                            label: Text(l10n.incomeRefundOption, style: TextStyle(fontSize: 12)),
                            icon: Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.green),
                          ),
                          ButtonSegment(
                            value: 'transfer',
                            label: Text(l10n.transferOption, style: TextStyle(fontSize: 12)),
                            icon: Icon(Icons.swap_horiz_rounded, size: 14, color: Colors.blueAccent),
                          ),
                        ],
                        selected: {type},
                        onSelectionChanged: (set) {
                          setDialogState(() {
                            type = set.first;
                            if (type == 'transfer' && toAccountCtrl.text.isEmpty) {
                              toAccountCtrl.text = context.l10n.bankOption;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.amountLabel,
                          hintText: '0.00',
                          suffixText: 'SAR',
                          prefixIcon: Icon(Icons.attach_money_rounded, size: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.descriptionLabel,
                          hintText: l10n.descriptionHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fromAccountCtrl,
                              decoration: InputDecoration(
                                labelText: type == 'transfer' ? l10n.fromAccount : l10n.paymentMethodLabel,
                                hintText: l10n.paymentMethodHint,
                              ),
                            ),
                          ),
                          if (type == 'transfer') ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: toAccountCtrl,
                                decoration: InputDecoration(
                                  labelText: l10n.toAccount,
                                  hintText: l10n.toAccountHint,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.handshake_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.settlementLabel,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: settlementType,
                              isDense: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'none',
                                  child: Text(l10n.normalTransaction, style: TextStyle(fontSize: 12)),
                                ),
                                DropdownMenuItem(
                                  value: 'claim_from_work',
                                  child: Text(l10n.paidFromPocket, style: TextStyle(fontSize: 12, color: Colors.green)),
                                ),
                                DropdownMenuItem(
                                  value: 'owe_to_work',
                                  child: Text(l10n.paidPersonalFromWork, style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setDialogState(() => settlementType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (type == 'expense')
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Text(l10n.notReceivedInvoice, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Text(l10n.reminderNote, style: TextStyle(fontSize: 11, color: Colors.orange)),
                            ],
                          ),
                          subtitle: Text(
                            l10n.pendingInvoiceReminder,
                            style: TextStyle(fontSize: 11),
                          ),
                          value: isPendingInvoice,
                          onChanged: (val) {
                            setDialogState(() => isPendingInvoice = val ?? false);
                          },
                        ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.additionalNotes,
                          hintText: l10n.notesHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (title.isEmpty || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.invalidTransactionMsg)),
                      );
                      return;
                    }

                    final status = isPendingInvoice ? 'pending_invoice' : 'completed';

                    if (record == null) {
                      await controller.addRecord(
                        type: type,
                        amount: amount,
                        currency: currency,
                        title: title,
                        category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                        status: status,
                        fromAccount: fromAccountCtrl.text.trim().isEmpty ? null : fromAccountCtrl.text.trim(),
                        toAccount: type == 'transfer' ? toAccountCtrl.text.trim() : null,
                        settlementType: settlementType,
                        settlementStatus: settlementType != 'none' ? 'pending' : 'none',
                        transactionDate: txDate,
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      );
                    } else {
                      final updated = record.copyWith(
                        type: type,
                        amount: amount,
                        currency: currency,
                        title: title,
                        category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                        status: status,
                        fromAccount: fromAccountCtrl.text.trim().isEmpty ? null : fromAccountCtrl.text.trim(),
                        toAccount: type == 'transfer' ? toAccountCtrl.text.trim() : null,
                        settlementType: settlementType,
                        settlementStatus: settlementType == 'none'
                            ? 'none'
                            : (record.settlementStatus == 'none' ? 'pending' : record.settlementStatus),
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                        updatedAt: DateTime.now().toUtc(),
                      );
                      await controller.updateRecord(updated);
                    }

                    if (context.mounted) Navigator.pop(dialogContext);
                  },
                  child: Text(record == null ? l10n.registerTransaction : l10n.saveEdit),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
