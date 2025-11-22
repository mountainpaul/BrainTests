import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../providers/cognitive_exercise_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExercises = ref.watch(completedExercisesProvider);
    final averageScores = ref.watch(averageExerciseScoresByTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Exercises'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Types
            Text(
              'Choose an Exercise',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildExerciseTypeGrid(context, ref),
            
            const SizedBox(height: 24),
            
            // Progress Overview
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            averageScores.when(
              data: (scores) => _buildProgressSection(context, scores),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Exercises
            Text(
              'Recent Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            completedExercises.when(
              data: (exercises) => exercises.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No exercises completed yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: exercises.take(5).map((exercise) {
                        return _buildExerciseCard(context, exercise);
                      }).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildExerciseTypeGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: ExerciseType.values.map((type) {
        return CustomCard(
          onTap: () => _startExercise(context, ref, type),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  _getExerciseIcon(type),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    _getExerciseTitle(type),
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
                    _getExerciseDescription(type),
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
      }).toList(),
    );
  }

  Widget _buildProgressSection(BuildContext context, Map<ExerciseType, double> scores) {
    if (scores.isEmpty) {
      return CustomCard(
        child: Text(
          'Complete exercises to see your progress',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Column(
      children: scores.entries.map((entry) {
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                _getExerciseIcon(entry.key),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getExerciseTitle(entry.key),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Average Score: ${entry.value.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _buildScoreIndicator(context, entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseCard(BuildContext context, CognitiveExercise exercise) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getExerciseIcon(exercise.type),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getDifficultyLabel(exercise.difficulty)),
            if (exercise.completedAt != null)
              Text(
                '${exercise.completedAt!.day}/${exercise.completedAt!.month}/${exercise.completedAt!.year}',
              ),
            Text('Time: ${exercise.formattedTime}'),
          ],
        ),
        trailing: exercise.score != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${exercise.score}/${exercise.maxScore}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${exercise.percentage?.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildScoreIndicator(BuildContext context, double score) {
    Color color;
    if (score >= 80) {
      color = Colors.green;
    } else if (score >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _startExercise(BuildContext context, WidgetRef ref, ExerciseType type) async {
    // Show difficulty selection dialog
    final difficulty = await showDialog<ExerciseDifficulty>(
      context: context,
      builder: (context) => _buildDifficultyDialog(context, type),
    );

    if (difficulty != null && context.mounted) {
      // Navigate to exercise detail screen with selected difficulty
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExerciseDetailScreen(
            exerciseType: type,
            initialDifficulty: difficulty,
          ),
        ),
      );
    }
  }

  Widget _buildDifficultyDialog(BuildContext context, ExerciseType type) {
    return AlertDialog(
      title: Text(_getExerciseTitle(type)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Difficulty Level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildDifficultyOption(
            context,
            ExerciseDifficulty.easy,
            'Easy',
            'Perfect for beginners',
            Colors.green,
            Icons.mood,
          ),
          const SizedBox(height: 8),
          _buildDifficultyOption(
            context,
            ExerciseDifficulty.medium,
            'Medium',
            'A good challenge',
            Colors.orange,
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          _buildDifficultyOption(
            context,
            ExerciseDifficulty.hard,
            'Hard',
            'For experienced users',
            Colors.red,
            Icons.fitness_center,
          ),
          const SizedBox(height: 8),
          _buildDifficultyOption(
            context,
            ExerciseDifficulty.expert,
            'Expert',
            'Maximum difficulty',
            Colors.purple,
            Icons.emoji_events,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildDifficultyOption(
    BuildContext context,
    ExerciseDifficulty difficulty,
    String label,
    String description,
    Color color,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(difficulty),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }


  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return Icons.memory;
      case ExerciseType.wordPuzzle:
        return Icons.shuffle;
      case ExerciseType.wordSearch:
        return Icons.grid_on;
      case ExerciseType.spanishAnagram:
        return Icons.translate;
      case ExerciseType.mathProblem:
        return Icons.calculate;
      case ExerciseType.patternRecognition:
        return Icons.pattern;
      case ExerciseType.sequenceRecall:
        return Icons.list;
      case ExerciseType.spatialAwareness:
        return Icons.view_in_ar;
    }
  }

  String _getExerciseTitle(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return 'Memory Game';
      case ExerciseType.wordPuzzle:
        return 'Word Anagram';
      case ExerciseType.wordSearch:
        return 'Word Search';
      case ExerciseType.spanishAnagram:
        return 'Spanish Anagram';
      case ExerciseType.mathProblem:
        return 'Math Problem';
      case ExerciseType.patternRecognition:
        return 'Pattern Recognition';
      case ExerciseType.sequenceRecall:
        return 'Sequence Recall';
      case ExerciseType.spatialAwareness:
        return 'Spatial Awareness';
    }
  }

  String _getExerciseDescription(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return 'Test your memory';
      case ExerciseType.wordPuzzle:
        return 'Unscramble letters';
      case ExerciseType.wordSearch:
        return 'Find hidden words';
      case ExerciseType.spanishAnagram:
        return 'Unscramble Spanish words';
      case ExerciseType.mathProblem:
        return 'Mathematical thinking';
      case ExerciseType.patternRecognition:
        return 'Identify patterns';
      case ExerciseType.sequenceRecall:
        return 'Remember sequences';
      case ExerciseType.spatialAwareness:
        return 'Spatial skills';
    }
  }

  String _getDifficultyLabel(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Easy';
      case ExerciseDifficulty.medium:
        return 'Medium';
      case ExerciseDifficulty.hard:
        return 'Hard';
      case ExerciseDifficulty.expert:
        return 'Expert';
    }
  }
}

