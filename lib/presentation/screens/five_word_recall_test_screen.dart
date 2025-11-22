import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/assessment.dart';
import '../providers/assessment_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/custom_card.dart';

class FiveWordRecallTestScreen extends ConsumerStatefulWidget {
  const FiveWordRecallTestScreen({super.key});

  @override
  ConsumerState<FiveWordRecallTestScreen> createState() => _FiveWordRecallTestScreenState();
}

class _FiveWordRecallTestScreenState extends ConsumerState<FiveWordRecallTestScreen> {
  Timer? _timer;
  
  // Test phases
  bool _testStarted = false;
  bool _studyPhaseComplete = false;
  bool _immediateRecallComplete = false;
  bool _delayPhaseComplete = false;
  bool _testCompleted = false;
  
  // Timing
  int _remainingSeconds = 20; // Study phase: 20 seconds
  final int _delaySeconds = 300; // 5-minute delay
  
  // Test data
  List<String> _testWords = [];
  List<String> _immediateRecall = [];
  List<String> _delayedRecall = [];
  
  // Input controllers
  final List<TextEditingController> _immediateControllers = [];
  final List<TextEditingController> _delayedControllers = [];
  
  // Scoring
  int _immediateScore = 0;
  int _delayedScore = 0;
  
  static const List<List<String>> wordLists = [
    ['FACE', 'VELVET', 'CHURCH', 'DAISY', 'RED'],
    ['VILLAGE', 'KITCHEN', 'BABY', 'TABLE', 'RIVER'],
    ['CAPTAIN', 'HONEY', 'LION', 'PENCIL', 'CARPET'],
    ['LETTER', 'QUEEN', 'CORNER', 'CABBAGE', 'TRAIN'],
    ['MOUNTAIN', 'GLASSES', 'TOWEL', 'CLOUD', 'BOAT'],
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomWordList();
    for (int i = 0; i < 5; i++) {
      _immediateControllers.add(TextEditingController());
      _delayedControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _immediateControllers) {
      controller.dispose();
    }
    for (final controller in _delayedControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectRandomWordList() {
    final random = Random();
    _testWords = wordLists[random.nextInt(wordLists.length)];
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _remainingSeconds = 20;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        _completeStudyPhase();
      }
    });
  }

  void _completeStudyPhase() {
    _timer?.cancel();
    setState(() {
      _studyPhaseComplete = true;
    });
  }

  void _submitImmediateRecall() {
    _immediateRecall = _immediateControllers.map((c) => c.text.trim().toUpperCase()).toList();
    _calculateImmediateScore();
    setState(() {
      _immediateRecallComplete = true;
      _remainingSeconds = _delaySeconds;
    });
    _startDelayTimer();
  }

  void _startDelayTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        _completeDelayPhase();
      }
    });
  }

  void _completeDelayPhase() {
    _timer?.cancel();
    setState(() {
      _delayPhaseComplete = true;
    });
  }

  void _submitDelayedRecall() {
    _delayedRecall = _delayedControllers.map((c) => c.text.trim().toUpperCase()).toList();
    _calculateDelayedScore();
    _saveTestResults();
    setState(() {
      _testCompleted = true;
    });
  }

  void _calculateImmediateScore() {
    _immediateScore = 0;
    for (int i = 0; i < _immediateRecall.length; i++) {
      if (i < _testWords.length && _immediateRecall[i] == _testWords[i]) {
        _immediateScore++;
      }
    }
  }

  void _calculateDelayedScore() {
    _delayedScore = 0;
    for (int i = 0; i < _delayedRecall.length; i++) {
      if (i < _testWords.length && _delayedRecall[i] == _testWords[i]) {
        _delayedScore++;
      }
    }
  }

  Future<void> _saveTestResults() async {
    final notifier = ref.read(assessmentProvider.notifier);

    // Save immediate recall test
    final immediateAssessment = Assessment(
      type: AssessmentType.memoryRecall,
      score: _immediateScore,
      maxScore: 5,
      notes: '5-Word Recall (Immediate): ${_immediateRecall.join(", ")}',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await notifier.addAssessment(immediateAssessment);

    // Save delayed recall test
    final delayedAssessment = Assessment(
      type: AssessmentType.memoryRecall,
      score: _delayedScore,
      maxScore: 5,
      notes: '5-Word Recall (Delayed): ${_delayedRecall.join(", ")}',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await notifier.addAssessment(delayedAssessment);
  }

  String _getImmediatePerformanceLevel() {
    if (_immediateScore == 5) return 'Excellent';
    if (_immediateScore >= 4) return 'Good';
    if (_immediateScore >= 3) return 'Average';
    if (_immediateScore >= 2) return 'Below Average';
    return 'Poor';
  }

  String _getDelayedPerformanceLevel() {
    if (_delayedScore >= 4) return 'Excellent';
    if (_delayedScore >= 3) return 'Good';
    if (_delayedScore >= 2) return 'Average';
    if (_delayedScore >= 1) return 'Below Average';
    return 'Poor';
  }

  Color _getPerformanceColor(int score, bool isDelayed) {
    final threshold = isDelayed ? 2 : 3;
    if (score >= threshold + 2) return Colors.green;
    if (score >= threshold + 1) return Colors.lightGreen;
    if (score >= threshold) return Colors.orange;
    if (score >= threshold - 1) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Word Recall Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_testStarted) _buildInstructions(),
            if (_testStarted && !_studyPhaseComplete) _buildStudyPhase(),
            if (_studyPhaseComplete && !_immediateRecallComplete) _buildImmediateRecall(),
            if (_immediateRecallComplete && !_delayPhaseComplete) _buildDelayPhase(),
            if (_delayPhaseComplete && !_testCompleted) _buildDelayedRecall(),
            if (_testCompleted) _buildResults(),
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
                    const Icon(Icons.memory, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '5-Word Recall Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This test assesses short-term and working memory by testing immediate and delayed recall of five words.',
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
                  'Test Phases',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildPhaseStep('1', 'Study Phase', '20 seconds to memorize 5 words'),
                _buildPhaseStep('2', 'Immediate Recall', 'Write down the 5 words immediately'),
                _buildPhaseStep('3', 'Delay Period', '5-minute break (distraction-free)'),
                _buildPhaseStep('4', 'Delayed Recall', 'Write down the 5 words again'),
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
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Try to create mental images or associations to help remember the words.',
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
            onPressed: _startTest,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test'),
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

  Widget _buildPhaseStep(String number, String title, String description) {
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

  Widget _buildStudyPhase() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _remainingSeconds <= 5 ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Study These Words',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '$_remainingSeconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'seconds remaining',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Memorize These 5 Words',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                for (int i = 0; i < _testWords.length; i++) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      _testWords[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImmediateRecall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Immediate Recall',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Write down the 5 words you just studied, in any order:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 5; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _immediateControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Word ${i + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitImmediateRecall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit Immediate Recall'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDelayPhase() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Delay Period',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'remaining',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.timer, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  '5-Minute Break',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait for the timer to complete. Try to avoid thinking about the words during this break.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Immediate Recall Results:\nYou will see your scores after the delayed recall phase.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDelayedRecall() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delayed Recall',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Now write down the same 5 words again, in any order:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 5; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _delayedControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Word ${i + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitDelayedRecall,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete Test'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                  'Test Complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // Immediate Recall Results
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(_immediateScore, false).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor(_immediateScore, false).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Immediate Recall',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_immediateScore/5',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(_immediateScore, false),
                        ),
                      ),
                      Text(
                        _getImmediatePerformanceLevel(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(_immediateScore, false),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Delayed Recall Results
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor(_delayedScore, true).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor(_delayedScore, true).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Delayed Recall',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_delayedScore/5',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(_delayedScore, true),
                        ),
                      ),
                      Text(
                        _getDelayedPerformanceLevel(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(_delayedScore, true),
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
        
        // Word Comparison
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Word Comparison',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < 5; i++) ...[
                  _buildWordComparison(i),
                  if (i < 4) const Divider(),
                ],
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
                  'Score Interpretation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Immediate Recall:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                _buildScoreRange('5', 'Excellent', Colors.green, false),
                _buildScoreRange('4', 'Good', Colors.lightGreen, false),
                _buildScoreRange('3', 'Average', Colors.orange, false),
                _buildScoreRange('2', 'Below Average', Colors.deepOrange, false),
                _buildScoreRange('0-1', 'Poor', Colors.red, false),
                const SizedBox(height: 12),
                Text(
                  'Delayed Recall:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                _buildScoreRange('4-5', 'Excellent', Colors.green, true),
                _buildScoreRange('3', 'Good', Colors.lightGreen, true),
                _buildScoreRange('2', 'Average', Colors.orange, true),
                _buildScoreRange('1', 'Below Average', Colors.deepOrange, true),
                _buildScoreRange('0', 'Poor', Colors.red, true),
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
                    _studyPhaseComplete = false;
                    _immediateRecallComplete = false;
                    _delayPhaseComplete = false;
                    _testCompleted = false;
                    _immediateRecall.clear();
                    _delayedRecall.clear();
                    _immediateScore = 0;
                    _delayedScore = 0;
                    _remainingSeconds = 20;
                  });
                  _selectRandomWordList();
                  for (final controller in _immediateControllers) {
                    controller.clear();
                  }
                  for (final controller in _delayedControllers) {
                    controller.clear();
                  }
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

  Widget _buildWordComparison(int index) {
    final correct = _testWords[index];
    final immediateAnswer = index < _immediateRecall.length ? _immediateRecall[index] : '';
    final delayedAnswer = index < _delayedRecall.length ? _delayedRecall[index] : '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${index + 1}.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(correct, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Immediate:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(
                  immediateAnswer.isEmpty ? '(blank)' : immediateAnswer,
                  style: TextStyle(
                    color: immediateAnswer == correct ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delayed:', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(
                  delayedAnswer.isEmpty ? '(blank)' : delayedAnswer,
                  style: TextStyle(
                    color: delayedAnswer == correct ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRange(String range, String level, Color color, bool isDelayed) {
    final currentScore = isDelayed ? _delayedScore : _immediateScore;
    final currentLevel = isDelayed ? _getDelayedPerformanceLevel() : _getImmediatePerformanceLevel();
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
            width: 50,
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