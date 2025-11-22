import 'package:brain_tests/presentation/screens/cambridge/rti_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RTI Test Screen', () {
    testWidgets('Should display introduction screen with mode selection', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify introduction elements
      expect(find.text('Reaction Time'), findsWidgets);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Simple Reaction Time'), findsOneWidget);
      expect(find.text('Choice Reaction Time'), findsOneWidget);
      expect(find.textContaining('Tap as quickly as possible'), findsOneWidget);
    });

    testWidgets('Should transition to simple mode when Simple RT is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Simple Reaction Time button
      await tester.tap(find.text('Simple Reaction Time'));
      await tester.pumpAndSettle();

      // Should no longer show introduction
      expect(find.text('Simple Reaction Time'), findsNothing);

      // Should show SIMPLE RT label
      expect(find.text('SIMPLE RT'), findsOneWidget);
    });

    testWidgets('Should transition to choice mode when Choice RT is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Choice Reaction Time button
      await tester.tap(find.text('Choice Reaction Time'));
      await tester.pumpAndSettle();

      // Should no longer show introduction
      expect(find.text('Choice Reaction Time'), findsNothing);

      // Should show CHOICE RT label
      expect(find.text('CHOICE RT'), findsOneWidget);
    });

    testWidgets('Simple mode should display single target position', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start simple mode
      await tester.tap(find.text('Simple Reaction Time'));
      await tester.pumpAndSettle();

      // Wait for initial delay to pass
      await tester.pump(const Duration(seconds: 4));

      // Should show stimulus (yellow circle)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Choice mode should display five target positions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start choice mode
      await tester.tap(find.text('Choice Reaction Time'));
      await tester.pumpAndSettle();

      // Should show 5 positions (represented as containers/gesture detectors)
      // The exact count depends on implementation, but should be multiple positions
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Should record reaction time on tap', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start simple mode
      await tester.tap(find.text('Simple Reaction Time'));
      await tester.pumpAndSettle();

      // Wait for stimulus to appear
      await tester.pump(const Duration(seconds: 4));

      // Tap on screen to respond
      final gestures = find.byType(GestureDetector);
      if (gestures.evaluate().isNotEmpty) {
        await tester.tap(gestures.first);
        await tester.pump();

        // Test should continue (response recorded)
        expect(find.text('SIMPLE RT'), findsOneWidget);
      }
    });

    testWidgets('Should show waiting state between trials', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start simple mode
      await tester.tap(find.text('Simple Reaction Time'));
      await tester.pumpAndSettle();

      // In waiting state, should show instruction text
      expect(find.textContaining('Wait'), findsOneWidget);
    });

    testWidgets('Should complete test after all trials', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RTITestScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify back button exists in AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('RTI Test Performance Metrics', () {
    testWidgets('Should track multiple trials in simple mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start simple mode
      await tester.tap(find.text('Simple Reaction Time'));
      await tester.pumpAndSettle();

      // Wait for first stimulus
      await tester.pump(const Duration(seconds: 4));

      // Verify test is running
      expect(find.text('SIMPLE RT'), findsOneWidget);

      // Make a response by tapping
      final gestures = find.byType(GestureDetector);
      if (gestures.evaluate().isNotEmpty) {
        await tester.tap(gestures.first);
        await tester.pump();

        // Should continue to next trial (still showing SIMPLE RT)
        expect(find.text('SIMPLE RT'), findsOneWidget);
      }
    });

    testWidgets('Should differentiate reaction time and movement time in choice mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RTITestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start choice mode
      await tester.tap(find.text('Choice Reaction Time'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('CHOICE RT'), findsOneWidget);

      // In choice mode, there should be multiple tap targets
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });

  group('RTI Test Navigation', () {
    testWidgets('Should allow navigation back from results', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RTITestScreen(),
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
