import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/assessment.dart';
import '../providers/assessment_provider.dart';
import '../../core/providers/database_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/custom_card.dart';

class TrailMakingTestScreen extends ConsumerStatefulWidget {
  const TrailMakingTestScreen({super.key});

  @override
  ConsumerState<TrailMakingTestScreen> createState() => _TrailMakingTestScreenState();
}

class _TrailMakingTestScreenState extends ConsumerState<TrailMakingTestScreen> {
  Timer? _timer;
  
  // Test configuration
  bool _testStarted = false;
  bool _testAComplete = false;
  bool _testBComplete = false;
  bool _allTestsComplete = false;
  
  // Test A (Numbers 1-25)
  bool _testAStarted = false;
  int _testATime = 0;
  final List<int> _testASequence = [];
  int _testACurrentTarget = 1;
  int _testAErrors = 0;
  
  // Test B (Numbers 1-13 + Letters A-L alternating)
  bool _testBStarted = false;
  int _testBTime = 0;
  final List<String> _testBSequence = [];
  String _testBCurrentTarget = '1';
  int _testBErrors = 0;
  bool _testBExpectingNumber = true;
  int _testBNumberTarget = 1;
  int _testBLetterTarget = 0; // 0=A, 1=B, etc.
  
  // Circle positions for visual display
  List<CircleData> _testACircles = [];
  List<CircleData> _testBCircles = [];
  final List<String> _path = [];

  @override
  void initState() {
    super.initState();
    _generateTestLayouts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateTestLayouts() {
    // Base canvas size - circles will be positioned in this coordinate system
    const double canvasSize = 800.0; // Base coordinate system for circle positions

    // Generate Test A circles (numbers 1-25)
    _testACircles = _generateCircleLayout(
      List.generate(25, (i) => (i + 1).toString()),
      canvasSize,
    );

    // Generate Test B circles (1-A-2-B-3-C...13-L)
    final List<String> testBItems = [];
    for (int i = 1; i <= 13; i++) {
      testBItems.add(i.toString());
      if (i <= 12) { // Only add letters A through L (12 letters)
        testBItems.add(String.fromCharCode(65 + i - 1)); // A=65, B=66, etc.
      }
    }
    _testBCircles = _generateCircleLayout(testBItems, canvasSize);
  }

  List<CircleData> _generateCircleLayout(List<String> items, double canvasSize) {
    final random = math.Random();
    final List<CircleData> circles = [];
    const double circleRadius = 20.2;
    const double margin = 40.0; // Margin for spacing from edges

    // Use larger grid for increased spacing
    final gridSize = (items.length <= 12) ? 4 :  // Reduced items per grid for more space
                    (items.length <= 20) ? 5 : 6; // More conservative spacing

    final availableWidth = canvasSize - (2 * margin);
    final availableHeight = canvasSize - (2 * margin);
    final cellWidth = availableWidth / gridSize;
    final cellHeight = availableHeight / gridSize;

    // Generate all grid positions
    final List<Map<String, int>> gridPositions = [];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        gridPositions.add({'row': row, 'col': col});
      }
    }

    // Shuffle for randomness
    gridPositions.shuffle(random);

    for (int i = 0; i < items.length; i++) {
      final gridPos = gridPositions[i];
      final row = gridPos['row']!;
      final col = gridPos['col']!;

      // Calculate center position of this grid cell
      final centerX = margin + (col * cellWidth) + (cellWidth / 2);
      final centerY = margin + (row * cellHeight) + (cellHeight / 2);

      // Add small random offset within the cell (but ensure no overlap)
      final maxOffset = math.min(cellWidth, cellHeight) * 0.25; // 25% of cell size
      final offsetX = (random.nextDouble() - 0.5) * maxOffset;
      final offsetY = (random.nextDouble() - 0.5) * maxOffset;

      final finalX = (centerX + offsetX).clamp(margin, canvasSize - margin);
      final finalY = (centerY + offsetY).clamp(margin, canvasSize - margin);

      circles.add(CircleData(
        value: items[i],
        x: finalX,
        y: finalY,
        isConnected: false,
        isError: false,
      ));
    }

    return circles;
  }

  void _startTestA() {
    setState(() {
      _testStarted = true;
      _testAStarted = true;
      _testATime = 0;
      _testACurrentTarget = 1;
      _testASequence.clear();
      _testAErrors = 0;
      _path.clear();
      
      // Reset circle states
      for (final circle in _testACircles) {
        circle.isConnected = false;
        circle.isError = false;
      }
    });
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _testATime += 100;
      });
    });
  }

  void _onTestACircleTapped(String value) {
    if (!_testAStarted || _testAComplete) return;
    
    final int circleNumber = int.parse(value);
    
    if (circleNumber == _testACurrentTarget) {
      // Correct selection
      setState(() {
        _testASequence.add(circleNumber);
        _path.add(value);
        
        // Mark circle as connected
        final circle = _testACircles.firstWhere((c) => c.value == value);
        circle.isConnected = true;
        
        _testACurrentTarget++;
      });
      
      if (_testACurrentTarget > 25) {
        _completeTestA();
      }
    } else {
      // Incorrect selection - count as error
      setState(() {
        _testAErrors++;
        final circle = _testACircles.firstWhere((c) => c.value == value);
        circle.isError = true;
      });
      
      // Reset error state after a moment
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            final circle = _testACircles.firstWhere((c) => c.value == value);
            circle.isError = false;
          });
        }
      });
    }
  }

  void _completeTestA() {
    _timer?.cancel();
    setState(() {
      _testAComplete = true;
    });
    _saveTestAResults();
  }

  void _startTestB() {
    setState(() {
      _testBStarted = true;
      _testBTime = 0;
      _testBCurrentTarget = '1';
      _testBSequence.clear();
      _testBErrors = 0;
      _testBExpectingNumber = true;
      _testBNumberTarget = 1;
      _testBLetterTarget = 0;
      _path.clear();
      
      // Reset circle states
      for (final circle in _testBCircles) {
        circle.isConnected = false;
        circle.isError = false;
      }
    });
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _testBTime += 100;
      });
    });
  }

  void _onTestBCircleTapped(String value) {
    if (!_testBStarted || _testBComplete) return;
    
    bool isCorrect = false;
    
    if (_testBExpectingNumber) {
      // Expecting a number
      if (value == _testBNumberTarget.toString()) {
        isCorrect = true;
        setState(() {
          _testBNumberTarget++;
          _testBExpectingNumber = false;
          _testBCurrentTarget = String.fromCharCode(65 + _testBLetterTarget);
        });
      }
    } else {
      // Expecting a letter
      if (value == String.fromCharCode(65 + _testBLetterTarget)) {
        isCorrect = true;
        setState(() {
          _testBLetterTarget++;
          _testBExpectingNumber = true;
          _testBCurrentTarget = _testBNumberTarget.toString();
        });
      }
    }
    
    if (isCorrect) {
      setState(() {
        _testBSequence.add(value);
        _path.add(value);
        
        // Mark circle as connected
        final circle = _testBCircles.firstWhere((c) => c.value == value);
        circle.isConnected = true;
      });
      
      // Check if test is complete (1-A-2-B...13-L, so last item is 'L')
      if (_testBNumberTarget > 13) {
        _completeTestB();
      }
    } else {
      // Incorrect selection
      setState(() {
        _testBErrors++;
        final circle = _testBCircles.firstWhere((c) => c.value == value);
        circle.isError = true;
      });
      
      // Reset error state after a moment
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            final circle = _testBCircles.firstWhere((c) => c.value == value);
            circle.isError = false;
          });
        }
      });
    }
  }

  void _completeTestB() {
    _timer?.cancel();
    setState(() {
      _testBComplete = true;
      _allTestsComplete = true;
    });
    _saveTestBResults();
  }

  Future<void> _saveTestAResults() async {
    final notifier = ref.read(assessmentProvider.notifier);

    final assessment = Assessment(
      type: AssessmentType.processingSpeed,
      score: (_testATime / 1000).round(), // Time in seconds
      maxScore: 120, // 2 minutes max reasonable time
      notes: 'Trail Making Test A - Time: ${(_testATime / 1000).toStringAsFixed(1)}s, Errors: $_testAErrors',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await notifier.addAssessment(assessment);
  }

  Future<void> _saveTestBResults() async {
    final notifier = ref.read(assessmentProvider.notifier);

    final assessment = Assessment(
      type: AssessmentType.executiveFunction,
      score: (_testBTime / 1000).round(), // Time in seconds
      maxScore: 300, // 5 minutes max reasonable time
      notes: 'Trail Making Test B - Time: ${(_testBTime / 1000).toStringAsFixed(1)}s, Errors: $_testBErrors',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await notifier.addAssessment(assessment);
  }

  String _getTestAPerformanceLevel() {
    final timeInSeconds = _testATime / 1000;
    if (timeInSeconds <= 30) return 'Excellent';
    if (timeInSeconds <= 45) return 'Good';
    if (timeInSeconds <= 60) return 'Average';
    if (timeInSeconds <= 90) return 'Below Average';
    return 'Poor';
  }

  String _getTestBPerformanceLevel() {
    final timeInSeconds = _testBTime / 1000;
    if (timeInSeconds <= 75) return 'Excellent';
    if (timeInSeconds <= 120) return 'Good';
    if (timeInSeconds <= 180) return 'Average';
    if (timeInSeconds <= 240) return 'Below Average';
    return 'Poor';
  }

  Color _getPerformanceColor(bool isTestB) {
    final timeInSeconds = (isTestB ? _testBTime : _testATime) / 1000;
    final thresholds = isTestB ? [75, 120, 180, 240] : [30, 45, 60, 90];
    
    if (timeInSeconds <= thresholds[0]) return Colors.green;
    if (timeInSeconds <= thresholds[1]) return Colors.lightGreen;
    if (timeInSeconds <= thresholds[2]) return Colors.orange;
    if (timeInSeconds <= thresholds[3]) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatTime(int milliseconds) {
    final totalSeconds = milliseconds / 1000;
    final minutes = (totalSeconds / 60).floor();
    final seconds = (totalSeconds % 60);
    return '$minutes:${seconds.toStringAsFixed(1).padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trail Making Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_testStarted) _buildInstructions(),
            if (_testStarted && !_testAComplete) _buildTestA(),
            if (_testAComplete && !_testBStarted) _buildTestBIntro(),
            if (_testBStarted && !_testBComplete) _buildTestB(),
            if (_allTestsComplete) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Trail Making Test A & B',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This test measures processing speed (Test A) and mental flexibility/executive function (Test B).',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildInstructionStep(
                  '1',
                  'Test A: Connect Numbers',
                  'Tap circles numbered 1-25 in order (1→2→3...→25)',
                ),
                _buildInstructionStep(
                  '2',
                  'Test B: Alternate Numbers & Letters',
                  'Tap alternating: 1→A→2→B→3→C...→13→L',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.speed, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Work as quickly and accurately as possible. Your time and errors will be recorded.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startTestA,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test A'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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

  Widget _buildTestA() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Test A: Connect Numbers in Order',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(_testATime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Next: $_testACurrentTarget | Errors: $_testAErrors',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 500,
          child: CustomCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildTrailCanvas(_testACircles, _onTestACircleTapped, constraints);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestBIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Test A Complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${_formatTime(_testATime)} | Errors: $_testAErrors',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Now for Test B',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connect in alternating order:\n1→A→2→B→3→C...→13→L',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startTestB,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test B'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestB() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Test B: Alternate Numbers & Letters',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(_testBTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Next: $_testBCurrentTarget | Errors: $_testBErrors',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 500,
          child: CustomCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildTrailCanvas(_testBCircles, _onTestBCircleTapped, constraints);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailCanvas(List<CircleData> circles, Function(String) onTap, BoxConstraints constraints) {
    final double availableWidth = constraints.maxWidth - 16;
    final double availableHeight = constraints.maxHeight - 16;
    final double canvasSize = math.min(availableWidth, availableHeight);

    // Scale factor to fit circles within available space
    final double scaleFactor = canvasSize / 800.0; // Scale from 800px base to actual canvas size

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPaint(
        painter: TrailPainter(circles, _path, scaleFactor),
        child: SizedBox(
          width: canvasSize,
          height: canvasSize,
          child: Stack(
            children: circles.map((circle) {
              final double scaledX = circle.x * scaleFactor;
              final double scaledY = circle.y * scaleFactor;
              final double circleSize = 93.5 * scaleFactor; // 15% smaller (110 * 0.85)

              return Positioned(
                left: scaledX - (circleSize / 2),
                top: scaledY - (circleSize / 2),
                child: GestureDetector(
                  onTap: () => onTap(circle.value),
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circle.isError
                          ? Colors.red.withOpacity(0.8)
                          : circle.isConnected
                              ? Colors.green.withOpacity(0.8)
                              : Colors.blue.withOpacity(0.8),
                      border: Border.all(
                        color: circle.isError
                            ? Colors.red
                            : circle.isConnected
                                ? Colors.green
                                : Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        circle.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 36 * scaleFactor, // Larger font for better readability
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Both Tests Complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // Test A Results
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(false).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor(false).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Test A (Numbers)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_testATime),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(false),
                        ),
                      ),
                      Text(
                        _getTestAPerformanceLevel(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(false),
                        ),
                      ),
                      Text('$_testAErrors errors'),
                    ],
                  ),
                ),
                
                // Test B Results
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(true).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor(true).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Test B (Numbers & Letters)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_testBTime),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(true),
                        ),
                      ),
                      Text(
                        _getTestBPerformanceLevel(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(true),
                        ),
                      ),
                      Text('$_testBErrors errors'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Score Interpretation
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time Interpretation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Test A (Processing Speed):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                _buildTimeRange('≤30s', 'Excellent', Colors.green, false),
                _buildTimeRange('31-45s', 'Good', Colors.lightGreen, false),
                _buildTimeRange('46-60s', 'Average', Colors.orange, false),
                _buildTimeRange('61-90s', 'Below Average', Colors.deepOrange, false),
                _buildTimeRange('>90s', 'Poor', Colors.red, false),
                const SizedBox(height: 12),
                Text(
                  'Test B (Executive Function):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                _buildTimeRange('≤75s', 'Excellent', Colors.green, true),
                _buildTimeRange('76-120s', 'Good', Colors.lightGreen, true),
                _buildTimeRange('121-180s', 'Average', Colors.orange, true),
                _buildTimeRange('181-240s', 'Below Average', Colors.deepOrange, true),
                _buildTimeRange('>240s', 'Poor', Colors.red, true),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Tests'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Reset and restart test
                  setState(() {
                    _testStarted = false;
                    _testAComplete = false;
                    _testBComplete = false;
                    _allTestsComplete = false;
                    _testAStarted = false;
                    _testBStarted = false;
                    _testATime = 0;
                    _testBTime = 0;
                    _testACurrentTarget = 1;
                    _testBCurrentTarget = '1';
                    _testAErrors = 0;
                    _testBErrors = 0;
                    _testBExpectingNumber = true;
                    _testBNumberTarget = 1;
                    _testBLetterTarget = 0;
                    _testASequence.clear();
                    _testBSequence.clear();
                    _path.clear();
                  });
                  _generateTestLayouts();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRange(String range, String level, Color color, bool isTestB) {
    final currentLevel = isTestB ? _getTestBPerformanceLevel() : _getTestAPerformanceLevel();
    final isCurrentLevel = level == currentLevel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: isCurrentLevel ? BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ) : null,
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              range,
              style: TextStyle(
                fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                color: isCurrentLevel ? color : null,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            level,
            style: TextStyle(
              fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLevel ? color : null,
              fontSize: 12,
            ),
          ),
          if (isCurrentLevel) ...[ 
            const Spacer(),
            Icon(Icons.arrow_left, color: color, size: 16),
          ],
        ],
      ),
    );
  }
}

class CircleData {

  CircleData({
    required this.value,
    required this.x,
    required this.y,
    this.isConnected = false,
    this.isError = false,
  });
  final String value;
  final double x;
  final double y;
  bool isConnected;
  bool isError;
}

class TrailPainter extends CustomPainter {

  TrailPainter(this.circles, this.path, [this.scaleFactor = 1.0]);
  final List<CircleData> circles;
  final List<String> path;
  final double scaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 2 * scaleFactor
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < path.length - 1; i++) {
      final currentCircle = circles.firstWhere((c) => c.value == path[i]);
      final nextCircle = circles.firstWhere((c) => c.value == path[i + 1]);

      canvas.drawLine(
        Offset(currentCircle.x * scaleFactor, currentCircle.y * scaleFactor),
        Offset(nextCircle.x * scaleFactor, nextCircle.y * scaleFactor),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}