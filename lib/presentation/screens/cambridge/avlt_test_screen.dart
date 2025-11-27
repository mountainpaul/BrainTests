import 'dart:async';
import 'package:flutter/material.dart';
import 'package:brain_tests/core/services/tts_service.dart';
import 'package:brain_tests/core/services/google_cloud_speech_service.dart';
import 'package:brain_tests/data/word_lists/word_list_manager.dart';
import 'package:brain_tests/domain/services/avlt_scoring_service.dart';
import 'package:brain_tests/domain/entities/cambridge_assessment.dart';

/// Audio Verbal Learning Test (AVLT) Screen
/// Tests verbal episodic memory with:
/// - 1 immediate recall trial
/// - 5-minute delay
/// - 1 delayed recall trial
///
/// Scoring:
/// - Serial position score (words in correct position)
/// - Total recall score (words recalled anywhere)
class AVLTTestScreen extends StatefulWidget {
  const AVLTTestScreen({super.key});

  @override
  State<AVLTTestScreen> createState() => _AVLTTestScreenState();
}

class _AVLTTestScreenState extends State<AVLTTestScreen> {
  // Services
  final TTSService _ttsService = TTSService();
  GoogleCloudSpeechService? _cloudSpeech;
  final WordListManager _wordListManager = WordListManager();
  StreamSubscription<SpeechRecognitionResult>? _cloudSpeechSubscription;
  Timer? _delayTimer;

  // Test state
  TestPhase _currentPhase = TestPhase.instructions;
  int _currentTrial = 1;
  List<String> _targetWords = [];
  DateTime? _testStartTime;
  DateTime? _delayStartTime;

  // Trial results
  final List<TrialData> _immediateTrials = [];
  TrialData? _delayedTrial;

  // UI state
  String _statusMessage = '';
  List<String> _currentUserWords = [];
  bool _isProcessing = false;
  bool _isListening = false;
  String _currentRecognizedText = '';
  int _lastProcessedWordCount = 0; // Track words from partial results

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _cloudSpeechSubscription?.cancel();
    _cloudSpeech?.dispose();
    _delayTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Initializing...';
    });

    try {
      // Initialize services
      await _ttsService.initialize();

      // Initialize Google Cloud Speech
      _cloudSpeech = GoogleCloudSpeechService();
      final cloudAvailable = await _cloudSpeech!.initialize();

      if (!cloudAvailable) {
        _showError('Google Cloud Speech not configured. Please add credentials.');
        return;
      }

      // Setup result stream
      _cloudSpeechSubscription = _cloudSpeech!.resultStream.listen((result) {
        _handleSpeechResult(result.transcript, result.isFinal);
      });

      // Load word list
      await _wordListManager.initialize();
      _targetWords = await _wordListManager.getNextWordList();

      setState(() {
        _isProcessing = false;
        _statusMessage = 'Ready to begin';
      });
    } catch (e) {
      _showError('Initialization failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _statusMessage = message;
      _isProcessing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _startTest() async {
    setState(() {
      _currentPhase = TestPhase.trial1;
      _currentTrial = 1;
      _testStartTime = DateTime.now();
    });
    await _runTrial();
  }

  void _handleSpeechResult(String text, bool isFinal) {
    if (!mounted) return;

    final recognizedText = text.toLowerCase().trim();

    // Debug logging (matches Fluency test)
    print('=== AVLT: Speech result ===');
    print('  Final: $isFinal');
    print('  Text: "$recognizedText"');
    print('  Current word count: ${_currentUserWords.length}');

    if (recognizedText.isNotEmpty) {
      // Split by multiple delimiters (same as Fluency)
      final words = recognizedText
          .split(RegExp(r'[,\s.!?;:]+'))
          .map((word) => word.trim().replaceAll(RegExp(r'[^\w]'), ''))
          .where((word) => word.isNotEmpty)
          .toList();

      print('  Extracted ${words.length} words from text');

      // For partial results: only process NEW words that appeared since last update
      // For final results: process all words
      final int startIndex = isFinal ? 0 : _lastProcessedWordCount;
      final List<String> newWords = words.sublist(startIndex.clamp(0, words.length));

      print('  Processing ${newWords.length} new words (starting from index $startIndex)');

      // Process each new word
      int newWordsAdded = 0;
      for (final String word in newWords) {
        if (word.length < 2) {
          print('  ✗ Skipping "$word" - too short');
          continue;
        }

        // Add word if not duplicate and we have room
        if (!_currentUserWords.contains(word) && _currentUserWords.length < 5) {
          setState(() {
            _currentUserWords.add(word);
            newWordsAdded++;
            print('  ✓ Added: "$word"');
          });
        }
      }

      // Update the last processed count for next partial result
      if (!isFinal) {
        _lastProcessedWordCount = words.length;
      } else {
        // Reset on final result (for next recognition cycle)
        _lastProcessedWordCount = 0;
      }

      if (newWordsAdded > 0) {
        print('  Added $newWordsAdded new word(s). Total: ${_currentUserWords.length}');
      }

      print('=== AVLT: Result processed (${isFinal ? 'FINAL' : 'PARTIAL'}), total words captured: ${_currentUserWords.length} ===');

      // Update display with current recognized text
      setState(() {
        _currentRecognizedText = recognizedText;
      });

      // If we have 5 words, stop and process (but let timeout handle stopping)
      if (_currentUserWords.length >= 5 && _isListening) {
        print('=== AVLT: Got 5 words, processing results ===');
        _stopListeningAndProcess();
      }
    }
  }

  void _stopListeningAndProcess() async {
    if (!_isListening) return;

    await _cloudSpeech?.stopListening();
    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    _processTrialResult(_currentUserWords);
  }

  void _processTrialResult(List<String> userWords) {
    // Calculate scores
    final serialScore = calculateSerialPositionScore(_targetWords, userWords);
    final totalScore = calculateTotalRecallScore(_targetWords, userWords);

    // Save trial data
    final trialData = TrialData(
      trialNumber: _currentTrial,
      userWords: userWords,
      serialScore: serialScore,
      totalScore: totalScore,
      timestamp: DateTime.now(),
    );

    if (_currentPhase == TestPhase.delayedRecall) {
      setState(() {
        _delayedTrial = trialData;
        _isProcessing = false;
        _statusMessage = 'Delayed recall complete: $totalScore/5 words recalled';
      });
    } else {
      setState(() {
        _immediateTrials.add(trialData);
        _isProcessing = false;
        _statusMessage = 'Trial $_currentTrial complete: $totalScore/5 words recalled';
      });
    }

    // Move to next phase after short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextPhase();
    });
  }

  Future<void> _runTrial() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Trial $_currentTrial: Listen to the words...';
      _currentUserWords = [];
      _currentRecognizedText = '';
    });

    // Speak the word list
    await _ttsService.speakWordList(_targetWords);

    // Small delay before listening
    await Future.delayed(const Duration(milliseconds: 500));

    // Start listening with Google Cloud Speech
    if (!mounted) return;

    setState(() {
      _statusMessage = 'Now say the words you remember...';
      _isProcessing = false;
    });

    try {
      await _cloudSpeech!.startListening();
      if (!mounted) return;

      setState(() {
        _isListening = true;
      });

      // Auto-stop after 60 seconds (or when 5 words detected in _handleSpeechResult)
      Future.delayed(const Duration(seconds: 60), () async {
        if (_isListening && mounted) {
          await _cloudSpeech!.stopListening();
          if (!mounted) return;

          setState(() {
            _isListening = false;
          });

          // Process whatever we have
          if (_currentUserWords.isEmpty && _currentRecognizedText.isNotEmpty) {
            final words = _currentRecognizedText.split(RegExp(r'\s+'))
                .map((w) => w.trim())
                .where((w) => w.isNotEmpty)
                .take(5)
                .toList();
            _processTrialResult(words);
          }
        }
      });
    } catch (e) {
      _showError('Failed to start speech recognition: $e');
    }
  }

  void _nextPhase() {
    switch (_currentPhase) {
      case TestPhase.instructions:
        _startTest();
        break;
      case TestPhase.trial1:
        setState(() {
          _currentPhase = TestPhase.delay;
        });
        _startDelay();
        break;
      case TestPhase.delay:
        setState(() {
          _currentPhase = TestPhase.delayedRecall;
        });
        _runDelayedRecall();
        break;
      case TestPhase.delayedRecall:
        setState(() {
          _currentPhase = TestPhase.results;
        });
        _showResults();
        break;
      case TestPhase.results:
        // Stay on results
        break;
    }
  }

  void _startDelay() {
    setState(() {
      _delayStartTime = DateTime.now();
      _statusMessage = 'Please wait 5 minutes before the final recall...';
      _isProcessing = false;
    });

    // Start 5-minute timer with periodic updates
    _delayTimer?.cancel();
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentPhase != TestPhase.delay) {
        timer.cancel();
        return;
      }

      setState(() {
        // Rebuild to update timer display
        final elapsed = DateTime.now().difference(_delayStartTime!);
        if (elapsed.inMinutes >= 5) {
          timer.cancel();
          _nextPhase();
        }
      });
    });
  }

  Future<void> _runDelayedRecall() async {
    // Use the same logic as _runTrial
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Delayed Recall: Say the words you remember from the beginning...';
      _currentUserWords = [];
      _currentRecognizedText = '';
    });

    // Speak the recall prompt
    await _ttsService.speakWord('Please recall the 5 words you were given.');

    // Small delay after speaking
    await Future.delayed(const Duration(milliseconds: 500));

    // Start listening with Google Cloud Speech
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    try {
      await _cloudSpeech!.startListening();
      if (!mounted) return;

      setState(() {
        _isListening = true;
      });

      // Auto-stop after 60 seconds
      Future.delayed(const Duration(seconds: 60), () async {
        if (_isListening && mounted) {
          await _cloudSpeech!.stopListening();
          if (!mounted) return;

          setState(() {
            _isListening = false;
          });

          // Process whatever we have
          if (_currentUserWords.isEmpty && _currentRecognizedText.isNotEmpty) {
            final words = _currentRecognizedText.split(RegExp(r'\s+'))
                .map((w) => w.trim())
                .where((w) => w.isNotEmpty)
                .take(5)
                .toList();
            _processTrialResult(words);
          }
        }
      });
    } catch (e) {
      _showError('Failed to start speech recognition: $e');
    }
  }

  void _showResults() {
    // Results are displayed in the build method
  }

  AVLTResult _buildResult() {
    final trial1 = _immediateTrials[0];
    final delayed = _delayedTrial!;

    // Learning slope not applicable with single trial
    final learningSlope = 0.0;

    final retention = calculateRetentionPercentage(
      trial1.totalScore,
      delayed.totalScore,
    );

    final totalTrials = 2; // 1 immediate + 1 delayed
    final totalCorrect = trial1.totalScore + delayed.totalScore;
    final accuracy = (totalCorrect / (totalTrials * 5)) * 100;

    final durationSeconds = DateTime.now().difference(_testStartTime!).inSeconds;

    return AVLTResult(
      completedAt: DateTime.now(),
      durationSeconds: durationSeconds,
      accuracy: accuracy,
      totalTrials: totalTrials,
      correctTrials: totalCorrect,
      errorCount: ((totalTrials * 5) - totalCorrect).toInt(),
      meanLatencyMs: 0.0, // Not applicable for AVLT
      medianLatencyMs: 0.0, // Not applicable for AVLT
      normScore: 0.0, // To be calculated based on age norms
      interpretation: _interpretPerformance(accuracy, retention, learningSlope),
      trial1SerialScore: trial1.serialScore,
      trial1TotalScore: trial1.totalScore,
      trial2SerialScore: 0, // Not used (single trial version)
      trial2TotalScore: 0, // Not used (single trial version)
      trial3SerialScore: 0, // Not used (single trial version)
      trial3TotalScore: 0, // Not used (single trial version)
      delayedSerialScore: delayed.serialScore,
      delayedTotalScore: delayed.totalScore,
      learningSlope: learningSlope,
      retentionPercentage: retention,
    );
  }

  String _interpretPerformance(double accuracy, double retention, double learningSlope) {
    if (accuracy >= 80 && retention >= 80 && learningSlope > 0) {
      return 'Excellent verbal memory with good learning and retention';
    } else if (accuracy >= 60 && retention >= 60) {
      return 'Good verbal memory performance';
    } else if (accuracy >= 40) {
      return 'Average verbal memory with room for improvement';
    } else {
      return 'Below average performance - may benefit from further assessment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Verbal Learning Test'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Phase indicator
              _buildPhaseIndicator(),
              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: _buildPhaseContent(),
              ),

              // Action button
              if (!_isProcessing && _currentPhase != TestPhase.delay)
                _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal, // Dark background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getPhaseIcon(),
            color: Colors.white, // White icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getPhaseTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon() {
    switch (_currentPhase) {
      case TestPhase.instructions:
        return Icons.info_outline;
      case TestPhase.trial1:
        return Icons.hearing;
      case TestPhase.delay:
        return Icons.timer;
      case TestPhase.delayedRecall:
        return Icons.psychology;
      case TestPhase.results:
        return Icons.assessment;
    }
  }

  String _getPhaseTitle() {
    switch (_currentPhase) {
      case TestPhase.instructions:
        return 'Instructions';
      case TestPhase.trial1:
        return 'Immediate Recall';
      case TestPhase.delay:
        return '5-Minute Delay';
      case TestPhase.delayedRecall:
        return 'Delayed Recall';
      case TestPhase.results:
        return 'Results';
    }
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case TestPhase.instructions:
        return _buildInstructions();
      case TestPhase.trial1:
        return _buildTrialContent();
      case TestPhase.delay:
        return _buildDelayContent();
      case TestPhase.delayedRecall:
        return _buildDelayedRecallContent();
      case TestPhase.results:
        return _buildResultsContent();
    }
  }

  Widget _buildInstructions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Instructions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '1',
            'You will hear 5 words spoken one at a time',
          ),
          _buildInstructionStep(
            '2',
            'After hearing all 5 words, say back as many as you remember in any order',
          ),
          _buildInstructionStep(
            '3',
            'If you can\'t remember a word, say "skip" to move to the next position',
          ),
          _buildInstructionStep(
            '4',
            'After a 5-minute break, you\'ll be asked to recall the words one final time. A notification will prompt you.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.mic, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This test requires microphone access for voice recognition.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _statusMessage,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_isProcessing)
            const CircularProgressIndicator()
          else if (_isListening)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: Colors.green, size: 32),
                          SizedBox(width: 12),
                          Text(
                            'LISTENING',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (_currentRecognizedText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Recognized:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentRecognizedText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            )
          else if (_currentUserWords.isNotEmpty)
            _buildUserWordsDisplay(),
        ],
      ),
    );
  }

  Widget _buildUserWordsDisplay() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.record_voice_over,
                size: 48,
                color: Colors.teal,
              ),
              const SizedBox(height: 16),
              const Text(
                'Words You Said:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _currentUserWords.map((word) {
                  final isCorrect = _targetWords.map((w) => w.toUpperCase()).contains(word.toUpperCase());
                  return Chip(
                    label: Text(
                      word,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDelayContent() {
    final elapsed = _delayStartTime != null
        ? DateTime.now().difference(_delayStartTime!)
        : Duration.zero;
    final remaining = const Duration(minutes: 5) - elapsed;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 64, color: Colors.teal),
          const SizedBox(height: 24),
          const Text(
            'Please wait...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can do another activity during this time.\nCome back when the timer ends.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayedRecallContent() {
    return _buildTrialContent();
  }

  Widget _buildResultsContent() {
    if (_delayedTrial == null) {
      return const Center(child: Text('No results available'));
    }

    final result = _buildResult();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Complete!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildResultCard(
            'Overall Accuracy',
            '${result.accuracy.toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.blue,
          ),
          _buildResultCard(
            'Learning Slope',
            result.learningSlope > 0
                ? '+${result.learningSlope.toStringAsFixed(1)} words'
                : '${result.learningSlope.toStringAsFixed(1)} words',
            Icons.trending_up,
            result.learningSlope > 0 ? Colors.green : Colors.orange,
          ),
          _buildResultCard(
            'Retention',
            '${result.retentionPercentage.toStringAsFixed(1)}%',
            Icons.memory,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          const Text(
            'Trial Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTrialSummary('Immediate Recall', result.trial1TotalScore, result.trial1SerialScore),
          _buildTrialSummary('Delayed Recall', result.delayedTotalScore, result.delayedSerialScore),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interpretation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(result.interpretation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialSummary(String trialName, int totalScore, int serialScore) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            trialName,
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                'Total: $totalScore/5',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Text(
                'Serial: $serialScore/5',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (_currentPhase) {
      case TestPhase.instructions:
        buttonText = 'Start Test';
        onPressed = _startTest;
        break;
      case TestPhase.results:
        buttonText = 'Finish';
        onPressed = () => Navigator.of(context).pop();
        break;
      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

enum TestPhase {
  instructions,
  trial1,
  delay,
  delayedRecall,
  results,
}

class TrialData {
  final int trialNumber;
  final List<String> userWords;
  final int serialScore;
  final int totalScore;
  final DateTime timestamp;

  TrialData({
    required this.trialNumber,
    required this.userWords,
    required this.serialScore,
    required this.totalScore,
    required this.timestamp,
  });
}
