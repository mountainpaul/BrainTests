import '../entities/cognitive_exercise.dart';

/// Service for calculating exercise streaks
class StreakCalculator {
  /// Calculates the current daily streak of completed cognitive exercises
  ///
  /// A streak is the number of consecutive days (starting from today going backward)
  /// where at least one cognitive exercise was completed.
  ///
  /// Returns 0 if no exercises were completed or if there's a gap in completion dates.
  static int calculateDailyStreak(List<CognitiveExercise> exercises) {
    if (exercises.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      // Check if any exercise was completed on checkDate
      final hasExerciseOnDate = exercises.any((exercise) {
        if (exercise.completedAt == null) return false;

        final exerciseDate = DateTime(
          exercise.completedAt!.year,
          exercise.completedAt!.month,
          exercise.completedAt!.day,
        );

        return exerciseDate == checkDate;
      });

      if (hasExerciseOnDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Streak broken - stop counting
        break;
      }
    }

    return streak;
  }
}
