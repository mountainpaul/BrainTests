import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/domain/services/streak_calculator.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Daily Streak Calculator', () {
    test('should return 0 when no exercises completed', () {
      // Arrange
      final exercises = <CognitiveExercise>[];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 0);
    });

    test('should return 1 when only today has exercise', () {
      // Arrange
      final now = DateTime.now();
      final exercises = [
        CognitiveExercise(
          name: 'Test',
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

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 1);
    });

    test('should return 0 when last exercise was yesterday (gap today)', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final exercises = [
        CognitiveExercise(
          name: 'Test',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: yesterday,
          createdAt: yesterday,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 0, reason: 'Streak should be 0 when no exercise completed today');
    });

    test('should return 2 when exercises on today and yesterday', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final exercises = [
        CognitiveExercise(
          name: 'Test Today',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
        CognitiveExercise(
          name: 'Test Yesterday',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 45,
          isCompleted: true,
          completedAt: yesterday,
          createdAt: yesterday,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 2);
    });

    test('should return 3 when exercises on today, yesterday, and 2 days ago', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final exercises = [
        CognitiveExercise(
          name: 'Test Today',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
        CognitiveExercise(
          name: 'Test Yesterday',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 45,
          isCompleted: true,
          completedAt: yesterday,
          createdAt: yesterday,
        ),
        CognitiveExercise(
          name: 'Test 2 Days Ago',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.medium,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 90,
          isCompleted: true,
          completedAt: twoDaysAgo,
          createdAt: twoDaysAgo,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 3);
    });

    test('should return 2 when today, yesterday have exercises but gap 2 days ago', () {
      // Arrange
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3)); // Gap at day 2
      final exercises = [
        CognitiveExercise(
          name: 'Test Today',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
        CognitiveExercise(
          name: 'Test Yesterday',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 45,
          isCompleted: true,
          completedAt: yesterday,
          createdAt: yesterday,
        ),
        CognitiveExercise(
          name: 'Test 3 Days Ago',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.medium,
          score: 85,
          maxScore: 100,
          timeSpentSeconds: 90,
          isCompleted: true,
          completedAt: threeDaysAgo,
          createdAt: threeDaysAgo,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 2, reason: 'Streak stops at gap (day 2 missing)');
    });

    test('should handle multiple exercises on same day (count day once)', () {
      // Arrange
      final now = DateTime.now();
      final exercises = [
        CognitiveExercise(
          name: 'Test 1',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
        CognitiveExercise(
          name: 'Test 2',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 45,
          isCompleted: true,
          completedAt: now.add(const Duration(hours: 2)),
          createdAt: now.add(const Duration(hours: 2)),
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 1, reason: 'Multiple exercises on same day count as 1 day');
    });

    test('should ignore exercises with null completedAt', () {
      // Arrange
      final now = DateTime.now();
      final exercises = [
        CognitiveExercise(
          name: 'Test Today',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
        ),
        CognitiveExercise(
          name: 'Incomplete',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 0,
          maxScore: 100,
          timeSpentSeconds: 0,
          isCompleted: false,
          completedAt: null,
          createdAt: now,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 1, reason: 'Incomplete exercises should not affect streak');
    });

    test('should handle exercises completed at different times on same day', () {
      // Arrange
      final now = DateTime.now();
      final todayMorning = DateTime(now.year, now.month, now.day, 8, 0);
      final todayEvening = DateTime(now.year, now.month, now.day, 20, 0);
      final exercises = [
        CognitiveExercise(
          name: 'Morning Test',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: todayMorning,
          createdAt: todayMorning,
        ),
        CognitiveExercise(
          name: 'Evening Test',
          type: ExerciseType.wordPuzzle,
          difficulty: ExerciseDifficulty.easy,
          score: 90,
          maxScore: 100,
          timeSpentSeconds: 45,
          isCompleted: true,
          completedAt: todayEvening,
          createdAt: todayEvening,
        ),
      ];

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 1, reason: 'Different times on same day count as 1 day');
    });

    test('should handle 7-day streak correctly', () {
      // Arrange
      final now = DateTime.now();
      final exercises = List.generate(7, (i) {
        final date = now.subtract(Duration(days: i));
        return CognitiveExercise(
          name: 'Test Day $i',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.easy,
          score: 100,
          maxScore: 100,
          timeSpentSeconds: 60,
          isCompleted: true,
          completedAt: date,
          createdAt: date,
        );
      });

      // Act
      final streak = StreakCalculator.calculateDailyStreak(exercises);

      // Assert
      expect(streak, 7);
    });
  });
}
