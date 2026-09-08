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

    test('يترجم خطأ عدم تأكيد البريد إلى رسالة واضحة وتوجيهية', () {
      final msg = AuthController.translateAuthError('Email not confirmed');
      expect(msg, contains('تأكيد بريدك الإلكتروني'));
      expect(msg, contains('رابط التفعيل'));
    });

    test('يترجم أخطاء تسجيل الدخول الأخرى بدقة', () {
      expect(
        AuthController.translateAuthError('Invalid login credentials'),
        equals('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
      );
      expect(
        AuthController.translateAuthError('User already registered'),
        equals('هذا البريد الإلكتروني مسجل بالفعل'),
      );
      expect(
        AuthController.translateAuthError('Password should be at least 6 characters'),
        equals('كلمة المرور يجب ألا تقل عن 6 أحرف'),
      );
    });
  });
}
