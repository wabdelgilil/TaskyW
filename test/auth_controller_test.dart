import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthController Translation and Detection', () {
    test('يكتشف خطأ عدم تأكيد البريد من الرسالة أو الكود', () {
      expect(
        AuthController.isUnconfirmedError('Email not confirmed'),
        isTrue,
      );
      expect(
        AuthController.isUnconfirmedError('Some other error', 'email_not_confirmed'),
        isTrue,
      );
      expect(
        AuthController.isUnconfirmedError('Invalid login credentials'),
        isFalse,
      );
    });

    test('يترجم خطأ عدم تأكيد البريد إلى رسالة واضحة (بدون l10n → إنجليزي)', () {
      final msg = AuthController.translateAuthError('Email not confirmed');
      expect(msg, contains('email'));
      expect(msg, contains('activation link'));
    });

    test('يترجم أخطاء تسجيل الدخول الأخرى بدقة (بدون l10n → إنجليزي)', () {
      expect(
        AuthController.translateAuthError('Invalid login credentials'),
        equals('Invalid email or password'),
      );
      expect(
        AuthController.translateAuthError('User already registered'),
        equals('This email is already registered'),
      );
      expect(
        AuthController.translateAuthError('Password should be at least 6 characters'),
        equals('Password must be at least 6 characters'),
      );
    });

    test('يترجم الأخطاء بـ l10n عربي إذا وُجد', () {
      // Note: This test verifies the fallback path works correctly.
      // Full l10n integration is tested via widget tests.
      final msg = AuthController.translateAuthError('Invalid login credentials', null, null);
      expect(msg, equals('Invalid email or password'));
    });
  });
}
