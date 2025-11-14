import 'dart:async';
import 'dart:convert';

import 'package:brain_plan/domain/entities/cambridge_assessment.dart';
import 'package:brain_plan/domain/services/cambridge_test_generator.dart';
import 'package:brain_plan/presentation/providers/cambridge_assessment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// OTS (One Touch Stockings of Cambridge) Test Screen - Cambridge CANTAB assessment
/// Tests spatial planning and problem-solving
class OTSTestScreen extends ConsumerStatefulWidget {
  const OTSTestScreen({super.key});

  @override
  ConsumerState<OTSTestScreen> createState() => _OTSTestScreenState();
}

class _OTSTestScreenState extends ConsumerState<OTSTestScreen> {
  OTSPhase _phase = OTSPhase.introduction;
  int _currentProblem = 0;
  final List<int> _problemDifficulties = [1, 2, 2, 3, 3, 4, 4, 5]; // Progression of minimum moves

  OTSTrial? _currentTrial;
  final TextEditingController _answerController = TextEditingController();
  DateTime? _problemStartTime;
  DateTime? _testStartTime;

  final List<OTSResult> _results = [];

  @override
  void dispose() {
    _answerController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _phase = OTSPhase.testing;
      _currentProblem = 0;
      _results.clear();
    });
    WakelockPlus.enable();
    _testStartTime = DateTime.now();
    _startProblem();
  }

  void _startProblem() {
    if (_currentProblem >= _problemDifficulties.length) {
      _completeTest();
      return;
    }

    final difficulty = _problemDifficulties[_currentProblem];
    _currentTrial = CambridgeTestGenerator.generateOTSTrial(difficulty);
    _problemStartTime = DateTime.now();

    setState(_answerController.clear);
  }

  void _submitAnswer() {
    if (_answerController.text.isEmpty) return;

    final userAnswer = int.tryParse(_answerController.text);
    if (userAnswer == null) return;

    final thinkingTime = DateTime.now().difference(_problemStartTime!).inMilliseconds;
    final isCorrect = userAnswer == _currentTrial!.minimumMoves;

    _results.add(OTSResult(
      problemNumber: _currentProblem + 1,
      minimumMoves: _currentTrial!.minimumMoves,
      userAnswer: userAnswer,
      correct: isCorrect,
      thinkingTimeMs: thinkingTime,
    ));

    // Move to next problem
    _currentProblem++;
    _startProblem();
  }

  Future<void> _completeTest() async {
    setState(() {
      _phase = OTSPhase.results;
    });
    WakelockPlus.disable();

    // Save to database
    await _saveResults();
  }

  Future<void> _saveResults() async {
    if (_results.isEmpty || _testStartTime == null) return;

    final correctCount = _results.where((r) => r.correct).length;
    final accuracy = (correctCount / _results.length) * 100;
    final avgThinkingTime = _results.map((r) => r.thinkingTimeMs).reduce((a, b) => a + b) / _results.length;
    final duration = DateTime.now().difference(_testStartTime!).inSeconds;

    // Calculate median thinking time
    final sortedTimes = _results.map((r) => r.thinkingTimeMs).toList()..sort();
    final medianTime = sortedTimes[sortedTimes.length ~/ 2].toDouble();

    // Store test-specific metrics in JSON
    final specificMetrics = jsonEncode({
      'totalProblems': _results.length,
      'problemsByDifficulty': {
        for (var i = 1; i <= 5; i++)
          i.toString(): {
            'count': _results.where((r) => _problemDifficulties[r.problemNumber - 1] == i).length,
            'correct': _results.where((r) => _problemDifficulties[r.problemNumber - 1] == i && r.correct).length,
          }
      },
      'averageError': _results.map((r) => (r.userAnswer - r.minimumMoves).abs()).reduce((a, b) => a + b) / _results.length,
      'perfectSolutions': _results.where((r) => r.correct).length,
    });

    try {
      final notifier = ref.read(cambridgeAssessmentProvider.notifier);
      final metrics = jsonDecode(specificMetrics) as Map<String, dynamic>;

      final result = CambridgeAssessmentResult(
        testType: CambridgeTestType.soc,
        completedAt: DateTime.now(),
        durationSeconds: duration,
        accuracy: accuracy,
        totalTrials: _results.length,
        correctTrials: correctCount,
        errorCount: _results.length - correctCount,
        meanLatencyMs: avgThinkingTime,
        medianLatencyMs: medianTime,
        specificMetrics: metrics,
        normScore: accuracy,
        interpretation: _getInterpretation(accuracy),
      );

      await notifier.addAssessment(result);
    } catch (e) {
      debugPrint('Error saving OTS results: $e');
    }
  }

  String _getInterpretation(double accuracy) {
    if (accuracy >= 87.5) return 'Excellent spatial planning ability'; // 7+/8 correct
    if (accuracy >= 75) return 'Good spatial planning ability'; // 6/8 correct
    if (accuracy >= 62.5) return 'Average spatial planning ability'; // 5/8 correct
    if (accuracy >= 50) return 'Below average spatial planning ability'; // 4/8 correct
    return 'Impaired spatial planning ability';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockings of Cambridge (OTS)'),
        backgroundColor: Colors.teal[700],
      ),
      body: SafeArea(
        child: _buildPhaseContent(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case OTSPhase.introduction:
        return _buildIntroduction();
      case OTSPhase.testing:
        return _buildTestScreen();
      case OTSPhase.results:
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
            'Stockings of Cambridge',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
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
                    '• You will see two displays: INITIAL and GOAL\\n'
                    '• Each has 3 stockings with colored balls\\n'
                    '• Determine the minimum number of moves to match the goal\\n'
                    '• You can only move one ball at a time\\n'
                    '• You can only move the top ball from each stocking\\n'
                    '• Enter your answer and tap Submit\\n'
                    '• Problems will increase in difficulty',
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
              backgroundColor: Colors.teal[700],
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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.teal[700],
            child: Column(
              children: [
                const Text(
                  'OTS TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Problem ${_currentProblem + 1} of ${_problemDifficulties.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Initial and Goal configurations
          Row(
            children: [
              // Initial configuration
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Initial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConfiguration(_currentTrial!.initialConfiguration),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward, size: 40, color: Colors.teal[700]),

              // Goal configuration
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConfiguration(_currentTrial!.goalConfiguration),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Answer input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Text(
                  'What is the minimum number of moves?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[700]!, width: 3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguration(List<List<int>> config) {
    final colors = [Colors.red, Colors.blue, Colors.green];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (stockingIndex) {
        final stocking = config[stockingIndex];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Balls in stocking (top to bottom)
            ...stocking.map((ballColor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[ballColor],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Stocking base
            Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                border: Border.all(color: Colors.grey[600]!, width: 2),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildResults() {
    final correctCount = _results.where((r) => r.correct).length;
    final avgThinkingTime = _results.isEmpty
        ? 0.0
        : _results.map((r) => r.thinkingTimeMs).reduce((a, b) => a + b) / _results.length;

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
              color: Colors.teal[700],
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
                    'Problems Completed: ${_results.length}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Correct Answers: $correctCount/${_results.length}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Average Thinking Time: ${(avgThinkingTime / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This test measures spatial planning and problem-solving ability. '
                    'Higher accuracy and faster thinking times indicate better executive function.',
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
              backgroundColor: Colors.teal[700],
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

enum OTSPhase {
  introduction,
  testing,
  results,
}

class OTSResult {

  OTSResult({
    required this.problemNumber,
    required this.minimumMoves,
    required this.userAnswer,
    required this.correct,
    required this.thinkingTimeMs,
  });
  final int problemNumber;
  final int minimumMoves;
  final int userAnswer;
  final bool correct;
  final int thinkingTimeMs;
}
