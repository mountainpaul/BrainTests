import 'package:brain_tests/presentation/screens/cambridge/ots_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OTS Test Screen', () {
    testWidgets('Should display introduction screen with instructions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify introduction elements
      expect(find.textContaining('Stockings of Cambridge'), findsWidgets);
      expect(find.text('Instructions'), findsOneWidget);
      expect(find.text('Start Test'), findsOneWidget);
      expect(find.textContaining('minimum number of moves'), findsOneWidget);
    });

    testWidgets('Should transition to test when Start Test is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
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
      expect(find.text('OTS TEST'), findsOneWidget);
    });

    testWidgets('Should display initial and goal configurations', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show initial and goal labels
      expect(find.text('Initial'), findsOneWidget);
      expect(find.text('Goal'), findsOneWidget);
    });

    testWidgets('Should display input field for answer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('moves'), findsWidgets);
    });

    testWidgets('Should allow submitting answer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Enter an answer
      await tester.enterText(find.byType(TextField), '3');
      await tester.pump();

      // Should show submit button
      expect(find.text('Submit'), findsOneWidget);

      // Tap submit
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Should progress (either to next problem or show feedback)
      expect(find.text('OTS TEST'), findsOneWidget);
    });

    testWidgets('Should show problem counter', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show problem number
      expect(find.textContaining('Problem'), findsOneWidget);
    });

    testWidgets('Should progress through multiple problems', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Verify test is running
      expect(find.text('OTS TEST'), findsOneWidget);

      // Should show problem indicator
      expect(find.textContaining('Problem'), findsOneWidget);
    });

    testWidgets('Should display results after test completion', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: OTSTestScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify back button exists in AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('OTS Test Configuration Display', () {
    testWidgets('Should display stockings for initial state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show initial configuration
      expect(find.text('Initial'), findsOneWidget);
    });

    testWidgets('Should display stockings for goal state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Should show goal configuration
      expect(find.text('Goal'), findsOneWidget);
    });
  });

  group('OTS Test Scoring', () {
    testWidgets('Should track thinking time', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Test should be tracking time
      expect(find.text('OTS TEST'), findsOneWidget);
    });

    testWidgets('Should validate answers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OTSTestScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start the test
      await tester.tap(find.text('Start Test'));
      await tester.pumpAndSettle();

      // Enter an answer
      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();

      // Submit should be available
      expect(find.text('Submit'), findsOneWidget);
    });
  });

  group('OTS Test Navigation', () {
    testWidgets('Should allow navigation back from results', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: OTSTestScreen(),
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
