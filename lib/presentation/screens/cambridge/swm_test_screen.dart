import 'dart:async';
import 'dart:convert';

import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/domain/services/cambridge_test_generator.dart';
import 'package:brain_tests/presentation/providers/cambridge_assessment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// SWM (Spatial Working Memory) Test Screen
/// Tests working memory and strategy use
class SWMTestScreen extends ConsumerStatefulWidget {
  const SWMTestScreen({super.key});

  @override
  ConsumerState<SWMTestScreen> createState() => _SWMTestScreenState();
}

class _SWMTestScreenState extends ConsumerState<SWMTestScreen> {
  SWMPhase _phase = SWMPhase.introduction;
  int _currentStage = 0;
  final List<int> _stages = [3, 4, 6, 8]; // Number of boxes per stage

  SWMTrial? _currentTrial;
  final List<int> _searchSequence = []; // Complete search history for metrics
  final List<int> _collectedTokens = []; // Tokens collected (for UI display)
  final Set<int> _openedBoxes = {}; // Boxes currently being displayed
  final Map<int, bool> _openBoxStatus = {}; // Status of open boxes (true=Star/Success, false=X/Error/Empty)

  // New State for sequential logic
  int _currentTokenIndex = 0; // Which token in the sequence we are looking for
  final Set<int> _foundBoxes = {}; // Boxes that have already yielded a token (don't go back!)
  final Set<int> _currentSearchVisited = {}; // Boxes visited in CURRENT search (don't revisit!)
  int _stageBetweenErrors = 0; // Re-visiting box in same search
  int _stageWithinErrors = 0;  // Re-visiting box that already had token

  final List<SWMResult> _results = [];
  Timer? _animationTimer;
  DateTime? _testStartTime;

  @override
  void dispose() {
    _animationTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _phase = SWMPhase.testing;
      _currentStage = 0;
      _results.clear();
    });
    WakelockPlus.enable();
    _testStartTime = DateTime.now();
    _startStage();
  }

  void _startStage() {
    final numBoxes = _stages[_currentStage];
    _currentTrial = CambridgeTestGenerator.generateSWMTrial(numBoxes);

    setState(() {
      _searchSequence.clear();
      _collectedTokens.clear();
      _openedBoxes.clear();
      _openBoxStatus.clear();

      // Reset sequential logic state
      _currentTokenIndex = 0;
      _foundBoxes.clear();
      _currentSearchVisited.clear();
      _stageBetweenErrors = 0;
      _stageWithinErrors = 0;
    });
  }

  void _handleBoxTap(int position) {
    if (_phase != SWMPhase.testing) return;
    if (_openedBoxes.contains(position)) return; // Currently being displayed

    _searchSequence.add(position);

    bool isError = false;
    bool isFound = false;

    // Check for Within Error (Double Error) - Re-visiting a box that already had a token
    if (_foundBoxes.contains(position)) {
      _stageWithinErrors++;
      isError = true;
    }
    // Check for Between Error - Re-visiting a box in the current search sequence
    else if (_currentSearchVisited.contains(position)) {
      _stageBetweenErrors++;
      isError = true;
    } else {
      // Valid search move
      _currentSearchVisited.add(position);
    }

    if (!isError) {
      // Check if this box contains the CURRENT target token
      // The token is ONLY in one specific box at a time, defined by the sequence
      if (_currentTrial != null && position == _currentTrial!.tokenPositions[_currentTokenIndex]) {
        isFound = true;
      }
    }

    setState(() {
      _openedBoxes.add(position);
      _openBoxStatus[position] = isFound; // True = Star, False = X

      if (isFound) {
        _collectedTokens.add(position);
        _foundBoxes.add(position);

        // SUCCESS! Token found.
        // Reset for next search:
        // 1. Clear visited history for the *next* search (new search starts now)
        // 2. Advance index to look for next token
        _currentSearchVisited.clear();
        _currentTokenIndex++;
      }
    });

    // Close the box after a brief display (500ms)
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _openedBoxes.remove(position);
        _openBoxStatus.remove(position);

        // Check if all tokens found
        if (_collectedTokens.length == _currentTrial!.tokensToFind) {
          _completeStage();
        }
      });
    });
  }

  void _completeStage() {
    // Calculate metrics for this stage
    // Use the tracked errors instead of recalculating
    final strategyScore = _calculateStrategyScore();

    _results.add(SWMResult(
      stage: _currentStage + 1,
      numBoxes: _stages[_currentStage],
      betweenErrors: _stageBetweenErrors, // Use tracked errors
      strategyScore: strategyScore,
      totalSearches: _searchSequence.length,
    ));

    // Move to next stage or complete test
    if (_currentStage < _stages.length - 1) {
      setState(() {
        _currentStage++;
      });
      _startStage();
    } else {
      _completeTest();
    }
  }

  double _calculateStrategyScore() {
    // Lower is better: measures sequential search efficiency (1-46 scale)
    if (_searchSequence.isEmpty) return 46.0;

    // Simple heuristic: reward sequential searching
    int sequentialCount = 0;
    for (int i = 0; i < _searchSequence.length - 1; i++) {
      if ((_searchSequence[i + 1] - _searchSequence[i]).abs() == 1) {
        sequentialCount++;
      }
    }

    final efficiency = _searchSequence.length > 1
        ? sequentialCount / (_searchSequence.length - 1)
        : 0.0;

    return 46.0 * (1.0 - efficiency);
  }

  Future<void> _completeTest() async {
    setState(() {
      _phase = SWMPhase.results;
    });
    WakelockPlus.disable();

    // Save to database
    await _saveResults();
  }

  Future<void> _saveResults() async {
    if (_results.isEmpty || _testStartTime == null) return;

    final totalErrors = _results.map((r) => r.betweenErrors).reduce((a, b) => a + b);
    final avgStrategyScore = _results.map((r) => r.strategyScore).reduce((a, b) => a + b) / _results.length;
    final totalSearches = _results.map((r) => r.totalSearches).reduce((a, b) => a + b);
    final duration = DateTime.now().difference(_testStartTime!).inSeconds;

    // Calculate accuracy (inverse of errors - more errors = lower accuracy)
    final maxPossibleErrors = totalSearches; // Worst case: every search is an error
    final accuracy = maxPossibleErrors > 0
        ? ((maxPossibleErrors - totalErrors) / maxPossibleErrors) * 100
        : 100.0;

    // Store test-specific metrics in JSON
    final specificMetrics = jsonEncode({
      'totalStages': _results.length,
      'stageResults': _results.map((r) => {
        'stage': r.stage,
        'numBoxes': r.numBoxes,
        'betweenErrors': r.betweenErrors,
        'strategyScore': r.strategyScore,
        'totalSearches': r.totalSearches,
      }).toList(),
      'totalBetweenErrors': totalErrors,
      'averageStrategyScore': avgStrategyScore,
      'totalSearches': totalSearches,
    });

    try {
      final notifier = ref.read(cambridgeAssessmentProvider.notifier);
      final metrics = jsonDecode(specificMetrics) as Map<String, dynamic>;

      // Metrics already include all SWM-specific data
      final metricsMap = jsonDecode(specificMetrics) as Map<String, dynamic>;

      final result = CambridgeAssessmentResult(
        testType: CambridgeTestType.swm,
        completedAt: DateTime.now(),
        durationSeconds: duration,
        accuracy: accuracy,
        totalTrials: _results.length,
        correctTrials: _results.where((r) => r.betweenErrors == 0).length,
        errorCount: totalErrors,
        meanLatencyMs: (duration * 1000 / totalSearches).roundToDouble(),
        medianLatencyMs: avgStrategyScore,
        specificMetrics: metricsMap,
        normScore: _getNormalizedScore(totalErrors, avgStrategyScore),
        interpretation: _getInterpretation(totalErrors, avgStrategyScore),
      );

      await notifier.addAssessment(result);
    } catch (e) {
      debugPrint('Error saving SWM results: $e');
    }
  }

  double _getNormalizedScore(int totalErrors, double avgStrategyScore) {
    // Lower errors and lower strategy score is better
    final errorScore = totalErrors <= 2 ? 100.0 : totalErrors <= 5 ? 80.0 : totalErrors <= 10 ? 60.0 : 40.0;
    final strategyScoreNorm = avgStrategyScore < 10 ? 100.0 : avgStrategyScore < 20 ? 80.0 : avgStrategyScore < 30 ? 60.0 : 40.0;
    return (errorScore + strategyScoreNorm) / 2;
  }

  String _getInterpretation(int totalErrors, double avgStrategyScore) {
    if (totalErrors <= 2 && avgStrategyScore < 15) return 'Excellent spatial working memory and strategy use';
    if (totalErrors <= 5 && avgStrategyScore < 25) return 'Good spatial working memory and strategy use';
    if (totalErrors <= 10 && avgStrategyScore < 35) return 'Average spatial working memory and strategy use';
    if (totalErrors <= 15) return 'Below average spatial working memory';
    return 'Impaired spatial working memory';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spatial Working Memory (SWM)'),
        backgroundColor: Colors.purple[700],
      ),
      body: SafeArea(
        child: _buildPhaseContent(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case SWMPhase.introduction:
        return _buildIntroduction();
      case SWMPhase.testing:
        return _buildTestScreen();
      case SWMPhase.results:
        return _buildResults();
    }
  }

  Widget _buildIntroduction() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Spatial Working Memory',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• Search for tokens hidden in boxes\n'
                    '• Find tokens one by one to fill the column\n'
                    '• CRITICAL: Once a token is found in a box, that box will NOT be used again in this trial\n'
                    '• Do not search boxes that have already given you a token\n'
                    '• Avoid searching the same empty box twice while looking for a token\n'
                    '• Use a systematic search strategy to avoid errors',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestScreen() {
    if (_currentTrial == null) return const SizedBox();

    return Row(
      children: [
        // Left side: Box grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.purple[700],
                child: Column(
                  children: [
                    const Text(
                      'SWM TEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stage ${_currentStage + 1} of ${_stages.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Box grid
              Expanded(
                child: Center(
                  child: _buildBoxGrid(),
                ),
              ),

              // Instruction text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Tap boxes to search for tokens',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Right side: Token collection column
        Container(
          width: 80,
          color: Colors.grey[100],
          child: _buildTokenColumn(),
        ),
      ],
    );
  }

  Widget _buildBoxGrid() {
    // Fixed "random" positions (x, y relative 0.0-1.0)
    // These ensure boxes don't overlap and look scattered like the original SWM test
    final List<Offset> slotPositions = [
      const Offset(0.15, 0.10), // Top Left
      const Offset(0.75, 0.15), // Top Right
      const Offset(0.45, 0.30), // Upper Middle
      const Offset(0.10, 0.45), // Middle Left
      const Offset(0.85, 0.50), // Middle Right
      const Offset(0.30, 0.65), // Bottom Left
      const Offset(0.60, 0.80), // Bottom Center
      const Offset(0.80, 0.25), // High Right
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Dynamic box size: make them large enough but ensure they don't overlap
        // Use the smaller dimension to guide size
        final minDim = width < height ? width : height;
        final boxSize = minDim / 55; // Reduced to 1/10th of original size

        return Stack(
          children: _currentTrial!.boxPositions.map((position) {
            // Map position index (0-7) to a coordinate slot
            final slotIndex = position % slotPositions.length;
            final relPos = slotPositions[slotIndex];

            // Calculate absolute position
            // Subtract boxSize to ensure it stays within bounds at 1.0
            final left = relPos.dx * (width - boxSize);
            final top = relPos.dy * (height - boxSize);

            final isCurrentlyOpen = _openedBoxes.contains(position);

            // Visual feedback logic
            final bool showToken = isCurrentlyOpen && (_openBoxStatus[position] == true);
            final bool showEmpty = isCurrentlyOpen && (_openBoxStatus[position] == false);

            return Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () => _handleBoxTap(position),
                child: Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: isCurrentlyOpen
                        ? (showToken ? Colors.yellow[100] : Colors.red[50])
                        : Colors.purple[100],
                    border: Border.all(
                      color: Colors.purple[700]!,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: showToken
                        ? Icon(Icons.star, size: boxSize * 0.5, color: Colors.yellow[700])
                        : (showEmpty
                            ? Icon(Icons.close, size: boxSize * 0.4, color: Colors.red[700])
                            : null),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTokenColumn() {
    final tokensToFind = _currentTrial!.tokensToFind;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Tokens',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(tokensToFind, (index) {
                final found = index < _collectedTokens.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: found ? Colors.yellow[700] : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: found
                        ? const Icon(Icons.star, color: Colors.white, size: 30)
                        : null,
                  ),
                );
              }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${_collectedTokens.length}/$tokensToFind',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final totalBetweenErrors = _results.fold<int>(0, (sum, r) => sum + r.betweenErrors);
    final avgStrategyScore = _results.isEmpty
        ? 0.0
        : _results.map((r) => r.strategyScore).reduce((a, b) => a + b) / _results.length;
    final totalSearches = _results.fold<int>(0, (sum, r) => sum + r.totalSearches);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Test Complete',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stages Completed: ${_results.length}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Total Between Errors: $totalBetweenErrors',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Average Strategy Score: ${avgStrategyScore.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Total Searches: $totalSearches',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lower strategy scores indicate better sequential search patterns. '
                    'Between-errors occur when you search the same box twice.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

enum SWMPhase {
  introduction,
  testing,
  results,
}

class SWMResult {

  SWMResult({
    required this.stage,
    required this.numBoxes,
    required this.betweenErrors,
    required this.strategyScore,
    required this.totalSearches,
  });
  final int stage;
  final int numBoxes;
  final int betweenErrors;
  final double strategyScore;
  final int totalSearches;
}
