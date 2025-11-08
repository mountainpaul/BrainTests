import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../providers/assessment_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';
import 'assessment_detail_screen.dart';

class AssessmentsScreen extends ConsumerWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessments = ref.watch(assessmentsProvider);
    final averageScores = ref.watch(averageScoresByTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assessment Types
            Text(
              'Start New Assessment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAssessmentTypeGrid(context, ref),
            
            const SizedBox(height: 24),
            
            // Average Scores
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            averageScores.when(
              data: (scores) => _buildAverageScoresSection(context, scores),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Assessments
            Text(
              'Recent Assessments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            assessments.when(
              data: (assessmentList) => assessmentList.isEmpty
                  ? CustomCard(
                      child: Text(
                        'No assessments completed yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Column(
                      children: assessmentList.take(5).map((assessment) {
                        return _buildAssessmentCard(context, assessment);
                      }).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildAssessmentTypeGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      children: AssessmentType.values.map((type) {
        return CustomCard(
          onTap: () => _startAssessment(context, ref, type),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  _getAssessmentIcon(type),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    _getAssessmentTitle(type),
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
                    _getAssessmentDescription(type),
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

  Widget _buildAverageScoresSection(BuildContext context, Map<AssessmentType, double> scores) {
    if (scores.isEmpty) {
      return CustomCard(
        child: Text(
          'Complete assessments to see your progress',
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
                _getAssessmentIcon(entry.key),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAssessmentTitle(entry.key),
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

  Widget _buildAssessmentCard(BuildContext context, Assessment assessment) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getAssessmentIcon(assessment.type),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(_getAssessmentTitle(assessment.type)),
        subtitle: Text(
          '${assessment.completedAt.day}/${assessment.completedAt.month}/${assessment.completedAt.year}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${assessment.score}/${assessment.maxScore}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${assessment.percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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

  void _startAssessment(BuildContext context, WidgetRef ref, AssessmentType type) {
    // Navigate to assessment detail screen with real assessment tests
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssessmentDetailScreen(
          assessmentType: type,
        ),
      ),
    );
  }


  IconData _getAssessmentIcon(AssessmentType type) {
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
    }
  }

  String _getAssessmentTitle(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall';
      case AssessmentType.attentionFocus:
        return 'Attention Focus';
      case AssessmentType.executiveFunction:
        return 'Executive Function';
      case AssessmentType.languageSkills:
        return 'Language Skills';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Skills';
      case AssessmentType.processingSpeed:
        return 'Processing Speed';
    }
  }

  String _getAssessmentDescription(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Test your memory abilities';
      case AssessmentType.attentionFocus:
        return 'Measure concentration';
      case AssessmentType.executiveFunction:
        return 'Problem solving skills';
      case AssessmentType.languageSkills:
        return 'Language comprehension';
      case AssessmentType.visuospatialSkills:
        return 'Spatial awareness';
      case AssessmentType.processingSpeed:
        return 'Information processing';
    }
  }
}