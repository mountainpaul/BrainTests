import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/validated_assessments.dart';
import '../providers/assessment_provider.dart';

class ClockDrawingTestScreen extends ConsumerStatefulWidget {
  const ClockDrawingTestScreen({super.key});

  @override
  ConsumerState<ClockDrawingTestScreen> createState() => _ClockDrawingTestScreenState();
}

class _ClockDrawingTestScreenState extends ConsumerState<ClockDrawingTestScreen> {
  List<Offset> drawingPoints = [];
  bool isDrawingStarted = false;
  bool isTestCompleted = false;
  DateTime? startTime;
  Duration? drawingTime;
  int selectedScore = 6;
  String scoringNotes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock Drawing Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isTestCompleted) ...[
              _buildInstructions(),
              const SizedBox(height: 20),
              _buildDrawingArea(),
              const SizedBox(height: 20),
              _buildDrawingControls(),
            ] else ...[
              _buildScoringInterface(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clock Drawing Test Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              ClockDrawingTest.instructions,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'Please draw in the white area below. Take your time and include all numbers and both hands.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
          onPanStart: (details) {
            if (!isDrawingStarted) {
              startTime = DateTime.now();
              isDrawingStarted = true;
            }
            setState(() {
              drawingPoints.add(details.localPosition);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              drawingPoints.add(details.localPosition);
            });
          },
          onPanEnd: (details) {
            setState(() {
              drawingPoints.add(Offset.infinite);
            });
          },
          child: CustomPaint(
            painter: DrawingPainter(drawingPoints),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _clearDrawing,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: isDrawingStarted ? _completeDrawing : null,
          icon: const Icon(Icons.check),
          label: const Text('Complete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildScoringInterface() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Drawing Completed',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drawing time: ${drawingTime?.inSeconds ?? 0} seconds',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Show the completed drawing
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: DrawingPainter(drawingPoints),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 20),

            _buildScoringCriteria(),
            const SizedBox(height: 20),

            _buildScoreSelection(),
            const SizedBox(height: 20),

            _buildNotesSection(),
            const SizedBox(height: 20),

            _buildResultsSection(),
            const SizedBox(height: 20),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringCriteria() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scoring Criteria:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...ClockDrawingTest.scoringCriteria.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: entry.key == selectedScore ? Colors.blue : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          entry.key.toString(),
                          style: TextStyle(
                            color: entry.key == selectedScore ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: entry.key == selectedScore ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Score (1-6):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3, 4, 5, 6].map((score) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedScore = score;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selectedScore == score ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedScore == score ? Colors.blue.shade700 : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        score.toString(),
                        style: TextStyle(
                          color: selectedScore == score ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scoring Notes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add notes about the drawing quality, errors, or observations...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                scoringNotes = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    final results = ClockDrawingResults(
      score: selectedScore,
      scoringNotes: scoringNotes,
      completedAt: DateTime.now(),
      drawingTime: drawingTime ?? Duration.zero,
    );

    return Card(
      color: _getInterpretationColor(results.interpretation),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getInterpretationIcon(results.interpretation),
                  size: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Test Interpretation:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $selectedScore/6',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _getInterpretationText(results.interpretation),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _retakeTest,
          icon: const Icon(Icons.refresh),
          label: const Text('Retake Test'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveResults,
          icon: const Icon(Icons.save),
          label: const Text('Save Results'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getInterpretationColor(ClockDrawingInterpretation interpretation) {
    switch (interpretation) {
      case ClockDrawingInterpretation.normal:
        return Colors.green;
      case ClockDrawingInterpretation.mildImpairment:
        return Colors.orange;
      case ClockDrawingInterpretation.severeImpairment:
        return Colors.red;
    }
  }

  IconData _getInterpretationIcon(ClockDrawingInterpretation interpretation) {
    switch (interpretation) {
      case ClockDrawingInterpretation.normal:
        return Icons.check_circle;
      case ClockDrawingInterpretation.mildImpairment:
        return Icons.warning;
      case ClockDrawingInterpretation.severeImpairment:
        return Icons.error;
    }
  }

  String _getInterpretationText(ClockDrawingInterpretation interpretation) {
    switch (interpretation) {
      case ClockDrawingInterpretation.normal:
        return 'Normal cognitive function (Score 5-6)';
      case ClockDrawingInterpretation.mildImpairment:
        return 'Mild cognitive impairment (Score 3-4)';
      case ClockDrawingInterpretation.severeImpairment:
        return 'Severe cognitive impairment (Score 1-2)';
    }
  }

  void _clearDrawing() {
    setState(() {
      drawingPoints.clear();
      isDrawingStarted = false;
      startTime = null;
    });
  }

  void _completeDrawing() {
    if (startTime != null) {
      drawingTime = DateTime.now().difference(startTime!);
    }

    setState(() {
      isTestCompleted = true;
    });
  }

  void _retakeTest() {
    setState(() {
      drawingPoints.clear();
      isDrawingStarted = false;
      isTestCompleted = false;
      startTime = null;
      drawingTime = null;
      selectedScore = 6;
      scoringNotes = '';
    });
  }

  Future<void> _saveResults() async {
    final results = ClockDrawingResults(
      score: selectedScore,
      scoringNotes: scoringNotes,
      completedAt: DateTime.now(),
      drawingTime: drawingTime ?? Duration.zero,
    );

    // Save to database
    final notifier = ref.read(assessmentProvider.notifier);
    final assessment = Assessment(
      type: AssessmentType.visuospatialSkills,
      score: selectedScore,
      maxScore: 6,
      notes: 'Clock Drawing Test - ${results.interpretation.toString().split('.').last}',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await notifier.addAssessment(assessment);

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Results Saved'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clock Drawing Test completed successfully.'),
            const SizedBox(height: 8),
            Text('Final Score: ${results.score}/6'),
            Text('Interpretation: ${_getInterpretationText(results.interpretation)}'),
            Text('Drawing Time: ${results.drawingTime.inSeconds} seconds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to main screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {

  DrawingPainter(this.points);
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}