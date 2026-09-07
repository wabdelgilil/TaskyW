import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/utils/validators.dart';

void main() {
  group('Validators.isNotEmpty', () {
    test('يعيد false للنصوص الفارغة أو المكونة من مسافات', () {
      expect(Validators.isNotEmpty(null), isFalse);
      expect(Validators.isNotEmpty(''), isFalse);
      expect(Validators.isNotEmpty('   '), isFalse);
    });

    test('يعيد true للنصوص غير الفارغة', () {
      expect(Validators.isNotEmpty('مهمة'), isTrue);
      expect(Validators.isNotEmpty('  نص  '), isTrue);
    });
  });

  group('Validators.isValidHexColor', () {
    test('يقبل صيغة #RRGGBB', () {
      expect(Validators.isValidHexColor('#3B82F6'), isTrue);
      expect(Validators.isValidHexColor('#ff0000'), isTrue);
    });

    test('يقبل صيغة #RGB', () {
      expect(Validators.isValidHexColor('#3B8'), isTrue);
    });

    test('يقبل بدون علامة #', () {
      expect(Validators.isValidHexColor('3B82F6'), isTrue);
    });

    test('يرفض القيم غير الصالحة', () {
      expect(Validators.isValidHexColor(null), isFalse);
      expect(Validators.isValidHexColor(''), isFalse);
      expect(Validators.isValidHexColor('#GGGGGG'), isFalse);
      expect(Validators.isValidHexColor('#12345'), isFalse);
    });
  });

  group('Validators.isValidUrl', () {
    test('يقبل روابط http و https', () {
      expect(Validators.isValidUrl('https://example.com'), isTrue);
      expect(Validators.isValidUrl('http://sub.example.com/path'), isTrue);
    });

    test('يرفض المدخلات غير الصالحة', () {
      expect(Validators.isValidUrl(null), isFalse);
      expect(Validators.isValidUrl(''), isFalse);
      expect(Validators.isValidUrl('not a url'), isFalse);
      expect(Validators.isValidUrl('http://'), isFalse);
      expect(Validators.isValidUrl('example.com'), isFalse);
    });
  });

  group('Validators.isValidEmail', () {
    test('يقبل البريد الإلكتروني الصحيح', () {
      expect(Validators.isValidEmail('user@example.com'), isTrue);
    });

    test('يرفض البريد غير الصحيح', () {
      expect(Validators.isValidEmail(null), isFalse);
      expect(Validators.isValidEmail('user@'), isFalse);
      expect(Validators.isValidEmail('@example.com'), isFalse);
      expect(Validators.isValidEmail('user example.com'), isFalse);
    });
  });
}