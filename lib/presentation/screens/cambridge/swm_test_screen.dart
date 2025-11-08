import 'dart:async';
import 'dart:convert';

import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/cambridge_test_generator.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// SWM (Spatial Working Memory) Test Screen - Cambridge CANTAB assessment
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
  final Set<int> _searchedBoxes = {}; // Track which boxes have been searched (no visual cue)
  final List<int> _collectedTokens = []; // Tokens collected (for UI display)
  final Set<int> _openedBoxes = {}; // Boxes currently being displayed

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
      _searchedBoxes.clear();
      _collectedTokens.clear();
      _openedBoxes.clear();
    });
  }

  void _handleBoxTap(int position) {
    if (_phase != SWMPhase.testing) return;
    if (_openedBoxes.contains(position)) return; // Currently being displayed

    // Record the search
    _searchSequence.add(position);
    _searchedBoxes.add(position);

    // Check if this box contains a token
    final hasToken = _currentTrial!.tokenPositions.contains(position);

    // Show the box contents temporarily
    setState(() {
      _openedBoxes.add(position);

      if (hasToken) {
        _collectedTokens.add(position);
      }
    });

    // Close the box after a brief display (500ms)
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _openedBoxes.remove(position);

        // Check if all tokens found
        if (_collectedTokens.length == _currentTrial!.tokensToFind) {
          _completeStage();
        }
      });
    });
  }

  void _completeStage() {
    // Calculate metrics for this stage
    final betweenErrors = _calculateBetweenErrors();
    final strategyScore = _calculateStrategyScore();

    _results.add(SWMResult(
      stage: _currentStage + 1,
      numBoxes: _stages[_currentStage],
      betweenErrors: betweenErrors,
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

  int _calculateBetweenErrors() {
    // Count revisits to boxes already searched
    int errors = 0;
    final searched = <int>{};

    for (final pos in _searchSequence) {
      if (searched.contains(pos)) {
        errors++; // Revisited a box
      }
      searched.add(pos);
    }

    return errors;
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
      final db = ref.read(databaseProvider);
      await db.into(db.cambridgeAssessmentTable).insert(
        CambridgeAssessmentTableCompanion.insert(
          testType: CambridgeTestType.swm,
          durationSeconds: duration,
          accuracy: accuracy,
          totalTrials: _results.length,
          correctTrials: _results.where((r) => r.betweenErrors == 0).length,
          errorCount: totalErrors,
          meanLatencyMs: (duration * 1000 / totalSearches).roundToDouble(), // Average time per search
          medianLatencyMs: avgStrategyScore, // Use strategy score as a proxy
          normScore: _getNormalizedScore(totalErrors, avgStrategyScore),
          interpretation: _getInterpretation(totalErrors, avgStrategyScore),
          specificMetrics: specificMetrics,
          completedAt: DateTime.now(),
        ),
      );
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
                    '• NOT every box contains a token\n'
                    '• Find tokens by process of elimination\n'
                    '• Tokens will fill the column on the right\n'
                    '• Remember which boxes you have already searched\n'
                    '• Use a systematic search strategy\n'
                    '• Progress through stages with more boxes (3, 4, 6, 8)',
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
    final numBoxes = _currentTrial!.numBoxes;

    // Determine grid layout based on number of boxes
    final boxSize = numBoxes <= 4 ? 120.0 : 100.0;

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _currentTrial!.boxPositions.map((position) {
        final isCurrentlyOpen = _openedBoxes.contains(position);
        final hasToken = _currentTrial!.tokenPositions.contains(position);
        final showToken = isCurrentlyOpen && hasToken;
        final showEmpty = isCurrentlyOpen && !hasToken;

        // Visual states:
        // 1. Yellow with star = currently showing token
        // 2. Red with X = currently showing empty
        // 3. Purple = closed (all boxes look the same when closed - user must remember!)

        return GestureDetector(
          onTap: () => _handleBoxTap(position),
          child: Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: isCurrentlyOpen
                  ? (hasToken ? Colors.yellow[100] : Colors.red[50])
                  : Colors.purple[100],
              border: Border.all(
                color: Colors.purple[700]!,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: showToken
                  ? Icon(Icons.star, size: 50, color: Colors.yellow[700])
                  : (showEmpty
                      ? Icon(Icons.close, size: 40, color: Colors.red[700])
                      : null),
            ),
          ),
        );
      }).toList(),
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
