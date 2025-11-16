import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/presentation/providers/cognitive_exercise_provider.dart';
import 'package:brain_tests/presentation/screens/cognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([])
void main() {
  group('CognitionOverviewTab - Start Your First Test Button', () {
    testWidgets('should show "Start Your First Test" button when no exercises completed',
        (WidgetTester tester) async {
      // Arrange - Mock empty exercise list
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentExercisesProvider.overrideWith((ref) async => []),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: CognitionOverviewTab(
                  onStartTest: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Assert - Button should be visible
      expect(find.text('Start Your First Test'), findsOneWidget);
      expect(find.text('No recent cognitive tests completed.'), findsOneWidget);
    });

    testWidgets('should call onStartTest callback when "Start Your First Test" is pressed',
        (WidgetTester tester) async {
      // Arrange - Track if callback was called
      bool callbackCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentExercisesProvider.overrideWith((ref) async => []),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CognitionOverviewTab(
                onStartTest: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Verify we can see the button
      expect(find.text('Start Your First Test'), findsOneWidget);
      expect(callbackCalled, false);

      // Act - Tap the "Start Your First Test" button
      await tester.tap(find.text('Start Your First Test'));
      await tester.pumpAndSettle();

      // Assert - Callback should have been called
      expect(callbackCalled, true);
    });

    testWidgets('should NOT show "Start Your First Test" button when exercises exist',
        (WidgetTester tester) async {
      // Arrange - Mock exercise list with data
      final mockExercises = [
        CognitiveExercise(
          name: 'Word Puzzle',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 120,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentExercisesProvider.overrideWith((ref) async => mockExercises),
            completedExercisesProvider.overrideWith((ref) async => mockExercises),
          ],
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: CognitionOverviewTab(
                  onStartTest: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Assert - Button should NOT be visible
      expect(find.text('Start Your First Test'), findsNothing);
      expect(find.text('No recent cognitive tests completed.'), findsNothing);

      // Should show recent exercises instead
      expect(find.text('Word Puzzle - 85%'), findsOneWidget);
    });
  });
}
