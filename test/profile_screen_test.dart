import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/settings/presentation/screens/profile_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      );

  group('ProfileScreen', () {
    testWidgets('renders with AppBar title', (tester) async {
      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الملف الشخصي'), findsOneWidget);
    });

    testWidgets('shows unauthenticated state with cloud_off icon', (tester) async {
      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows not signed in message', (tester) async {
      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('غير مسجل الدخول'), findsOneWidget);
    });

    testWidgets('sign in button exists with login icon', (tester) async {
      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('no overflow errors on narrow mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('الملف الشخصي'), findsOneWidget);
    });

    testWidgets('does not show authenticated-only elements when signed out', (tester) async {
      await tester.pumpWidget(wrap(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الاسم المعروض'), findsNothing);
      expect(find.text('البريد الإلكتروني'), findsNothing);
      expect(find.text('حالة السحابة'), findsNothing);
      expect(find.byIcon(Icons.logout), findsNothing);
    });
  });
}
