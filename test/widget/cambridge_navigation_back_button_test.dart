import 'package:brain_plan/presentation/screens/cambridge_assessments_screen.dart';
import 'package:brain_plan/presentation/screens/cognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Cambridge Assessments Navigation Tests', () {
    testWidgets('should show back button when navigating from Cognition screen', (tester) async {
      // Arrange - Create a router with both screens
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const CognitionScreen(),
          ),
          GoRoute(
            path: '/cambridge',
            builder: (context, state) => const CambridgeAssessmentsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Navigate to Cambridge Assessments
      await tester.ensureVisible(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();

      // Assert - Should be on Cambridge screen with back button
      expect(find.text('Cambridge Cognitive Tests'), findsOneWidget);
      expect(find.text('CANTAB-Style Tests'), findsOneWidget);

      // Back button should be present in AppBar
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('should navigate back to Cognition screen when back button is pressed', (tester) async {
      // Arrange
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const CognitionScreen(),
          ),
          GoRoute(
            path: '/cambridge',
            builder: (context, state) => const CambridgeAssessmentsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Cambridge screen
      await tester.ensureVisible(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();

      // Verify we're on Cambridge screen
      expect(find.text('CANTAB-Style Tests'), findsOneWidget);

      // Act - Press back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Assert - Should be back on Cognition screen
      // The Cambridge Assessments card should be visible again
      expect(find.text('Cambridge Assessments'), findsOneWidget);
      expect(find.text('PAL, RVP, RTI, SWM, PRM - Clinically validated tests'), findsOneWidget);
    });

    testWidgets('should use context.push instead of context.go for navigation', (tester) async {
      // Arrange
      bool usedPush = false;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const CognitionScreen(),
          ),
          GoRoute(
            path: '/cambridge',
            builder: (context, state) {
              // If we got here via push, there should be a previous route
              usedPush = Navigator.of(context).canPop();
              return const CambridgeAssessmentsScreen();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Navigate to Cambridge
      await tester.ensureVisible(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cambridge Assessments'));
      await tester.pumpAndSettle();

      // Assert - Should have used push (navigation stack should exist)
      expect(usedPush, isTrue, reason: 'Navigation should use context.push() to maintain navigation stack');
    });
  });
}
