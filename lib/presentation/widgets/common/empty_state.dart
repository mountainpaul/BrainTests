import 'package:flutter/material.dart';

/// Empty state widget with friendly message and action
///
/// Provides clear guidance when lists or views have no data
/// Especially important for elderly users who may be confused by empty screens
class EmptyState extends StatelessWidget {

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios

class EmptyAssessmentsList extends StatelessWidget {

  const EmptyAssessmentsList({
    super.key,
    required this.onStartAssessment,
  });
  final VoidCallback onStartAssessment;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.assessment,
      title: 'No Assessments Yet',
      message: 'Start your first cognitive assessment to track your progress.',
      actionLabel: 'Start Assessment',
      onAction: onStartAssessment,
    );
  }
}

class EmptyRemindersList extends StatelessWidget {

  const EmptyRemindersList({
    super.key,
    required this.onAddReminder,
  });
  final VoidCallback onAddReminder;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_none,
      title: 'No Reminders',
      message: 'Add your first reminder to stay on track with your health routine.',
      actionLabel: 'Add Reminder',
      onAction: onAddReminder,
    );
  }
}

class EmptyExercisesList extends StatelessWidget {

  const EmptyExercisesList({
    super.key,
    required this.onStartExercise,
  });
  final VoidCallback onStartExercise;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.fitness_center,
      title: 'No Exercises Yet',
      message: 'Start your first brain exercise to keep your mind active.',
      actionLabel: 'Start Exercise',
      onAction: onStartExercise,
    );
  }
}

class EmptyMoodEntries extends StatelessWidget {

  const EmptyMoodEntries({
    super.key,
    required this.onLogMood,
  });
  final VoidCallback onLogMood;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.mood,
      title: 'No Mood Entries',
      message: 'Track your daily mood to understand your emotional wellbeing.',
      actionLabel: 'Log Mood',
      onAction: onLogMood,
    );
  }
}

class EmptySearchResults extends StatelessWidget {
  const EmptySearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try adjusting your search or filters.',
    );
  }
}
