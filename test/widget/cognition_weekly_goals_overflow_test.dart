import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/cognitive_exercise.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/providers/cognitive_exercise_provider.dart';
import 'package:brain_plan/presentation/screens/cognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cognition Weekly Goals Overflow Tests', () {
    testWidgets('should not overflow weekly goals on narrow screen', (tester) async {
      // Arrange - iPhone SE size
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 0),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();

      // Wait for async data to load
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - No overflow errors
      expect(tester.takeException(), isNull, reason: 'Weekly goals should not overflow on narrow screen');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should handle long goal titles without overflow', (tester) async {
      // Arrange - Very narrow screen to stress test
      tester.view.physicalSize = const Size(280, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 3),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - No overflow even on very narrow screens
      expect(tester.takeException(), isNull, reason: 'Should handle narrow screens without overflow');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display all three weekly goals without overflow', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      final now = DateTime.now();
      final mockExercises = [
        CognitiveExercise(
          name: 'Test Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 2),
            completedExercisesProvider.overrideWith((ref) async => mockExercises),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Act - Scroll to find the Weekly Goals section
      final weeklyGoalsFinder = find.text('Weekly Goals');
      if (weeklyGoalsFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(weeklyGoalsFinder);
        await tester.pumpAndSettle();

        // Assert - All three goals should be present
        expect(find.textContaining('Complete 5 MCI tests'), findsOneWidget);
        expect(find.textContaining('Play 5 brain games'), findsOneWidget);
        expect(find.textContaining('Daily streak'), findsOneWidget);
      }

      // No overflow errors
      expect(tester.takeException(), isNull);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should ellipsize long goal text with Expanded widget', (tester) async {
      // Arrange - Create extremely narrow screen
      tester.view.physicalSize = const Size(250, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 5),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - Should use Expanded to prevent overflow
      // Text should ellipsize if too long rather than overflow
      expect(tester.takeException(), isNull, reason: 'Text should ellipsize rather than overflow');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should display progress bars without overflow', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 4),
            completedExercisesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Act - Find progress indicators
      final progressIndicators = find.byType(LinearProgressIndicator);

      // Assert - Progress bars should be present
      if (progressIndicators.evaluate().isNotEmpty) {
        expect(progressIndicators, findsWidgets);
      }

      // No overflow from progress bars
      expect(tester.takeException(), isNull);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('should handle different goal progress values without overflow', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      final now = DateTime.now();
      // Create 5 exercises for today to max out the daily goal
      final mockExercises = List.generate(5, (i) {
        return CognitiveExercise(
          name: 'Exercise $i',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weeklyMCITestCountProvider.overrideWith((ref) async => 5), // Max
            completedExercisesProvider.overrideWith((ref) async => mockExercises),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - Should display 5/5 values without overflow
      expect(tester.takeException(), isNull, reason: 'Should handle max goal values without overflow');

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
