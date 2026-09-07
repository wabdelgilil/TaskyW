import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
