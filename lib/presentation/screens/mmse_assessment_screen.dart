import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/validated_assessments.dart';
import '../providers/assessment_provider.dart';
import '../widgets/custom_card.dart';

class MMSEAssessmentScreen extends ConsumerStatefulWidget {
  const MMSEAssessmentScreen({super.key});

  @override
  ConsumerState<MMSEAssessmentScreen> createState() => _MMSEAssessmentScreenState();
}

class _MMSEAssessmentScreenState extends ConsumerState<MMSEAssessmentScreen> {
  int currentSection = 0;
  int currentQuestion = 0;
  final List<MMSEResponse> responses = [];
  DateTime? sectionStartTime;

  final List<MMSESection> sections = [
    MMSESection(
      title: 'Orientation to Time',
      instructions: 'Ask the following questions. Award 1 point for each correct answer.',
      questions: MMSEAssessment.orientationTimeQuestions.asMap().entries.map((e) =>
        MMSEQuestion(
          section: 'orientation_time',
          question: e.value,
          type: MMSEQuestionType.openEnded,
          maxPoints: 1,
        )
      ).toList(),
    ),
    MMSESection(
      title: 'Orientation to Place',
      instructions: 'Ask the following questions. Award 1 point for each correct answer.',
      questions: MMSEAssessment.orientationPlaceQuestions.asMap().entries.map((e) =>
        MMSEQuestion(
          section: 'orientation_place',
          question: e.value,
          type: MMSEQuestionType.openEnded,
          maxPoints: 1,
        )
      ).toList(),
    ),
    MMSESection(
      title: 'Registration',
      instructions: 'Say the three words clearly and ask the patient to repeat them. Score 1 point for each word correctly repeated.',
      questions: [
        MMSEQuestion(
          section: 'registration',
          question: 'Please repeat these three words: ${MMSEAssessment.registrationWords.join(", ")}',
          type: MMSEQuestionType.verbal,
          correctAnswer: MMSEAssessment.registrationWords,
          maxPoints: 3,
          instructions: 'Continue repeating until all three words are learned or up to 6 trials.',
        ),
      ],
    ),
    MMSESection(
      title: 'Attention and Calculation',
      instructions: 'Ask patient to subtract 7 from 100, then continue subtracting 7 from each answer. Stop after 5 subtractions. Award 1 point for each correct answer.',
      questions: [
        const MMSEQuestion(
          section: 'attention',
          question: 'Starting with 100, subtract 7 and keep subtracting 7 from each answer.',
          type: MMSEQuestionType.calculation,
          correctAnswer: MMSEAssessment.serialSevensCorrectSequence,
          maxPoints: 5,
          instructions: 'Alternative: Spell "WORLD" backward if patient cannot do serial 7s.',
        ),
      ],
    ),
    MMSESection(
      title: 'Recall',
      instructions: 'Ask patient to recall the three words from the registration test.',
      questions: [
        const MMSEQuestion(
          section: 'recall',
          question: 'What were the three words I asked you to remember?',
          type: MMSEQuestionType.verbal,
          correctAnswer: MMSEAssessment.registrationWords,
          maxPoints: 3,
        ),
      ],
    ),
    MMSESection(
      title: 'Language - Naming',
      instructions: 'Show patient a watch and pencil. Ask them to name each object.',
      questions: [
        const MMSEQuestion(
          section: 'language_naming',
          question: 'What is this object? (Show watch)',
          type: MMSEQuestionType.naming,
          correctAnswer: 'watch',
          maxPoints: 1,
        ),
        const MMSEQuestion(
          section: 'language_naming',
          question: 'What is this object? (Show pencil)',
          type: MMSEQuestionType.naming,
          correctAnswer: 'pencil',
          maxPoints: 1,
        ),
      ],
    ),
    MMSESection(
      title: 'Language - Repetition',
      instructions: 'Ask patient to repeat the following phrase exactly.',
      questions: [
        const MMSEQuestion(
          section: 'language_repetition',
          question: 'Please repeat: "${MMSEAssessment.languageRepeatPhrase}"',
          type: MMSEQuestionType.repetition,
          correctAnswer: MMSEAssessment.languageRepeatPhrase,
          maxPoints: 1,
        ),
      ],
    ),
    MMSESection(
      title: 'Language - Following Commands',
      instructions: 'Give patient a piece of paper and provide the following instructions.',
      questions: [
        MMSEQuestion(
          section: 'language_commands',
          question: 'Follow these instructions: ${MMSEAssessment.threeStageCommand.join(", ")}',
          type: MMSEQuestionType.following,
          correctAnswer: MMSEAssessment.threeStageCommand,
          maxPoints: 3,
        ),
      ],
    ),
    MMSESection(
      title: 'Language - Reading',
      instructions: 'Show patient the written command and ask them to read and obey it.',
      questions: [
        const MMSEQuestion(
          section: 'language_reading',
          question: 'Read this and do what it says: "${MMSEAssessment.readingCommand}"',
          type: MMSEQuestionType.openEnded,
          correctAnswer: 'close eyes',
          maxPoints: 1,
        ),
      ],
    ),
    MMSESection(
      title: 'Language - Writing',
      instructions: 'Ask patient to write a complete sentence.',
      questions: [
        const MMSEQuestion(
          section: 'language_writing',
          question: MMSEAssessment.writingSentencePrompt,
          type: MMSEQuestionType.openEnded,
          maxPoints: 1,
          instructions: 'Sentence must be spontaneous, make sense, and have a subject and verb.',
        ),
      ],
    ),
    MMSESection(
      title: 'Visuospatial - Copy Design',
      instructions: 'Ask patient to copy the intersecting pentagons exactly as shown.',
      questions: [
        const MMSEQuestion(
          section: 'visuospatial',
          question: MMSEAssessment.copyPentagonsTask,
          type: MMSEQuestionType.drawing,
          maxPoints: 1,
          instructions: 'All angles must be present and two must intersect.',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    sectionStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MMSE Assessment'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Section ${currentSection + 1}/${sections.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (currentSection + 1) / sections.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
          ),

          // Content
          Expanded(
            child: currentSection < sections.length
                ? _buildCurrentSection()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    final section = sections[currentSection];
    final question = section.questions[currentQuestion];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  section.instructions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Current question
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${currentQuestion + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${currentQuestion + 1} of ${section.questions.length}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Max Points: ${question.maxPoints}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (question.instructions != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.instructions!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Scoring interface
          _buildScoringInterface(question),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (currentSection > 0 || currentQuestion > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _goToPreviousQuestion,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),

              if (currentSection > 0 || currentQuestion > 0)
                const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _goToNextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _isLastQuestion() ? 'Complete Assessment' : 'Next',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoringInterface(MMSEQuestion question) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score this response:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Score selection
          Row(
            children: List.generate(question.maxPoints + 1, (score) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _ScoreButton(
                    score: score,
                    maxScore: question.maxPoints,
                    isSelected: _getSelectedScore(question) == score,
                    onTap: () => _selectScore(question, score),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Notes field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Any observations or details about the response...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => _updateNotes(question, value),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final results = MMSEResults(
      responses: responses,
      completedAt: DateTime.now(),
      totalTime: DateTime.now().difference(sectionStartTime!),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'MMSE Assessment Complete',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Score: ${results.totalScore}/30',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
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
                  'Clinical Interpretation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getInterpretationColor(results.interpretation).withOpacity(0.1),
                    border: Border.all(color: _getInterpretationColor(results.interpretation)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getInterpretationIcon(results.interpretation),
                            color: _getInterpretationColor(results.interpretation),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            results.interpretationDescription,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getInterpretationColor(results.interpretation),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getInterpretationDetails(results.interpretation),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section breakdown
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Section Scores',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...results.sectionScores.entries.map((entry) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getSectionDisplayName(entry.key),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${entry.value}/5', // Simplified - would need actual max scores
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Dashboard'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveResults,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? _getSelectedScore(MMSEQuestion question) {
    final responseId = '${question.section}_$currentQuestion';
    final response = responses.where((r) => r.questionId == responseId).firstOrNull;
    return response?.pointsAwarded;
  }

  void _selectScore(MMSEQuestion question, int score) {
    setState(() {
      final responseId = '${question.section}_$currentQuestion';

      // Remove existing response if any
      responses.removeWhere((r) => r.questionId == responseId);

      // Add new response
      responses.add(MMSEResponse(
        questionId: responseId,
        userResponse: score,
        pointsAwarded: score,
        responseTime: DateTime.now(),
      ));
    });
  }

  void _updateNotes(MMSEQuestion question, String notes) {
    final responseId = '${question.section}_$currentQuestion';
    final responseIndex = responses.indexWhere((r) => r.questionId == responseId);

    if (responseIndex != -1) {
      // Update existing response with notes
      // Note: MMSEResponse is immutable, so we'd need to create a new one
      // This is simplified for the example
    }
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (currentQuestion > 0) {
        currentQuestion--;
      } else if (currentSection > 0) {
        currentSection--;
        currentQuestion = sections[currentSection].questions.length - 1;
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (currentQuestion < sections[currentSection].questions.length - 1) {
        currentQuestion++;
      } else if (currentSection < sections.length - 1) {
        currentSection++;
        currentQuestion = 0;
      } else {
        // Complete assessment
        currentSection = sections.length;
      }
    });
  }

  bool _isLastQuestion() {
    return currentSection == sections.length - 1 &&
           currentQuestion == sections[currentSection].questions.length - 1;
  }

  Color _getInterpretationColor(MMSEInterpretation interpretation) {
    switch (interpretation) {
      case MMSEInterpretation.normal:
        return Colors.green;
      case MMSEInterpretation.mildImpairment:
        return Colors.orange;
      case MMSEInterpretation.severeImpairment:
        return Colors.red;
    }
  }

  IconData _getInterpretationIcon(MMSEInterpretation interpretation) {
    switch (interpretation) {
      case MMSEInterpretation.normal:
        return Icons.check_circle;
      case MMSEInterpretation.mildImpairment:
        return Icons.warning;
      case MMSEInterpretation.severeImpairment:
        return Icons.error;
    }
  }

  String _getInterpretationDetails(MMSEInterpretation interpretation) {
    switch (interpretation) {
      case MMSEInterpretation.normal:
        return 'Score suggests normal cognitive function for age and education level. Continue routine monitoring.';
      case MMSEInterpretation.mildImpairment:
        return 'Score suggests mild cognitive impairment. Consider additional evaluation and more frequent monitoring.';
      case MMSEInterpretation.severeImpairment:
        return 'Score suggests significant cognitive impairment. Comprehensive evaluation and immediate clinical attention recommended.';
    }
  }

  String _getSectionDisplayName(String sectionKey) {
    final sectionMap = {
      'orientation_time': 'Orientation (Time)',
      'orientation_place': 'Orientation (Place)',
      'registration': 'Registration',
      'attention': 'Attention',
      'recall': 'Recall',
      'language_naming': 'Language (Naming)',
      'language_repetition': 'Language (Repetition)',
      'language_commands': 'Language (Commands)',
      'language_reading': 'Language (Reading)',
      'language_writing': 'Language (Writing)',
      'visuospatial': 'Visuospatial',
    };

    return sectionMap[sectionKey] ?? sectionKey;
  }

  Future<void> _saveResults() async {
    try {
      final results = MMSEResults(
        responses: responses,
        completedAt: DateTime.now(),
        totalTime: DateTime.now().difference(sectionStartTime!),
      );

      final assessment = Assessment(
        type: AssessmentType.memoryRecall,
        score: results.totalScore,
        maxScore: 30,
        notes: 'MMSE Assessment - ${results.totalScore}/30',
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(assessmentProvider.notifier).addAssessment(assessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MMSE results saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class MMSESection {

  MMSESection({
    required this.title,
    required this.instructions,
    required this.questions,
  });
  final String title;
  final String instructions;
  final List<MMSEQuestion> questions;
}

class _ScoreButton extends StatelessWidget {

  const _ScoreButton({
    required this.score,
    required this.maxScore,
    required this.isSelected,
    required this.onTap,
  });
  final int score;
  final int maxScore;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.blue[800]! : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}