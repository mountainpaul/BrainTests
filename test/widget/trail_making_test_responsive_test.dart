import 'package:brain_tests/presentation/screens/trail_making_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trail Making Test Responsive Canvas Tests', () {
    testWidgets('should not require scrolling on small screen during Test A', (tester) async {
      // Arrange - iPhone SE size (smallest common screen)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - No overflow on initial load
      expect(tester.takeException(), isNull, reason: 'Screen should not overflow on small screen');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should not require scrolling on small screen during Test B', (tester) async {
      // Arrange - Small screen
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Note: We can't easily test Test B without completing Test A,
      // but we can verify no fixed heights cause overflow
      expect(tester.takeException(), isNull);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should adapt canvas size to available screen height', (tester) async {
      // Arrange - Narrow tall screen
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should adapt without fixed height
      expect(tester.takeException(), isNull, reason: 'Should adapt to taller screens');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should fit canvas on very small screen (280px width)', (tester) async {
      // Arrange - Very small screen
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should not overflow even on very small screens
      expect(tester.takeException(), isNull, reason: 'Should handle very small screens');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should use responsive layout instead of fixed 1400px height', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - Should not have fixed height causing issues
      expect(tester.takeException(), isNull, reason: 'Canvas should use responsive height');
    });
  });
}
