import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/datasources/database.dart';
import '../../domain/services/streak_calculator.dart';
import '../providers/assessment_provider.dart';
import '../providers/cognitive_exercise_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';
import 'assessments_screen.dart';
import 'exercises_screen.dart';
import 'five_word_recall_test_screen.dart';
import 'fluency_test_screen.dart';
import 'sdmt_test_screen.dart';
import 'trail_making_test_screen.dart';

class CognitionScreen extends ConsumerStatefulWidget {
  const CognitionScreen({super.key});

  @override
  ConsumerState<CognitionScreen> createState() => _CognitionScreenState();
}

class _CognitionScreenState extends ConsumerState<CognitionScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToBrainTrainingTab() {
    _tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cognition'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'MCI Tests', icon: Icon(Icons.assessment)),
            Tab(text: 'Brain Training', icon: Icon(Icons.psychology)),
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const MCITestsTab(),
          const BrainTrainingTab(),
          CognitionOverviewTab(onStartTest: _switchToBrainTrainingTab),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}

class MCITestsTab extends ConsumerWidget {
  const MCITestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinical MCI Assessment Tests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scientifically validated tests for monitoring cognitive function',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          _buildMCITestCard(
            context,
            'Fluency Test (Animals)',
            'Name as many animals as possible in 60 seconds',
            Icons.pets,
            'Tests verbal fluency and executive function',
            () => _startFluencyTest(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildMCITestCard(
            context,
            '5-Word Recall Test',
            'Memory test with immediate and delayed recall',
            Icons.memory,
            'Assesses short-term and working memory',
            () => _start5WordRecall(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildMCITestCard(
            context,
            'Trail Making Test A/B',
            'Connect numbers and letters in sequence',
            Icons.timeline,
            'Measures processing speed and mental flexibility',
            () => _startTrailMaking(context),
          ),
          
          const SizedBox(height: 12),

          _buildMCITestCard(
            context,
            'Symbol-Digit Test (SDMT)',
            'Match symbols to numbers using a key',
            Icons.grid_3x3,
            'Tests processing speed and sustained attention',
            () => _startSDMT(context),
          ),

          const SizedBox(height: 24),

          // Cambridge CANTAB-style tests section
          Text(
            'Cambridge Cognitive Tests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'CANTAB-style tests - highly sensitive for early detection',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          CustomCard(
            child: ListTile(
              leading: const Icon(Icons.psychology, color: Colors.deepPurple),
              title: const Text('Cambridge Assessments'),
              subtitle: const Text('PAL, RVP, RTI, SWM, PRM - Clinically validated tests'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.go('/cambridge');
              },
            ),
          ),

          const SizedBox(height: 24),

          // Standard assessments section
          Text(
            'Additional Assessments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive cognitive assessments',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: ListTile(
              leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
              title: const Text('View All Assessments'),
              subtitle: const Text('Memory, attention, language, and more'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AssessmentsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMCITestCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String detail,
    VoidCallback onTap,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _startFluencyTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FluencyTestScreen()),
    );
  }

  void _start5WordRecall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FiveWordRecallTestScreen()),
    );
  }

  void _startTrailMaking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TrailMakingTestScreen()),
    );
  }

  void _startSDMT(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SDMTTestScreen()),
    );
  }
}

class BrainTrainingTab extends ConsumerWidget {
  const BrainTrainingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Brain Training Exercises',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Fun, engaging exercises to keep your mind sharp',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: ListTile(
              leading: Icon(Icons.psychology, color: Theme.of(context).primaryColor),
              title: const Text('View All Exercises'),
              subtitle: const Text('Memory games, puzzles, math problems, and more'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ExercisesScreen()),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick access to popular exercises
          Text(
            'Popular Exercises',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: [
              _buildQuickExerciseCard(
                context,
                'Memory Game',
                Icons.memory,
                'Match pairs of cards',
              ),
              _buildQuickExerciseCard(
                context,
                'Word Puzzle',
                Icons.text_fields,
                'Find hidden words',
              ),
              _buildQuickExerciseCard(
                context,
                'Math Problems',
                Icons.calculate,
                'Solve arithmetic',
              ),
              _buildQuickExerciseCard(
                context,
                'Pattern Recognition',
                Icons.pattern,
                'Identify patterns',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExerciseCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return CustomCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ExercisesScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CognitionOverviewTab extends ConsumerWidget {

  const CognitionOverviewTab({
    super.key,
    required this.onStartTest,
  });
  final VoidCallback onStartTest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentExercises = ref.watch(recentExercisesProvider);
    final completedExercises = ref.watch(completedExercisesProvider);
    final weeklyMCITestCount = ref.watch(weeklyMCITestCountProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cognitive Health Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Recent Activity
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: recentExercises.when(
                data: (exercises) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Activity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (exercises.isEmpty) ...[
                      const Text('No recent cognitive tests completed.'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onStartTest,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Your First Test'),
                      ),
                    ] else ...[
                      ...exercises.take(3).map((exercise) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              _getExerciseIcon(exercise.type),
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${exercise.name} - ${exercise.score}%',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Text(
                              _formatDate(exercise.completedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const Text('Error loading activities'),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Weekly Goals
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: completedExercises.when(
                data: (exercises) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  // Calculate today's exercises
                  final todayExercises = exercises.where((e) {
                    if (e.completedAt == null) return false;
                    final exerciseDate = DateTime(
                      e.completedAt!.year,
                      e.completedAt!.month,
                      e.completedAt!.day,
                    );
                    return exerciseDate == today;
                  }).toList();

                  // Calculate current streak using the tested service
                  final currentStreak = StreakCalculator.calculateDailyStreak(exercises);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Weekly Goals',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildGoalItem('Complete 5 MCI tests (weekly)', weeklyMCITestCount.asData?.value ?? 0, 5),
                      _buildGoalItem('Play 5 brain games (daily)', todayExercises.length, 5),
                      _buildGoalItem('Daily streak', currentStreak, currentStreak + 1),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Weekly Goals',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGoalItem('Complete 5 MCI tests (weekly)', 0, 5),
                    _buildGoalItem('Play 5 brain games (today)', 0, 5),
                    _buildGoalItem('Daily streak', 0, 1),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tips & Recommendations
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Tip',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Try to complete cognitive exercises when you feel most alert, typically in the morning for most people.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, int current, int target) {
    final progress = target > 0 ? current / target : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('$current/$target'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return Icons.grid_on;
      case ExerciseType.wordPuzzle:
        return Icons.abc;
      case ExerciseType.wordSearch:
        return Icons.search;
      case ExerciseType.spanishAnagram:
        return Icons.spellcheck;
      case ExerciseType.mathProblem:
        return Icons.calculate;
      case ExerciseType.patternRecognition:
        return Icons.pattern;
      case ExerciseType.sequenceRecall:
        return Icons.format_list_numbered;
      case ExerciseType.spatialAwareness:
        return Icons.explore;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}