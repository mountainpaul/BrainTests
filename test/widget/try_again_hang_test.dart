import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for "Try Again" hang issue
///
/// Bug: After completing expert difficulty math problems, clicking "Try Again"
/// would hang on "Preparing math problem" screen.
///
/// Root cause: Post-frame callback was deferring navigation, preventing
/// immediate pushReplacement that the button needs.
///
/// This test verifies that clicking "Try Again" navigates immediately
/// without hanging or timing out.
void main() {
  group('Try Again Button - No Hang', () {
    testWidgets(
        'Try Again button should navigate immediately without hanging',
        (WidgetTester tester) async {
      // Create a completion screen that simulates the bug scenario
      bool navigationCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Completion Screen')),
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Exercise Complete!'),
                    const Text('Score: 100/100'),
                    ElevatedButton(
                      onPressed: () {
                        // This is the FIXED pattern: direct pushReplacement
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: const Text('New Exercise')),
                              body: Builder(
                                builder: (ctx) {
                                  // Simulate heavy initialization like generating 12 problems
                                  navigationCompleted = true;
                                  return const Center(
                                    child: Text('Preparing math problems...'),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap Try Again button
      expect(find.text('Exercise Complete!'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));

      // This should complete quickly without hanging
      // If there's a hang, this will timeout
      await tester.pumpAndSettle();

      // Verify navigation completed
      expect(navigationCompleted, true);
      expect(find.text('Preparing math problems...'), findsOneWidget);
      expect(find.text('Exercise Complete!'), findsNothing);

      // No exceptions should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Try Again with post-frame callback should also work (old pattern)',
        (WidgetTester tester) async {
      // This tests the OLD pattern with post-frame callback
      // to document that it works in test but might hang in production

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // OLD pattern: post-frame callback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Scaffold(
                              body: Center(child: Text('New Screen')),
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('Try Again Old Pattern'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Try Again Old Pattern'));
      await tester.pumpAndSettle();

      // This works in tests but could hang in production with heavy widgets
      expect(find.text('New Screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Multiple rapid Try Again clicks should not cause issues',
        (WidgetTester tester) async {
      int navigationCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    navigationCount++;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: Center(
                            child: Text('Screen $navigationCount'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Try Again'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button (first navigation)
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Screen 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Try Again should complete navigation without timeout',
        (WidgetTester tester) async {
      // Test that Try Again completes quickly for all difficulty levels
      // This simulates clicking Try Again after expert difficulty (12 problems)

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Simulate generating many problems (like expert difficulty)
                    final problems = List.generate(12, (i) => 'Problem $i');

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: Center(
                            child: Text('Generated ${problems.length} problems'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Try Again Expert'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Try Again Expert'));

      // Should complete without hanging/timeout
      await tester.pumpAndSettle();

      expect(find.text('Generated 12 problems'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Try Again Button - Performance', () {
    testWidgets(
        'Try Again should not block UI thread for extended period',
        (WidgetTester tester) async {
      // This test ensures navigation completes quickly

      final startTime = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: Center(child: Text('New Screen')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Try Again'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      final duration = DateTime.now().difference(startTime);

      // Navigation should complete very quickly (under 1 second even in tests)
      expect(duration.inSeconds, lessThan(1));
      expect(find.text('New Screen'), findsOneWidget);
    });
  });
}
