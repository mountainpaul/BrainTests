import 'package:brain_tests/presentation/screens/sdmt_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SDMT Screen Overflow Tests', () {
    testWidgets('should not overflow when displaying key symbols on small screen', (tester) async {
      // Arrange - Set a narrow screen size to test overflow
      tester.view.physicalSize = const Size(320, 568); // iPhone SE size
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SDMTTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Act - Find the key display
      final keyFinder = find.text('Key (Memorize This)');
      expect(keyFinder, findsOneWidget);

      // Assert - No overflow errors should be present
      // Flutter test framework will fail if there are overflow errors by default
      expect(tester.takeException(), isNull, reason: 'Should not have overflow errors in key display');

      // Reset screen size
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display all 9 symbols in the key without overflow', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SDMTTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Act - Find the key section
      final keySection = find.text('Key (Memorize This)');
      expect(keySection, findsOneWidget);

      // Assert - Should be able to scroll if needed (SingleChildScrollView)
      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsWidgets, reason: 'Key display should use SingleChildScrollView');

      expect(tester.takeException(), isNull);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should not overflow reference key during active test on small screen', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SDMTTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Act - Scroll to and tap Start Test button
      final startButton = find.text('Start Test');
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();
      await tester.tap(startButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Reference key should be visible without overflow
      final referenceKeyFinder = find.text('Reference Key');
      expect(referenceKeyFinder, findsOneWidget);

      // No overflow errors during test
      expect(tester.takeException(), isNull, reason: 'Reference key should not overflow during test');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should handle very narrow screen (280px) without overflow', (tester) async {
      // Arrange - Very narrow screen
      tester.view.physicalSize = const Size(280, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SDMTTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - Even on very narrow screens, SingleChildScrollView should prevent overflow
      expect(tester.takeException(), isNull, reason: 'Should handle narrow screens without overflow');

      // Should be able to find scrollable widgets
      expect(find.byType(SingleChildScrollView), findsWidgets);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display key section without errors', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SDMTTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Act - Find the key title
      final keyTitle = find.text('Key (Memorize This)');

      // Assert - Key section should be present
      expect(keyTitle, findsOneWidget);

      // No overflow or other errors
      expect(tester.takeException(), isNull, reason: 'Key section should display without errors');
    });
  });
}
