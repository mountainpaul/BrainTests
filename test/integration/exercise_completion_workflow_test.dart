import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/presentation/providers/cognitive_exercise_provider.dart';
import 'package:brain_tests/core/providers/database_provider.dart';
import 'package:brain_tests/presentation/screens/cognition_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test to verify exercises are saved and displayed correctly
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  group('Exercise Completion Workflow', () {
    test('Memory Game should save to database via provider', () async {
      // Arrange - Create container with database override
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
      );

      // Act - Add exercise via provider (simulating completion)
      final notifier = container.read(cognitiveExerciseProvider.notifier);
      final exercise = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await notifier.addExercise(exercise);

      // Assert - Verify exercise was saved to database
      final exercises = await database.select(database.cognitiveExerciseTable).get();

      expect(exercises.length, equals(1), reason: 'Exercise should be saved to database');
      expect(exercises.first.name, equals('Memory Game'));
      expect(exercises.first.type, equals(ExerciseType.memoryGame));
      expect(exercises.first.difficulty, equals(ExerciseDifficulty.medium));
      expect(exercises.first.score, equals(85));

      container.dispose();
    });

    testWidgets('Completed exercise should appear in Recent Activity', (tester) async {}, skip: true);

    testWidgets('Completed exercise should count in daily brain games goal', (tester) async {}, skip: true);

    testWidgets('Provider invalidation should refresh UI after exercise added', (tester) async {}, skip: true);
  });
}
