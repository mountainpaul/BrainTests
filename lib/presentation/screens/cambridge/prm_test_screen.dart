import 'dart:async';
import 'dart:convert';
import 'dart:math' as dart_math;

import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/domain/services/cambridge_test_generator.dart';
import 'package:brain_tests/presentation/providers/cambridge_assessment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// PRM (Pattern Recognition Memory) Test Screen - Cambridge CANTAB assessment
/// Tests visual pattern recognition memory
class PRMTestScreen extends ConsumerStatefulWidget {
  const PRMTestScreen({super.key});

  @override
  ConsumerState<PRMTestScreen> createState() => _PRMTestScreenState();
}

class _PRMTestScreenState extends ConsumerState<PRMTestScreen> {
  PRMPhase _phase = PRMPhase.introduction;
  PRMTrial? _currentTrial;

  int _currentTestPattern = 0;
  DateTime? _patternStartTime;
  DateTime? _testStartTime;
  Timer? _phaseTimer;

  final List<PRMResult> _results = [];
  final int _numStudyPatterns = 12; // Number of patterns to study

  @override
  void dispose() {
    _phaseTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _phase = PRMPhase.study;
      _results.clear();
    });
    WakelockPlus.enable();
    _testStartTime = DateTime.now();

    // Generate trial
    _currentTrial = CambridgeTestGenerator.generatePRMTrial(_numStudyPatterns);

    // Auto-progress to test phase after brief study period
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _phase == PRMPhase.study) {
        _startTestPhase();
      }
    });
  }

  void _startTestPhase() {
    setState(() {
      _phase = PRMPhase.testing;
      _currentTestPattern = 0;
    });
    _patternStartTime = DateTime.now();
  }

  void _handleResponse(bool userSaysOld) {
    if (_phase != PRMPhase.testing || _currentTrial == null) return;

    final pattern = _currentTrial!.testPatterns[_currentTestPattern];
    final responseTime = DateTime.now().difference(_patternStartTime!).inMilliseconds;
    final isCorrect = userSaysOld == pattern.isOld;

    _results.add(PRMResult(
      patternNumber: _currentTestPattern + 1,
      wasOld: pattern.isOld,
      userResponse: userSaysOld,
      correct: isCorrect,
      responseTimeMs: responseTime,
    ));

    // Move to next pattern
    _currentTestPattern++;

    if (_currentTestPattern >= _currentTrial!.testPatterns.length) {
      _completeTest();
    } else {
      setState(() {
        _patternStartTime = DateTime.now();
      });
    }
  }

  Future<void> _completeTest() async {
    setState(() {
      _phase = PRMPhase.results;
    });
    WakelockPlus.disable();

    // Save to database
    await _saveResults();
  }

  Future<void> _saveResults() async {
    if (_results.isEmpty || _testStartTime == null) return;

    final correctCount = _results.where((r) => r.correct).length;
    final accuracy = (correctCount / _results.length) * 100;
    final avgResponseTime = _results.map((r) => r.responseTimeMs).reduce((a, b) => a + b) / _results.length;
    final duration = DateTime.now().difference(_testStartTime!).inSeconds;

    // Calculate median response time
    final sortedTimes = _results.map((r) => r.responseTimeMs).toList()..sort();
    final medianTime = sortedTimes[sortedTimes.length ~/ 2].toDouble();

    // Store test-specific metrics in JSON
    final specificMetrics = jsonEncode({
      'totalPatterns': _results.length,
      'oldPatternCount': _results.where((r) => r.wasOld).length,
      'newPatternCount': _results.where((r) => !r.wasOld).length,
      'truePositives': _results.where((r) => r.wasOld && r.userResponse).length,
      'falsePositives': _results.where((r) => !r.wasOld && r.userResponse).length,
      'trueNegatives': _results.where((r) => !r.wasOld && !r.userResponse).length,
      'falseNegatives': _results.where((r) => r.wasOld && !r.userResponse).length,
    });

    try {
      final notifier = ref.read(cambridgeAssessmentProvider.notifier);
      final metrics = jsonDecode(specificMetrics) as Map<String, dynamic>;

      final result = CambridgeAssessmentResult(
        testType: CambridgeTestType.prm,
        completedAt: DateTime.now(),
        durationSeconds: duration,
        accuracy: accuracy,
        totalTrials: _results.length,
        correctTrials: correctCount,
        errorCount: _results.length - correctCount,
        meanLatencyMs: avgResponseTime,
        medianLatencyMs: medianTime,
        specificMetrics: metrics,
        normScore: accuracy,
        interpretation: _getInterpretation(accuracy),
      );

      await notifier.addAssessment(result);
    } catch (e) {
      debugPrint('Error saving PRM results: $e');
    }
  }

  String _getInterpretation(double accuracy) {
    if (accuracy >= 90) return 'Excellent visual recognition memory';
    if (accuracy >= 80) return 'Good visual recognition memory';
    if (accuracy >= 70) return 'Average visual recognition memory';
    if (accuracy >= 60) return 'Below average visual recognition memory';
    return 'Impaired visual recognition memory';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Recognition Memory (PRM)'),
        backgroundColor: Colors.indigo[700],
      ),
      body: SafeArea(
        child: _buildPhaseContent(),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case PRMPhase.introduction:
        return _buildIntroduction();
      case PRMPhase.study:
        return _buildStudyScreen();
      case PRMPhase.testing:
        return _buildTestScreen();
      case PRMPhase.results:
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
            'Pattern Recognition Memory',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
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
                    '• First, you will study a series of abstract patterns\\n'
                    '• Try to remember each pattern\\n'
                    '• Then you will see test patterns one at a time\\n'
                    '• Some patterns are OLD (you saw them before)\\n'
                    '• Some patterns are NEW (you haven\'t seen them)\\n'
                    '• Tap "OLD" if you recognize the pattern\\n'
                    '• Tap "NEW" if you haven\'t seen it before',
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
              backgroundColor: Colors.indigo[700],
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

  Widget _buildStudyScreen() {
    if (_currentTrial == null) return const SizedBox();

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[700],
          child: const Column(
            children: [
              Text(
                'PRM TEST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Study Phase - Remember these patterns',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Study patterns grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: _currentTrial!.studyPatterns.length,
              itemBuilder: (context, index) {
                return _buildPattern(_currentTrial!.studyPatterns[index]);
              },
            ),
          ),
        ),

        // Progress indicator
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Memorizing patterns...',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTestScreen() {
    if (_currentTrial == null) return const SizedBox();

    final pattern = _currentTrial!.testPatterns[_currentTestPattern];

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[700],
          child: Column(
            children: [
              const Text(
                'PRM TEST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pattern ${_currentTestPattern + 1} of ${_currentTrial!.testPatterns.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Question
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Have you seen this pattern before?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 48),

        // Pattern display
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.indigo[700]!, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPattern(pattern),
          ),
        ),

        const Spacer(),

        // Response buttons
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleResponse(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(24),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('NEW'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleResponse(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(24),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('OLD'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPattern(PRMPattern pattern) {
    if (pattern.shape == null || pattern.color == null || pattern.size == null) {
      return const Center(child: Icon(Icons.help_outline, color: Colors.grey));
    }

    // CANTAB-style abstract patterns with color pairs
    // 20 unique color pair combinations (anti-chunking)
    final List<List<Color>> colorPairs = [
      [const Color(0xFFE91E63), const Color(0xFF00BCD4)],  // Pink + Cyan
      [const Color(0xFF795548), const Color(0xFFFFEB3B)],  // Brown + Yellow
      [const Color(0xFF9C27B0), const Color(0xFF4CAF50)],  // Purple + Green
      [const Color(0xFFFF5722), const Color(0xFF3F51B5)],  // Deep Orange + Indigo
      [const Color(0xFF00BCD4), const Color(0xFFE91E63)],  // Cyan + Pink
      [const Color(0xFF8BC34A), const Color(0xFF673AB7)],  // Light Green + Deep Purple
      [const Color(0xFFFF9800), const Color(0xFF009688)],  // Orange + Teal
      [const Color(0xFF5E35B1), const Color(0xFFFFA726)],  // Deep Purple + Light Orange
      [const Color(0xFF26A69A), const Color(0xFFEC407A)],  // Teal + Pink
      [const Color(0xFFFFEB3B), const Color(0xFF5D4037)],  // Yellow + Deep Brown
      [const Color(0xFFE53935), const Color(0xFF66BB6A)],  // Red + Light Green
      [const Color(0xFF42A5F5), const Color(0xFFFFCA28)],  // Blue + Amber
      [const Color(0xFFAB47BC), const Color(0xFF26C6DA)],  // Medium Purple + Light Cyan
      [const Color(0xFFEF5350), const Color(0xFF7CB342)],  // Light Red + Light Lime
      [const Color(0xFF29B6F6), const Color(0xFFFF7043)],  // Light Blue + Deep Orange
      [const Color(0xFFFFA726), const Color(0xFF5C6BC0)],  // Light Orange + Indigo
      [const Color(0xFF66BB6A), const Color(0xFFEC407A)],  // Light Green + Pink
      [const Color(0xFF8D6E63), const Color(0xFFAED581)],  // Brown + Light Green
      [const Color(0xFFBA68C8), const Color(0xFFFFD54F)],  // Purple + Amber
      [const Color(0xFF4DD0E1), const Color(0xFFE57373)],  // Cyan + Light Red
    ];

    final colors = colorPairs[pattern.color! % colorPairs.length];

    return CustomPaint(
      size: const Size(80, 80),
      painter: PRMPatternPainter(
        patternType: pattern.shape!,
        colors: colors,
        variation: pattern.size!,
      ),
    );
  }

  Widget _buildResults() {
    final correctCount = _results.where((r) => r.correct).length;
    final accuracy = _results.isEmpty ? 0.0 : (correctCount / _results.length) * 100;
    final avgResponseTime = _results.isEmpty
        ? 0.0
        : _results.map((r) => r.responseTimeMs).reduce((a, b) => a + b) / _results.length;

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
              color: Colors.indigo[700],
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
                    'Patterns Tested: ${_results.length}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Correct Responses: $correctCount/${_results.length}',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  Text(
                    'Average Response Time: ${(avgResponseTime / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This test measures visual recognition memory. '
                    'Higher accuracy indicates better pattern recognition and visual memory.',
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
              backgroundColor: Colors.indigo[700],
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

enum PRMPhase {
  introduction,
  study,
  testing,
  results,
}

class PRMResult {

  PRMResult({
    required this.patternNumber,
    required this.wasOld,
    required this.userResponse,
    required this.correct,
    required this.responseTimeMs,
  });
  final int patternNumber;
  final bool wasOld;
  final bool userResponse;
  final bool correct;
  final int responseTimeMs;
}

/// Custom painter for CANTAB-style abstract patterns
/// Based on Cambridge Cognition PAL methodology
class PRMPatternPainter extends CustomPainter {  // 0-4 for size/rotation variations

  PRMPatternPainter({
    required this.patternType,
    required this.colors,
    required this.variation,
  });
  final int patternType;  // 0-11 for 12 different patterns
  final List<Color> colors;  // Two-color pairs
  final int variation;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 4.0;
    final width = size.width - inset * 2;
    final height = size.height - inset * 2;

    canvas.save();
    canvas.translate(inset, inset);

    // Apply variation (rotation/scale)
    final scale = 0.8 + (variation % 5) * 0.05;  // 0.8 to 1.0
    final rotation = (variation % 5) * 0.2;  // 0 to 0.8 radians
    canvas.translate(width / 2, height / 2);
    canvas.scale(scale);
    canvas.rotate(rotation);
    canvas.translate(-width / 2, -height / 2);

    final paint1 = Paint()..color = colors[0]..style = PaintingStyle.fill;
    final paint2 = Paint()..color = colors[1]..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = colors[1]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // 12 abstract pattern types (similar to CANTAB PAL)
    switch (patternType % 12) {
      case 0:  // Irregular curved blob with dots
        final path = Path()
          ..moveTo(width * 0.3, height * 0.15)
          ..quadraticBezierTo(width * 0.7, height * 0.2, width * 0.75, height * 0.45)
          ..quadraticBezierTo(width * 0.65, height * 0.75, width * 0.35, height * 0.7)
          ..quadraticBezierTo(width * 0.15, height * 0.5, width * 0.3, height * 0.15);
        canvas.drawPath(path, paint1);
        canvas.drawCircle(Offset(width * 0.25, height * 0.6), width * 0.08, paint2);
        break;

      case 1:  // Asymmetric arc with elements
        final path = Path()
          ..moveTo(width * 0.2, height * 0.3)
          ..cubicTo(width * 0.4, height * 0.15, width * 0.65, height * 0.6, width * 0.8, height * 0.45);
        canvas.drawPath(path, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 6);
        canvas.drawRect(Rect.fromLTWH(width * 0.15, height * 0.65, width * 0.2, height * 0.15), paint2);
        break;

      case 2:  // Zigzag with fill
        final path = Path()
          ..moveTo(width * 0.15, height * 0.25)
          ..lineTo(width * 0.4, height * 0.15)
          ..lineTo(width * 0.35, height * 0.45)
          ..lineTo(width * 0.65, height * 0.35)
          ..lineTo(width * 0.55, height * 0.7)
          ..close();
        canvas.drawPath(path, paint1);
        canvas.drawCircle(Offset(width * 0.7, height * 0.6), width * 0.12, strokePaint);
        break;

      case 3:  // Wavy curve with elements
        final path = Path()
          ..moveTo(width * 0.1, height * 0.5)
          ..quadraticBezierTo(width * 0.3, height * 0.2, width * 0.5, height * 0.5)
          ..quadraticBezierTo(width * 0.7, height * 0.8, width * 0.9, height * 0.5);
        canvas.drawPath(path, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 5);
        canvas.drawCircle(Offset(width * 0.5, height * 0.3), width * 0.1, paint2);
        break;

      case 4:  // Irregular polygon
        final path = Path()
          ..moveTo(width * 0.5, height * 0.1)
          ..lineTo(width * 0.85, height * 0.3)
          ..lineTo(width * 0.75, height * 0.7)
          ..lineTo(width * 0.4, height * 0.85)
          ..lineTo(width * 0.15, height * 0.4)
          ..close();
        canvas.drawPath(path, paint1);
        canvas.drawRect(Rect.fromLTWH(width * 0.4, height * 0.4, width * 0.15, width * 0.15), paint2);
        break;

      case 5:  // Curved stripe with dots
        final path = Path()
          ..moveTo(width * 0.2, height * 0.2)
          ..quadraticBezierTo(width * 0.5, height * 0.4, width * 0.8, height * 0.2)
          ..lineTo(width * 0.8, height * 0.4)
          ..quadraticBezierTo(width * 0.5, height * 0.6, width * 0.2, height * 0.4)
          ..close();
        canvas.drawPath(path, paint1);
        canvas.drawCircle(Offset(width * 0.5, height * 0.7), width * 0.12, paint2);
        break;

      case 6:  // Split diagonal with circles
        canvas.drawRect(Rect.fromLTWH(width * 0.1, height * 0.3, width * 0.35, height * 0.4), paint1);
        canvas.drawCircle(Offset(width * 0.7, height * 0.3), width * 0.15, paint2);
        canvas.drawCircle(Offset(width * 0.6, height * 0.7), width * 0.12, strokePaint);
        break;

      case 7:  // Complex curve
        final path = Path()
          ..moveTo(width * 0.25, height * 0.25)
          ..cubicTo(width * 0.1, height * 0.5, width * 0.4, height * 0.8, width * 0.75, height * 0.65)
          ..lineTo(width * 0.75, height * 0.75)
          ..cubicTo(width * 0.5, height * 0.85, width * 0.2, height * 0.6, width * 0.25, height * 0.35)
          ..close();
        canvas.drawPath(path, paint1);
        break;

      case 8:  // Starburst shape
        final path = Path()..moveTo(width * 0.5, height * 0.1);
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * 3.14159 / 5) - 3.14159 / 2;
          final x = width * 0.5 + width * 0.35 * cos(angle);
          final y = height * 0.5 + height * 0.35 * sin(angle);
          path.lineTo(x, y);
          final angle2 = ((i + 0.5) * 2 * 3.14159 / 5) - 3.14159 / 2;
          final x2 = width * 0.5 + width * 0.15 * cos(angle2);
          final y2 = height * 0.5 + height * 0.15 * sin(angle2);
          path.lineTo(x2, y2);
        }
        path.close();
        canvas.drawPath(path, paint1);
        break;

      case 9:  // Spiral-like curves
        final path = Path()
          ..moveTo(width * 0.5, height * 0.2)
          ..quadraticBezierTo(width * 0.7, height * 0.35, width * 0.6, height * 0.6)
          ..quadraticBezierTo(width * 0.3, height * 0.7, width * 0.4, height * 0.4);
        canvas.drawPath(path, Paint()..color = colors[0]..style = PaintingStyle.stroke..strokeWidth = 8);
        canvas.drawCircle(Offset(width * 0.5, height * 0.5), width * 0.08, paint2);
        break;

      case 10:  // Asymmetric blob with stripe
        final path = Path()
          ..moveTo(width * 0.35, height * 0.2)
          ..quadraticBezierTo(width * 0.65, height * 0.15, width * 0.7, height * 0.5)
          ..quadraticBezierTo(width * 0.6, height * 0.8, width * 0.3, height * 0.7)
          ..quadraticBezierTo(width * 0.2, height * 0.45, width * 0.35, height * 0.2);
        canvas.drawPath(path, paint1);
        canvas.drawLine(Offset(width * 0.4, height * 0.35), Offset(width * 0.55, height * 0.65),
            Paint()..color = colors[1]..strokeWidth = 4);
        break;

      case 11:  // Irregular pentagon with accent
        final path = Path()
          ..moveTo(width * 0.5, height * 0.15)
          ..lineTo(width * 0.8, height * 0.35)
          ..lineTo(width * 0.7, height * 0.75)
          ..lineTo(width * 0.3, height * 0.75)
          ..lineTo(width * 0.2, height * 0.35)
          ..close();
        canvas.drawPath(path, paint1);
        canvas.drawCircle(Offset(width * 0.5, height * 0.5), width * 0.1, paint2);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PRMPatternPainter oldDelegate) {
    return oldDelegate.patternType != patternType ||
        oldDelegate.colors != colors ||
        oldDelegate.variation != variation;
  }
}

double cos(double radians) => dart_math.cos(radians);
double sin(double radians) => dart_math.sin(radians);
