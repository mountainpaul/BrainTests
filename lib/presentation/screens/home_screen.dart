import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/user_profile_service.dart';
import '../../data/datasources/database.dart';
import '../providers/assessment_provider.dart';
import '../providers/mood_entry_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';
import 'profile_setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAssessments = ref.watch(recentAssessmentsProvider);
    final upcomingReminders = ref.watch(upcomingRemindersProvider);
    final todayMoodEntry = ref.watch(todayMoodEntryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.go('/reports'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Brain Plan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your cognitive health journey',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Setup Prompt
            FutureBuilder<int?>(
              future: UserProfileService.getUserAge(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.data == null) {
                  return Column(
                    children: [
                      CustomCard(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                              );
                              if (result == true && context.mounted) {
                                // Refresh the home screen to hide the prompt
                                (context as Element).reassemble();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      color: Colors.blue,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Set up your profile',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Get age-adjusted feedback and optimized exercises',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/assessments'),
                    child: const Column(
                      children: [
                        Icon(Icons.assessment, size: 32, color: Colors.blue),
                        SizedBox(height: 8),
                        Text('Take Assessment'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/exercises'),
                    child: const Column(
                      children: [
                        Icon(Icons.psychology, size: 32, color: Colors.purple),
                        SizedBox(height: 8),
                        Text('Brain Exercise'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/mood'),
                    child: const Column(
                      children: [
                        Icon(Icons.mood, size: 32, color: Colors.orange),
                        SizedBox(height: 8),
                        Text('Log Mood'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: CustomCard(
                    onTap: () => context.go('/reminders'),
                    child: const Column(
                      children: [
                        Icon(Icons.notifications, size: 32, color: Colors.green),
                        SizedBox(height: 8),
                        Text('Set Reminder'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Mood
            todayMoodEntry.when(
              data: (moodEntry) => moodEntry != null
                  ? _buildTodayMoodCard(context, moodEntry)
                  : _buildNoMoodCard(context),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => _buildNoMoodCard(context),
            ),
            
            const SizedBox(height: 16),

            // Recent Assessments
            Text(
              'Recent Assessments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            recentAssessments.when(
              data: (assessments) => assessments.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No recent assessments',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: assessments.take(5).map((assessment) {
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              _getAssessmentIcon(assessment.type),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(_getAssessmentTypeLabel(assessment.type)),
                            subtitle: Text(
                              'Score: ${assessment.score}/${assessment.maxScore} • '
                              '${_formatDate(assessment.completedAt)}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.go('/reports'),
                          ),
                        );
                      }).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 24),

            // Upcoming Reminders
            Text(
              'Upcoming Reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            upcomingReminders.when(
              data: (reminders) => reminders.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No upcoming reminders',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: reminders.take(3).map((reminder) {
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              _getReminderIcon(reminder.type),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(reminder.title),
                            subtitle: Text(
                              '${reminder.scheduledAt.hour.toString().padLeft(2, '0')}:'
                              '${reminder.scheduledAt.minute.toString().padLeft(2, '0')}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.go('/reminders'),
                          ),
                        );
                      }).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTodayMoodCard(BuildContext context, moodEntry) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Mood',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getMoodIcon(moodEntry.mood),
                size: 32,
                color: _getMoodColor(moodEntry.mood),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodLabel(moodEntry.mood),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Wellness Score: ${moodEntry.overallWellness.toStringAsFixed(1)}/10',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoodCard(BuildContext context) {
    return CustomCard(
      onTap: () => context.go('/mood'),
      child: Row(
        children: [
          const Icon(Icons.mood, size: 32, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Today\'s Mood',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Tap to record how you\'re feeling today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  IconData _getReminderIcon(type) {
    switch (type.toString()) {
      case 'ReminderType.medication':
        return Icons.medication;
      case 'ReminderType.exercise':
        return Icons.fitness_center;
      case 'ReminderType.assessment':
        return Icons.assessment;
      case 'ReminderType.appointment':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  IconData _getMoodIcon(mood) {
    switch (mood.toString()) {
      case 'MoodLevel.excellent':
        return Icons.sentiment_very_satisfied;
      case 'MoodLevel.good':
        return Icons.sentiment_satisfied;
      case 'MoodLevel.neutral':
        return Icons.sentiment_neutral;
      case 'MoodLevel.low':
        return Icons.sentiment_dissatisfied;
      case 'MoodLevel.veryLow':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(mood) {
    switch (mood.toString()) {
      case 'MoodLevel.excellent':
        return Colors.green;
      case 'MoodLevel.good':
        return Colors.lightGreen;
      case 'MoodLevel.neutral':
        return Colors.yellow;
      case 'MoodLevel.low':
        return Colors.orange;
      case 'MoodLevel.veryLow':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMoodLabel(mood) {
    switch (mood.toString()) {
      case 'MoodLevel.excellent':
        return 'Excellent';
      case 'MoodLevel.good':
        return 'Good';
      case 'MoodLevel.neutral':
        return 'Neutral';
      case 'MoodLevel.low':
        return 'Low';
      case 'MoodLevel.veryLow':
        return 'Very Low';
      default:
        return 'Unknown';
    }
  }

  IconData _getAssessmentIcon(type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return Icons.psychology;
      case AssessmentType.attentionFocus:
        return Icons.center_focus_strong;
      case AssessmentType.executiveFunction:
        return Icons.account_tree;
      case AssessmentType.languageSkills:
        return Icons.language;
      case AssessmentType.visuospatialSkills:
        return Icons.view_in_ar;
      case AssessmentType.processingSpeed:
        return Icons.speed;
      default:
        return Icons.assessment;
    }
  }

  String _getAssessmentTypeLabel(type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall';
      case AssessmentType.attentionFocus:
        return 'Attention Focus';
      case AssessmentType.executiveFunction:
        return 'Executive Function (Trail Making B)';
      case AssessmentType.languageSkills:
        return 'Language Skills';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Skills';
      case AssessmentType.processingSpeed:
        return 'Processing Speed (Trail Making A)';
      default:
        return 'Assessment';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final testDate = DateTime(date.year, date.month, date.day);

    if (testDate == today) {
      return 'Today';
    } else if (testDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final daysAgo = today.difference(testDate).inDays;
      if (daysAgo < 7) {
        return '$daysAgo days ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    }
  }
}