import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/native_speech_recognition_service.dart';
import '../../core/services/google_cloud_speech_service.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/assessment.dart';
import '../providers/assessment_provider.dart';
import '../widgets/custom_card.dart';

class LanguageSkillsTestScreen extends ConsumerStatefulWidget {
  const LanguageSkillsTestScreen({
    super.key,
    this.category,
  });

  final String? category; // e.g., "animals", "words starting with F", "types of furniture"

  @override
  ConsumerState<LanguageSkillsTestScreen> createState() => _LanguageSkillsTestScreenState();
}

class _LanguageSkillsTestScreenState extends ConsumerState<LanguageSkillsTestScreen> {
  final _textController = TextEditingController();
  final _nativeSpeech = NativeSpeechRecognitionService();
  GoogleCloudSpeechService? _cloudSpeech;
  bool _useCloudSpeech = false;
  StreamSubscription<SpeechRecognitionResult>? _cloudSpeechSubscription;
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _testStarted = false;
  bool _testCompleted = false;
  bool _speechEnabled = false;
  bool _speechListening = false;
  String _speechStatus = 'ready';
  double _soundLevel = 0.0;
  final List<String> _enteredWords = [];
  List<String> _validWords = [];
  int _score = 0;
  int _lastProcessedWordCount = 0; // Track how many words we've processed from partial results

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _cloudSpeechSubscription?.cancel();
    _cloudSpeech?.dispose();
    _nativeSpeech.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    print('=== LANGUAGE SKILLS TEST: Initializing speech services ===');

    // Try to initialize Google Cloud Speech first
    _cloudSpeech = GoogleCloudSpeechService();
    final isConfigured = await _cloudSpeech!.isConfigured();

    if (isConfigured) {
      print('✓ Using Google Cloud Speech (no beeping!)');
      _useCloudSpeech = true;

      // Setup Google Cloud Speech streams
      _cloudSpeechSubscription = _cloudSpeech!.resultStream.listen((result) {
        _handleSpeechResult(result.transcript, result.isFinal);
      });

      _cloudSpeech!.errorStream.listen((error) {
        print('=== LANGUAGE SKILLS: Cloud speech error: $error ===');
      });

      _cloudSpeech!.statusStream.listen((status) {
        print('=== LANGUAGE SKILLS: Cloud speech status: $status ===');
      });

      setState(() {
        _speechEnabled = true;
      });
    } else {
      print('⚠️  Using native speech (will beep) - Google Cloud credentials not configured');
      _useCloudSpeech = false;

      // Setup callbacks for native speech recognition (fallback)
      _nativeSpeech.onResult = (String text, bool isFinal) {
        _handleSpeechResult(text, isFinal);
      };

      _nativeSpeech.onError = (String error) {
        print('=== LANGUAGE SKILLS: Native speech error: $error ===');
      };

      _nativeSpeech.onSoundLevel = (double level) {
        if (mounted) {
          setState(() {
            _soundLevel = level;
          });
        }
      };

      _nativeSpeech.onStatus = (String status) {
        print('=== LANGUAGE SKILLS: Native speech status: $status ===');
        if (mounted) {
          setState(() {
            _speechStatus = status;
          });
        }
      };

      setState(() {
        _speechEnabled = true;
      });
    }

    print('=== LANGUAGE SKILLS: Speech initialization complete, enabled: $_speechEnabled ===');
  }

  void _startTest() {
    print('=== LANGUAGE SKILLS: Starting test, _speechEnabled: $_speechEnabled ===');
    setState(() {
      _testStarted = true;
      _remainingSeconds = 60;  // Full 60 seconds
    });

    // Start continuous listening immediately
    _startListening();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _completeTest();
      }
    });
  }

  void _addWord() {
    final word = _textController.text.trim().toLowerCase();
    if (word.isNotEmpty && !_enteredWords.contains(word)) {
      setState(() {
        _enteredWords.add(word);
        _textController.clear();
      });
    }
  }

  void _startListening() async {
    print('=== LANGUAGE SKILLS: Starting speech recognition ===');
    if (_speechEnabled && !_testCompleted) {
      try {
        if (_useCloudSpeech) {
          await _cloudSpeech!.startListening();
          print('=== LANGUAGE SKILLS: Google Cloud speech started ===');
        } else {
          await _nativeSpeech.startListening();
          print('=== LANGUAGE SKILLS: Native speech started ===');
        }
        setState(() {
          _speechListening = true;
        });
      } catch (e) {
        print('=== LANGUAGE SKILLS: Error starting speech: $e ===');
      }
    }
  }

  void _stopListening() async {
    print('=== LANGUAGE SKILLS: Stopping speech recognition ===');
    try {
      if (_useCloudSpeech) {
        await _cloudSpeech!.stopListening();
      } else {
        await _nativeSpeech.stopListening();
      }
      setState(() {
        _speechListening = false;
      });
    } catch (e) {
      print('=== LANGUAGE SKILLS: Error stopping speech: $e ===');
    }
  }

  void _handleSpeechResult(String text, bool isFinal) {
    final recognizedText = text.toLowerCase().trim();

    // Enhanced debug logging
    print('=== LANGUAGE SKILLS: Speech result ===');
    print('  Final: $isFinal');
    print('  Text: "$recognizedText"');
    print('  Current word count: ${_enteredWords.length}');

    if (recognizedText.isNotEmpty) {
      // Split by multiple delimiters and clean up words
      final words = recognizedText
          .split(RegExp(r'[,\s.!?;:]+'))
          .map((word) => word.trim().replaceAll(RegExp(r'[^\w]'), ''))
          .where((word) => word.isNotEmpty)  // Accept all non-empty words
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
        if (word.length < 3) {
          // Skip very short words - likely fragments
          print('  ✗ Skipping "$word" - too short (< 3 chars)');
          continue;
        }

        // Check if this word is similar to any existing word
        // We want to keep the LONGEST version
        bool foundSimilar = false;
        final List<String> wordsToRemove = [];

        for (final String existingWord in _enteredWords) {
          // Check if words are similar (one is a prefix of the other)
          if (existingWord.startsWith(word)) {
            // Existing word is longer - skip this shorter version
            foundSimilar = true;
            print('  ✗ Skipping "$word" - shorter version of existing "$existingWord"');
            break;
          } else if (word.startsWith(existingWord)) {
            // New word is longer - mark old word for removal
            wordsToRemove.add(existingWord);
            foundSimilar = true;
            print('  ↻ Will replace "$existingWord" with longer "$word"');
          }
        }

        if (!foundSimilar) {
          // Completely new word - check if already exists
          if (!_enteredWords.contains(word)) {
            setState(() {
              _enteredWords.add(word);
              newWordsAdded++;
              print('  ✓ Added: "$word"');
            });
          }
        } else if (wordsToRemove.isNotEmpty) {
          // Replace shorter versions with longer version
          setState(() {
            for (final String toRemove in wordsToRemove) {
              _enteredWords.remove(toRemove);
            }
            if (!_enteredWords.contains(word)) {
              _enteredWords.add(word);
              newWordsAdded++;
              print('  ✓ Replaced with: "$word"');
            }
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
        print('  Added $newWordsAdded new word(s). Total: ${_enteredWords.length}');
      }

      print('=== LANGUAGE SKILLS: Result processed (${isFinal ? 'FINAL' : 'PARTIAL'}), total words captured: ${_enteredWords.length} ===');
    }
  }

  void _completeTest() {
    _timer?.cancel();
    _stopListening();
    setState(() {
      _testCompleted = true;
    });
    _calculateScore();
    _saveResults();
  }

  Future<void> _saveResults() async {
    final notifier = ref.read(assessmentProvider.notifier);

    final assessment = Assessment(
      type: AssessmentType.languageSkills,
      score: _score,
      maxScore: 20, // Typical max for fluency tests
      notes: widget.category != null
        ? 'Language Skills (${widget.category}): ${_validWords.length} valid words'
        : 'Language Skills (Open): ${_validWords.length} valid words',
      completedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await notifier.addAssessment(assessment);
  }

  void _calculateScore() {
    // Language Skills test: Accept ALL words of 3+ characters
    // No category restriction (unlike Animal Fluency)
    _validWords = _enteredWords.where((word) => word.length >= 3).toList();

    setState(() {
      _score = _validWords.length;
    });
  }

  String _getPerformanceLevel() {
    // Based on typical fluency test norms
    if (_score >= 18) return 'Excellent';
    if (_score >= 14) return 'Good';
    if (_score >= 10) return 'Average';
    if (_score >= 7) return 'Below Average';
    return 'Poor';
  }

  Color _getPerformanceColor() {
    if (_score >= 18) return Colors.green;
    if (_score >= 14) return Colors.lightGreen;
    if (_score >= 10) return Colors.orange;
    if (_score >= 7) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Skills Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    const Icon(Icons.pets, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Language Skills Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'This test measures verbal fluency and executive function.',
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
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('1. You will have 60 seconds'),
                Text(widget.category != null
                  ? '2. Say as many ${widget.category} as you can'
                  : '2. Say as many words as you can - any category'),
                const Text('3. Speak naturally - the app listens continuously'),
                const Text('4. Try to avoid repeating words'),
                Text(widget.category != null
                  ? '5. Only words matching the category count'
                  : '5. Any words count - nouns, verbs, adjectives, etc.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.category != null
                            ? 'Focus on the category: ${widget.category}'
                            : 'Think of different categories: objects, actions, descriptions, places, people, etc.',
                          style: const TextStyle(fontStyle: FontStyle.italic),
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
        // Timer
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
                'Time Remaining',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$_remainingSeconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'seconds',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Continuous Listening Status
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_speechEnabled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _speechListening ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _speechListening ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _speechListening ? Icons.mic : Icons.mic_off,
                              size: 32,
                              color: _speechListening ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _speechListening ? 'LISTENING CONTINUOUSLY' : 'Starting...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _speechListening ? Colors.green : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _speechListening
                            ? 'Speak naturally - name words as they come to mind'
                            : 'Initializing speech recognition...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (_speechListening && _soundLevel > -25) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (_soundLevel + 25) / 15, // Normalize to 0-1 range
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sound detected',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.mic_off, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Voice input not available',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check microphone permissions in Settings',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Words entered so far
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Words Spoken (${_enteredWords.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (_enteredWords.isEmpty)
                  const Text(
                    'No words entered yet',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _enteredWords.map((word) => Chip(
                      label: Text(word),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _completeTest,
            icon: const Icon(Icons.stop),
            label: const Text('End Test Early'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
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
                        '$_score',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getPerformanceColor(),
                        ),
                      ),
                      Text(
                        'valid words',
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
        
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valid Words (${_validWords.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _validWords.map((word) => Chip(
                    label: Text(word),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  )).toList(),
                ),
                
                if (_enteredWords.length > _validWords.length) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Invalid/Repeated (${_enteredWords.length - _validWords.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _enteredWords
                        .where((word) => !_validWords.contains(word))
                        .map((word) => Chip(
                          label: Text(word),
                          backgroundColor: Colors.red.withOpacity(0.1),
                        ))
                        .toList(),
                  ),
                ],
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
                  'Score Interpretation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _buildScoreRange('18+', 'Excellent', Colors.green),
                _buildScoreRange('14-17', 'Good', Colors.lightGreen),
                _buildScoreRange('10-13', 'Average', Colors.orange),
                _buildScoreRange('7-9', 'Below Average', Colors.deepOrange),
                _buildScoreRange('0-6', 'Poor', Colors.red),
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
                    _enteredWords.clear();
                    _validWords.clear();
                    _score = 0;
                    _remainingSeconds = 60;
                  });
                  _textController.clear();
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