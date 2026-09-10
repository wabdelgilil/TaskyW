import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/settings/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    SharedPreferences.setMockInitialValues({});
    await SettingsController.instance.load();
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      );

  // ارتفاع كبير كافٍ لعرض كل أقسام الـ ListView دفعة واحدة (بدون لفّ).
  Future<void> pumpFullScreen(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(wrap(child));
    await tester.pump();
  }

  group('SettingsScreen', () {
    testWidgets('renders with AppBar title', (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen()));
      await tester.pump();

      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('shows language section header and picker cards', (tester) async {
      await pumpFullScreen(tester, const SettingsScreen());

      expect(find.text('اللغة والمنطقة'), findsOneWidget);
      expect(find.text('تلقائي'), findsOneWidget);
      expect(find.text('العربية (RTL)'), findsOneWidget);
      expect(find.text('English (LTR)'), findsOneWidget);
      expect(find.text('اتجاه الواجهة والسايد بار'), findsOneWidget);
    });

    testWidgets('shows notification section with switch and permission button', (tester) async {
      await pumpFullScreen(tester, const SettingsScreen());

      expect(find.text('الإشعارات والتنبيهات'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('إشعارات التطبيق'), findsOneWidget);
      expect(find.text('تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)'), findsOneWidget);
      expect(find.text('طلب صلاحية التنبيهات'), findsOneWidget);
    });

    testWidgets('shows theme mode section header and cards', (tester) async {
      await pumpFullScreen(tester, const SettingsScreen());

      expect(find.text('المظهر والثيم'), findsOneWidget);
      expect(find.text('وضع المظهر'), findsOneWidget);
      expect(find.text('نهاري'), findsOneWidget);
      expect(find.text('ليلي'), findsOneWidget);
      expect(find.text('OLED'), findsOneWidget);
    });

    testWidgets('shows currency section', (tester) async {
      await pumpFullScreen(tester, const SettingsScreen());

      expect(find.text('المالية والعملات'), findsOneWidget);
      expect(find.text('العملة الافتراضية'), findsOneWidget);
    });

    testWidgets('version label is shown in data section', (tester) async {
      await pumpFullScreen(tester, const SettingsScreen());

      expect(find.text('بيانات التطبيق'), findsOneWidget);
      expect(find.text('إصدار التطبيق'), findsOneWidget);
      expect(find.text('حالة الحساب'), findsOneWidget);
    });

    testWidgets('no overflow errors on narrow mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrap(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('الإعدادات'), findsOneWidget);
    });
  });
}