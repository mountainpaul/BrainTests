import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/database_provider.dart';
import '../widgets/custom_card.dart';

class SDMTTestScreen extends ConsumerStatefulWidget {
  const SDMTTestScreen({super.key});

  @override
  ConsumerState<SDMTTestScreen> createState() => _SDMTTestScreenState();
}

class _SDMTTestScreenState extends ConsumerState<SDMTTestScreen> {
  Timer? _timer;
  
  // Test state
  bool _testStarted = false;
  bool _testCompleted = false;
  int _remainingSeconds = 90; // 90 second test
  
  // Test data
  Map<String, String> _symbolToDigitMap = {};
  List<String> _testSymbols = [];
  final List<String> _userAnswers = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  
  // Input controller
  final _answerController = TextEditingController();
  final _focusNode = FocusNode();
  
  // Symbol set - using geometric shapes similar to standard SDMT
  // 2 L-shapes, 2 T-shapes, 2 crosses, 3 basic shapes
  static const List<String> symbols = ['L', 'Γ', 'T', '⊥', '×', '+', '○', '△', '□'];
  static const List<String> digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  @override
  void initState() {
    super.initState();
    _generateSymbolMap();
    _generateTestSequence();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _generateSymbolMap() {
    // Create a random mapping from symbols to digits
    final List<String> shuffledDigits = List.from(digits);
    shuffledDigits.shuffle();
    
    _symbolToDigitMap = {};
    for (int i = 0; i < symbols.length; i++) {
      _symbolToDigitMap[symbols[i]] = shuffledDigits[i];
    }
  }

  void _generateTestSequence() {
    // Generate a sequence of 110 symbols (more than can be completed in 90 seconds)
    final random = Random();
    _testSymbols = [];
    for (int i = 0; i < 110; i++) {
      _testSymbols.add(symbols[random.nextInt(symbols.length)]);
    }
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _remainingSeconds = 90;
      _currentIndex = 0;
      _userAnswers.clear();
      _correctAnswers = 0;
    });
    
    // Auto-focus the input field
    _focusNode.requestFocus();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        _completeTest();
      }
    });
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    
    if (answer.isEmpty) return;
    
    setState(() {
      _userAnswers.add(answer);
      
      // Check if answer is correct
      final correctDigit = _symbolToDigitMap[_testSymbols[_currentIndex]];
      if (answer == correctDigit) {
        _correctAnswers++;
      }
      
      _currentIndex++;
      _answerController.clear();
    });
    
    // Auto-focus for next answer
    _focusNode.requestFocus();
    
    // Check if we've completed all symbols (unlikely but possible)
    if (_currentIndex >= _testSymbols.length) {
      _completeTest();
    }
  }

  void _completeTest() {
    _timer?.cancel();
    setState(() {
      _testCompleted = true;
    });
    _saveTestResults();
  }

  Future<void> _saveTestResults() async {
    final database = ref.read(databaseProvider);
    
    await database.into(database.assessmentTable).insert(
      AssessmentTableCompanion.insert(
        type: AssessmentType.processingSpeed,
        score: _correctAnswers,
        maxScore: _currentIndex, // Total attempted
        notes: Value('SDMT - Correct: $_correctAnswers, Attempted: $_currentIndex, Accuracy: ${_getAccuracyPercentage()}%'),
        completedAt: DateTime.now(),
      ),
    );
  }

  double _getAccuracyPercentage() {
    if (_currentIndex == 0) return 0.0;
    return (_correctAnswers / _currentIndex) * 100;
  }

  String _getPerformanceLevel() {
    // Based on age-adjusted norms for SDMT
    if (_correctAnswers >= 55) return 'Excellent';
    if (_correctAnswers >= 45) return 'Good';
    if (_correctAnswers >= 35) return 'Average';
    if (_correctAnswers >= 25) return 'Below Average';
    return 'Poor';
  }

  Color _getPerformanceColor() {
    if (_correctAnswers >= 55) return Colors.green;
    if (_correctAnswers >= 45) return Colors.lightGreen;
    if (_correctAnswers >= 35) return Colors.orange;
    if (_correctAnswers >= 25) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symbol-Digit Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_testStarted) _buildInstructions(),
            if (_testStarted && !_testCompleted) _buildActiveTest(),
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
                    const Icon(Icons.grid_3x3, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Symbol-Digit Modalities Test',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This test measures processing speed and sustained attention by having you match symbols to numbers.',
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
                  'Key (Memorize This)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      // Symbol to digit mapping
                      Row(
                        children: symbols.map((symbol) => Expanded(
                          child: Container(
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                symbol,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: symbols.map((symbol) => Expanded(
                          child: Container(
                            height: 32,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.grey[100],
                            ),
                            child: Center(
                              child: Text(
                                _symbolToDigitMap[symbol]!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
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
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('1. Study the symbol-to-number key above'),
                const Text('2. You will have 90 seconds'),
                const Text('3. For each symbol shown, type the corresponding number'),
                const Text('4. Press Enter or Next to submit each answer'),
                const Text('5. Work as quickly and accurately as possible'),
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
                          'Take a moment to memorize the key. The key will remain visible during the test.',
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

  Widget _buildActiveTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer and progress
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _remainingSeconds <= 10 ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Symbol-Digit Matching Test',
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
              const SizedBox(height: 8),
              Text(
                'Progress: $_currentIndex | Correct: $_correctAnswers',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Key reference (smaller version)
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  'Reference Key',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: symbols.map((symbol) => Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _symbolToDigitMap[symbol]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Current symbol and input
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'What number does this symbol represent?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentIndex < _testSymbols.length
                          ? _testSymbols[_currentIndex]
                          : '?',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Enter number',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onSubmitted: (_) => _submitAnswer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent answers
        if (_userAnswers.isNotEmpty)
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Answers',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _userAnswers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final answer = entry.value;
                      final correctAnswer = _symbolToDigitMap[_testSymbols[index]];
                      final isCorrect = answer == correctAnswer;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_testSymbols[index]}→$answer',
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList().reversed.take(20).toList(),
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
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: _getPerformanceColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Test Complete!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getPerformanceColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getPerformanceColor().withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Score',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_correctAnswers',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(),
                        ),
                      ),
                      Text(
                        'correct answers',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPerformanceLevel(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(),
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
        
        // Detailed results
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Results',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildResultRow('Correct Answers:', '$_correctAnswers'),
                _buildResultRow('Total Attempted:', '$_currentIndex'),
                _buildResultRow('Accuracy:', '${_getAccuracyPercentage().toStringAsFixed(1)}%'),
                _buildResultRow('Processing Rate:', '${(_correctAnswers / 90 * 60).toStringAsFixed(1)} per minute'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Score interpretation
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
                _buildScoreRange('55+', 'Excellent', Colors.green),
                _buildScoreRange('45-54', 'Good', Colors.lightGreen),
                _buildScoreRange('35-44', 'Average', Colors.orange),
                _buildScoreRange('25-34', 'Below Average', Colors.deepOrange),
                _buildScoreRange('0-24', 'Poor', Colors.red),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'The SDMT measures processing speed and sustained attention. Higher scores indicate better cognitive processing efficiency.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
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
                    _testCompleted = false;
                    _remainingSeconds = 90;
                    _currentIndex = 0;
                    _correctAnswers = 0;
                    _userAnswers.clear();
                  });
                  _answerController.clear();
                  _generateSymbolMap();
                  _generateTestSequence();
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRange(String range, String level, Color color) {
    final isCurrentLevel = level == _getPerformanceLevel();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            level,
            style: TextStyle(
              fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLevel ? color : null,
            ),
          ),
          if (isCurrentLevel) ...[ 
            const Spacer(),
            Icon(Icons.arrow_left, color: color),
          ],
        ],
      ),
    );
  }
}