import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitiveExercise Entity Tests', () {
    test('should calculate percentage correctly when score exists', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.percentage, 85.0);
    });

    test('should return null percentage when score is null', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Word Puzzle',
        type: ExerciseType.wordPuzzle,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 50,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.percentage, isNull);
    });

    test('should format time correctly', () {
      // Arrange
      final exercise1 = CognitiveExercise(
        name: 'Math Problem',
        type: ExerciseType.mathProblem,
        difficulty: ExerciseDifficulty.hard,
        maxScore: 100,
        timeSpentSeconds: 125, // 2m 5s
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      final exercise2 = CognitiveExercise(
        name: 'Pattern Recognition',
        type: ExerciseType.patternRecognition,
        difficulty: ExerciseDifficulty.expert,
        maxScore: 100,
        timeSpentSeconds: 60, // 1m 0s
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise1.formattedTime, '2m 5s');
      expect(exercise2.formattedTime, '1m 0s');
    });

    test('should return -- for formatted time when null', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Sequence Recall',
        type: ExerciseType.sequenceRecall,
        difficulty: ExerciseDifficulty.medium,
        maxScore: 100,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.formattedTime, '--');
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalExercise = CognitiveExercise(
        id: 1,
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 100,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      final completedExercise = originalExercise.copyWith(
        score: 90,
        timeSpentSeconds: 180,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      // Assert
      expect(completedExercise.id, 1);
      expect(completedExercise.score, 90);
      expect(completedExercise.timeSpentSeconds, 180);
      expect(completedExercise.isCompleted, true);
      expect(completedExercise.completedAt, isNotNull);
      expect(completedExercise.name, 'Memory Game'); // unchanged
    });

    test('should maintain equality with same properties', () {
      // Arrange
      final dateTime = DateTime.now();
      final exercise1 = CognitiveExercise(
        id: 1,
        name: 'Spatial Test',
        type: ExerciseType.spatialAwareness,
        difficulty: ExerciseDifficulty.medium,
        score: 75,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        createdAt: dateTime,
        completedAt: dateTime,
      );
      
      final exercise2 = CognitiveExercise(
        id: 1,
        name: 'Spatial Test',
        type: ExerciseType.spatialAwareness,
        difficulty: ExerciseDifficulty.medium,
        score: 75,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        createdAt: dateTime,
        completedAt: dateTime,
      );

      // Assert
      expect(exercise1, equals(exercise2));
    });

    test('should not be equal with different properties', () {
      // Arrange
      final dateTime = DateTime.now();
      final exercise1 = CognitiveExercise(
        id: 1,
        name: 'Test 1',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 100,
        isCompleted: true,
        createdAt: dateTime,
      );
      
      final exercise2 = CognitiveExercise(
        id: 1,
        name: 'Test 2',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 100,
        isCompleted: true,
        createdAt: dateTime,
      );

      // Assert
      expect(exercise1, isNot(equals(exercise2)));
    });

    test('should handle zero time correctly', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Quick Test',
        type: ExerciseType.mathProblem,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 100,
        timeSpentSeconds: 0,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.formattedTime, '0m 0s');
    });

    test('should handle large time values correctly', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Long Test',
        type: ExerciseType.sequenceRecall,
        difficulty: ExerciseDifficulty.expert,
        maxScore: 100,
        timeSpentSeconds: 3661, // 61m 1s
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.formattedTime, '61m 1s');
    });

    test('should handle edge case with exact minute', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Exact Minute Test',
        type: ExerciseType.patternRecognition,
        difficulty: ExerciseDifficulty.medium,
        maxScore: 100,
        timeSpentSeconds: 120, // exactly 2m 0s
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.formattedTime, '2m 0s');
    });

    test('should create copy preserving null values when not overridden', () {
      // Arrange
      final originalExercise = CognitiveExercise(
        id: 1,
        name: 'Test',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 100,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Act
      final copiedExercise = originalExercise.copyWith(
        name: 'Updated Test',
      );

      // Assert
      expect(copiedExercise.score, isNull);
      expect(copiedExercise.timeSpentSeconds, isNull);
      expect(copiedExercise.exerciseData, isNull);
      expect(copiedExercise.completedAt, isNull);
      expect(copiedExercise.formattedTime, '--');
      expect(copiedExercise.percentage, isNull);
      expect(copiedExercise.name, 'Updated Test');
    });

    test('should handle perfect score percentage', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Perfect Test',
        type: ExerciseType.mathProblem,
        difficulty: ExerciseDifficulty.expert,
        score: 100,
        maxScore: 100,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.percentage, 100.0);
    });

    test('should handle zero score percentage', () {
      // Arrange
      final exercise = CognitiveExercise(
        name: 'Zero Score Test',
        type: ExerciseType.wordPuzzle,
        difficulty: ExerciseDifficulty.easy,
        score: 0,
        maxScore: 100,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(exercise.percentage, 0.0);
    });
  });
}