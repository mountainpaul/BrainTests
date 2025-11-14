import 'dart:async';
import 'dart:convert';

import 'package:brain_plan/domain/entities/cambridge_assessment.dart';
import 'package:brain_plan/domain/services/cambridge_test_generator.dart';
import 'package:brain_plan/presentation/providers/cambridge_assessment_provider.dart';
import 'package:brain_plan/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PAL (Paired Associates Learning) Test Screen
/// Most sensitive test for early Alzheimer's detection
/// Tests visual episodic memory by showing patterns in boxes
class PALTestScreen extends ConsumerStatefulWidget {
  const PALTestScreen({super.key});

  @override
  ConsumerState<PALTestScreen> createState() => _PALTestScreenState();
}

class _PALTestScreenState extends ConsumerState<PALTestScreen> {
  // Test state
  PALPhase _phase = PALPhase.introduction;
  int _currentStage = 0;
  int _currentTrial = 0;
  PALTrial? _currentPALTrial;

  // Pattern display
  final List<String> _patterns = ['■', '●', '▲', '◆', '★', '▼', '◀', '▶'];
  final List<Color> _patternColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // Scoring
  int _totalErrors = 0;
  int _stagesCompleted = 0;
  int _firstTrialMemoryScore = 0;
  final List<int> _trialLatencies = [];
  final DateTime _testStartTime = DateTime.now();

  // Current trial state
  Map<int, int>? _currentPatternMap; // pattern -> position
  int? _currentPatternToPlace;
  bool _showingPatterns = false;
  Timer? _displayTimer;
  final Set<int> _placedPatterns = {}; // Track which patterns have been placed

  // Sequential pattern display state
  int _currentDisplayingPatternIndex = 0;
  List<int> _patternDisplayOrder = []; // Order in which to display patterns

  // Results tracking
  final List<bool> _trialResults = [];
  final Map<String, dynamic> _detailedMetrics = {};

  @override
  void initState() {
    super.initState();
    // User will manually start the test from introduction screen
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  void _startNextStage() {
    print('PAL: _startNextStage called, current stage: $_currentStage');
    if (_currentStage >= 8) {
      print('PAL: Test complete!');
      _completeTest();
      return;
    }

    setState(() {
      _currentStage++;
      _currentTrial = 0;
      _phase = PALPhase.presentation;
    });

    print('PAL: Advanced to stage $_currentStage');
    _generateTrial();
  }

  void _generateTrial() {
    _currentTrial++;
    final trial = CambridgeTestGenerator.generatePALTrial(_currentStage);

    setState(() {
      _currentPALTrial = trial;
      _currentPatternMap = trial.patternPositions;
      _showingPatterns = true;
      _placedPatterns.clear(); // Clear placed patterns for new trial
      _phase = PALPhase.presentation; // Reset phase to presentation for new trial
      _currentDisplayingPatternIndex = 0;
      _patternDisplayOrder = trial.patternPositions.keys.toList();
    });

    // Start sequential pattern display
    _displayTimer?.cancel();
    _showNextPattern();
  }

  void _showNextPattern() {
    if (_currentDisplayingPatternIndex >= _patternDisplayOrder.length) {
      // All patterns have been displayed, move to recall phase
      if (mounted) {
        setState(() {
          _showingPatterns = false;
          _phase = PALPhase.recall;
          _currentPatternToPlace = _currentPatternMap!.keys.first;
        });
      }
      return;
    }

    // Display current pattern for 3 seconds
    if (mounted) {
      setState(() {
        _showingPatterns = true;
      });
    }

    _displayTimer = Timer(const Duration(seconds: 3), () {
      // Move to next pattern
      _currentDisplayingPatternIndex++;
      _showNextPattern();
    });
  }

  void _handleBoxTap(int position) {
    if (_phase != PALPhase.recall || _currentPatternToPlace == null) {
      print('PAL: Tap ignored - phase: $_phase, pattern: $_currentPatternToPlace');
      return;
    }

    print('PAL: Box tapped at position $position');
    final correctPosition = _currentPatternMap![_currentPatternToPlace!];
    final isCorrect = position == correctPosition;
    print('PAL: Correct position: $correctPosition, isCorrect: $isCorrect');

    if (!isCorrect) {
      _totalErrors++;
      _showFeedback(false, position);
      return;
    }

    // Correct! Move to next pattern
    _showFeedback(true, position);

    // Mark this pattern as placed
    _placedPatterns.add(_currentPatternToPlace!);
    print('PAL: Placed pattern $_currentPatternToPlace, all placed: $_placedPatterns');

    final remainingPatterns = _currentPatternMap!.keys
        .where((p) => !_placedPatterns.contains(p))
        .toList();

    print('PAL: Current pattern: $_currentPatternToPlace, All patterns: ${_currentPatternMap!.keys.toList()}, Remaining: $remainingPatterns');

    if (remainingPatterns.isEmpty) {
      // Trial complete - all patterns placed correctly
      print('PAL: Trial complete! Stage: $_currentStage, Trial: $_currentTrial');
      _trialResults.add(true);
      if (_currentTrial == 1) {
        _firstTrialMemoryScore += _currentPatternMap!.length;
      }

      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        print('PAL: Checking progression - Trial: $_currentTrial, Stage: $_currentStage');
        if (_currentTrial >= 3 || _currentStage == 1) {
          // Stage complete
          print('PAL: Stage $_currentStage complete, advancing to next stage');
          _stagesCompleted = _currentStage;
          _startNextStage();
        } else {
          // Repeat with same stage
          print('PAL: Repeating stage $_currentStage');
          _generateTrial();
        }
      });
    } else {
      // Continue with next pattern
      setState(() {
        _currentPatternToPlace = remainingPatterns.first;
      });
    }
  }

  void _showFeedback(bool correct, int position) {
    // Visual feedback implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? 'Correct!' : 'Try again'),
        duration: const Duration(milliseconds: 500),
        backgroundColor: correct ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _completeTest() async {
    final duration = DateTime.now().difference(_testStartTime);
    final accuracy = _trialResults.where((r) => r).length / _trialResults.length * 100;

    _detailedMetrics['stagesCompleted'] = _stagesCompleted;
    _detailedMetrics['firstTrialMemoryScore'] = _firstTrialMemoryScore;
    _detailedMetrics['totalErrors'] = _totalErrors;
    _detailedMetrics['trialResults'] = _trialResults;

    setState(() {
      _phase = PALPhase.results;
    });

    await _saveResults(duration, accuracy);
  }

  Future<void> _saveResults(Duration duration, double accuracy) async {
    final notifier = ref.read(cambridgeAssessmentProvider.notifier);
    final normScore = await _calculateNormScore(accuracy);

    final palMetrics = {
      'stagesCompleted': _stagesCompleted,
      'firstTrialMemoryScore': _firstTrialMemoryScore,
      'totalErrors': _totalErrors.toDouble(),
    };

    final result = CambridgeAssessmentResult(
      testType: CambridgeTestType.pal,
      completedAt: DateTime.now(),
      durationSeconds: duration.inSeconds,
      accuracy: accuracy,
      totalTrials: _trialResults.length,
      correctTrials: _trialResults.where((r) => r).length,
      errorCount: _totalErrors,
      meanLatencyMs: _trialLatencies.isEmpty ? 0 :
          _trialLatencies.reduce((a, b) => a + b) / _trialLatencies.length,
      medianLatencyMs: 0.0,
      specificMetrics: palMetrics,
      normScore: normScore,
      interpretation: _getInterpretation(accuracy, _stagesCompleted),
    );

    await notifier.addAssessment(result);
  }

  Future<double> _calculateNormScore(double accuracy) async {
    // CANTAB PAL age-adjusted z-score calculation
    // Based on normative data from Heinz Nixdorf Recall study
    // Reference: PMC6305838 - Normative data from CANTAB

    // TODO: Implement user age retrieval
    final userAge = 65; // Default age for now

    // Raw score (total errors adjusted is the primary PAL outcome measure)
    final rawScore = _totalErrors.toDouble();

    // Get predicted score based on age using regression model
    final predictedScore = _getPredictedErrorsForAge(userAge);

    // Calculate residual and standardize (z-score)
    final residualSD = _getResidualSD(userAge);
    final zScore = -(rawScore - predictedScore) / residualSD; // Negative because lower errors = better

    return zScore;
  }

  /// Get predicted PAL total errors based on age using regression model
  /// Based on normative data showing ~30% increase in errors between age 60-64 and 65-69
  double _getPredictedErrorsForAge(int? age) {
    if (age == null) return 15.0; // Population mean

    // Linear regression model: errors increase with age
    // Intercept: ~8 errors at age 50
    // Slope: ~0.3 errors per year (based on 30% increase over 5 years)
    const intercept = 8.0;
    const ageCoefficient = 0.3;

    return intercept + (ageCoefficient * (age - 50).clamp(0, 40));
  }

  /// Get residual standard deviation for age group
  double _getResidualSD(int? age) {
    if (age == null) return 8.0; // General population SD

    // SD tends to increase slightly with age
    if (age < 60) return 7.0;
    if (age < 70) return 8.0;
    if (age < 80) return 9.0;
    return 10.0;
  }

  String _getInterpretation(double accuracy, int stages) {
    if (stages >= 7 && accuracy >= 80) {
      return 'Excellent - No memory concerns';
    } else if (stages >= 5 && accuracy >= 65) {
      return 'Good - Normal performance';
    } else if (stages >= 3 && accuracy >= 50) {
      return 'Fair - Mild difficulty with complex patterns';
    } else {
      return 'Impaired - Consider consultation';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAL - Paired Associates Learning'),
        backgroundColor: Colors.purple,
      ),
      body: _buildPhaseContent(),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case PALPhase.introduction:
        return _buildIntroduction();
      case PALPhase.presentation:
        return _buildPresentation();
      case PALPhase.recall:
        return _buildRecall();
      case PALPhase.results:
        return _buildResults();
    }
  }

  Widget _buildIntroduction() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        const Icon(Icons.view_carousel, size: 64, color: Colors.purple),
                        const SizedBox(height: 16),
                        Text(
                          'Paired Associates Learning',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Most sensitive test for early Alzheimer\'s detection',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructionStep(
                          1,
                          'Patterns will appear in boxes',
                          'Watch carefully where each pattern appears',
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          2,
                          'Remember the locations',
                          'The boxes will close after 3 seconds',
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          3,
                          'Place patterns back',
                          'Tap the box where each pattern was shown',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The test gets progressively harder with more patterns. Duration: ~8 minutes.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNextStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Start Test',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresentation() {
    if (_currentPALTrial == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stage $_currentStage of 8',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Trial $_currentTrial',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_showingPatterns)
            CustomCard(
              child: Column(
                children: [
                  Text(
                    'Remember this pattern... (${_currentDisplayingPatternIndex + 1} of ${_patternDisplayOrder.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildPatternGrid(showPatterns: _showingPatterns),
          ),
        ],
      ),
    );
  }

  Widget _buildRecall() {
    if (_currentPALTrial == null || _currentPatternToPlace == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stage $_currentStage of 8',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Errors: $_totalErrors',
                  style: TextStyle(
                    color: _totalErrors > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              children: [
                const Text(
                  'Where was this pattern?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _patternColors[_currentPatternToPlace! % _patternColors.length].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _patternColors[_currentPatternToPlace! % _patternColors.length],
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _patterns[_currentPatternToPlace! % _patterns.length],
                      style: TextStyle(
                        fontSize: 48,
                        color: _patternColors[_currentPatternToPlace! % _patternColors.length],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildPatternGrid(showPatterns: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternGrid({required bool showPatterns}) {
    if (_currentPALTrial == null) return const SizedBox();

    final gridSize = _currentPALTrial!.gridSize;
    final rows = gridSize <= 6 ? 2 : 2;
    final cols = gridSize <= 6 ? 3 : 4;

    // During presentation phase, only show the current pattern being displayed
    int? currentlyDisplayingPattern;
    if (showPatterns && _currentDisplayingPatternIndex < _patternDisplayOrder.length) {
      currentlyDisplayingPattern = _patternDisplayOrder[_currentDisplayingPatternIndex];
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: gridSize,
      itemBuilder: (context, index) {
        final pattern = _currentPatternMap!.entries
            .firstWhere(
              (entry) => entry.value == index,
              orElse: () => const MapEntry(-1, -1),
            )
            .key;

        final hasPattern = pattern != -1;

        // Only show pattern if it's the currently displaying one during presentation
        final shouldShowPattern = showPatterns &&
                                  hasPattern &&
                                  pattern == currentlyDisplayingPattern;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print('PAL: Grid box $index tapped');
              _handleBoxTap(index);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _phase == PALPhase.recall
                      ? Colors.blue[300]!
                      : Colors.grey[300]!,
                  width: _phase == PALPhase.recall ? 3 : 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: shouldShowPattern
                  ? Center(
                      child: Text(
                        _patterns[pattern % _patterns.length],
                        style: TextStyle(
                          fontSize: 48,
                          color: _patternColors[pattern % _patternColors.length],
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    final accuracy = _trialResults.where((r) => r).length / _trialResults.length * 100;
    final interpretation = _getInterpretation(accuracy, _stagesCompleted);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: accuracy >= 70 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Test Complete!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildResultRow('Stages Completed', '$_stagesCompleted / 8'),
                        const Divider(),
                        _buildResultRow('Accuracy', '${accuracy.toStringAsFixed(1)}%'),
                        const Divider(),
                        _buildResultRow('Total Errors', '$_totalErrors'),
                        const Divider(),
                        _buildResultRow('First Trial Score', '$_firstTrialMemoryScore'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interpretation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interpretation,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum PALPhase {
  introduction,
  presentation,
  recall,
  results,
}
