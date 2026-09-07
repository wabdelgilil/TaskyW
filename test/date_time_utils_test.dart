import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils.isToday', () {
    test('يعيد true لتاريخ اليوم الحالي', () {
      expect(DateTimeUtils.isToday(DateTime.now()), isTrue);
    });

    test('يعيد false للتاريخ null', () {
      expect(DateTimeUtils.isToday(null), isFalse);
    });

    test('يعيد false لتاريخ أمس', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeUtils.isToday(yesterday), isFalse);
    });

    test('يعيد false لتاريخ غداً', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateTimeUtils.isToday(tomorrow), isFalse);
    });
  });

  group('DateTimeUtils.isUpcoming', () {
    test('يعيد true لتاريخ بعد اليوم', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateTimeUtils.isUpcoming(tomorrow), isTrue);
    });

    test('يعيد false لتاريخ اليوم أو الماضي', () {
      expect(DateTimeUtils.isUpcoming(DateTime.now()), isFalse);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeUtils.isUpcoming(yesterday), isFalse);
    });

    test('يعيد false للتاريخ null', () {
      expect(DateTimeUtils.isUpcoming(null), isFalse);
    });
  });

  group('DateTimeUtils.isOverdue', () {
    test('يعيد true لتاريخ قبل اليوم', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeUtils.isOverdue(yesterday), isTrue);
    });

    test('يعيد false لتاريخ اليوم أو المستقبل', () {
      expect(DateTimeUtils.isOverdue(DateTime.now()), isFalse);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateTimeUtils.isOverdue(tomorrow), isFalse);
    });

    test('يعيد false للتاريخ null', () {
      expect(DateTimeUtils.isOverdue(null), isFalse);
    });
  });

  group('DateTimeUtils.formatFriendlyDate', () {
    test('يعيد "بدون تاريخ" عند مرور null', () {
      expect(DateTimeUtils.formatFriendlyDate(null), 'بدون تاريخ');
    });

    test('يعبر عن اليوم بصيغة "اليوم"', () {
      expect(DateTimeUtils.formatFriendlyDate(DateTime.now()), startsWith('اليوم'));
    });

    test('يعبر عن غداً بصيغة "غداً"', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateTimeUtils.formatFriendlyDate(tomorrow), isNot(contains('اليوم')));
    });

    test('يستخدم اسم الشهر العربي الصحيح لتاريخ ثابت', () {
      final date = DateTime(2026, 10, 5);
      final formatted = DateTimeUtils.formatFriendlyDate(date);
      expect(formatted, contains('أكتوبر'));
    });
  });
}