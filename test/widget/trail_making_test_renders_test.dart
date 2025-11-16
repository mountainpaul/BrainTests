import 'package:brain_tests/presentation/screens/trail_making_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trail Making Test Screen Render Tests', () {
    testWidgets('should render instructions screen without blank screen', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Screen should not be blank
      expect(find.text('Trail Making Test'), findsOneWidget);
      expect(find.text('Trail Making Test A & B'), findsOneWidget);
      expect(find.text('Test Instructions'), findsOneWidget);
      expect(find.text('Start Test A'), findsOneWidget);

      // Should not have any exceptions causing blank screen
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render Test A screen after starting', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Scroll to button and start Test A
      await tester.ensureVisible(find.text('Start Test A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Assert - Test A should be visible, not blank
      expect(find.text('Test A: Connect Numbers in Order'), findsOneWidget);
      expect(find.text('Next: 1 | Errors: 0'), findsOneWidget);

      // Should render circles (at least some numbers visible)
      expect(find.text('1'), findsWidgets);

      // Should not have exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render Test B intro after completing Test A', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Scroll to button and start Test A
      await tester.ensureVisible(find.text('Start Test A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Tap circles 1 through 25
      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Assert - Test B intro should be visible
      expect(find.text('Test A Complete!'), findsOneWidget);
      expect(find.text('Now for Test B'), findsOneWidget);
      expect(find.text('Start Test B'), findsOneWidget);

      // Should not have exceptions
      expect(tester.takeException(), isNull);
    });
  });
}
