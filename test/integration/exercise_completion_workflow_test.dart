import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/cognitive_exercise_repository_impl.dart';
import 'package:brain_plan/domain/entities/cognitive_exercise.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


import '../helpers/test_database.dart';

void main() {
  group('Exercise Completion Workflow Integration Tests', () {
    late AppDatabase database;
    late CognitiveExerciseRepositoryImpl repository;

    setUp(() {
      database = createTestDatabase();
      repository = CognitiveExerciseRepositoryImpl(database);
    });

    group('Exercise Saving', () {
      test('should save completed word puzzle anagram exercise', () async {
        // Arrange
        final exercise = CognitiveExercise(
          name: 'Word Puzzle',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.medium,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 120,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final exerciseId = await repository.insertExercise(exercise);

        // Assert
        expect(exerciseId, equals(1));
        expect(exercise.score, equals(85));
        expect(exercise.maxScore, equals(100));
        expect(exercise.percentage, equals(85.0));
        expect(exercise.isCompleted, isTrue);
        expect(exercise.type, equals(ExerciseType.wordPuzzle));
        expect(exercise.difficulty, equals(ExerciseDifficulty.medium));

      });

      test('should save memory game exercise with perfect score', () async {
        // Arrange
        final exercise = CognitiveExercise(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final exerciseId = await repository.insertExercise(exercise);

        // Assert
        expect(exerciseId, equals(2));
        expect(exercise.percentage, equals(100.0));
        expect(exercise.formattedTime, equals('1m 0s'));

      });

      test('should save math problem exercise with low score', () async {
        // Arrange
        final exercise = CognitiveExercise(
          name: 'Math Problem',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.hard,
          score: 45,
          maxScore: 100,
          timeSpentSeconds: 300,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final exerciseId = await repository.insertExercise(exercise);

        // Assert
        expect(exerciseId, equals(3));
        expect(exercise.percentage, equals(45.0));
        expect(exercise.formattedTime, equals('5m 0s'));
        expect(exercise.difficulty, equals(ExerciseDifficulty.hard));

      });
    });

    group('Recent Exercises Retrieval', () {
      test('should retrieve recently completed exercises in order', () async {
        // Arrange
        final now = DateTime.now();
        final exercises = [
          CognitiveExercise(
            id: 1,
            name: 'Word Puzzle',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.medium,
            score: 85,
            maxScore: 100,
            timeSpentSeconds: 120,
            isCompleted: true,
            completedAt: now.subtract(const Duration(hours: 1)),
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Memory Game',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.easy,
            score: 95,
            maxScore: 100,
            timeSpentSeconds: 90,
            isCompleted: true,
            completedAt: now.subtract(const Duration(minutes: 30)),
            createdAt: now.subtract(const Duration(minutes: 30)),
          ),
          CognitiveExercise(
            id: 3,
            name: 'Spanish Anagram',
            type: ExerciseType.spanishAnagram,
            difficulty: ExerciseDifficulty.medium,
            score: 78,
            maxScore: 100,
            timeSpentSeconds: 150,
            isCompleted: true,
            completedAt: now.subtract(const Duration(minutes: 5)),
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
        ];


        // Act
        final recentExercises = await repository.getRecentExercises(limit: 5);

        // Assert
        expect(recentExercises.length, equals(3));
        expect(recentExercises[0].id, equals(1));
        expect(recentExercises[1].id, equals(2));
        expect(recentExercises[2].id, equals(3));
        expect(recentExercises.every((e) => e.isCompleted), isTrue);

      });

      test('should return empty list when no exercises completed', () async {
        // Arrange

        // Act
        final recentExercises = await repository.getRecentExercises(limit: 5);

        // Assert
        expect(recentExercises, isEmpty);
      });
    });

    group('Average Scores By Type', () {
      test('should calculate average scores for each exercise type', () async {
        // Arrange
        final averageScores = {
          ExerciseType.memoryGame: 87.5,
          ExerciseType.wordPuzzle: 82.0,
          ExerciseType.mathProblem: 75.3,
          ExerciseType.spanishAnagram: 80.0,
        };


        // Act
        final scores = await repository.getAverageScoresByType();

        // Assert
        expect(scores.length, equals(4));
        expect(scores[ExerciseType.memoryGame], equals(87.5));
        expect(scores[ExerciseType.wordPuzzle], equals(82.0));
        expect(scores[ExerciseType.mathProblem], equals(75.3));
        expect(scores[ExerciseType.spanishAnagram], equals(80.0));

      });

      test('should return empty map when no exercises completed', () async {
        // Arrange

        // Act
        final scores = await repository.getAverageScoresByType();

        // Assert
        expect(scores, isEmpty);
      });
    });

    group('Exercise Progress Tracking', () {
      test('should track exercise completion over time', () async {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        final exercises = List.generate(7, (index) {
          return CognitiveExercise(
            id: index + 1,
            name: 'Exercise ${index + 1}',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.medium,
            score: 80 + index,
            maxScore: 100,
            timeSpentSeconds: 120,
            isCompleted: true,
            completedAt: startDate.add(Duration(days: index)),
            createdAt: startDate.add(Duration(days: index)),
          );
        });


        // Act
        final weeklyExercises = await repository.getCompletedExercises();

        // Assert
        expect(weeklyExercises.length, equals(7));
        expect(weeklyExercises.first.score, equals(80));
        expect(weeklyExercises.last.score, equals(86));

        // Verify score improvement trend
        for (int i = 0; i < weeklyExercises.length - 1; i++) {
          expect(weeklyExercises[i + 1].score, greaterThan(weeklyExercises[i].score!));
        }

      });
    });

    group('Exercise Types and Difficulties', () {
      test('should filter exercises by type', () async {
        // Arrange
        final wordPuzzleExercises = [
          CognitiveExercise(
            id: 1,
            name: 'Word Puzzle 1',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.easy,
            score: 90,
            maxScore: 100,
            timeSpentSeconds: 100,
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Word Puzzle 2',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.hard,
            score: 75,
            maxScore: 100,
            timeSpentSeconds: 180,
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];


        // Act
        final exercises = await repository.getExercisesByType(ExerciseType.wordPuzzle);

        // Assert
        expect(exercises.length, equals(2));
        expect(exercises.every((e) => e.type == ExerciseType.wordPuzzle), isTrue);
        expect(exercises[0].difficulty, equals(ExerciseDifficulty.easy));
        expect(exercises[1].difficulty, equals(ExerciseDifficulty.hard));

      });

      test('should filter exercises by difficulty', () async {
        // Arrange
        final hardExercises = [
          CognitiveExercise(
            id: 1,
            name: 'Math Problem',
            type: ExerciseType.mathProblem,
            difficulty: ExerciseDifficulty.hard,
            score: 70,
            maxScore: 100,
            timeSpentSeconds: 240,
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Pattern Recognition',
            type: ExerciseType.patternRecognition,
            difficulty: ExerciseDifficulty.hard,
            score: 68,
            maxScore: 100,
            timeSpentSeconds: 220,
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];


        // Act
        final exercises = await repository.getExercisesByDifficulty(ExerciseDifficulty.hard);

        // Assert
        expect(exercises.length, equals(2));
        expect(exercises.every((e) => e.difficulty == ExerciseDifficulty.hard), isTrue);
        expect(exercises[0].type, equals(ExerciseType.mathProblem));
        expect(exercises[1].type, equals(ExerciseType.patternRecognition));

      });
    });

    group('Error Handling', () {
      test('should handle database insertion errors gracefully', () async {
        // Arrange
        final exercise = CognitiveExercise(
          name: 'Test Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 120,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act & Assert
        expect(
          () async => await repository.insertExercise(exercise),
          throwsException,
        );

      });

      test('should handle retrieval errors gracefully', () async {
        // Arrange

        // Act & Assert
        expect(
          () async => await repository.getRecentExercises(limit: 5),
          throwsException,
        );

      });
    });
  });
}
