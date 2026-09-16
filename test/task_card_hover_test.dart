import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_card.dart';
import 'package:tasky/l10n/app_localizations.dart';

void main() {
  final sampleTask = TaskModel(
    id: 't-hover-1',
    areaId: 'area-hover-1',
    title: 'مهمة لاختبار التحويم والتباين',
    description: 'وصف المهمة للتأكد من تباين النص',
    status: 'todo',
    priority: 'high',
    createdAt: DateTime(2026, 9, 16),
    updatedAt: DateTime(2026, 9, 16),
  );

  Widget buildTestCard({
    required ThemeData theme,
    bool isCompact = false,
  }) {
    return MaterialApp(
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),
      home: Scaffold(
        body: Center(
          child: TaskCard(
            task: sampleTask,
            isCompact: isCompact,
            projectName: 'مشروع رئيسي',
          ),
        ),
      ),
    );
  }

  group('TaskCard High-Contrast Hover Tests', () {
    testWidgets('في الوضع النهاري (Light Mode): عند التحويم يتغير لون الخلفية للداكن والنص للأبيض', (tester) async {
      await tester.pumpWidget(buildTestCard(theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      // الحالة الساكنة قبل التحويم: النص داكن والخلفية بيضاء
      final titleFinder = find.text('مهمة لاختبار التحويم والتباين');
      expect(titleFinder, findsOneWidget);
      var textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(AppColors.lightTextPrimary));

      // محاكاة تحويم الفأرة فوق الكارت
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(titleFinder));
      await tester.pumpAndSettle();

      // بعد التحويم: العنوان أصبح أبيض عالي التباين
      textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(Colors.white));

      // عند خروج المؤشر يعود للحالة الطبيعية
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(AppColors.lightTextPrimary));
    });

    testWidgets('في الوضع المضغوط (Compact Mode): عند التحويم يتغير لون النص للأبيض', (tester) async {
      await tester.pumpWidget(buildTestCard(theme: AppTheme.lightTheme, isCompact: true));
      await tester.pumpAndSettle();

      final titleFinder = find.text('مهمة لاختبار التحويم والتباين');
      expect(titleFinder, findsOneWidget);

      var textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(AppColors.lightTextPrimary));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(titleFinder));
      await tester.pumpAndSettle();

      textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('في الوضع الليلي (Dark Slate): عند التحويم يظل النص ناصع البياض', (tester) async {
      await tester.pumpWidget(buildTestCard(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      final titleFinder = find.text('مهمة لاختبار التحويم والتباين');
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(titleFinder));
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.color, equals(Colors.white));
    });
  });
}
