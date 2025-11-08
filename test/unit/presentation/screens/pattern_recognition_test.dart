import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/screens/exercise_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatternRecognitionWidget', () {
    testWidgets('should have SingleChildScrollView to prevent overflow', (WidgetTester tester) async {
      // Build the widget with normal screen size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternRecognitionWidget(
              difficulty: ExerciseDifficulty.expert, // Expert has more items that will wrap
              onCompleted: (score, timeSpent) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget is scrollable (SingleChildScrollView should be present)
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify no overflow errors occurred during build
      expect(tester.takeException(), isNull);
    });

    testWidgets('should build without overflow on small screen', (WidgetTester tester) async {
      // Set a very small screen size that would cause overflow without scroll
      await tester.binding.setSurfaceSize(const Size(300, 400));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternRecognitionWidget(
              difficulty: ExerciseDifficulty.expert,
              onCompleted: (score, timeSpent) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the SingleChildScrollView
      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      // No overflow should occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display pattern items and question mark', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternRecognitionWidget(
              difficulty: ExerciseDifficulty.easy,
              onCompleted: (score, timeSpent) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify question mark is displayed
      expect(find.text('?'), findsOneWidget);

      // Verify the prompt text
      expect(find.text('What comes next in this pattern?'), findsOneWidget);
    });
  });
}
