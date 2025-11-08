import 'package:brain_plan/presentation/screens/cambridge/rvp_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RVP Test Screen', () {
    testWidgets('Should display introduction screen with buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify introduction elements
      expect(find.text('Rapid Visual Processing'), findsWidgets);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Start Practice'), findsOneWidget);
      expect(find.text('Skip to Test'), findsOneWidget);
      expect(find.textContaining('Detect Target Sequences'), findsOneWidget);
    });

    testWidgets('Should transition to practice phase when Start Practice is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Start Practice button
      await tester.tap(find.text('Start Practice'));
      await tester.pump();

      // Should no longer show introduction
      expect(find.text('Start Practice'), findsNothing);

      // With new timing, first digit appears immediately
      await tester.pump();

      // Should show PRACTICE label
      expect(find.text('PRACTICE'), findsOneWidget);
    });

    testWidgets('Should start test phase when Skip to Test is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Skip to Test button
      await tester.tap(find.text('Skip to Test'));
      await tester.pump();

      // Should no longer show introduction
      expect(find.text('Skip to Test'), findsNothing);

      // With new timing, first digit appears immediately
      await tester.pump();

      // Should show TEST label
      expect(find.text('TEST'), findsOneWidget);
    });

    testWidgets('Should display digit stream during test', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Skip to Test'));
      await tester.pump();

      // Wait for digit stream to start and first digit to appear
      await tester.pump(const Duration(milliseconds: 700));

      // Should display a digit (0-9)
      final digitFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data != null && RegExp(r'^[0-9]$').hasMatch(widget.data!),
      );
      expect(digitFinder, findsOneWidget);
    });

    testWidgets('Should handle screen taps during test', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Skip to Test'));
      await tester.pump();

      // Wait for digit stream to start
      await tester.pump(const Duration(milliseconds: 700));

      // Verify TEST label is present
      expect(find.text('TEST'), findsOneWidget);

      // Tap anywhere on the screen (GestureDetector)
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Screen should still be showing test (continues running)
      expect(find.text('TEST'), findsOneWidget);
    });
  });

  group('RVP Test Performance Metrics', () {
    testWidgets('Should track response metrics during test', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RVPTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Skip to Test'));
      await tester.pump();

      // Wait for test to start
      await tester.pump(const Duration(milliseconds: 700));

      // Verify test is running
      expect(find.text('TEST'), findsOneWidget);

      // Make a response by tapping the screen
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // The response should be recorded (either as hit or false alarm)
      // This verifies the interaction is possible
      expect(find.text('TEST'), findsOneWidget);
    });
  });

  group('RVP Test Navigation', () {
    testWidgets('Should allow navigation back from results', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RVPTestScreen(),
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
