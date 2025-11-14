import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Daily Goals Entity Tests', () {
    test('should create daily goal with required fields', () {
      // Arrange & Act
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 0,
        isCompleted: false,
      );

      // Assert
      expect(goal.id, 1);
      expect(goal.date, DateTime(2025, 11, 8));
      expect(goal.targetGames, 5);
      expect(goal.completedGames, 0);
      expect(goal.isCompleted, false);
    });

    test('should mark goal as completed when target is reached', () {
      // Arrange
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 5,
        isCompleted: true,
      );

      // Assert
      expect(goal.isCompleted, true);
      expect(goal.completedGames, goal.targetGames);
    });

    test('should calculate progress percentage correctly', () {
      // Arrange
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 3,
        isCompleted: false,
      );

      // Act
      final progress = goal.progressPercentage;

      // Assert
      expect(progress, 0.6); // 3/5 = 60%
    });

    test('should return 0 progress when no games completed', () {
      // Arrange
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 0,
        isCompleted: false,
      );

      // Assert
      expect(goal.progressPercentage, 0.0);
    });

    test('should return 1.0 progress when goal is completed', () {
      // Arrange
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 5,
        isCompleted: true,
      );

      // Assert
      expect(goal.progressPercentage, 1.0);
    });

    test('should handle over-achievement (more games than target)', () {
      // Arrange
      final goal = DailyGoal(
        id: 1,
        date: DateTime(2025, 11, 8),
        targetGames: 5,
        completedGames: 7,
        isCompleted: true,
      );

      // Assert
      expect(goal.progressPercentage, 1.0); // Capped at 100%
      expect(goal.completedGames, greaterThan(goal.targetGames));
    });
  });

  group('Daily Goals Streak Calculation Tests', () {
    test('should calculate current streak correctly for consecutive days', () {
      // Arrange
      final goals = [
        DailyGoal(id: 1, date: DateTime(2025, 11, 4), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 2, date: DateTime(2025, 11, 5), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 3, date: DateTime(2025, 11, 6), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 4, date: DateTime(2025, 11, 7), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 5, date: DateTime(2025, 11, 8), targetGames: 5, completedGames: 5, isCompleted: true),
      ];

      // Act
      final streak = DailyGoal.calculateCurrentStreak(goals, DateTime(2025, 11, 8));

      // Assert
      expect(streak, 5);
    });

    test('should return 0 streak when today is not completed', () {
      // Arrange
      final goals = [
        DailyGoal(id: 1, date: DateTime(2025, 11, 7), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 2, date: DateTime(2025, 11, 8), targetGames: 5, completedGames: 2, isCompleted: false),
      ];

      // Act
      final streak = DailyGoal.calculateCurrentStreak(goals, DateTime(2025, 11, 8));

      // Assert
      expect(streak, 0);
    });

    test('should break streak on missed day', () {
      // Arrange
      final goals = [
        DailyGoal(id: 1, date: DateTime(2025, 11, 5), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 2, date: DateTime(2025, 11, 6), targetGames: 5, completedGames: 2, isCompleted: false),
        DailyGoal(id: 3, date: DateTime(2025, 11, 7), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 4, date: DateTime(2025, 11, 8), targetGames: 5, completedGames: 5, isCompleted: true),
      ];

      // Act
      final streak = DailyGoal.calculateCurrentStreak(goals, DateTime(2025, 11, 8));

      // Assert
      expect(streak, 2); // Only last 2 consecutive days
    });

    test('should return 1 for single completed day', () {
      // Arrange
      final goals = [
        DailyGoal(id: 1, date: DateTime(2025, 11, 8), targetGames: 5, completedGames: 5, isCompleted: true),
      ];

      // Act
      final streak = DailyGoal.calculateCurrentStreak(goals, DateTime(2025, 11, 8));

      // Assert
      expect(streak, 1);
    });

    test('should return 0 for empty goal list', () {
      // Arrange
      final goals = <DailyGoal>[];

      // Act
      final streak = DailyGoal.calculateCurrentStreak(goals, DateTime(2025, 11, 8));

      // Assert
      expect(streak, 0);
    });

    test('should calculate longest streak correctly', () {
      // Arrange
      final goals = [
        DailyGoal(id: 1, date: DateTime(2025, 11, 1), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 2, date: DateTime(2025, 11, 2), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 3, date: DateTime(2025, 11, 3), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 4, date: DateTime(2025, 11, 4), targetGames: 5, completedGames: 2, isCompleted: false), // Break
        DailyGoal(id: 5, date: DateTime(2025, 11, 5), targetGames: 5, completedGames: 5, isCompleted: true),
        DailyGoal(id: 6, date: DateTime(2025, 11, 6), targetGames: 5, completedGames: 5, isCompleted: true),
      ];

      // Act
      final longestStreak = DailyGoal.calculateLongestStreak(goals);

      // Assert
      expect(longestStreak, 3); // First 3 days
    });

    test('should return 0 longest streak for empty list', () {
      // Arrange
      final goals = <DailyGoal>[];

      // Act
      final longestStreak = DailyGoal.calculateLongestStreak(goals);

      // Assert
      expect(longestStreak, 0);
    });
  });
}

// Placeholder class - will be implemented after tests
class DailyGoal {
  final int id;
  final DateTime date;
  final int targetGames;
  final int completedGames;
  final bool isCompleted;

  DailyGoal({
    required this.id,
    required this.date,
    required this.targetGames,
    required this.completedGames,
    required this.isCompleted,
  });

  double get progressPercentage {
    if (targetGames == 0) return 0.0;
    final progress = completedGames / targetGames;
    return progress > 1.0 ? 1.0 : progress;
  }

  static int calculateCurrentStreak(List<DailyGoal> goals, DateTime today) {
    if (goals.isEmpty) return 0;

    // Sort goals by date descending (most recent first)
    final sortedGoals = List<DailyGoal>.from(goals)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Check if today's goal is completed
    final todayGoal = sortedGoals.firstWhere(
      (g) => g.date.year == today.year &&
             g.date.month == today.month &&
             g.date.day == today.day,
      orElse: () => DailyGoal(
        id: -1,
        date: today,
        targetGames: 0,
        completedGames: 0,
        isCompleted: false,
      ),
    );

    if (!todayGoal.isCompleted) return 0;

    // Count consecutive completed days working backwards from today
    int streak = 0;
    DateTime checkDate = today;

    for (var goal in sortedGoals) {
      // Normalize dates to compare just year/month/day
      final goalDate = DateTime(goal.date.year, goal.date.month, goal.date.day);
      final expectedDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (goalDate.isAtSameMomentAs(expectedDate)) {
        if (goal.isCompleted) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else if (goalDate.isBefore(expectedDate)) {
        // Gap in the streak
        break;
      }
    }

    return streak;
  }

  static int calculateLongestStreak(List<DailyGoal> goals) {
    if (goals.isEmpty) return 0;

    // Sort goals by date ascending
    final sortedGoals = List<DailyGoal>.from(goals)
      ..sort((a, b) => a.date.compareTo(b.date));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var goal in sortedGoals) {
      if (goal.isCompleted) {
        if (lastDate == null) {
          // First completed goal
          currentStreak = 1;
        } else {
          final daysDiff = goal.date.difference(lastDate).inDays;
          if (daysDiff == 1) {
            // Consecutive day
            currentStreak++;
          } else {
            // Streak broken, start new streak
            longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
            currentStreak = 1;
          }
        }
        lastDate = goal.date;
      } else {
        // Incomplete goal breaks the streak
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
        currentStreak = 0;
        lastDate = null;
      }
    }

    // Check final streak
    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;

    return longestStreak;
  }
}
