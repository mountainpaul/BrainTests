import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/assessment_provider.dart';
import '../providers/cognitive_exercise_provider.dart';
import '../providers/mood_entry_provider.dart';
import '../providers/pdf_provider.dart';
import '../widgets/charts/assessment_chart.dart';
import '../widgets/charts/exercise_progress_chart.dart';
import '../widgets/charts/mood_chart.dart';
import '../widgets/charts/overview_pie_chart.dart';
import '../widgets/custom_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentMoodEntries = ref.watch(recentMoodEntriesProvider);
    final recentAssessments = ref.watch(recentAssessmentsProvider);
    final recentExercises = ref.watch(recentExercisesProvider);
    final averageScores = ref.watch(averageScoresByTypeProvider);
    
    final allAssessments = ref.watch(assessmentsProvider);
    final allMoodEntries = ref.watch(moodEntriesProvider);
    final allExercises = ref.watch(completedExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleExportAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save to Device'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            Text(
              'Assessment Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: SizedBox(
                height: 200,
                child: averageScores.when(
                  data: (scores) => scores.isNotEmpty
                      ? OverviewPieChart(averageScores: scores)
                      : const Center(child: Text('No assessment data available')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Assessment Progress
            Text(
              'Assessment Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: SizedBox(
                height: 250,
                child: recentAssessments.when(
                  data: (assessments) => assessments.isNotEmpty
                      ? AssessmentChart(assessments: assessments)
                      : const Center(child: Text('No assessment data available')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Exercise Progress
            Text(
              'Exercise Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: SizedBox(
                height: 250,
                child: recentExercises.when(
                  data: (exercises) => exercises.isNotEmpty
                      ? ExerciseProgressChart(exercises: exercises)
                      : const Center(child: Text('No exercise data available')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Mood Trends
            Text(
              'Mood & Wellness Trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: SizedBox(
                height: 250,
                child: recentMoodEntries.when(
                  data: (entries) => entries.isNotEmpty
                      ? Column(
                          children: [
                            Expanded(child: MoodChart(moodEntries: entries)),
                            const SizedBox(height: 8),
                            _buildMoodLegend(),
                          ],
                        )
                      : const Center(child: Text('No mood data available')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Wellness', Colors.blue),
        _buildLegendItem('Energy', Colors.green),
        _buildLegendItem('Low Stress', Colors.red),
        _buildLegendItem('Sleep', Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _handleExportAction(BuildContext context, WidgetRef ref, String action) async {
    final pdfNotifier = ref.read(pDFGeneratorProvider.notifier);
    
    // Collect all data for export
    final assessmentsAsync = ref.read(assessmentsProvider);
    final moodEntriesAsync = ref.read(moodEntriesProvider);
    final exercisesAsync = ref.read(completedExercisesProvider);

    assessmentsAsync.when(
      data: (assessments) {
        moodEntriesAsync.when(
          data: (moodEntries) {
            exercisesAsync.when(
              data: (exercises) {
                if (action == 'share') {
                  _shareReport(context, pdfNotifier, assessments, moodEntries, exercises);
                } else if (action == 'save') {
                  _saveReport(context, pdfNotifier, assessments, moodEntries, exercises);
                }
              },
              loading: () => _showError(context, 'Loading exercise data...'),
              error: (error, stack) => _showError(context, 'Error loading exercises: $error'),
            );
          },
          loading: () => _showError(context, 'Loading mood data...'),
          error: (error, stack) => _showError(context, 'Error loading mood entries: $error'),
        );
      },
      loading: () => _showError(context, 'Loading assessment data...'),
      error: (error, stack) => _showError(context, 'Error loading assessments: $error'),
    );
  }

  void _shareReport(BuildContext context, pdfNotifier, assessments, moodEntries, exercises) async {
    try {
      await pdfNotifier.generateAndShareReport(
        assessments: assessments,
        moodEntries: moodEntries,
        exercises: exercises,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showError(context, 'Error generating report: $error');
      }
    }
  }

  void _saveReport(BuildContext context, pdfNotifier, assessments, moodEntries, exercises) async {
    try {
      await pdfNotifier.saveReportToDevice(
        assessments: assessments,
        moodEntries: moodEntries,
        exercises: exercises,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report saved to device successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showError(context, 'Error saving report: $error');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}