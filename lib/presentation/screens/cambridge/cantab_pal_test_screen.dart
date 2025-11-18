import 'dart:async';
import 'dart:convert';
import 'dart:math' as dart_math;

import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/presentation/providers/cambridge_assessment_provider.dart';
import 'package:brain_tests/presentation/screens/cambridge/cantab_pal_config.dart';
import 'package:brain_tests/presentation/screens/cambridge/pal_box_layout.dart';
import 'package:brain_tests/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PAL (Paired Associates Learning) Test Screen
/// Research-validated protocol for visual episodic memory assessment
/// Reference: PMC10879687 - Clinical PAL methodology
///
/// Key features:
/// - 5 stages: 2, 4, 6, 8, 10 pattern-location pairings
/// - Up to 4 attempts per stage
/// - Boxes opened sequentially one-by-one showing pattern or empty
/// - Patterns recalled one-at-a-time (shown in center, indicate box)
/// - On error, boxes re-open showing patterns for retry
/// - Test ends after 4 failed attempts at any stage

/// P1 Fix: Enum for box display modes (replaces magic numbers)
enum BoxDisplayMode {
  none,          // No box shown (initial state)
  sequential,    // Show one box at a time during presentation/reopen
}

class CANTABPALTestScreen extends ConsumerStatefulWidget {
  const CANTABPALTestScreen({super.key});

  @override
  ConsumerState<CANTABPALTestScreen> createState() => _CANTABPALTestScreenState();
}

class _CANTABPALTestScreenState extends ConsumerState<CANTABPALTestScreen> {
  // P2 Fix: Use centralized configuration (no instantiation needed - all static)

  // Test state
  CANTABPALPhase _phase = CANTABPALPhase.introduction;
  int _currentStageIndex = 0; // 0-6 for the 7 stages
  int _currentAttemptInStage = 0; // Total attempts at current stage
  int _failedAttemptsInStage = 0; // Failed attempts at current stage (for termination)

  // Pattern display - CANTAB uses abstract patterns from image files
  // Using pre-designed abstract patterns from assets/patterns/
  final List<String> _patternImages = [
    'assets/patterns/abs1.png',
    'assets/patterns/abs2.png',
    'assets/patterns/abs3.png',
    'assets/patterns/abs4.png',
    'assets/patterns/abs5.png',
    'assets/patterns/abs6.png',
    'assets/patterns/abs7.png',
    'assets/patterns/abs8.png',
  ];

  // Current trial data
  Map<int, int>? _currentPatternMap; // pattern index -> box position
  final Map<int, int> _userAnswers = {}; // pattern index -> selected box position
  bool _showingPatterns = false;
  Timer? _displayTimer;

  // Sequential presentation state
  BoxDisplayMode _boxDisplayMode = BoxDisplayMode.none;
  int? _currentBoxIndex; // Which box (0-9) is currently shown (null = none)
  List<int> _boxOpenSequence = []; // Order in which boxes will open
  int _sequenceIndex = 0; // Current position in open sequence

  // One-at-a-time recall state
  int _currentPatternBeingRecalled = -1; // Which pattern index user is placing
  List<int> _patternRecallOrder = []; // Order in which to recall patterns

  // Scoring - CANTAB standard metrics
  int _firstAttemptMemoryScore = 0; // Correct on first attempt
  int _totalErrorsAdjusted = 0; // Errors accounting for stage difficulty
  final List<int> _errorsPerStage = [0, 0, 0, 0, 0]; // 5 stages
  final List<bool> _stageResults = []; // Did they pass each stage?
  final DateTime _testStartTime = DateTime.now();

  // Per-attempt tracking
  int _currentStageErrors = 0;
  bool _isFirstAttemptThisStage = true;

  // P0 Fix: Disposal safety flag to prevent state updates after disposal
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _displayTimer?.cancel();
    super.dispose();
  }

  int get _currentPatternCount => CANTABPALConfig.getPatternCountForStage(_currentStageIndex);

  void _startTest() {
    setState(() {
      _currentStageIndex = 0;
      _currentAttemptInStage = 0;
      _failedAttemptsInStage = 0;
      _phase = CANTABPALPhase.presentation;
    });
    _generateAttempt();
  }

  void _generateAttempt() {
    _currentAttemptInStage++;

    // Generate random pattern-position mappings
    final patternCount = _currentPatternCount;

    // CRITICAL FIX: We render exactly patternCount boxes in _buildBoxGrid
    // So we must use positions 0 to (patternCount-1) only
    // Simply assign each pattern to a unique box in that range
    final List<int> selectedPositions = List.generate(patternCount, (i) => i)..shuffle();

    // Map patterns to positions (1-to-1 mapping)
    final Map<int, int> patternMap = {};
    for (int i = 0; i < patternCount; i++) {
      patternMap[i] = selectedPositions[i];
    }

    // Create random order for opening boxes (ONLY boxes with patterns, not all boxes)
    // This follows CANTAB protocol: only show boxes that contain patterns
    final boxOpenOrder = List<int>.from(selectedPositions)..shuffle();

    // Create random order for recalling patterns
    final patternOrder = List.generate(patternCount, (i) => i)..shuffle();

    setState(() {
      _currentPatternMap = patternMap;
      _userAnswers.clear();
      _showingPatterns = true;
      _phase = CANTABPALPhase.presentation;

      // Initialize sequential presentation
      _boxOpenSequence = boxOpenOrder;
      _sequenceIndex = 0;
      _boxDisplayMode = BoxDisplayMode.sequential;
      _currentBoxIndex = null;

      // Initialize one-at-a-time recall
      _patternRecallOrder = patternOrder;
      _currentPatternBeingRecalled = -1;
    });

    // Start sequential box opening
    _showNextBox();
  }

  void _showNextBox() {
    // P0 Fix: Early exit if disposed
    if (_isDisposed) return;

    if (_sequenceIndex >= _boxOpenSequence.length) {
      // P1 Fix: Safety check for empty pattern recall order
      if (_patternRecallOrder.isEmpty) {
        debugPrint('CANTAB_PAL Error: Empty pattern recall order');
        return;
      }

      // All boxes have been shown, transition to recall
      setState(() {
        _showingPatterns = false;
        _phase = CANTABPALPhase.recall;
        _currentPatternBeingRecalled = _patternRecallOrder[0]; // Start with first pattern
      });
      return;
    }

    setState(() {
      _boxDisplayMode = BoxDisplayMode.sequential;
      _currentBoxIndex = _boxOpenSequence[_sequenceIndex];
    });

    // Show this box for configured duration (CANTAB standard: 3 seconds)
    _displayTimer?.cancel();
    _displayTimer = Timer(CANTABPALConfig.boxDisplayDuration, () {
      if (_isDisposed || !mounted) return;
      _sequenceIndex++;
      _showNextBox(); // Move to next box
    });
  }

  void _handleBoxSelection(int boxPosition) {
    if (_phase != CANTABPALPhase.recall) return;
    if (_currentPatternBeingRecalled < 0) return;

    // P1 Fix: Input validation for box position
    assert(boxPosition >= 0 && boxPosition < 10,
           'CANTAB_PAL: Invalid box position: $boxPosition. Must be 0-9.');

    if (boxPosition < 0 || boxPosition >= 10) {
      debugPrint('CANTAB_PAL Error: Invalid box position: $boxPosition');
      return;
    }

    // Record the answer for the current pattern
    setState(() {
      _userAnswers[_currentPatternBeingRecalled] = boxPosition;
    });

    // Move to next pattern or check answers if done
    final currentIndex = _patternRecallOrder.indexOf(_currentPatternBeingRecalled);
    if (currentIndex + 1 < _patternRecallOrder.length) {
      // More patterns to recall
      setState(() {
        _currentPatternBeingRecalled = _patternRecallOrder[currentIndex + 1];
      });
    } else {
      // All patterns recalled, check answers
      _checkAnswers();
    }
  }

  void _checkAnswers() {
    // P0 Fix: Add null safety check
    if (_currentPatternMap == null) {
      debugPrint('CANTAB_PAL Error: _currentPatternMap is null in _checkAnswers');
      return;
    }

    bool allCorrect = true;
    int correctCount = 0;

    for (final entry in _currentPatternMap!.entries) {
      final patternIndex = entry.key;
      final correctPosition = entry.value;
      final userPosition = _userAnswers[patternIndex];

      if (userPosition == correctPosition) {
        correctCount++;
      } else {
        allCorrect = false;
      }
    }

    if (allCorrect) {
      // Success! Count first attempt memory score
      if (_isFirstAttemptThisStage) {
        _firstAttemptMemoryScore += correctCount;
      }

      _stageResults.add(true);
      _errorsPerStage[_currentStageIndex] = _currentStageErrors;

      // Advance to next stage
      Timer(CANTABPALConfig.stageTransitionDelay, () {
        if (!mounted) return;
        _advanceToNextStage();
      });
    } else {
      // Error - increment counters
      _currentStageErrors++;
      _totalErrorsAdjusted++;
      _isFirstAttemptThisStage = false;

      // Increment failed attempts counter
      _failedAttemptsInStage++;

      // Check if exceeded 3 failed attempts
      if (_failedAttemptsInStage >= CANTABPALConfig.maxFailedAttempts) {
        // Failed stage - test ends
        _stageResults.add(false);
        _errorsPerStage[_currentStageIndex] = _currentStageErrors;
        _completeTest();
      } else {
        // Show patterns again in boxes (re-open) before retry
        _showFeedback(false, correctCount);
        Timer(CANTABPALConfig.feedbackDuration, () {
          if (!mounted) return;
          _reopenBoxesToShowPatterns();
        });
      }
    }
  }

  void _reopenBoxesToShowPatterns() {
    // CANTAB protocol: Boxes re-open sequentially (not all at once)
    // to remind participant of pattern locations before retry
    setState(() {
      _phase = CANTABPALPhase.presentation;
      _showingPatterns = true;
      _boxDisplayMode = BoxDisplayMode.sequential;
      _sequenceIndex = 0;
      _currentBoxIndex = null;
      // Reuse the same box open sequence and pattern map from this attempt
    });

    // Start sequential box opening again
    _showNextBox();
  }

  void _advanceToNextStage() {
    if (_currentStageIndex >= CANTABPALConfig.totalStages - 1) {
      // Completed all stages!
      _completeTest();
      return;
    }

    setState(() {
      _currentStageIndex++;
      _currentAttemptInStage = 0;
      _failedAttemptsInStage = 0; // Reset for new stage
      _currentStageErrors = 0;
      _isFirstAttemptThisStage = true;
    });

    _generateAttempt();
  }

  void _showFeedback(bool success, int correctCount) {
    final message = success
        ? 'Perfect! Moving to next stage.'
        : 'Not quite right. Got $correctCount/$_currentPatternCount correct. Try again.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: CANTABPALConfig.feedbackDuration,
        backgroundColor: success ? Colors.green : Colors.orange,
      ),
    );
  }

  void _completeTest() {
    final duration = DateTime.now().difference(_testStartTime);
    final stagesCompleted = _stageResults.where((r) => r).length;
    final accuracy = stagesCompleted / CANTABPALConfig.totalStages * 100;

    // Save results BEFORE changing phase to avoid ref disposal issues
    _saveResults(duration, accuracy, stagesCompleted);

    setState(() {
      _phase = CANTABPALPhase.results;
    });
  }

  Future<void> _saveResults(Duration duration, double accuracy, int stagesCompleted) async {
    // Check if still mounted before accessing ref
    if (!mounted) {
      debugPrint('CANTAB_PAL: Not mounted, skipping save');
      return;
    }

    try {
      final notifier = ref.read(cambridgeAssessmentProvider.notifier);

      final detailedMetrics = {
        'stagesCompleted': stagesCompleted,
        'firstAttemptMemoryScore': _firstAttemptMemoryScore,
        'totalErrorsAdjusted': _totalErrorsAdjusted,
        'errorsPerStage': _errorsPerStage,
        'stageResults': _stageResults,
        'testType': 'CANTAB-PAL',
      };

      final result = CambridgeAssessmentResult(
        testType: CambridgeTestType.pal,
        completedAt: DateTime.now(),
        durationSeconds: duration.inSeconds,
        accuracy: accuracy,
        totalTrials: _stageResults.length,
        correctTrials: stagesCompleted,
        errorCount: _totalErrorsAdjusted,
        meanLatencyMs: 0.0,
        medianLatencyMs: 0.0,
        specificMetrics: detailedMetrics,
        normScore: CANTABPALConfig.calculateNormScore(stagesCompleted, _firstAttemptMemoryScore),
        interpretation: CANTABPALConfig.getInterpretation(stagesCompleted, _totalErrorsAdjusted),
      );

      await notifier.addAssessment(result);
      debugPrint('CANTAB_PAL: Results saved successfully');

      // Show success message
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PAL test results saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('CANTAB_PAL Error: Failed to save results: $e');
      debugPrint('Stack trace: $stackTrace');

      // Show user-friendly error message
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save test results. Please try again or contact support.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // P2 Fix: Removed _calculateNormScore and _getInterpretation methods
  // These are now handled by CANTABPALConfig for better maintainability

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAL Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildPhaseContent(),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case CANTABPALPhase.introduction:
        return _buildIntroduction();
      case CANTABPALPhase.presentation:
        return _buildPresentation();
      case CANTABPALPhase.recall:
        return _buildRecall();
      case CANTABPALPhase.results:
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
                        const Icon(Icons.psychology, size: 64, color: Colors.deepPurple),
                        const SizedBox(height: 16),
                        Text(
                          'CANTAB PAL Test',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cambridge Cognition validated protocol for visual episodic memory',
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
                    'How It Works',
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
                          'Watch the boxes open',
                          'Boxes will open in random order revealing patterns',
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          2,
                          'Remember locations',
                          'Memorize which pattern appeared in which box (3 seconds)',
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          3,
                          'Match patterns to boxes',
                          'Tap each pattern, then tap its original box location',
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          4,
                          'Progress through stages',
                          'Progress through 5 stages: 2, 4, 6, 8, and 10 patterns',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You have up to ${CANTABPALConfig.maxFailedAttempts} attempts per stage. Test ends if a stage isn\'t completed.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Duration: ~${CANTABPALConfig.estimatedDuration} depending on performance',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
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
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'Start CANTAB PAL Test',
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
            color: Colors.deepPurple,
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stage ${_currentStageIndex + 1} of 5',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_currentPatternCount pattern${_currentPatternCount > 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Attempt $_currentAttemptInStage of ${CANTABPALConfig.maxFailedAttempts}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      'Errors: $_currentStageErrors',
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentStageErrors > 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_showingPatterns)
            CustomCard(
              child: Column(
                children: [
                  Text(
                    _boxDisplayMode == BoxDisplayMode.sequential && _currentBoxIndex != null
                        ? 'Box ${_sequenceIndex + 1} of ${_boxOpenSequence.length}'
                        : 'Watch carefully...',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _sequenceIndex / _boxOpenSequence.length,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: _buildBoxGrid(showPatterns: _showingPatterns),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecall() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stage ${_currentStageIndex + 1} of ${CANTABPALConfig.totalStages}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_userAnswers.length}/$_currentPatternCount placed',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_currentPatternBeingRecalled >= 0)
            CustomCard(
              child: Column(
                children: [
                  const Text(
                    'Which box had this pattern?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  // Show current pattern in center
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.deepPurple, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(1), // 1 pixel margin
                      color: Colors.white,
                      child: Container(
                        color: Colors.black, // Black background for pattern
                        child: Image.asset(
                          _patternImages[_currentPatternBeingRecalled % _patternImages.length],
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_userAnswers.length < _currentPatternCount)
                    Text(
                      'Pattern ${_userAnswers.length + 1} of $_currentPatternCount',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: _buildBoxGrid(showPatterns: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(_currentPatternCount, (patternIndex) {
        final isPlaced = _userAnswers.containsKey(patternIndex);

        return InkWell(
          onTap: isPlaced ? null : () {
            // Pattern selected, now waiting for box tap
            setState(() {
              // Visual indication that this pattern is being placed
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isPlaced ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPlaced ? Colors.grey : Colors.blue,
                width: 2,
              ),
            ),
            child: Center(
              child: isPlaced
                  ? const Icon(Icons.check, color: Colors.grey, size: 24)
                  : _buildComplexPattern(patternIndex),
            ),
          ),
        );
      }),
    );
  }

  List<Offset> _generateBoxPositions(BoxLayout layout, int patternCount, Size containerSize) {
    // All positions are relative to the container, not screen
    // Container will be centered on screen
    final centerX = containerSize.width * 0.5;
    final centerY = containerSize.height * 0.5;

    switch (layout) {
      case BoxLayout.horizontal:
        // Stage 1 (2 patterns): Horizontal layout centered
        final spacing = containerSize.width * 0.4;
        return [
          Offset(centerX - spacing/2, centerY),
          Offset(centerX + spacing/2, centerY),
        ];

      case BoxLayout.grid:
        // Stage 2 (4 patterns): 2x2 grid centered
        final spacing = 80.0;
        return [
          Offset(centerX - spacing, centerY - spacing), // Top-left
          Offset(centerX + spacing, centerY - spacing), // Top-right
          Offset(centerX - spacing, centerY + spacing), // Bottom-left
          Offset(centerX + spacing, centerY + spacing), // Bottom-right
        ];

      case BoxLayout.circle:
        // Stages 3-7 (5-8 patterns): Circular arrangement centered
        final radius = dart_math.min(containerSize.width, containerSize.height) * 0.35;

        return List.generate(patternCount, (i) {
          final angle = (i * 2 * 3.14159) / patternCount - (3.14159 / 2);
          final x = radius * dart_math.cos(angle);
          final y = radius * dart_math.sin(angle);
          return Offset(centerX + x, centerY + y);
        });
    }
  }

  Widget _buildBoxGrid({required bool showPatterns}) {
    final layout = CANTABPALConfig.getLayoutForStage(_currentStageIndex);
    final patternCount = _currentPatternCount;
    const boxSize = 80.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Container size - consistent across all layouts for centering
    final containerWidth = screenWidth * 0.9;
    final containerHeight = screenHeight * 0.5; // Use half screen height

    // Generate positions based on layout (relative to container)
    final positions = _generateBoxPositions(layout, patternCount, Size(containerWidth, containerHeight));

    return Center(
      child: SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: Stack(
          children: List.generate(patternCount, (boxIndex) {
          final position = positions[boxIndex];
          final left = position.dx - (boxSize / 2);
          final top = position.dy - (boxSize / 2);

          // Check if this box has a pattern
          final patternEntry = _currentPatternMap?.entries.firstWhere(
            (entry) => entry.value == boxIndex,
            orElse: () => const MapEntry(-1, -1),
          );
          final hasPattern = patternEntry != null && patternEntry.key != -1;
          final patternIndex = hasPattern ? patternEntry.key : -1;

          // During presentation, show only the currently-open box (sequential opening)
          final isCurrentBox = _boxDisplayMode == BoxDisplayMode.sequential &&
                                _currentBoxIndex == boxIndex;
          final shouldShow = !showPatterns || isCurrentBox;

          return Positioned(
            left: left,
            top: top,
            child: shouldShow
                ? _buildBox(
                    boxIndex,
                    hasPattern: hasPattern,
                    patternIndex: patternIndex,
                    showPattern: showPatterns && hasPattern && isCurrentBox,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
          );
        }),
        ),
      ),
    );
  }

  Widget _buildBox(int boxIndex, {required bool hasPattern, required int patternIndex, required bool showPattern}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _phase == CANTABPALPhase.recall ? () {
          // User selects this box for the current pattern
          _handleBoxSelection(boxIndex);
        } : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _phase == CANTABPALPhase.recall ? Colors.blue[400]! : Colors.grey[400]!,
              width: _phase == CANTABPALPhase.recall ? 2 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: showPattern
              ? _buildComplexPattern(patternIndex)
              : null,
        ),
      ),
    );
  }

  Widget _buildResults() {
    final stagesCompleted = _stageResults.where((r) => r).length;
    final accuracy = (stagesCompleted / CANTABPALConfig.totalStages * 100);

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
                          color: stagesCompleted >= 4 ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Test Complete!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildResultRow('Stages Completed', '$stagesCompleted / 9'),
                        const Divider(),
                        _buildResultRow('Success Rate', '${accuracy.toStringAsFixed(1)}%'),
                        const Divider(),
                        _buildResultRow('First Attempt Score', '$_firstAttemptMemoryScore'),
                        const Divider(),
                        _buildResultRow('Total Errors', '$_totalErrorsAdjusted'),
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
                          CANTABPALConfig.getInterpretation(stagesCompleted, _totalErrorsAdjusted),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.science, color: Colors.deepPurple, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'CANTAB Standard Metrics',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._errorsPerStage.asMap().entries.map((entry) {
                          final stageIndex = entry.key;
                          final errors = entry.value;
                          final patternCount = CANTABPALConfig.getPatternCountForStage(stageIndex);
                          final completed = stageIndex < _stageResults.length && _stageResults[stageIndex];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  completed ? Icons.check_circle : Icons.cancel,
                                  size: 16,
                                  color: completed ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Stage ${stageIndex + 1} ($patternCount patterns): ',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  completed ? '$errors errors' : 'Failed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: completed ? Colors.grey[700] : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
                backgroundColor: Colors.deepPurple,
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

  // Build abstract patterns from image files
  Widget _buildComplexPattern(int patternIndex) {
    final imagePath = _patternImages[patternIndex % _patternImages.length];

    return Container(
      padding: const EdgeInsets.all(1), // 1 pixel white margin
      color: Colors.white, // White border/margin
      child: Container(
        color: Colors.black, // Black background for pattern
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover, // Fill the entire space
        ),
      ),
    );
  }
}

// Custom painter for complex abstract patterns
class ComplexPatternPainter extends CustomPainter {

  ComplexPatternPainter(this.patternIndex, this.colors);
  final int patternIndex;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    // Add insets to prevent clipping at edges
    const inset = 4.0; // Padding from edges
    final drawableWidth = size.width - inset * 2;
    final drawableHeight = size.height - inset * 2;

    // Translate canvas to account for inset
    canvas.save();
    canvas.translate(inset, inset);

    final paint1 = Paint()
      ..color = colors[0]
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Anti-chunking abstract patterns
    // Each is asymmetric, non-geometric, and non-categorical
    // Now supports 12 unique patterns
    switch (patternIndex % 12) {
      case 0: // Irregular curved blob with offset dots
        final path = Path()
          ..moveTo(drawableWidth * 0.3, drawableHeight * 0.15)
          ..quadraticBezierTo(drawableWidth * 0.7, drawableHeight * 0.2, drawableWidth * 0.75, drawableHeight * 0.45)
          ..quadraticBezierTo(drawableWidth * 0.65, drawableHeight * 0.75, drawableWidth * 0.35, drawableHeight * 0.7)
          ..quadraticBezierTo(drawableWidth * 0.15, drawableHeight * 0.5, drawableWidth * 0.3, drawableHeight * 0.15);
        canvas.drawPath(path, paint1);
        canvas.drawCircle(Offset(drawableWidth * 0.25, drawableHeight * 0.6), drawableWidth * 0.08, paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.6, drawableHeight * 0.35), drawableWidth * 0.06, paint2);
        break;

      case 1: // Asymmetric curved arc with scattered elements
        final path = Path()
          ..moveTo(drawableWidth * 0.2, drawableHeight * 0.3)
          ..cubicTo(drawableWidth * 0.4, drawableHeight * 0.15, drawableWidth * 0.65, drawableHeight * 0.6, drawableWidth * 0.8, drawableHeight * 0.45);
        canvas.drawPath(path, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 6);
        canvas.drawRect(Rect.fromLTWH(drawableWidth * 0.15, drawableHeight * 0.65, drawableWidth * 0.2, drawableHeight * 0.15), paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.7, drawableHeight * 0.75), drawableWidth * 0.1, paint1);
        break;

      case 2: // Irregular zigzag with asymmetric fill
        final path = Path()
          ..moveTo(drawableWidth * 0.15, drawableHeight * 0.25)
          ..lineTo(drawableWidth * 0.4, drawableHeight * 0.15)
          ..lineTo(drawableWidth * 0.35, drawableHeight * 0.45)
          ..lineTo(drawableWidth * 0.65, drawableHeight * 0.35)
          ..lineTo(drawableWidth * 0.55, drawableHeight * 0.7)
          ..lineTo(drawableWidth * 0.25, drawableHeight * 0.75)
          ..close();
        canvas.drawPath(path, paint1);
        final smallCircle = Offset(drawableWidth * 0.7, drawableHeight * 0.6);
        canvas.drawCircle(smallCircle, drawableWidth * 0.12, strokePaint);
        break;

      case 3: // Wavy curve with offset geometric elements
        final path = Path()
          ..moveTo(drawableWidth * 0.2, drawableHeight * 0.5)
          ..quadraticBezierTo(drawableWidth * 0.35, drawableHeight * 0.2, drawableWidth * 0.5, drawableHeight * 0.45)
          ..quadraticBezierTo(drawableWidth * 0.65, drawableHeight * 0.7, drawableWidth * 0.8, drawableHeight * 0.4);
        canvas.drawPath(path, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 7);
        canvas.drawRect(Rect.fromLTWH(drawableWidth * 0.55, drawableHeight * 0.15, drawableWidth * 0.15, drawableHeight * 0.2), paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.25, drawableHeight * 0.75), drawableWidth * 0.09, paint2);
        break;

      case 4: // Irregular blob with internal curve
        final outerPath = Path()
          ..moveTo(drawableWidth * 0.25, drawableHeight * 0.2)
          ..quadraticBezierTo(drawableWidth * 0.5, drawableHeight * 0.1, drawableWidth * 0.7, drawableHeight * 0.25)
          ..quadraticBezierTo(drawableWidth * 0.85, drawableHeight * 0.5, drawableWidth * 0.65, drawableHeight * 0.75)
          ..quadraticBezierTo(drawableWidth * 0.4, drawableHeight * 0.85, drawableWidth * 0.2, drawableHeight * 0.6)
          ..quadraticBezierTo(drawableWidth * 0.1, drawableHeight * 0.35, drawableWidth * 0.25, drawableHeight * 0.2);
        canvas.drawPath(outerPath, paint1);
        final innerCurve = Path()
          ..moveTo(drawableWidth * 0.35, drawableHeight * 0.4)
          ..quadraticBezierTo(drawableWidth * 0.5, drawableHeight * 0.5, drawableWidth * 0.55, drawableHeight * 0.6);
        canvas.drawPath(innerCurve, Paint()..color = colors[1]..style = PaintingStyle.stroke..strokeWidth = 4);
        break;

      case 5: // Scattered irregular rectangles at angles
        canvas.save();
        canvas.translate(drawableWidth * 0.3, drawableHeight * 0.25);
        canvas.rotate(0.4);
        canvas.drawRect(Rect.fromLTWH(-drawableWidth * 0.1, -drawableHeight * 0.08, drawableWidth * 0.25, drawableHeight * 0.16), paint1);
        canvas.restore();

        canvas.save();
        canvas.translate(drawableWidth * 0.65, drawableHeight * 0.55);
        canvas.rotate(-0.3);
        canvas.drawRect(Rect.fromLTWH(-drawableWidth * 0.12, -drawableHeight * 0.1, drawableWidth * 0.24, drawableHeight * 0.2), paint2);
        canvas.restore();

        canvas.drawCircle(Offset(drawableWidth * 0.25, drawableHeight * 0.7), drawableWidth * 0.09, paint1);
        break;

      case 6: // Curved ribbon-like shape with dot
        final path = Path()
          ..moveTo(drawableWidth * 0.2, drawableHeight * 0.3)
          ..quadraticBezierTo(drawableWidth * 0.5, drawableHeight * 0.15, drawableWidth * 0.75, drawableHeight * 0.35)
          ..lineTo(drawableWidth * 0.7, drawableHeight * 0.5)
          ..quadraticBezierTo(drawableWidth * 0.45, drawableHeight * 0.35, drawableWidth * 0.25, drawableHeight * 0.45)
          ..close();
        canvas.drawPath(path, paint1);
        final lowerPath = Path()
          ..moveTo(drawableWidth * 0.35, drawableHeight * 0.6)
          ..quadraticBezierTo(drawableWidth * 0.55, drawableHeight * 0.75, drawableWidth * 0.7, drawableHeight * 0.65);
        canvas.drawPath(lowerPath, Paint()..color = colors[1]..style = PaintingStyle.stroke..strokeWidth = 5);
        canvas.drawCircle(Offset(drawableWidth * 0.6, drawableHeight * 0.78), drawableWidth * 0.07, paint2);
        break;

      case 7: // Abstract comma-like swoosh with geometric accent
        final path = Path()
          ..moveTo(drawableWidth * 0.45, drawableHeight * 0.2)
          ..quadraticBezierTo(drawableWidth * 0.65, drawableHeight * 0.25, drawableWidth * 0.7, drawableHeight * 0.45)
          ..quadraticBezierTo(drawableWidth * 0.68, drawableHeight * 0.65, drawableWidth * 0.5, drawableHeight * 0.75)
          ..quadraticBezierTo(drawableWidth * 0.55, drawableHeight * 0.5, drawableWidth * 0.52, drawableHeight * 0.35)
          ..quadraticBezierTo(drawableWidth * 0.48, drawableHeight * 0.25, drawableWidth * 0.45, drawableHeight * 0.2);
        canvas.drawPath(path, paint1);
        canvas.drawRect(Rect.fromLTWH(drawableWidth * 0.18, drawableHeight * 0.35, drawableWidth * 0.18, drawableHeight * 0.22), paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.27, drawableHeight * 0.7), drawableWidth * 0.08, strokePaint);
        break;

      case 8: // Spiral-like curved line with scattered dots
        final spiralPath = Path()
          ..moveTo(drawableWidth * 0.5, drawableHeight * 0.2)
          ..quadraticBezierTo(drawableWidth * 0.3, drawableHeight * 0.3, drawableWidth * 0.35, drawableHeight * 0.5)
          ..quadraticBezierTo(drawableWidth * 0.4, drawableHeight * 0.7, drawableWidth * 0.6, drawableHeight * 0.65)
          ..quadraticBezierTo(drawableWidth * 0.75, drawableHeight * 0.6, drawableWidth * 0.7, drawableHeight * 0.4);
        canvas.drawPath(spiralPath, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 5);
        canvas.drawCircle(Offset(drawableWidth * 0.25, drawableHeight * 0.25), drawableWidth * 0.07, paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.75, drawableHeight * 0.75), drawableWidth * 0.09, paint2);
        canvas.drawCircle(Offset(drawableWidth * 0.5, drawableHeight * 0.55), drawableWidth * 0.06, paint1);
        break;

      case 9: // Organic stepped shape with curve
        final steppedPath = Path()
          ..moveTo(drawableWidth * 0.2, drawableHeight * 0.3)
          ..lineTo(drawableWidth * 0.4, drawableHeight * 0.25)
          ..lineTo(drawableWidth * 0.45, drawableHeight * 0.4)
          ..lineTo(drawableWidth * 0.65, drawableHeight * 0.38)
          ..lineTo(drawableWidth * 0.7, drawableHeight * 0.55)
          ..quadraticBezierTo(drawableWidth * 0.55, drawableHeight * 0.75, drawableWidth * 0.3, drawableHeight * 0.65)
          ..close();
        canvas.drawPath(steppedPath, paint1);
        canvas.drawCircle(Offset(drawableWidth * 0.5, drawableHeight * 0.5), drawableWidth * 0.08, strokePaint);
        canvas.drawRect(Rect.fromLTWH(drawableWidth * 0.15, drawableHeight * 0.7, drawableWidth * 0.12, drawableHeight * 0.15), paint2);
        break;

      case 10: // Meandering river-like curve with offset rectangles
        final riverPath = Path()
          ..moveTo(drawableWidth * 0.3, drawableHeight * 0.2)
          ..quadraticBezierTo(drawableWidth * 0.5, drawableHeight * 0.3, drawableWidth * 0.4, drawableHeight * 0.5)
          ..quadraticBezierTo(drawableWidth * 0.3, drawableHeight * 0.65, drawableWidth * 0.55, drawableHeight * 0.7)
          ..quadraticBezierTo(drawableWidth * 0.7, drawableHeight * 0.73, drawableWidth * 0.75, drawableHeight * 0.6);
        canvas.drawPath(riverPath, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 6);
        canvas.save();
        canvas.translate(drawableWidth * 0.65, drawableHeight * 0.3);
        canvas.rotate(0.6);
        canvas.drawRect(Rect.fromLTWH(-drawableWidth * 0.08, -drawableHeight * 0.06, drawableWidth * 0.16, drawableHeight * 0.12), paint2);
        canvas.restore();
        canvas.drawCircle(Offset(drawableWidth * 0.25, drawableHeight * 0.45), drawableWidth * 0.09, paint1);
        break;

      case 11: // Asymmetric overlapping curves with dot accent
        final curve1 = Path()
          ..moveTo(drawableWidth * 0.2, drawableHeight * 0.4)
          ..quadraticBezierTo(drawableWidth * 0.4, drawableHeight * 0.2, drawableWidth * 0.6, drawableHeight * 0.35)
          ..quadraticBezierTo(drawableWidth * 0.75, drawableHeight * 0.45, drawableWidth * 0.65, drawableHeight * 0.65);
        canvas.drawPath(curve1, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 7);
        final curve2 = Path()
          ..moveTo(drawableWidth * 0.35, drawableHeight * 0.6)
          ..quadraticBezierTo(drawableWidth * 0.5, drawableHeight * 0.75, drawableWidth * 0.7, drawableHeight * 0.7);
        canvas.drawPath(curve2, Paint()..color = colors[1]..style = PaintingStyle.stroke..strokeWidth = 5);
        canvas.drawCircle(Offset(drawableWidth * 0.5, drawableHeight * 0.45), drawableWidth * 0.11, paint2);
        final innerCircle = Offset(drawableWidth * 0.5, drawableHeight * 0.45);
        canvas.drawCircle(innerCircle, drawableWidth * 0.05, paint1);
        break;
    }

    // Restore canvas after inset translation
    canvas.restore();
  }

  @override
  bool shouldRepaint(ComplexPatternPainter oldDelegate) =>
      patternIndex != oldDelegate.patternIndex || colors != oldDelegate.colors;
}

enum CANTABPALPhase {
  introduction,
  presentation,
  recall,
  results,
}
