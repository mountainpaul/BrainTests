import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/models/assessment_models.dart';
import '../../domain/services/assessment_generator.dart';
import '../providers/assessment_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/custom_card.dart';

class AssessmentTestScreen extends ConsumerStatefulWidget {
  const AssessmentTestScreen({
    super.key,
    required this.assessmentType,
    this.difficulty = 1,
  });
  final AssessmentType assessmentType;
  final int difficulty;

  @override
  ConsumerState<AssessmentTestScreen> createState() => _AssessmentTestScreenState();
}

class _AssessmentTestScreenState extends ConsumerState<AssessmentTestScreen> {
  AssessmentQuestion? question;
  late DateTime testStartTime;
  bool testCompleted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAssessment();
  }

  Future<void> _initializeAssessment() async {
    setState(() {
      isLoading = true;
    });

    final questions = await AssessmentGenerator.generateAssessmentBattery(
      type: widget.assessmentType,
      difficulty: widget.difficulty,
    );
    
    if (mounted) {
      setState(() {
        question = questions.first;
        testStartTime = DateTime.now();
        isLoading = false;
      });

      if (question!.timeLimit > 0) {
        ref.read(countdownTimerProvider(question!.timeLimit).notifier).start();
      }
    }
  }

  @override
  void dispose() {
    // Stop the timer when the widget is disposed
    // Note: We cannot safely read the provider here if we don't know the exact question/timeLimit
    // However, since countdownTimerProvider is likely autoDispose, it will clean itself up.
    // If it's not autoDispose, we should ideally stop it.
    // Given the complexity of accessing the family provider in dispose without the question being guaranteed non-null,
    // we rely on Riverpod's cleanup or the fact that the timer is part of the state.
    // If we really need to stop it, we should have stored the subscription or the provider reference.
    super.dispose();
  }

  void _completeAssessment() {
    if (question != null && question!.timeLimit > 0) {
      ref.read(countdownTimerProvider(question!.timeLimit).notifier).pause();
    }
    setState(() {
      testCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the timer provider for time-out completion
    if (question != null && question!.timeLimit > 0) {
      ref.listen(countdownTimerProvider(question!.timeLimit), (previous, next) {
        if (next.isCompleted && !testCompleted) {
           _completeAssessment();
        }
      });
    }

    if (isLoading || question == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_getAssessmentTitle())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAssessmentTitle()),
        actions: [
          if (question!.timeLimit > 0 && !testCompleted)
            Consumer(
              builder: (context, ref, child) {
                final timerState = ref.watch(countdownTimerProvider(question!.timeLimit));
                final remainingTimeSeconds = timerState.remainingSeconds;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: remainingTimeSeconds <= 30 ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${remainingTimeSeconds ~/ 60}:${(remainingTimeSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: testCompleted ? _buildCompletionScreen() : _buildTestContent(),
    );
  }

  Widget _buildTestContent() {
    switch (widget.assessmentType) {
      case AssessmentType.memoryRecall:
        return _buildMemoryRecallTest(question! as MemoryRecallQuestion);
      case AssessmentType.attentionFocus:
        return _buildAttentionFocusTest(question! as AttentionFocusQuestion);
      case AssessmentType.executiveFunction:
        return _buildExecutiveFunctionTest(question! as ExecutiveFunctionQuestion);
      case AssessmentType.languageSkills:
        return _buildLanguageSkillsTest(question! as LanguageSkillsQuestion);
      case AssessmentType.visuospatialSkills:
        return _buildVisuospatialTest(question! as VisuospatialQuestion);
      case AssessmentType.processingSpeed:
        return _buildProcessingSpeedTest(question! as ProcessingSpeedQuestion);
    }
  }

  Widget _buildMemoryRecallTest(MemoryRecallQuestion memoryQuestion) {
    return MemoryRecallWidget(
      question: memoryQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildAttentionFocusTest(AttentionFocusQuestion attentionQuestion) {
    return AttentionFocusWidget(
      question: attentionQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildExecutiveFunctionTest(ExecutiveFunctionQuestion executiveQuestion) {
    return ExecutiveFunctionWidget(
      question: executiveQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildLanguageSkillsTest(LanguageSkillsQuestion languageQuestion) {
    return LanguageSkillsWidget(
      question: languageQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildVisuospatialTest(VisuospatialQuestion visuospatialQuestion) {
    return VisuospatialWidget(
      question: visuospatialQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildProcessingSpeedTest(ProcessingSpeedQuestion processingQuestion) {
    return ProcessingSpeedWidget(
      question: processingQuestion,
      onCompleted: (response) {
        _saveAssessmentResult(response);
        _completeAssessment();
      },
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Assessment Completed!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your results have been saved.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Return to Assessments'),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssessmentTitle() {
    switch (widget.assessmentType) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall Test';
      case AssessmentType.attentionFocus:
        return 'Attention Focus Test';
      case AssessmentType.executiveFunction:
        return 'Executive Function Test';
      case AssessmentType.languageSkills:
        return 'Language Skills Test';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Test';
      case AssessmentType.processingSpeed:
        return 'Processing Speed Test';
    }
  }

  Future<void> _saveAssessmentResult(AssessmentResponse response) async {
    try {
      // Calculate score using the assessment generator
      final score = AssessmentGenerator.calculateAssessmentScore(
        widget.assessmentType,
        [response],
      );

      final assessment = Assessment(
        type: widget.assessmentType,
        score: score.round(),
        maxScore: 100,
        notes: '${_getAssessmentTitle()} - Score: ${score.toStringAsFixed(1)}',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(assessmentProvider.notifier).addAssessment(assessment);

      print('Assessment saved successfully with score: ${score.toStringAsFixed(1)}');
    } catch (e) {
      print('Error saving assessment result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assessment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Memory Recall Test Widget
class MemoryRecallWidget extends StatefulWidget {

  const MemoryRecallWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final MemoryRecallQuestion question;
  final Function(MemoryRecallResponse) onCompleted;

  @override
  State<MemoryRecallWidget> createState() => _MemoryRecallWidgetState();
}

class _MemoryRecallWidgetState extends State<MemoryRecallWidget> {
  int currentPhase = 0; // 0: instructions, 1: study, 2: recall, 3: recognition
  Timer? phaseTimer;
  final TextEditingController recallController = TextEditingController();
  final Set<String> selectedRecognitionWords = {};
  late DateTime testStartTime;

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    switch (currentPhase) {
      case 0:
        return _buildInstructionPhase();
      case 1:
        return _buildStudyPhase();
      case 2:
        return _buildRecallPhase();
      case 3:
        return _buildRecognitionPhase();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.psychology, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Memory Recall Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'You will see ${widget.question.wordsToMemorize.length} words for ${widget.question.studyTimeSeconds} seconds.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Study them carefully, then recall as many as you can.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startStudyPhase,
                  child: const Text('Start Study Phase'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPhase() {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Study These Words',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ...widget.question.wordsToMemorize.map((word) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                word.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecallPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        children: [
          Expanded(
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Recall',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Write down all the words you remember, one per line:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: recallController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Type the words you remember here...',
                        border: OutlineInputBorder(),
                      ),
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
              onPressed: _startRecognitionPhase,
              child: const Text('Continue to Recognition'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recognition Phase',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select all words that were in the original list:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.question.recognitionOptions.length,
              itemBuilder: (context, index) {
                final word = widget.question.recognitionOptions[index];
                final isSelected = selectedRecognitionWords.contains(word);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedRecognitionWords.remove(word);
                      } else {
                        selectedRecognitionWords.add(word);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        word,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeTest,
              child: const Text('Complete Assessment'),
            ),
          ),
        ],
      ),
    );
  }

  void _startStudyPhase() {
    setState(() {
      currentPhase = 1;
    });
    
    Timer(Duration(seconds: widget.question.studyTimeSeconds), () {
      if (mounted) {
        setState(() {
          currentPhase = 2;
        });
      }
    });
  }

  void _startRecognitionPhase() {
    setState(() {
      currentPhase = 3;
    });
  }

  void _completeTest() {
    final recalledWords = recallController.text
        .split('\n')
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.isNotEmpty)
        .toList();
    
    final correctRecall = recalledWords
        .where((word) => widget.question.wordsToMemorize.contains(word))
        .length;
    
    final correctRecognition = selectedRecognitionWords
        .where((word) => widget.question.wordsToMemorize.contains(word))
        .length;
    
    final response = MemoryRecallResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: correctRecall > 0 || correctRecognition > 0,
      recalledWords: recalledWords,
      recognizedWords: selectedRecognitionWords.toList(),
      freeRecallScore: (correctRecall / widget.question.wordsToMemorize.length * 100).round(),
      recognitionScore: (correctRecognition / widget.question.wordsToMemorize.length * 100).round(),
    );
    
    widget.onCompleted(response);
  }
}

/// Attention Focus Test Widget - Sustained Attention to Response Task
class AttentionFocusWidget extends StatefulWidget {

  const AttentionFocusWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final AttentionFocusQuestion question;
  final Function(AttentionFocusResponse) onCompleted;

  @override
  State<AttentionFocusWidget> createState() => _AttentionFocusWidgetState();
}

class _AttentionFocusWidgetState extends State<AttentionFocusWidget> {
  int currentStimulusIndex = 0;
  Timer? stimulusTimer;
  late DateTime testStartTime;
  final List<bool> responses = [];
  final List<int> reactionTimes = [];
  bool showStimulus = false;
  bool waitingForResponse = false;
  DateTime? stimulusShowTime;
  int phase = 0; // 0: instructions, 1: test running

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
  }

  @override
  void dispose() {
    stimulusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (phase == 0) {
      return _buildInstructionPhase();
    } else {
      return _buildTestPhase();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.visibility, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Sustained Attention Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Numbers will appear on screen. Tap the button for every number EXCEPT ${widget.question.targetNumber}.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay focused throughout the entire task. Work as quickly and accurately as possible.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DO NOT TAP when you see: ${widget.question.targetNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startTest,
                  child: const Text('Start Test'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestPhase() {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: currentStimulusIndex / widget.question.stimulusSequence.length,
          backgroundColor: Colors.grey[300],
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stimulus display
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: showStimulus ? Colors.blue : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      showStimulus && currentStimulusIndex < widget.question.stimulusSequence.length
                          ? widget.question.stimulusSequence[currentStimulusIndex].toString()
                          : '',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Progress: ${currentStimulusIndex + 1} / ${widget.question.stimulusSequence.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Remember: Do NOT tap for ${widget.question.targetNumber}',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Response button
        Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: double.infinity,
            height: 80,
            child: ElevatedButton(
              onPressed: waitingForResponse ? _handleResponse : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: waitingForResponse ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'TAP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _startTest() {
    setState(() {
      phase = 1;
    });
    _showNextStimulus();
  }

  void _showNextStimulus() {
    if (currentStimulusIndex >= widget.question.stimulusSequence.length) {
      _completeTest();
      return;
    }

    setState(() {
      showStimulus = true;
      waitingForResponse = true;
      stimulusShowTime = DateTime.now();
    });

    // Hide stimulus after specified duration
    Timer(Duration(milliseconds: widget.question.stimulusDurationMs), () {
      if (mounted) {
        setState(() {
          showStimulus = false;
        });
      }
    });

    // Move to next stimulus after inter-stimulus interval
    Timer(Duration(milliseconds: widget.question.stimulusDurationMs + widget.question.interStimulusIntervalMs), () {
      if (mounted) {
        // If no response was given, record it as no response
        if (waitingForResponse) {
          responses.add(false);
          reactionTimes.add(0);
        }
        
        setState(() {
          currentStimulusIndex++;
          waitingForResponse = false;
        });
        
        _showNextStimulus();
      }
    });
  }

  void _handleResponse() {
    if (!waitingForResponse || stimulusShowTime == null) return;
    
    final reactionTime = DateTime.now().difference(stimulusShowTime!).inMilliseconds;
    
    setState(() {
      waitingForResponse = false;
    });
    
    responses.add(true);
    reactionTimes.add(reactionTime);
  }

  void _completeTest() {
    // Calculate performance metrics
    int hits = 0;
    int misses = 0;
    int falseAlarms = 0;
    int correctRejections = 0;
    
    for (int i = 0; i < widget.question.stimulusSequence.length; i++) {
      final wasTarget = widget.question.stimulusSequence[i] == widget.question.targetNumber;
      final responded = i < responses.length ? responses[i] : false;
      
      if (wasTarget) {
        if (!responded) {
          correctRejections++; // Correctly did not respond to target
        } else {
          falseAlarms++; // Incorrectly responded to target
        }
      } else {
        if (responded) {
          hits++; // Correctly responded to non-target
        } else {
          misses++; // Incorrectly did not respond to non-target
        }
      }
    }
    
    final response = AttentionFocusResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: (hits + correctRejections) > (misses + falseAlarms),
      responses: responses,
      reactionTimes: reactionTimes,
      hits: hits,
      misses: misses,
      falseAlarms: falseAlarms,
      correctRejections: correctRejections,
    );
    
    widget.onCompleted(response);
  }
}

/// Executive Function Test Widget - Tower of Hanoi
class ExecutiveFunctionWidget extends StatefulWidget {

  const ExecutiveFunctionWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final ExecutiveFunctionQuestion question;
  final Function(ExecutiveFunctionResponse) onCompleted;

  @override
  State<ExecutiveFunctionWidget> createState() => _ExecutiveFunctionWidgetState();
}

class _ExecutiveFunctionWidgetState extends State<ExecutiveFunctionWidget> {
  late List<List<int>> currentState;
  final List<Move> moves = [];
  late DateTime testStartTime;
  DateTime? firstMoveTime;
  int? selectedTower;
  int phase = 0; // 0: instructions, 1: playing

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
    currentState = widget.question.initialState.map(List<int>.from).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (phase == 0) {
      return _buildInstructionPhase();
    } else {
      return _buildGamePhase();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.account_tree, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Tower of Hanoi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Move all disks from the left tower to the right tower.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Rules:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Only move one disk at a time\n• Never place a larger disk on a smaller one\n• Use the middle tower to help',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Target: ${widget.question.maxMoves} moves or fewer',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('Start Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePhase() {
    return Column(
      children: [
        // Status bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.blue[200]!),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Moves: ${moves.length}/${widget.question.maxMoves}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Target: Right Tower',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              if (_isComplete())
                Text(
                  'COMPLETE!',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
            ],
          ),
        ),
        // Game area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTower(0, 'Start'),
                _buildTower(1, 'Helper'),
                _buildTower(2, 'Target'),
              ],
            ),
          ),
        ),
        // Complete button
        if (_isComplete())
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeTest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Complete Test'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTower(int towerIndex, String label) {
    final tower = currentState[towerIndex];
    final isSelected = selectedTower == towerIndex;

    return GestureDetector(
      onTap: () => _selectTower(towerIndex),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : Colors.grey[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Tower base (wider and more prominent)
                    Container(
                      width: 6,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.brown[800],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        border: Border.all(color: Colors.brown[900]!),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    // Tower platform
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 90,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.brown[800]!),
                        ),
                      ),
                    ),
                    // Disks
                    ...tower.asMap().entries.map((entry) {
                      final diskIndex = entry.key;
                      final diskSize = entry.value;
                      final diskWidth = 25.0 + (diskSize * 12.0);

                      return Positioned(
                        bottom: 10 + (diskIndex * 22.0),
                        child: Container(
                          width: diskWidth,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getDiskColor(diskSize),
                                _getDiskColor(diskSize).withOpacity(0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              diskSize.toString(),
                              style: TextStyle(
                                color: _getDiskTextColor(diskSize),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: _getDiskTextColor(diskSize) == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                                    offset: const Offset(1, 1),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ), // Container child of GestureDetector
    ); // GestureDetector
  }

  Color _getDiskColor(int size) {
    final colors = [
      Colors.red[600]!,
      Colors.orange[600]!,
      Colors.amber[600]!,
      Colors.green[600]!,
      Colors.blue[600]!,
      Colors.purple[600]!,
      Colors.pink[600]!,
    ];
    return colors[(size - 1) % colors.length];
  }

  Color _getDiskTextColor(int size) {
    // Use white text for darker colors, black for lighter colors
    final lightColors = [3]; // Yellow/amber gets black text
    return lightColors.contains(size) ? Colors.black : Colors.white;
  }

  void _selectTower(int towerIndex) {
    if (selectedTower == null) {
      // Select source tower (must have disks)
      if (currentState[towerIndex].isNotEmpty) {
        setState(() {
          selectedTower = towerIndex;
        });
      }
    } else if (selectedTower == towerIndex) {
      // Deselect
      setState(() {
        selectedTower = null;
      });
    } else {
      // Attempt move
      _attemptMove(selectedTower!, towerIndex);
      setState(() {
        selectedTower = null;
      });
    }
  }

  void _attemptMove(int fromTower, int toTower) {
    final fromStack = currentState[fromTower];
    final toStack = currentState[toTower];
    
    if (fromStack.isEmpty) return;
    
    final diskToMove = fromStack.last;
    
    // Check if move is valid
    if (toStack.isNotEmpty && toStack.last < diskToMove) {
      // Invalid move - larger disk on smaller disk
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot place larger disk on smaller disk!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    
    // Make the move
    setState(() {
      fromStack.removeLast();
      toStack.add(diskToMove);
    });
    
    // Record move
    final moveTime = DateTime.now();
    firstMoveTime ??= moveTime;
    
    moves.add(Move(
      fromTower: fromTower,
      toTower: toTower,
      timestamp: moveTime,
    ));
  }

  void _startGame() {
    setState(() {
      phase = 1;
    });
  }

  bool _isComplete() {
    return const ListEquality().equals(currentState[2], widget.question.targetState[2]);
  }

  void _completeTest() {
    final planningTime = firstMoveTime != null
        ? firstMoveTime!.difference(testStartTime).inMilliseconds
        : 0;
    
    final response = ExecutiveFunctionResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: _isComplete(),
      moves: moves,
      totalMoves: moves.length,
      solved: _isComplete(),
      planningTime: planningTime,
      numberOfDisks: widget.question.numberOfDisks,
    );
    
    widget.onCompleted(response);
  }
}

/// Language Skills Test Widget - Word Fluency
class LanguageSkillsWidget extends StatefulWidget {

  const LanguageSkillsWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final LanguageSkillsQuestion question;
  final Function(LanguageSkillsResponse) onCompleted;

  @override
  State<LanguageSkillsWidget> createState() => _LanguageSkillsWidgetState();
}

class _LanguageSkillsWidgetState extends State<LanguageSkillsWidget> {
  final TextEditingController wordController = TextEditingController();
  final List<String> enteredWords = [];
  late DateTime testStartTime;
  Timer? countdownTimer;
  int remainingSeconds = 0;
  int phase = 0; // 0: instructions, 1: test running, 2: completed

  // Speech recognition
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  bool _speechListening = false;
  bool _continuousListening = false;

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
    remainingSeconds = widget.question.responseTimeSeconds;
    _initSpeech();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    wordController.dispose();
    _stopListening();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      final bool available = await _speech.initialize(
        onError: (val) {
          print('Speech recognition error: $val');
          if (_speechListening) {
            setState(() {
              _speechListening = false;
            });
            // Try to restart after error
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (_continuousListening && phase == 1) {
                _startListening();
              }
            });
          }
        },
        onStatus: (val) {
          print('Speech recognition status: $val');
          if (val == 'notListening' && _speechListening) {
            setState(() {
              _speechListening = false;
            });
            // Auto-restart when it stops listening (if continuous mode is on)
            if (_continuousListening && phase == 1) {
              print('Auto-restarting speech recognition due to status change');
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_continuousListening && phase == 1 && !_speechListening) {
                  _startListening();
                }
              });
            }
          } else if (val == 'done' && _continuousListening && phase == 1) {
            print('Speech recognition done, restarting in 500ms');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_continuousListening && phase == 1 && !_speechListening) {
                _startListening();
              }
            });
          }
        },
      );

      if (available) {
        final bool hasPermission = await _speech.hasPermission;
        print('Speech recognition available: $available, has permission: $hasPermission');
        _speechEnabled = hasPermission;
      } else {
        _speechEnabled = false;
        print('Speech recognition not available on this device');
      }

      setState(() {});
    } catch (e) {
      print('Error initializing speech recognition: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  void _startListening() async {
    if (!_speechListening && _speechEnabled && phase == 1) {
      print('Starting speech recognition...');
      setState(() {
        _speechListening = true;
      });
      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: "en_US",
          onSoundLevelChange: (level) => print('Sound level: $level'),
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        );
        print('Speech recognition started successfully');
      } catch (e) {
        print('Error starting speech recognition: $e');
        setState(() {
          _speechListening = false;
        });
      }
    } else {
      print('Cannot start listening: listening=$_speechListening, enabled=$_speechEnabled, phase=$phase');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords.toLowerCase().trim();

    print('Speech result - Final: ${result.finalResult}, Confidence: ${result.confidence}, Text: "$recognizedText"');

    if (recognizedText.isNotEmpty) {
      // Split by multiple delimiters and clean up words
      final words = recognizedText
          .split(RegExp(r'[,\s.!?;:]+'))
          .map((word) => word.trim().replaceAll(RegExp(r'[^\w]'), ''))
          .where((word) => word.isNotEmpty && word.length > 1)
          .toList();

      print('Extracted words: $words');

      for (final String word in words) {
        if (!enteredWords.contains(word)) {
          print('Adding new word: $word');
          setState(() {
            enteredWords.add(word);
          });
        } else {
          print('Word already exists: $word');
        }
      }
    } else {
      print('Empty recognized text');
    }

    // Only restart on final result with shorter delay to maintain continuity
    if (result.finalResult && _continuousListening && phase == 1) {
      print('Final result received, restarting listening in 500ms');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_continuousListening && phase == 1 && !_speechListening) {
          print('Restarting speech recognition after delay');
          _startListening();
        }
      });
    }
  }

  void _stopListening() async {
    _continuousListening = false;
    if (_speechListening) {
      await _speech.stop();
      setState(() {
        _speechListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case 0:
        return _buildInstructionPhase();
      case 1:
        return _buildTestPhase();
      default:
        return _buildCompletionPhase();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.record_voice_over, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Word Fluency Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.question.prompt,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You have ${widget.question.responseTimeSeconds} seconds. You can type words or use voice input to add them to your list.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tips:\n• Think of as many different words as possible\n• Avoid repetitions\n• Be creative!',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startTest,
                  child: const Text('Start Test'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestPhase() {
    return Column(
      children: [
        // Timer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: remainingSeconds <= 10 ? Colors.red[100] : Colors.blue[100],
          child: Text(
            'Time Remaining: ${remainingSeconds}s',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: remainingSeconds <= 10 ? Colors.red : Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Input area
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question.prompt,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wordController,
                      decoration: const InputDecoration(
                        hintText: 'Type a word and press Enter',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _addWord,
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addWord(wordController.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Voice input controls
              if (_speechEnabled) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _speechListening ? _stopListening : () {
                      _continuousListening = true;
                      _startListening();
                    },
                    icon: Icon(_speechListening ? Icons.mic_off : Icons.mic),
                    label: Text(_speechListening ? 'Stop Voice Input' : 'Start Voice Input'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _speechListening ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
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
                        'You can still type words manually using the text field above.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Text(
                'Words entered: ${enteredWords.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        // Words list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomCard(
              child: enteredWords.isEmpty
                  ? const Center(
                      child: Text(
                        'Your words will appear here as you type them',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: enteredWords.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(enteredWords[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeWord(index),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
        // Early completion button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: ElevatedButton(
            onPressed: _completeTest,
            child: const Text('Finish Early'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionPhase() {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Test Complete!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'You entered ${enteredWords.length} words',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _startTest() {
    setState(() {
      phase = 1;
    });
    
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        _completeTest();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void _addWord(String word) {
    final trimmedWord = word.trim().toLowerCase();
    if (trimmedWord.isNotEmpty && !enteredWords.contains(trimmedWord)) {
      setState(() {
        enteredWords.add(trimmedWord);
        wordController.clear();
      });
    }
  }

  void _removeWord(int index) {
    setState(() {
      enteredWords.removeAt(index);
    });
  }

  void _completeTest() async {
    countdownTimer?.cancel();
    _stopListening(); // Stop speech recognition
    setState(() {
      phase = 2;
    });
    
    // Validate words
    int validWords = 0;
    for (final word in enteredWords) {
      if (await WordValidator.isValidWord(widget.question.category, word)) {
        validWords++;
      }
    }
    
    final categories = await WordValidator.categorizeWords(enteredWords);

    final response = LanguageSkillsResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: validWords > 0,
      words: enteredWords,
      validWords: validWords,
      invalidWords: enteredWords.length - validWords,
      repetitions: 0, // Already handled by not allowing duplicates
      categories: categories,
    );
    
    // Delay before completing to show results
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onCompleted(response);
      }
    });
  }
}

/// Visuospatial Skills Test Widget - Mental Rotation
class VisuospatialWidget extends StatefulWidget {

  const VisuospatialWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final VisuospatialQuestion question;
  final Function(VisuospatialResponse) onCompleted;

  @override
  State<VisuospatialWidget> createState() => _VisuospatialWidgetState();
}

class _VisuospatialWidgetState extends State<VisuospatialWidget> {
  int? selectedOption;
  late DateTime testStartTime;
  int phase = 0; // 0: instructions, 1: test
  double confidence = 50.0;

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (phase == 0) {
      return _buildInstructionPhase();
    } else {
      return _buildTestPhase();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.rotate_right, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Mental Rotation Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'You will see a target shape and several options. Select which option shows the same shape when rotated.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startTest,
                  child: const Text('Start Test'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestPhase() {
    return Column(
      children: [
        // Target shape
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Target Shape',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: _buildShape(widget.question.targetShape, 0, size: 80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Options
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Which option matches the target when rotated?',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            spacing: 12,
                            runSpacing: 20,
                            children: List.generate(widget.question.optionShapes.length, (index) {
                              final isSelected = selectedOption == index;
                              return GestureDetector(
                                onTap: () => _selectOption(index),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.grey,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected ? Colors.blue[50] : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Option ${String.fromCharCode(65 + index)}',
                                        style: Theme.of(context).textTheme.labelSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      _buildShape(widget.question.optionShapes[index], 0, size: 50),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ), // Expanded
                ],
              ),
            ),
          ),
        ),
        // Confidence slider and submit button - made more compact
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CustomCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How confident are you in your answer?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: confidence,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '${confidence.round()}%',
                    onChanged: (value) {
                      setState(() {
                        confidence = value;
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedOption != null ? _completeTest : null,
                      child: const Text('Submit Answer'),
                    ),
                ),
              ],
            ), // Column
          ), // Padding
        ), // CustomCard
        ), // Container
      ],
    );
  }

  Widget _buildShape(String shapeData, double rotation, {double size = 60}) {
    print('_buildShape called with: shapeData="$shapeData", rotation=$rotation, size=$size');

    // Parse shape data to extract shape name and rotation
    String shapeName;
    double totalRotation = rotation;

    if (shapeData.contains('_') && shapeData.contains('deg')) {
      // Format: "L_shape_90deg"
      final parts = shapeData.split('_');
      if (parts.length >= 2) {
        shapeName = '${parts[0]}_${parts[1]}'; // "L_shape"

        // Extract rotation degrees
        if (parts.length > 2 && parts.last.contains('deg')) {
          final rotationStr = parts.last.replaceAll('deg', '');
          final shapeRotation = double.tryParse(rotationStr) ?? 0.0;
          totalRotation += shapeRotation;
          print('Extracted shape rotation: $shapeRotation°');
        }
      } else {
        shapeName = shapeData;
      }
    } else {
      // Simple format: "L_shape"
      shapeName = shapeData;
    }

    print('Final shapeName="$shapeName", totalRotation=$totalRotation');

    return Transform.rotate(
      angle: totalRotation * (3.14159 / 180), // Convert degrees to radians
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: CustomPaint(
          painter: ShapePainter(shapeName),
        ),
      ),
    );
  }

  void _startTest() {
    setState(() {
      phase = 1;
    });
  }

  void _selectOption(int index) {
    setState(() {
      selectedOption = index;
    });
  }

  void _completeTest() {
    final response = VisuospatialResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: selectedOption == widget.question.correctOptionIndex,
      selectedOption: selectedOption!,
      correctOption: widget.question.correctOptionIndex,
      confidence: confidence,
    );
    
    widget.onCompleted(response);
  }
}

/// Custom painter for drawing simple geometric shapes
class ShapePainter extends CustomPainter {
  
  ShapePainter(this.shapeName);
  final String shapeName;
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[800]!
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    print('ShapePainter.paint called with shapeName: "$shapeName"');

    // Force draw different shapes for testing if we get unknown shapes
    final knownShapes = [
      'L_shape', 'F_shape', 'T_shape', 'plus_shape', 'arrow_shape',
      'H_shape', 'U_shape', 'C_shape', 'E_shape', 'Z_shape',
      'diamond_shape', 'hexagon_shape', 'star_shape', 'cross_shape', 'triangle_shape'
    ];

    if (!knownShapes.contains(shapeName)) {
      print('Unknown shape: "$shapeName", drawing test shapes based on hash');
      final hash = shapeName.hashCode % 15;
      final testShapes = [
        () => _drawLShape(canvas, size, paint, fillPaint),
        () => _drawFShape(canvas, size, paint, fillPaint),
        () => _drawTShape(canvas, size, paint, fillPaint),
        () => _drawPlusShape(canvas, size, paint, fillPaint),
        () => _drawArrowShape(canvas, size, paint, fillPaint),
        () => _drawHShape(canvas, size, paint, fillPaint),
        () => _drawUShape(canvas, size, paint, fillPaint),
        () => _drawCShape(canvas, size, paint, fillPaint),
        () => _drawEShape(canvas, size, paint, fillPaint),
        () => _drawZShape(canvas, size, paint, fillPaint),
        () => _drawDiamondShape(canvas, size, paint, fillPaint),
        () => _drawHexagonShape(canvas, size, paint, fillPaint),
        () => _drawStarShape(canvas, size, paint, fillPaint),
        () => _drawCrossShape(canvas, size, paint, fillPaint),
        () => _drawTriangleShape(canvas, size, paint, fillPaint),
      ];
      testShapes[hash]();
      return;
    }

    switch (shapeName) {
      case 'L_shape':
        print('Drawing L_shape');
        _drawLShape(canvas, size, paint, fillPaint);
        break;
      case 'F_shape':
        print('Drawing F_shape');
        _drawFShape(canvas, size, paint, fillPaint);
        break;
      case 'T_shape':
        print('Drawing T_shape');
        _drawTShape(canvas, size, paint, fillPaint);
        break;
      case 'plus_shape':
        print('Drawing plus_shape');
        _drawPlusShape(canvas, size, paint, fillPaint);
        break;
      case 'arrow_shape':
        print('Drawing arrow_shape');
        _drawArrowShape(canvas, size, paint, fillPaint);
        break;
      case 'H_shape':
        print('Drawing H_shape');
        _drawHShape(canvas, size, paint, fillPaint);
        break;
      case 'U_shape':
        print('Drawing U_shape');
        _drawUShape(canvas, size, paint, fillPaint);
        break;
      case 'C_shape':
        print('Drawing C_shape');
        _drawCShape(canvas, size, paint, fillPaint);
        break;
      case 'E_shape':
        print('Drawing E_shape');
        _drawEShape(canvas, size, paint, fillPaint);
        break;
      case 'Z_shape':
        print('Drawing Z_shape');
        _drawZShape(canvas, size, paint, fillPaint);
        break;
      case 'diamond_shape':
        print('Drawing diamond_shape');
        _drawDiamondShape(canvas, size, paint, fillPaint);
        break;
      case 'hexagon_shape':
        print('Drawing hexagon_shape');
        _drawHexagonShape(canvas, size, paint, fillPaint);
        break;
      case 'star_shape':
        print('Drawing star_shape');
        _drawStarShape(canvas, size, paint, fillPaint);
        break;
      case 'cross_shape':
        print('Drawing cross_shape');
        _drawCrossShape(canvas, size, paint, fillPaint);
        break;
      case 'triangle_shape':
        print('Drawing triangle_shape');
        _drawTriangleShape(canvas, size, paint, fillPaint);
        break;
      default:
        print('Fallback: Unknown shape "$shapeName", drawing default rectangle');
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.4),
          Paint()..color = Colors.red[200]!,
        );
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.6, size.height * 0.4),
          Paint()..color = Colors.red[800]!..strokeWidth = 2..style = PaintingStyle.stroke,
        );
    }
  }
  
  void _drawLShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.15)
      ..lineTo(size.width * 0.15, size.height * 0.85)
      ..lineTo(size.width * 0.85, size.height * 0.85)
      ..lineTo(size.width * 0.85, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.15)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
  
  void _drawFShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.55)
      ..lineTo(size.width * 0.7, size.height * 0.55)
      ..lineTo(size.width * 0.7, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
  
  void _drawTShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.2, size.height * 0.4)
      ..close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
  
  void _drawPlusShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
  
  void _drawArrowShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawHShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.65, size.height * 0.8)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawUShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.75)
      ..lineTo(size.width * 0.2, size.height * 0.75)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawCShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.65)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.35, size.height * 0.35)
      ..lineTo(size.width * 0.8, size.height * 0.35)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawEShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.35)
      ..lineTo(size.width * 0.35, size.height * 0.35)
      ..lineTo(size.width * 0.35, size.height * 0.425)
      ..lineTo(size.width * 0.65, size.height * 0.425)
      ..lineTo(size.width * 0.65, size.height * 0.575)
      ..lineTo(size.width * 0.35, size.height * 0.575)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawZShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.35)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.35)
      ..lineTo(size.width * 0.2, size.height * 0.35)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawDiamondShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.85)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawHexagonShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.2)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.5)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawStarShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.4)
      ..lineTo(size.width * 0.67, size.height * 0.6)
      ..lineTo(size.width * 0.75, size.height * 0.85)
      ..lineTo(size.width * 0.5, size.height * 0.72)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..lineTo(size.width * 0.33, size.height * 0.6)
      ..lineTo(size.width * 0.15, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawCrossShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.4, size.height * 0.15)
      ..lineTo(size.width * 0.6, size.height * 0.15)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.85)
      ..lineTo(size.width * 0.4, size.height * 0.85)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.15, size.height * 0.6)
      ..lineTo(size.width * 0.15, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawTriangleShape(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.8)
      ..lineTo(size.width * 0.15, size.height * 0.8)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Processing Speed Test Widget - Symbol Digit Modalities
class ProcessingSpeedWidget extends StatefulWidget {

  const ProcessingSpeedWidget({
    super.key,
    required this.question,
    required this.onCompleted,
  });
  final ProcessingSpeedQuestion question;
  final Function(ProcessingSpeedResponse) onCompleted;

  @override
  State<ProcessingSpeedWidget> createState() => _ProcessingSpeedWidgetState();
}

class _ProcessingSpeedWidgetState extends State<ProcessingSpeedWidget> {
  int currentItemIndex = 0;
  final List<int> userAnswers = [];
  final List<DateTime> responseTimes = [];
  late DateTime testStartTime;
  late DateTime itemStartTime;
  Timer? timeoutTimer;
  int phase = 0; // 0: instructions, 1: test running
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (phase == 0) {
      return _buildInstructionPhase();
    } else {
      return _buildTestPhase();
    }
  }

  Widget _buildInstructionPhase() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(Icons.speed, size: 64, color: Theme.of(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Processing Speed Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Use the symbol-number key shown above to convert each symbol to its corresponding number.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Work as quickly and accurately as possible. You have ${widget.question.timeLimit} seconds total.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Show the symbol-number mapping
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Symbol-Number Key:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: widget.question.symbolToNumberMap.entries.map((entry) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${entry.key} = ${entry.value}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startTest,
                  child: const Text('Start Test'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestPhase() {
    if (currentItemIndex >= widget.question.symbolSequence.length) {
      return _buildCompletionMessage();
    }

    final currentSymbol = widget.question.symbolSequence[currentItemIndex];
    
    return Column(
      children: [
        // Progress and key reference
        Container(
          color: Colors.blue[50],
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress: ${currentItemIndex + 1}/${widget.question.symbolSequence.length}'),
                  Text('Items completed: ${userAnswers.length}'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: currentItemIndex / widget.question.symbolSequence.length,
              ),
              const SizedBox(height: 16),
              // Key reference (smaller)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.question.symbolToNumberMap.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${entry.key}=${entry.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Current item
        Expanded(
          child: Center(
            child: CustomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Convert this symbol:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        currentSymbol,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '?',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _submitAnswer,
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _submitAnswer(numberController.text),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Quick number pad for faster input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
            children: List.generate(9, (index) {
              final number = index + 1;
              return ElevatedButton(
                onPressed: () => _quickAnswer(number),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionMessage() {
    return Center(
      child: CustomCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Test Complete!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Processing results...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _startTest() {
    setState(() {
      phase = 1;
    });
    _startItemTimer();
    
    // Set overall test timeout
    timeoutTimer = Timer(Duration(seconds: widget.question.timeLimit), () {
      if (mounted) {
        _completeTest();
      }
    });
  }

  void _startItemTimer() {
    itemStartTime = DateTime.now();
  }

  void _quickAnswer(int number) {
    setState(() {
      numberController.text = number.toString();
    });
    _submitAnswer(number.toString());
  }

  void _submitAnswer(String answer) {
    final responseTime = DateTime.now();
    responseTimes.add(responseTime);
    
    final userAnswer = int.tryParse(answer.trim()) ?? 0;
    userAnswers.add(userAnswer);
    
    setState(() {
      currentItemIndex++;
      numberController.clear();
    });
    
    if (currentItemIndex >= widget.question.symbolSequence.length) {
      // Delay to show completion message
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          _completeTest();
        }
      });
    } else {
      _startItemTimer();
    }
  }

  void _completeTest() {
    timeoutTimer?.cancel();
    
    // Calculate performance metrics
    int correctCount = 0;
    for (int i = 0; i < userAnswers.length && i < widget.question.correctAnswers.length; i++) {
      if (userAnswers[i] == widget.question.correctAnswers[i]) {
        correctCount++;
      }
    }
    
    // Calculate average time per item
    double totalTimeSeconds = 0;
    if (responseTimes.isNotEmpty) {
      totalTimeSeconds = responseTimes.last.difference(testStartTime).inMilliseconds / 1000.0;
    }
    final averageTimePerItem = responseTimes.isNotEmpty ? totalTimeSeconds / responseTimes.length : 0.0;
    
    final response = ProcessingSpeedResponse(
      questionId: widget.question.id,
      startTime: testStartTime,
      endTime: DateTime.now(),
      isCorrect: correctCount > 0,
      userAnswers: userAnswers,
      correctAnswers: widget.question.correctAnswers,
      correctCount: correctCount,
      totalAttempted: userAnswers.length,
      averageTimePerItem: averageTimePerItem,
    );
    
    widget.onCompleted(response);
  }
}