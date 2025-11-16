import 'package:brain_tests/data/datasources/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import 'daily_goals_repository_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('Daily Goals Repository Tests', () {
    late MockAppDatabase mockDatabase;
    late DailyGoalsRepository repository;

    setUp(() {
      mockDatabase = MockAppDatabase();
      repository = DailyGoalsRepository(mockDatabase);
    });

    test('should create daily goal for today if not exists', () async {
      // Arrange
      final today = DateTime.now();
      final normalized = DateTime(today.year, today.month, today.day);

      final createdGoal = DailyGoalEntry(
        id: 1,
        date: normalized,
        targetGames: 5,
        completedGames: 0,
        isCompleted: false,
        createdAt: today,
        updatedAt: today,
      );

      // First call returns null, second call returns created goal
      var callCount = 0;
      when(mockDatabase.getDailyGoalForDate(any))
          .thenAnswer((_) async {
            callCount++;
            return callCount == 1 ? null : createdGoal;
          });

      when(mockDatabase.insertDailyGoal(any))
          .thenAnswer((_) async => 1);

      // Act
      final goal = await repository.getOrCreateTodayGoal();

      // Assert
      expect(goal, isNotNull);
      expect(goal.targetGames, 5);
      expect(goal.completedGames, 0);
      expect(goal.isCompleted, false);
      verify(mockDatabase.insertDailyGoal(any)).called(1);
    });

    test('should return existing daily goal for today', () async {
      // Arrange
      final today = DateTime.now();
      final existingGoal = DailyGoalEntry(
        id: 1,
        date: today,
        targetGames: 5,
        completedGames: 3,
        isCompleted: false,
        createdAt: today,
        updatedAt: today,
      );

      when(mockDatabase.getDailyGoalForDate(any))
          .thenAnswer((_) async => existingGoal);

      // Act
      final goal = await repository.getOrCreateTodayGoal();

      // Assert
      expect(goal.id, 1);
      expect(goal.completedGames, 3);
      verify(mockDatabase.getDailyGoalForDate(any)).called(1);
      verifyNever(mockDatabase.insertDailyGoal(any));
    });

    test('should increment completed games count', () async {
      // Arrange
      final existingGoal = DailyGoalEntry(
        id: 1,
        date: DateTime.now(),
        targetGames: 5,
        completedGames: 3,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockDatabase.getDailyGoalForDate(any))
          .thenAnswer((_) async => existingGoal);

      when(mockDatabase.updateDailyGoal(any))
          .thenAnswer((_) async => true);

      // Act
      await repository.incrementCompletedGames();

      // Assert
      verify(mockDatabase.updateDailyGoal(argThat(predicate<DailyGoalEntry>((goal) {
        return goal.completedGames == 4 && goal.isCompleted == false;
      })))).called(1);
    });

    test('should mark goal as completed when reaching target', () async {
      // Arrange
      final existingGoal = DailyGoalEntry(
        id: 1,
        date: DateTime.now(),
        targetGames: 5,
        completedGames: 4,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockDatabase.getDailyGoalForDate(any))
          .thenAnswer((_) async => existingGoal);

      when(mockDatabase.updateDailyGoal(any))
          .thenAnswer((_) async => true);

      // Act
      await repository.incrementCompletedGames();

      // Assert
      verify(mockDatabase.updateDailyGoal(argThat(predicate<DailyGoalEntry>((goal) {
        return goal.completedGames == 5 && goal.isCompleted == true;
      })))).called(1);
    });

    test('should get all daily goals', () async {
      // Arrange
      final goals = [
        DailyGoalEntry(
          id: 1,
          date: DateTime(2025, 11, 7),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 2,
          date: DateTime(2025, 11, 8),
          targetGames: 5,
          completedGames: 3,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockDatabase.getAllDailyGoals())
          .thenAnswer((_) async => goals);

      // Act
      final result = await repository.getAllGoals();

      // Assert
      expect(result.length, 2);
      expect(result[0].completedGames, 5);
      expect(result[1].completedGames, 3);
    });

    test('should get goals for date range', () async {
      // Arrange
      final start = DateTime(2025, 11, 1);
      final end = DateTime(2025, 11, 8);
      final goals = [
        DailyGoalEntry(
          id: 1,
          date: DateTime(2025, 11, 5),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 2,
          date: DateTime(2025, 11, 6),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockDatabase.getDailyGoalsInRange(any, any))
          .thenAnswer((_) async => goals);

      // Act
      final result = await repository.getGoalsInRange(start, end);

      // Assert
      expect(result.length, 2);
      verify(mockDatabase.getDailyGoalsInRange(start, end)).called(1);
    });

    test('should calculate current streak', () async {
      // Arrange
      final today = DateTime(2025, 11, 8);
      final goals = [
        DailyGoalEntry(
          id: 1,
          date: DateTime(2025, 11, 6),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 2,
          date: DateTime(2025, 11, 7),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 3,
          date: DateTime(2025, 11, 8),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockDatabase.getAllDailyGoals())
          .thenAnswer((_) async => goals);

      // Act
      final streak = await repository.getCurrentStreak(today);

      // Assert
      expect(streak, 3);
    });

    test('should calculate longest streak', () async {
      // Arrange
      final goals = [
        DailyGoalEntry(
          id: 1,
          date: DateTime(2025, 11, 1),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 2,
          date: DateTime(2025, 11, 2),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 3,
          date: DateTime(2025, 11, 3),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 4,
          date: DateTime(2025, 11, 4),
          targetGames: 5,
          completedGames: 2,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 5,
          date: DateTime(2025, 11, 5),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockDatabase.getAllDailyGoals())
          .thenAnswer((_) async => goals);

      // Act
      final longestStreak = await repository.getLongestStreak();

      // Assert
      expect(longestStreak, 3); // First 3 consecutive days
    });

    test('should reset daily goal', () async {
      // Arrange
      final goalId = 1;
      final existingGoal = DailyGoalEntry(
        id: goalId,
        date: DateTime.now(),
        targetGames: 5,
        completedGames: 3,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockDatabase.getAllDailyGoals())
          .thenAnswer((_) async => [existingGoal]);

      when(mockDatabase.updateDailyGoal(any))
          .thenAnswer((_) async => true);

      // Act
      await repository.resetGoal(goalId);

      // Assert
      verify(mockDatabase.updateDailyGoal(argThat(predicate<DailyGoalEntry>((goal) {
        return goal.id == goalId &&
               goal.completedGames == 0 &&
               goal.isCompleted == false;
      })))).called(1);
    });

    test('should get completion statistics', () async {
      // Arrange
      final goals = [
        DailyGoalEntry(
          id: 1,
          date: DateTime(2025, 11, 1),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 2,
          date: DateTime(2025, 11, 2),
          targetGames: 5,
          completedGames: 3,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        DailyGoalEntry(
          id: 3,
          date: DateTime(2025, 11, 3),
          targetGames: 5,
          completedGames: 5,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockDatabase.getAllDailyGoals())
          .thenAnswer((_) async => goals);

      // Act
      final stats = await repository.getCompletionStatistics();

      // Assert
      expect(stats['totalGoals'], 3);
      expect(stats['completedGoals'], 2);
      expect(stats['completionRate'], closeTo(0.666, 0.01)); // 2/3
      expect(stats['totalGamesPlayed'], 13); // 5 + 3 + 5
    });
  });
}

// Repository implementation
class DailyGoalsRepository {
  final AppDatabase database;

  DailyGoalsRepository(this.database);

  Future<DailyGoalEntry> getOrCreateTodayGoal() async {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);

    final existing = await database.getDailyGoalForDate(normalized);
    if (existing != null) {
      return existing;
    }

    // Create new goal
    final newGoal = DailyGoalEntry(
      id: 0, // Will be auto-incremented
      date: normalized,
      targetGames: 5,
      completedGames: 0,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final id = await database.insertDailyGoal(newGoal);
    return (await database.getDailyGoalForDate(normalized))!;
  }

  Future<void> incrementCompletedGames() async {
    final goal = await getOrCreateTodayGoal();
    final newCompleted = goal.completedGames + 1;
    final isCompleted = newCompleted >= goal.targetGames;

    final updated = goal.copyWith(
      completedGames: newCompleted,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    await database.updateDailyGoal(updated);
  }

  Future<List<DailyGoalEntry>> getAllGoals() async {
    return await database.getAllDailyGoals();
  }

  Future<List<DailyGoalEntry>> getGoalsInRange(DateTime start, DateTime end) async {
    return await database.getDailyGoalsInRange(start, end);
  }

  Future<int> getCurrentStreak(DateTime today) async {
    final goals = await database.getAllDailyGoals();

    // Convert to simple list for streak calculation
    final goalsList = goals.map((g) => _DailyGoal(
      id: g.id,
      date: g.date,
      targetGames: g.targetGames,
      completedGames: g.completedGames,
      isCompleted: g.isCompleted,
    )).toList();

    return _DailyGoal.calculateCurrentStreak(goalsList, today);
  }

  Future<int> getLongestStreak() async {
    final goals = await database.getAllDailyGoals();

    final goalsList = goals.map((g) => _DailyGoal(
      id: g.id,
      date: g.date,
      targetGames: g.targetGames,
      completedGames: g.completedGames,
      isCompleted: g.isCompleted,
    )).toList();

    return _DailyGoal.calculateLongestStreak(goalsList);
  }

  Future<void> resetGoal(int goalId) async {
    final goals = await database.getAllDailyGoals();
    final goal = goals.firstWhere((g) => g.id == goalId);

    final reset = goal.copyWith(
      completedGames: 0,
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    await database.updateDailyGoal(reset);
  }

  Future<Map<String, dynamic>> getCompletionStatistics() async {
    final goals = await database.getAllDailyGoals();

    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final totalGamesPlayed = goals.fold<int>(0, (sum, g) => sum + g.completedGames);
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'completionRate': completionRate,
      'totalGamesPlayed': totalGamesPlayed,
    };
  }
}

// Helper class for streak calculations (reusing logic from entity tests)
class _DailyGoal {
  final int id;
  final DateTime date;
  final int targetGames;
  final int completedGames;
  final bool isCompleted;

  _DailyGoal({
    required this.id,
    required this.date,
    required this.targetGames,
    required this.completedGames,
    required this.isCompleted,
  });

  static int calculateCurrentStreak(List<_DailyGoal> goals, DateTime today) {
    if (goals.isEmpty) return 0;

    final sortedGoals = List<_DailyGoal>.from(goals)
      ..sort((a, b) => b.date.compareTo(a.date));

    final todayGoal = sortedGoals.firstWhere(
      (g) => g.date.year == today.year &&
             g.date.month == today.month &&
             g.date.day == today.day,
      orElse: () => _DailyGoal(
        id: -1,
        date: today,
        targetGames: 0,
        completedGames: 0,
        isCompleted: false,
      ),
    );

    if (!todayGoal.isCompleted) return 0;

    int streak = 0;
    DateTime checkDate = today;

    for (var goal in sortedGoals) {
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
        break;
      }
    }

    return streak;
  }

  static int calculateLongestStreak(List<_DailyGoal> goals) {
    if (goals.isEmpty) return 0;

    final sortedGoals = List<_DailyGoal>.from(goals)
      ..sort((a, b) => a.date.compareTo(b.date));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var goal in sortedGoals) {
      if (goal.isCompleted) {
        if (lastDate == null) {
          currentStreak = 1;
        } else {
          final daysDiff = goal.date.difference(lastDate).inDays;
          if (daysDiff == 1) {
            currentStreak++;
          } else {
            longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
            currentStreak = 1;
          }
        }
        lastDate = goal.date;
      } else {
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
        currentStreak = 0;
        lastDate = null;
      }
    }

    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
    return longestStreak;
  }
}
