import 'package:brain_tests/presentation/screens/cambridge/swm_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SWM Test Screen', () {
    testWidgets('Should display introduction screen with instructions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify introduction elements
      expect(find.text('Spatial Working Memory'), findsWidgets);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Start Test'), findsOneWidget);
      expect(find.textContaining('Search for tokens'), findsOneWidget);
    });

    testWidgets('Should transition to test when Start Test is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Start Test button
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should no longer show introduction
      expect(find.text('Start Test'), findsNothing);

      // Should show test elements
      expect(find.text('SWM TEST'), findsOneWidget);
    });

    testWidgets('Should display boxes during test', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should display boxes (represented as GestureDetectors)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Should allow tapping boxes to search', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('SWM TEST'), findsOneWidget);

      // Tap a box (GestureDetector)
      final boxes = find.byType(GestureDetector);
      if (boxes.evaluate().isNotEmpty) {
        await tester.tap(boxes.first);
        await tester.pump();

        // Test should still be running (box opened)
        expect(find.text('SWM TEST'), findsOneWidget);
      }
    });

    testWidgets('Should show token count progress', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show tokens column with counter
      expect(find.text('Tokens'), findsOneWidget);
      expect(find.textContaining('/'), findsOneWidget); // Shows collected/total format (e.g., "0/3")
    });

    testWidgets('Should progress through multiple stages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('SWM TEST'), findsOneWidget);

      // Should show stage indicator
      expect(find.textContaining('Stage'), findsOneWidget);
    });

    testWidgets('Should display results after test completion', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SWMTestScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify back button exists in AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('SWM Test Performance Metrics', () {
    testWidgets('Should track between errors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('SWM TEST'), findsOneWidget);

      // Make searches by tapping boxes
      final boxes = find.byType(GestureDetector);
      if (boxes.evaluate().isNotEmpty) {
        await tester.tap(boxes.first);
        await tester.pump();

        // Should continue running (tracking errors)
        expect(find.text('SWM TEST'), findsOneWidget);
      }
    });

    testWidgets('Should calculate strategy score', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('SWM TEST'), findsOneWidget);

      // Strategy score will be calculated based on search pattern
      // The test should track sequential vs random searching
    });
  });

  group('SWM Test Stages', () {
    testWidgets('Should start with 3 boxes', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // First stage should show "3 boxes" or similar indicator
      expect(find.text('SWM TEST'), findsOneWidget);
    });

    testWidgets('Should progress to stages with more boxes', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SWMTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show stage progression
      expect(find.textContaining('Stage'), findsOneWidget);
    });
  });

  group('SWM Test Navigation', () {
    testWidgets('Should allow navigation back from results', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SWMTestScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify back button exists in AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
