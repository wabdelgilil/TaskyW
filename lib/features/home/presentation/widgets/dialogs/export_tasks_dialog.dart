import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';

/// نافذة معاينة بيانات المهام المُصدّرة بصيغة CSV
class ExportTasksDialog extends StatelessWidget {
  final String csvContent;

  const ExportTasksDialog({super.key, required this.csvContent});

  static Future<void> show(BuildContext context, {required String csvContent}) {
    return showDialog(
      context: context,
      builder: (ctx) => ExportTasksDialog(csvContent: csvContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.exportedCsvData),
      content: SizedBox(
        width: 500,
        height: 300,
        child: SingleChildScrollView(
          child: SelectableText(
            csvContent,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
