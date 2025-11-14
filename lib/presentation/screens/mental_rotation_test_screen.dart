import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/models/block_3d_shape.dart';
import 'package:brain_plan/domain/services/mental_rotation_generator.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/widgets/block_3d_renderer.dart';
import 'package:brain_plan/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MentalRotationTestScreen extends ConsumerStatefulWidget {

  const MentalRotationTestScreen({
    super.key,
    this.difficulty = DifficultyLevel.easy,
  });
  final DifficultyLevel difficulty;

  @override
  ConsumerState<MentalRotationTestScreen> createState() => _MentalRotationTestScreenState();
}

class _MentalRotationTestScreenState extends ConsumerState<MentalRotationTestScreen> {
  late List<MentalRotationTask> _tasks;
  int _currentTaskIndex = 0;
  int? _selectedOption;
  final List<bool> _results = [];
  final List<Duration> _responseTimes = [];
  DateTime? _taskStartTime;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _generateTasks();
    _startTask();
  }

  void _generateTasks() {
    // Generate a mix of tasks for the selected difficulty
    switch (widget.difficulty) {
      case DifficultyLevel.easy:
        _tasks = [
          for (int i = 0; i < 5; i++)
            MentalRotationGenerator.generateTask(DifficultyLevel.easy),
        ];
        break;
      case DifficultyLevel.medium:
        _tasks = [
          for (int i = 0; i < 6; i++)
            MentalRotationGenerator.generateTask(DifficultyLevel.medium),
        ];
        break;
      case DifficultyLevel.hard:
        _tasks = [
          for (int i = 0; i < 7; i++)
            MentalRotationGenerator.generateTask(DifficultyLevel.hard),
        ];
        break;
    }
  }

  void _startTask() {
    _taskStartTime = DateTime.now();
    _selectedOption = null;
    _hasSubmitted = false;
  }

  void _submitAnswer() {
    if (_selectedOption == null || _hasSubmitted) return;

    final responseTime = DateTime.now().difference(_taskStartTime!);
    _responseTimes.add(responseTime);

    final isCorrect = _selectedOption == _tasks[_currentTaskIndex].correctAnswerIndex;
    _results.add(isCorrect);

    setState(() {
      _hasSubmitted = true;
    });

    // Auto-advance after showing result
    // Show correct answer for 4 seconds if incorrect, 1.5 seconds if correct
    final delay = isCorrect ? const Duration(milliseconds: 1500) : const Duration(seconds: 4);

    Future.delayed(delay, () {
      if (_currentTaskIndex < _tasks.length - 1) {
        setState(() {
          _currentTaskIndex++;
          _startTask();
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() async {
    final correctCount = _results.where((r) => r).length;
    final accuracy = (correctCount / _results.length) * 100;
    final avgTime = _responseTimes.fold<Duration>(Duration.zero, (sum, time) => sum + time).inMilliseconds / _responseTimes.length;

    // Save to database
    final notifier = ref.read(assessmentProvider.notifier);
    final assessment = Assessment(
      type: AssessmentType.visuospatialSkills,
      score: correctCount,
      maxScore: _results.length,
      notes: 'Mental Rotation Test - Accuracy: ${accuracy.toStringAsFixed(1)}%',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await notifier.addAssessment(assessment);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Test Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accuracy: ${accuracy.toStringAsFixed(1)}%'),
            Text('Correct: $correctCount / ${_results.length}'),
            Text('Average Time: ${(avgTime / 1000).toStringAsFixed(1)}s'),
            const SizedBox(height: 16),
            Text(
              _getInterpretation(accuracy),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentTaskIndex = 0;
                _results.clear();
                _responseTimes.clear();
                _generateTasks();
                _startTask();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getInterpretation(double accuracy) {
    if (accuracy >= 80) return 'Excellent visuospatial ability!';
    if (accuracy >= 70) return 'Good performance!';
    if (accuracy >= 60) return 'Fair - consider practice';
    return 'Consider cognitive training';
  }

  @override
  Widget build(BuildContext context) {
    final currentTask = _tasks[_currentTaskIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Rotation - ${_getDifficultyName()}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Task ${_currentTaskIndex + 1}/${_tasks.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions
            CustomCard(
              child: Column(
                children: [
                  const Text(
                    '3D Mental Rotation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Which shape is the SAME as the reference (just rotated)?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_hasSubmitted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _results.last ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _results.last ? '✓ Correct!' : '✗ Incorrect',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reference shape
            const Text(
              'Reference Shape:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Block3DWidget(
              shape: currentTask.referenceShape,
              size: 160,
              blockColor: const Color(0xFF64B5F6),
              edgeColor: const Color(0xFF1976D2),
            ),

            const SizedBox(height: 24),

            // Options
            const Text(
              'Select the matching shape:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: currentTask.options.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = index == currentTask.correctAnswerIndex;
                  final showCorrect = _hasSubmitted && isCorrect;
                  final showWrong = _hasSubmitted && isSelected && !isCorrect;

                  return GestureDetector(
                    onTap: _hasSubmitted ? null : () {
                      setState(() {
                        _selectedOption = index;
                      });
                    },
                    child: Block3DWidget(
                      shape: currentTask.options[index],
                      size: 140,
                      blockColor: showCorrect
                          ? const Color(0xFF4CAF50) // Green for correct
                          : showWrong
                              ? const Color(0xFFE53935) // Red for wrong
                              : isSelected
                                  ? const Color(0xFFFFB74D) // Orange for selected
                                  : const Color(0xFF64B5F6), // Blue default
                      edgeColor: showCorrect
                          ? const Color(0xFF2E7D32)
                          : showWrong
                              ? const Color(0xFFC62828)
                              : isSelected
                                  ? const Color(0xFFF57C00)
                                  : const Color(0xFF1976D2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: showCorrect
                              ? Colors.green
                              : showWrong
                                  ? Colors.red
                                  : isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                          width: isSelected || showCorrect || showWrong ? 3 : 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: showCorrect
                                ? Colors.green.withOpacity(0.3)
                                : showWrong
                                    ? Colors.red.withOpacity(0.3)
                                    : isSelected
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                            blurRadius: isSelected || showCorrect || showWrong ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Submit button
            if (_selectedOption != null && !_hasSubmitted)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Submit Answer',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyName() {
    switch (widget.difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }
}
