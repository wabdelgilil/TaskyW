import 'package:flutter/widgets.dart';
import 'package:tasky/l10n/app_localizations.dart';

/// امتداد مساعد لاستدعاء الترجمة الرسمية بسهولة داخل الواجهات:
///
/// ```
/// Text(context.l10n.commonSave)
/// ```
///
/// يتطلب أن يكون `AppLocalizations` محمّلاً عبر `MaterialApp.localizationsDelegates`.
extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}