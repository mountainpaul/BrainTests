import 'dart:async';
import 'dart:convert';

import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/domain/services/cambridge_test_generator.dart';
import 'package:brain_tests/presentation/providers/cambridge_assessment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// RTI (Reaction Time) Test Screen - Cambridge CANTAB assessment
/// Measures simple and choice reaction times
class RTITestScreen extends ConsumerStatefulWidget {
  const RTITestScreen({super.key});

  @override
  ConsumerState<RTITestScreen> createState() => _RTITestScreenState();
}

class _RTITestScreenState extends ConsumerState<RTITestScreen> {
  RTIPhase _phase = RTIPhase.introduction;
  RTIMode? _currentMode;
  RTITrial? _currentTrial;
  Timer? _stimulusTimer;
  DateTime? _stimulusAppearTime;
  DateTime? _releaseTime;

  final List<RTIResult> _results = [];
  int _currentTrialNumber = 0;
  final int _totalTrials = 5; // 5 trials per mode
  DateTime? _testStartTime;

  bool _isStimulusVisible = false;
  bool _waitingForRelease = false;

  @override
  void dispose() {
    _stimulusTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startMode(RTIMode mode) {
    setState(() {
      _currentMode = mode;
      _phase = RTIPhase.testing;
      _currentTrialNumber = 0;
      _results.clear();
    });
    WakelockPlus.enable();
    _testStartTime = DateTime.now();
    _startNextTrial();
  }

  void _startNextTrial() {
    if (_currentTrialNumber >= _totalTrials) {
      _completeTest();
      return;
    }

    _currentTrialNumber++;
    _currentTrial = CambridgeTestGenerator.generateRTITrial(
      _currentMode!,
      _currentTrialNumber,
    );

    setState(() {
      _isStimulusVisible = false;
      _waitingForRelease = false;
    });

    // Wait for random delay before showing stimulus
    _stimulusTimer?.cancel();
    _stimulusTimer = Timer(
      Duration(milliseconds: _currentTrial!.delayMs),
      _showStimulus,
    );
  }

  void _showStimulus() {
    setState(() {
      _isStimulusVisible = true;
      _stimulusAppearTime = DateTime.now();
    });
  }

  void _handleTap(int position) {
    if (!_isStimulusVisible) return;

    final responseTime = DateTime.now();
    final reactionTimeMs = responseTime.difference(_stimulusAppearTime!).inMilliseconds;

    // Record result
    final isCorrect = (_currentMode == RTIMode.simple) ||
                      (position == _currentTrial!.targetPosition);

    _results.add(RTIResult(
      trialNumber: _currentTrialNumber,
      mode: _currentMode!,
      reactionTimeMs: reactionTimeMs,
      correct: isCorrect,
      targetPosition: _currentTrial!.targetPosition,
      responsePosition: position,
    ));

    // Move to next trial
    _startNextTrial();
  }

  Future<void> _completeTest() async {
    setState(() {
      _phase = RTIPhase.results;
    });
    WakelockPlus.disable();

    // Save to database
    await _saveResults();
  }

  Future<void> _saveResults() async {
    if (_results.isEmpty || _testStartTime == null) return;

    final correctCount = _results.where((r) => r.correct).length;
    final accuracy = (correctCount / _results.length) * 100;
    final avgReactionTime = _results.map((r) => r.reactionTimeMs).reduce((a, b) => a + b) / _results.length;
    final duration = DateTime.now().difference(_testStartTime!).inSeconds;

    // Calculate median reaction time
    final sortedTimes = _results.map((r) => r.reactionTimeMs).toList()..sort();
    final medianTime = sortedTimes[sortedTimes.length ~/ 2].toDouble();

    // Store test-specific metrics in JSON
    final specificMetrics = jsonEncode({
      'mode': _currentMode.toString().split('.').last,
      'totalTrials': _results.length,
      'simpleTrials': _results.where((r) => r.mode == RTIMode.simple).length,
      'choiceTrials': _results.where((r) => r.mode == RTIMode.choice).length,
      'averageReactionTime': avgReactionTime,
      'fastestReaction': _results.map((r) => r.reactionTimeMs).reduce((a, b) => a < b ? a : b),
      'slowestReaction': _results.map((r) => r.reactionTimeMs).reduce((a, b) => a > b ? a : b),
    });

    try {
      final notifier = ref.read(cambridgeAssessmentProvider.notifier);

      // Parse metrics back to use in entity
      final metrics = jsonDecode(specificMetrics) as Map<String, dynamic>;

      // Add RTI-specific metrics to the metrics map
      final metricsMap = jsonDecode(specificMetrics) as Map<String, dynamic>;
      metricsMap['simpleReactionTime'] = avgReactionTime;
      metricsMap['choiceReactionTime'] = avgReactionTime;
      metricsMap['movementTime'] = 0.0;
      metricsMap['anticipations'] = 0;

      final result = CambridgeAssessmentResult(
        testType: CambridgeTestType.rti,
        completedAt: DateTime.now(),
        durationSeconds: duration,
        accuracy: accuracy,
        totalTrials: _results.length,
        correctTrials: correctCount,
        errorCount: _results.length - correctCount,
        meanLatencyMs: avgReactionTime,
        medianLatencyMs: medianTime,
        specificMetrics: metricsMap,
        normScore: _getNormalizedScore(avgReactionTime),
        interpretation: _getInterpretation(avgReactionTime),
      );

      await notifier.addAssessment(result);
    } catch (e) {
      debugPrint('Error saving RTI results: $e');
    }
  }

  double _getNormalizedScore(double avgReactionTime) {
    // Lower reaction time is better, so invert the score
    // Typical reaction times: 200-300ms excellent, 300-400ms good, 400-500ms average
    if (avgReactionTime < 250) return 100.0;
    if (avgReactionTime < 350) return 85.0;
    if (avgReactionTime < 450) return 70.0;
    if (avgReactionTime < 550) return 55.0;
    return 40.0;
  }

  String _getInterpretation(double avgReactionTime) {
    if (avgReactionTime < 250) return 'Excellent reaction time';
    if (avgReactionTime < 350) return 'Good reaction time';
    if (avgReactionTime < 450) return 'Average reaction time';
    if (avgReactionTime < 550) return 'Below average reaction time';
    return 'Slow reaction time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reaction Time (RTI)'),
        backgroundColor: Colors.blue[700],
      ),
      body: SafeArea(
        child: _buildPhaseContent(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case RTIPhase.introduction:
        return _buildIntroduction();
      case RTIPhase.testing:
        return _buildTestScreen();
      case RTIPhase.results:
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
            'Reaction Time',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
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
                    '• Tap as quickly as possible when the yellow circle appears\n'
                    '• Simple mode: One location only\n'
                    '• Choice mode: Tap the correct position out of 5\n'
                    '• The circle will appear after a random delay\n'
                    '• Complete 5 trials',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _startMode(RTIMode.simple),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Simple Reaction Time'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _startMode(RTIMode.choice),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Choice Reaction Time'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestScreen() {
    return Column(
      children: [
        // Mode label
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: _currentMode == RTIMode.simple ? Colors.green : Colors.orange,
          child: Text(
            _currentMode == RTIMode.simple ? 'SIMPLE RT' : 'CHOICE RT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Trial counter
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Trial $_currentTrialNumber of $_totalTrials',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),

        Expanded(
          child: _currentMode == RTIMode.simple
              ? _buildSimpleMode()
              : _buildChoiceMode(),
        ),

        // Instruction text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _isStimulusVisible
                ? 'TAP NOW!'
                : 'Wait for the yellow circle...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isStimulusVisible ? Colors.red : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleMode() {
    return Center(
      child: GestureDetector(
        onTap: () => _handleTap(0),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isStimulusVisible ? Colors.yellow : Colors.grey[300],
            border: Border.all(color: Colors.grey[600]!, width: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceMode() {
    return Center(
      child: Wrap(
        spacing: 30,
        runSpacing: 30,
        alignment: WrapAlignment.center,
        children: List.generate(5, (index) {
          final isTarget = _isStimulusVisible &&
                          index == _currentTrial!.targetPosition;

          return GestureDetector(
            onTap: () => _handleTap(index),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTarget ? Colors.yellow : Colors.grey[300],
                border: Border.all(color: Colors.grey[600]!, width: 3),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResults() {
    final correctResults = _results.where((r) => r.correct).toList();
    final avgReactionTime = correctResults.isEmpty
        ? 0.0
        : correctResults.map((r) => r.reactionTimeMs).reduce((a, b) => a + b) /
            correctResults.length;

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
              color: Colors.blue[700],
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
                    'Mode: ${_currentMode == RTIMode.simple ? 'Simple' : 'Choice'}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Correct Responses: ${correctResults.length}/$_totalTrials',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Average Reaction Time: ${avgReactionTime.toStringAsFixed(0)} ms',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
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

enum RTIPhase {
  introduction,
  testing,
  results,
}

class RTIResult {

  RTIResult({
    required this.trialNumber,
    required this.mode,
    required this.reactionTimeMs,
    required this.correct,
    required this.targetPosition,
    required this.responsePosition,
  });
  final int trialNumber;
  final RTIMode mode;
  final int reactionTimeMs;
  final bool correct;
  final int targetPosition;
  final int responsePosition;
}
