import 'dart:async';
import 'dart:convert';

import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/domain/services/cambridge_test_generator.dart';
import 'package:brain_tests/presentation/providers/cambridge_assessment_provider.dart';
import 'package:brain_tests/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum RVPPhase {
  introduction,
  practice,
  testing,
  results,
}

class RVPTestScreen extends ConsumerStatefulWidget {
  const RVPTestScreen({super.key});

  @override
  ConsumerState<RVPTestScreen> createState() => _RVPTestScreenState();
}

class _RVPTestScreenState extends ConsumerState<RVPTestScreen> {
  RVPPhase _phase = RVPPhase.introduction;
  RVPSequence? _currentSequence;

  int _currentDigitIndex = 0;
  Timer? _digitTimer;

  // Performance metrics
  int _correctDetections = 0;  // Hits
  int _missedTargets = 0;      // Misses
  int _falseAlarms = 0;        // False positives
  final List<int> _reactionTimes = [];
  DateTime? _lastTargetTime;

  // Test configuration
  static const int _testDurationSeconds = 420; // 7 minutes
  static const int _practiceDurationSeconds = 60; // 1 minute practice
  DateTime? _testStartTime;

  @override
  void dispose() {
    _digitTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startPractice() {
    WakelockPlus.enable(); // Keep screen awake during test
    setState(() {
      _phase = RVPPhase.practice;
      _currentSequence = CambridgeTestGenerator.generateRVPSequence(_practiceDurationSeconds);
      _currentDigitIndex = 0;
    });
    _startDigitStream();
  }

  void _startTest() {
    WakelockPlus.enable(); // Keep screen awake during test
    setState(() {
      _phase = RVPPhase.testing;
      _currentSequence = CambridgeTestGenerator.generateRVPSequence(_testDurationSeconds);
      _currentDigitIndex = 0;
      _correctDetections = 0;
      _missedTargets = 0;
      _falseAlarms = 0;
      _reactionTimes.clear();
      _testStartTime = DateTime.now();
    });
    _startDigitStream();
  }

  void _startDigitStream() {
    _digitTimer?.cancel();
    _testStartTime = DateTime.now();
    _scheduleNextDigit();
  }

  void _scheduleNextDigit() {
    if (_currentSequence == null) return;

    if (_currentDigitIndex >= _currentSequence!.digits.length) {
      if (_phase == RVPPhase.practice) {
        // End practice, prompt to start real test
        setState(() {
          _phase = RVPPhase.introduction;
        });
      } else {
        _completeTest();
      }
      return;
    }

    // Calculate when the next digit should appear based on absolute time
    // Do this BEFORE setState to minimize delays
    final nextIndex = _currentDigitIndex + 1;
    final targetTime = _testStartTime!.add(
      Duration(milliseconds: nextIndex * _currentSequence!.intervalMs),
    );
    final now = DateTime.now();
    final delay = targetTime.difference(now);

    // Schedule next digit BEFORE setState to avoid being delayed by rebuild
    _digitTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      _scheduleNextDigit,
    );

    // Update UI after scheduling next timer
    setState(() {
      _currentDigitIndex++;
    });
  }

  void _handleResponse() {
    if (_currentSequence == null || _currentDigitIndex < 3) return;

    // Check if current position (or recent positions) form a target sequence
    final recentIndices = [
      _currentDigitIndex - 3,
      _currentDigitIndex - 2,
      _currentDigitIndex - 1,
    ];

    bool isTarget = false;
    for (final idx in recentIndices) {
      if (idx >= 2 && _currentSequence!.targetIndices.contains(idx)) {
        isTarget = true;
        if (_lastTargetTime != null) {
          final reactionTime = DateTime.now().difference(_lastTargetTime!).inMilliseconds;
          _reactionTimes.add(reactionTime);
        }
        break;
      }
    }

    setState(() {
      if (isTarget) {
        _correctDetections++;
      } else {
        _falseAlarms++;
      }
    });

    _lastTargetTime = DateTime.now();
  }

  void _completeTest() {
    final duration = DateTime.now().difference(_testStartTime!);

    // Calculate total targets
    final totalTargets = _currentSequence!.targetIndices.length;
    _missedTargets = totalTargets - _correctDetections;

    // Calculate metrics
    final accuracy = totalTargets > 0 ? (_correctDetections / totalTargets * 100) : 0.0;

    setState(() {
      _phase = RVPPhase.results;
    });

    _saveResults(duration, accuracy, totalTargets);
  }

  Future<void> _saveResults(Duration duration, double accuracy, int totalTargets) async {
    final notifier = ref.read(cambridgeAssessmentProvider.notifier);

    // Calculate sensitivity (A') and response bias
    final hitRate = totalTargets > 0 ? _correctDetections / totalTargets : 0.0;
    final falseAlarmRate = _currentSequence!.digits.isNotEmpty
        ? _falseAlarms / _currentSequence!.digits.length
        : 0.0;

    final detailedMetrics = {
      'correctDetections': _correctDetections,
      'missedTargets': _missedTargets,
      'falseAlarms': _falseAlarms,
      'totalTargets': totalTargets,
      'hitRate': hitRate,
      'falseAlarmRate': falseAlarmRate,
      'reactionTimes': _reactionTimes,
    };

    final aPrime = 0.5 + ((hitRate - falseAlarmRate) * (1 + hitRate - falseAlarmRate) / (4 * hitRate * (1 - falseAlarmRate)));

    // Add RVP-specific metrics to detailedMetrics
    detailedMetrics['aPrime'] = aPrime;
    detailedMetrics['correctRejections'] = _currentSequence!.digits.length - _falseAlarms;

    final result = CambridgeAssessmentResult(
      testType: CambridgeTestType.rvp,
      completedAt: DateTime.now(),
      durationSeconds: duration.inSeconds,
      accuracy: accuracy,
      totalTrials: totalTargets,
      correctTrials: _correctDetections,
      errorCount: _falseAlarms + _missedTargets,
      meanLatencyMs: _reactionTimes.isEmpty ? 0 :
          _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length,
      medianLatencyMs: _reactionTimes.isEmpty ? 0 : _calculateMedian(_reactionTimes),
      specificMetrics: detailedMetrics,
      normScore: _calculateNormScore(accuracy),
      interpretation: _getInterpretation(accuracy, hitRate),
    );

    await notifier.addAssessment(result);
  }

  double _calculateMedian(List<int> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<int>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  double _calculateNormScore(double accuracy) {
    // Simplified norm score - in production would use age-adjusted norms
    return accuracy;
  }

  String _getInterpretation(double accuracy, double hitRate) {
    if (accuracy >= 80 && hitRate >= 0.75) {
      return 'Excellent - Strong sustained attention';
    } else if (accuracy >= 65 && hitRate >= 0.60) {
      return 'Good - Normal attention performance';
    } else if (accuracy >= 50 && hitRate >= 0.45) {
      return 'Fair - Mild attention difficulties';
    } else {
      return 'Impaired - Significant attention deficits';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RVP - Rapid Visual Processing'),
        backgroundColor: Colors.blue,
      ),
      body: _buildPhaseContent(),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case RVPPhase.introduction:
        return _buildIntroduction();
      case RVPPhase.practice:
        return _buildTestView(isPractice: true);
      case RVPPhase.testing:
        return _buildTestView(isPractice: false);
      case RVPPhase.results:
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
                        const Icon(Icons.visibility, size: 64, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          'Rapid Visual Processing',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test your sustained attention and vigilance',
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
                  const SizedBox(height: 16),
                  _buildInstructionStep(
                    context,
                    1,
                    'Watch the Stream',
                    'A series of digits will appear rapidly in the center of the screen.',
                  ),
                  _buildInstructionStep(
                    context,
                    2,
                    'Detect Target Sequences',
                    'Tap the screen when you see these sequences:\n• 3-5-7\n• 2-4-6',
                  ),
                  _buildInstructionStep(
                    context,
                    3,
                    'Stay Focused',
                    'The test lasts 7 minutes. Try to maintain your attention throughout.',
                  ),
                  _buildInstructionStep(
                    context,
                    4,
                    'Respond Quickly',
                    'Tap as soon as you recognize a target sequence.',
                  ),
                  const SizedBox(height: 24),
                  CustomCard(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We\'ll start with a 1-minute practice session to help you get familiar with the task.',
                            style: Theme.of(context).textTheme.bodySmall,
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
              onPressed: _startPractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Start Practice',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startTest,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Skip to Test',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    int step,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.blue,
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
      ),
    );
  }

  Widget _buildTestView({required bool isPractice}) {
    if (_currentSequence == null || _currentDigitIndex == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentDigit = _currentDigitIndex <= _currentSequence!.digits.length
        ? _currentSequence!.digits[_currentDigitIndex - 1]
        : null;

    return GestureDetector(
      onTap: _handleResponse,
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Status bar
            Container(
              color: Colors.blue.withOpacity(0.9),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPractice ? 'PRACTICE' : 'TEST',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Targets: 3-5-7, 2-4-6',
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (!isPractice)
                    Text(
                      'Hits: $_correctDetections',
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
            // Digit display
            Expanded(
              child: Center(
                child: currentDigit != null
                    ? Text(
                        '$currentDigit',
                        style: const TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            // Response prompt
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 48,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TAP when you see 3-5-7 or 2-4-6',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final totalTargets = _currentSequence?.targetIndices.length ?? 0;
    final accuracy = totalTargets > 0 ? (_correctDetections / totalTargets * 100) : 0.0;
    final hitRate = totalTargets > 0 ? (_correctDetections / totalTargets) : 0.0;

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
                        const Icon(Icons.check_circle, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          'Test Complete!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getInterpretation(accuracy, hitRate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMetricRow('Accuracy', '${accuracy.toStringAsFixed(1)}%'),
                        _buildMetricRow('Correct Detections', '$_correctDetections / $totalTargets'),
                        _buildMetricRow('Missed Targets', '$_missedTargets'),
                        _buildMetricRow('False Alarms', '$_falseAlarms'),
                        if (_reactionTimes.isNotEmpty) ...[
                          const Divider(),
                          _buildMetricRow(
                            'Avg Reaction Time',
                            '${(_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).toStringAsFixed(0)}ms',
                          ),
                          _buildMetricRow(
                            'Median Reaction Time',
                            '${_calculateMedian(_reactionTimes).toStringAsFixed(0)}ms',
                          ),
                        ],
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
                backgroundColor: Colors.blue,
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

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
