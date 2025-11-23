import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/daily_goal.dart';
import '../datasources/database.dart';

class DailyGoalsRepository {
  final AppDatabase database;

  DailyGoalsRepository(this.database);

  Future<DailyGoal> getOrCreateTodayGoal() async {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);

    final existing = await database.getDailyGoalForDate(normalized);
    if (existing != null) {
      return _toDomain(existing);
    }

    // Create new goal
    final newGoal = DailyGoalEntry(
      id: 0, // Will be auto-incremented
      uuid: const Uuid().v4(),
      date: normalized,
      targetGames: 5,
      completedGames: 0,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingInsert,
      lastUpdatedAt: DateTime.now(),
    );

    await database.insertDailyGoal(newGoal);
    final created = await database.getDailyGoalForDate(normalized);
    return _toDomain(created!);
  }

  Future<void> incrementCompletedGames() async {
    final goal = await getOrCreateTodayGoal();
    final newCompleted = goal.completedGames + 1;
    final isCompleted = newCompleted >= goal.targetGames;

    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    final dbGoal = await database.getDailyGoalForDate(normalized);

    final updated = dbGoal!.copyWith(
      completedGames: newCompleted,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
      lastUpdatedAt: DateTime.now(),
    );

    await database.updateDailyGoal(updated);
  }

  Future<List<DailyGoal>> getAllGoals() async {
    final goals = await database.getAllDailyGoals();
    return goals.map(_toDomain).toList();
  }

  Future<List<DailyGoal>> getGoalsInRange(DateTime start, DateTime end) async {
    final goals = await database.getDailyGoalsInRange(start, end);
    return goals.map(_toDomain).toList();
  }

  Future<int> getCurrentStreak(DateTime today) async {
    final goals = await getAllGoals();
    return DailyGoal.calculateCurrentStreak(goals, today);
  }

  Future<int> getLongestStreak() async {
    final goals = await getAllGoals();
    return DailyGoal.calculateLongestStreak(goals);
  }

  Future<void> resetGoal(int goalId) async {
    final goals = await database.getAllDailyGoals();
    final goal = goals.firstWhere((g) => g.id == goalId);

    final reset = goal.copyWith(
      completedGames: 0,
      isCompleted: false,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
      lastUpdatedAt: DateTime.now(),
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

  DailyGoal _toDomain(DailyGoalEntry entry) {
    return DailyGoal(
      id: entry.id,
      date: entry.date,
      targetGames: entry.targetGames,
      completedGames: entry.completedGames,
      isCompleted: entry.isCompleted,
    );
  }
}
