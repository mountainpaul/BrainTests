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

    final sortedGoals = List<DailyGoal>.from(goals)
      ..sort((a, b) => b.date.compareTo(a.date));

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

  static int calculateLongestStreak(List<DailyGoal> goals) {
    if (goals.isEmpty) return 0;

    final sortedGoals = List<DailyGoal>.from(goals)
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
