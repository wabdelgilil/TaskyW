import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/home/presentation/screens/main_layout_screen.dart';

void main() {
  testWidgets('MainLayoutScreen UI smoke test on desktop', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now().toUtc();
    final testAreas = [
      AreaModel(
        id: 'area-1',
        name: 'العمل الأساسي',
        iconEmoji: '💼',
        colorHex: '#3B82F6',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: MainLayoutScreen(
          areas: testAreas,
          projects: const [],
          tasks: const [],
          subtasks: const [],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('TaskyW'), findsOneWidget);
    expect(find.text('العمل الأساسي'), findsOneWidget);
    expect(find.text('☀️ مهام اليوم'), findsOneWidget);
  });

  testWidgets('MainLayoutScreen UI responsive test on mobile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now().toUtc();
    final testAreas = [
      AreaModel(
        id: 'area-1',
        name: 'العمل الأساسي',
        iconEmoji: '💼',
        colorHex: '#3B82F6',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: MainLayoutScreen(
          areas: testAreas,
          projects: const [],
          tasks: const [],
          subtasks: const [],
        ),
      ),
    );
    await tester.pump();

    // التأكد من عدم وجود أي RenderFlex overflow وأن العناصر الرئيسية ظاهرة
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('☀️ مهام اليوم'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // اختبار فتح شريط البحث الموسع على الموبايل
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);

    // إغلاق البحث والعودة
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(find.text('☀️ مهام اليوم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MainLayoutScreen UI OLED theme full interface consistency test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oledTheme,
        home: Builder(
          builder: (context) {
            expect(AppColors.isOled(context), isTrue);
            expect(AppColors.surface(context), equals(AppColors.oledSurface));
            expect(AppColors.background(context), equals(AppColors.oledBackground));
            expect(AppColors.border(context), equals(AppColors.oledBorder));
            expect(AppColors.textPrimary(context), equals(AppColors.oledTextPrimary));
            expect(AppColors.textSecondary(context), equals(AppColors.oledTextSecondary));

            return const MainLayoutScreen(
              areas: [],
              projects: [],
              tasks: [],
              subtasks: [],
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // في وضع OLED يجب أن تكون الخلفية سوداء نقية بالكامل
    expect(Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor, equals(AppColors.oledBackground));
  });
}
