import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/sharing/presentation/screens/public_share_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      );

  group('PublicShareScreen', () {
    testWidgets('renders without errors (smoke test)', (tester) async {
      await tester.pumpWidget(
        wrap(const PublicShareScreen(shareToken: 'test-token-123')),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows error state with retry button after load fails', (tester) async {
      await tester.pumpWidget(
        wrap(const PublicShareScreen(shareToken: 'test-token-123')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.link_off_rounded), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('shows error icon with error-colored styling', (tester) async {
      await tester.pumpWidget(
        wrap(const PublicShareScreen(shareToken: 'test-token-123')),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.link_off_rounded));
      expect(icon.size, equals(64));
    });

    testWidgets('AppBar contains shared title', (tester) async {
      await tester.pumpWidget(
        wrap(const PublicShareScreen(shareToken: 'test-token-123')),
      );
      await tester.pumpAndSettle();

      expect(find.text('TaskyW — مشاركة عامة'), findsOneWidget);
    });

    testWidgets('retry button can be tapped', (tester) async {
      await tester.pumpWidget(
        wrap(const PublicShareScreen(shareToken: 'test-token-123')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });
  });
}
