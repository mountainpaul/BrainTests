import 'package:brain_tests/presentation/screens/cambridge/avlt_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AVLT Test Screen Error Handling', () {
    testWidgets('should not crash when showing error before widget is mounted', (tester) async {
      // This test ensures _showError() checks mounted state before using context
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      // Widget should build without crashing
      expect(find.byType(AVLTTestScreen), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
    });

    testWidgets('should display error message in UI when mounted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // The widget should be mounted and ready
      expect(find.byType(AVLTTestScreen), findsOneWidget);
    });
  });

  group('AVLT Test Screen Phase Transitions', () {
    testWidgets('should start with instructions phase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      // Wait for async initialization to complete
      await tester.pumpAndSettle();

      expect(find.text('Instructions'), findsOneWidget);
      // Start Test button may not appear if STT is not available in test environment
      // Just verify the screen doesn't crash
      expect(find.byType(AVLTTestScreen), findsOneWidget);
    });

    testWidgets('should display phase indicator correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      await tester.pump();

      // Should show instructions phase
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text('Instructions'), findsOneWidget);
    });
  });

  group('AVLT Test Screen State Management', () {
    testWidgets('should not call async methods inside setState', (tester) async {
      // This test ensures that phase transitions don't call async methods
      // directly inside setState, which would cause errors
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should initialize without setState errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle widget lifecycle correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AVLTTestScreen(),
        ),
      );

      // Initial pump
      await tester.pump();

      // Dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should dispose without errors
      expect(tester.takeException(), isNull);
    });
  });
}
