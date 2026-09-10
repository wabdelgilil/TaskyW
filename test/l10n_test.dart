import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations - ARB الرسمي للترجمة', () {
    test('تحميل القاموس العربي والإنجليزي بلا أخطاء', () async {
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(ar, isNotNull);
      expect(en, isNotNull);
    });

    test('اللغتان المدعومتان بالترتيب الرسمي', () {
      expect(AppLocalizations.supportedLocales, [
        const Locale('ar'),
        const Locale('en'),
      ]);
    });

    test('دعم المتغيرات (Placeholders) في النصوص المترجمة', () async {
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(ar.taskCountRemaining(5), 'متبقي 5 مهام');
      expect(en.taskCountRemaining(5), '5 tasks remaining');

      expect(ar.welcomeUser('أحمد'), 'مرحباً أحمد');
      expect(en.welcomeUser('Ahmed'), 'Welcome, Ahmed');
    });

    test('الدلالة: نموذج الإعدادات يقرأ من القاموس الصحيح', () async {
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(ar.commonSettings, 'الإعدادات');
      expect(en.commonSettings, 'Settings');
      expect(ar.settingsCurrencyDesc('SAR'), 'العملة المستخدمة في السجلات المالية الجديدة: SAR');
      expect(ar.versionLabel('3.0.0'), 'الإصدار 3.0.0');
    });
  });
}