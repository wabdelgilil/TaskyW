import 'package:flutter/widgets.dart';
import 'package:tasky/l10n/app_localizations.dart';
import 'package:tasky/l10n/app_localizations_ar.dart';

/// امتداد مساعد لاستدعاء الترجمة الرسمية بسهولة داخل الواجهات:
///
/// ```
/// Text(context.l10n.commonSave)
/// ```
///
/// يعيد تلقائياً النسخة العربية كـ fallback آمن في حال لم يتم تسجيل الـ delegates
/// في اختبارات الـ Widget أو بيئات الاختبار المنعزلة.
extension LocalizationX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsAr();
}