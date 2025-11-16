import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/cognitive_exercise_repository_impl.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('CognitiveExerciseRepositoryImpl Integration Tests', () {
    late AppDatabase database;
    late CognitiveExerciseRepositoryImpl repository;

    setUp(() async {
      database = createTestDatabase();
      repository = CognitiveExerciseRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('CRUD Operations', () {
      test('should insert and retrieve cognitive exercise', () async {
        final exercise = CognitiveExercise(
          name: 'Memory Test',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          score: 8,
          maxScore: 10,
          timeSpentSeconds: 120,
          isCompleted: true,
          exerciseData: '{"words": ["apple", "banana"]}',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);

        expect(id, greaterThan(0));

        final retrieved = await repository.getExerciseById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Memory Test'));
        expect(retrieved.type, equals(ExerciseType.memoryGame));
        expect(retrieved.difficulty, equals(ExerciseDifficulty.medium));
        expect(retrieved.score, equals(8));
        expect(retrieved.maxScore, equals(10));
        expect(retrieved.timeSpentSeconds, equals(120));
        expect(retrieved.isCompleted, isTrue);
        expect(retrieved.exerciseData, contains('apple'));
        expect(retrieved.percentage, equals(80.0));
        expect(retrieved.formattedTime, equals('2m 0s'));
      });

      test('should insert incomplete exercise', () async {
        final exercise = CognitiveExercise(
          name: 'Incomplete Puzzle',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          maxScore: 15,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);

        final retrieved = await repository.getExerciseById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.isCompleted, isFalse);
        expect(retrieved.score, isNull);
        expect(retrieved.percentage, isNull);
        expect(retrieved.completedAt, isNull);
        expect(retrieved.timeSpentSeconds, isNull);
      });

      test('should update exercise completion', () async {
        // Insert incomplete exercise
        final exercise = CognitiveExercise(
          name: 'Math Problem',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.hard,
          maxScore: 20,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);
        final inserted = await repository.getExerciseById(id);

        // Complete the exercise
        final completedTime = DateTime.now();
        final completed = inserted!.copyWith(
          score: 18,
          timeSpentSeconds: 300,
          isCompleted: true,
          completedAt: completedTime,
          exerciseData: '{"answers": [1, 2, 3]}',
        );

        final result = await repository.updateExercise(completed);

        expect(result, isTrue);

        final retrieved = await repository.getExerciseById(id);

        expect(retrieved!.score, equals(18));
        expect(retrieved.timeSpentSeconds, equals(300));
        expect(retrieved.isCompleted, isTrue);
        expect(retrieved.completedAt, isNotNull);
        expect(retrieved.percentage, equals(90.0));
        expect(retrieved.formattedTime, equals('5m 0s'));
      });

      test('should delete exercise', () async {
        final exercise = CognitiveExercise(
          name: 'Test Exercise',
          type: ExerciseType.sequenceRecall,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);

        // Verify it exists
        final retrieved = await repository.getExerciseById(id);
        expect(retrieved, isNotNull);

        // Delete it
        final result = await repository.deleteExercise(id);
        expect(result, isTrue);

        // Verify it's gone
        final afterDelete = await repository.getExerciseById(id);
        expect(afterDelete, isNull);
      });
    });

    group('Query Operations', () {
      setUp(() async {
        // Insert test data with various types and difficulties
        final testExercises = [
          CognitiveExercise(
            name: 'Memory Game Easy',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.easy,
            score: 8,
            maxScore: 10,
            timeSpentSeconds: 60,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 5)),
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          CognitiveExercise(
            name: 'Memory Game Medium',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.medium,
            score: 7,
            maxScore: 10,
            timeSpentSeconds: 90,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          CognitiveExercise(
            name: 'Word Puzzle',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.medium,
            score: 9,
            maxScore: 12,
            timeSpentSeconds: 180,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          CognitiveExercise(
            name: 'Math Problem Hard',
            type: ExerciseType.mathProblem,
            difficulty: ExerciseDifficulty.hard,
            score: 15,
            maxScore: 20,
            timeSpentSeconds: 240,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          CognitiveExercise(
            name: 'Incomplete Exercise',
            type: ExerciseType.patternRecognition,
            difficulty: ExerciseDifficulty.easy,
            maxScore: 8,
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ];

        for (final exercise in testExercises) {
          await repository.insertExercise(exercise);
        }
      });

      test('should get all exercises', () async {
        final result = await repository.getAllExercises();

        expect(result.length, equals(5));
      });

      test('should get exercises by type', () async {
        final memoryGameExercises = await repository.getExercisesByType(
          ExerciseType.memoryGame);

        expect(memoryGameExercises.length, equals(2));
        expect(memoryGameExercises.every(
          (e) => e.type == ExerciseType.memoryGame), isTrue);

        final wordPuzzleExercises = await repository.getExercisesByType(
          ExerciseType.wordPuzzle);

        expect(wordPuzzleExercises.length, equals(1));
        expect(wordPuzzleExercises.first.type, equals(ExerciseType.wordPuzzle));
      });

      test('should get exercises by difficulty', () async {
        final easyExercises = await repository.getExercisesByDifficulty(
          ExerciseDifficulty.easy);

        expect(easyExercises.length, equals(2));
        expect(easyExercises.every(
          (e) => e.difficulty == ExerciseDifficulty.easy), isTrue);

        final hardExercises = await repository.getExercisesByDifficulty(
          ExerciseDifficulty.hard);

        expect(hardExercises.length, equals(1));
        expect(hardExercises.first.difficulty, equals(ExerciseDifficulty.hard));
      });

      test('should get completed exercises only', () async {
        final completedExercises = await repository.getCompletedExercises();

        expect(completedExercises.length, equals(4));
        expect(completedExercises.every((e) => e.isCompleted), isTrue);

        // Should be ordered by completedAt descending
        for (int i = 0; i < completedExercises.length - 1; i++) {
          expect(completedExercises[i].completedAt!
              .isAfter(completedExercises[i + 1].completedAt!), isTrue);
        }
      });

      test('should calculate average scores by type', () async {
        final averages = await repository.getAverageScoresByType();

        // Memory game: (8/10)*100 + (7/10)*100 = 80 + 70 = 75% average
        expect(averages[ExerciseType.memoryGame], equals(75.0));

        // Word puzzle: (9/12)*100 = 75%
        expect(averages[ExerciseType.wordPuzzle], equals(75.0));

        // Math problem: (15/20)*100 = 75%
        expect(averages[ExerciseType.mathProblem], equals(75.0));

        // Pattern recognition has no completed exercises, so shouldn't be in map
        expect(averages.containsKey(ExerciseType.patternRecognition), isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle exercises with null optional fields', () async {
        final exercise = CognitiveExercise(
          name: 'Minimal Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);
        final retrieved = await repository.getExerciseById(id);

        expect(retrieved!.score, isNull);
        expect(retrieved.timeSpentSeconds, isNull);
        expect(retrieved.exerciseData, isNull);
        expect(retrieved.completedAt, isNull);
        expect(retrieved.percentage, isNull);
        expect(retrieved.formattedTime, equals('--'));
      });

      test('should handle exercises with zero scores', () async {
        final exercise = CognitiveExercise(
          name: 'Failed Exercise',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.hard,
          score: 0,
          maxScore: 10,
          timeSpentSeconds: 300,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertExercise(exercise);
        final retrieved = await repository.getExerciseById(id);

        expect(retrieved!.score, equals(0));
        expect(retrieved.percentage, equals(0.0));
        expect(retrieved.isCompleted, isTrue);
      });
    });
  });
}