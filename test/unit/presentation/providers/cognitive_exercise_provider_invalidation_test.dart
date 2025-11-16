import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/presentation/providers/cognitive_activity_provider.dart';
import 'package:brain_tests/presentation/providers/cognitive_exercise_provider.dart';
import 'package:brain_tests/presentation/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test to verify provider invalidation works correctly
void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.memory();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    await database.close();
    container.dispose();
  });

  group('CognitiveExercise Provider Invalidation', () {
    test('completedExercisesProvider should refresh after adding exercise', () async {
      // Arrange - Get initial count
      final initialExercises = await container.read(completedExercisesProvider.future);
      expect(initialExercises.length, equals(0));

      // Act - Add exercise via notifier
      final notifier = container.read(cognitiveExerciseProvider.notifier);
      await notifier.addExercise(CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      // Assert - Provider should be invalidated and show new count
      final updatedExercises = await container.read(completedExercisesProvider.future);
      expect(updatedExercises.length, equals(1), reason: 'completedExercisesProvider should refresh after adding exercise');
      expect(updatedExercises.first.name, equals('Memory Game'));
    });

    test('recentCognitiveActivityProvider should refresh after adding exercise', () async {
      // Arrange
      final initialActivities = await container.read(recentCognitiveActivityProvider.future);
      expect(initialActivities.length, equals(0));

      // Act
      final notifier = container.read(cognitiveExerciseProvider.notifier);
      await notifier.addExercise(CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      // Assert
      final updatedActivities = await container.read(recentCognitiveActivityProvider.future);
      expect(updatedActivities.length, equals(1), reason: 'recentCognitiveActivityProvider should refresh');
      expect(updatedActivities.first.name, equals('Memory Game'));
    });

    test('should filter exercises by today for daily goal count', () async {
      // Arrange - Add yesterday's exercise
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await container.read(cognitiveExerciseProvider.notifier).addExercise(
        CognitiveExercise(
          name: 'Yesterday Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: yesterday,
          createdAt: yesterday,
        ),
      );

      // Add today's exercise
      await container.read(cognitiveExerciseProvider.notifier).addExercise(
        CognitiveExercise(
          name: 'Today Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 120,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      // Act - Get all completed exercises
      final allExercises = await container.read(completedExercisesProvider.future);

      // Filter for today (mimicking cognition_screen logic)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayExercises = allExercises.where((e) {
        if (e.completedAt == null) return false;
        final exerciseDate = DateTime(
          e.completedAt!.year,
          e.completedAt!.month,
          e.completedAt!.day,
        );
        return exerciseDate == today;
      }).toList();

      // Assert
      expect(allExercises.length, equals(2), reason: 'Should have 2 total exercises');
      expect(todayExercises.length, equals(1), reason: 'Should have only 1 exercise today');
      expect(todayExercises.first.name, equals('Today Exercise'));
    });
  });
}
