import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/validated_assessments.dart';
import '../widgets/custom_card.dart';

class MoCAAssessmentScreen extends ConsumerStatefulWidget {
  const MoCAAssessmentScreen({super.key});

  @override
  ConsumerState<MoCAAssessmentScreen> createState() => _MoCAAssessmentScreenState();
}

class _MoCAAssessmentScreenState extends ConsumerState<MoCAAssessmentScreen> {
  int currentSection = 0;
  int currentQuestion = 0;
  final List<MMSEResponse> responses = []; // Reuse MMSEResponse for MoCA
  DateTime? assessmentStartTime;

  final List<MoCASection> sections = [
    MoCASection(
      title: 'Visuospatial/Executive',
      instructions: 'This section tests visual-spatial abilities and executive function.',
      subsections: [
        MoCASubsection(
          title: 'Trail Making',
          instruction: 'Please draw a line connecting the circles in ascending order, alternating between numbers and letters (1-A-2-B-3-C-4-D-5).',
          maxPoints: 1,
          type: MoCATaskType.trailMaking,
        ),
        MoCASubsection(
          title: 'Copy Cube',
          instruction: 'Please copy this cube exactly as shown.',
          maxPoints: 1,
          type: MoCATaskType.drawing,
        ),
        MoCASubsection(
          title: 'Clock Drawing',
          instruction: 'Draw a clock. Put in all the numbers and set the time to 10 past 11.',
          maxPoints: 3,
          type: MoCATaskType.clockDrawing,
          scoringDetails: [
            'Contour (1 pt): Circle or square with minimal distortion',
            'Numbers (1 pt): All numbers present in correct position',
            'Hands (1 pt): Correct time with proper hand length'
          ],
        ),
      ],
    ),
    MoCASection(
      title: 'Naming',
      instructions: 'Point to each animal and ask the patient to name it.',
      subsections: [
        MoCASubsection(
          title: 'Animal Naming',
          instruction: 'Please name these animals: Lion, Rhinoceros, Camel',
          maxPoints: 3,
          type: MoCATaskType.naming,
          correctAnswers: ['lion', 'rhinoceros', 'camel'],
        ),
      ],
    ),
    MoCASection(
      title: 'Memory',
      instructions: 'Read list of words, patient must repeat them. Do 2 learning trials even if 1st trial is successful.',
      subsections: [
        MoCASubsection(
          title: 'Word Registration',
          instruction: 'I am going to read you a list of words that you will have to remember. Listen carefully: Face, Velvet, Church, Daisy, Red',
          maxPoints: 0, // No points for registration, tested later
          type: MoCATaskType.wordRegistration,
          correctAnswers: ['face', 'velvet', 'church', 'daisy', 'red'],
        ),
      ],
    ),
    MoCASection(
      title: 'Attention',
      instructions: 'This section tests different aspects of attention.',
      subsections: [
        MoCASubsection(
          title: 'Digit Span Forward',
          instruction: 'I am going to say some numbers and when I am finished, repeat them back to me exactly as I said them: 2-1-8-5-4',
          maxPoints: 1,
          type: MoCATaskType.digitSpan,
          correctAnswers: ['21854'],
        ),
        MoCASubsection(
          title: 'Digit Span Backward',
          instruction: 'Now I am going to say some more numbers, but when I am finished, say them backwards: 7-4-2',
          maxPoints: 1,
          type: MoCATaskType.digitSpan,
          correctAnswers: ['247'],
        ),
        MoCASubsection(
          title: 'Vigilance',
          instruction: 'I will read a sequence of letters. Every time I say the letter A, tap your hand once: F-B-A-C-M-N-A-A-J-K-L-B-A-F-A-K-D-E-A-A-A-J-A-M-O-F-A-A-B',
          maxPoints: 1,
          type: MoCATaskType.vigilance,
          correctAnswers: ['10'], // 10 A's in the sequence
        ),
        MoCASubsection(
          title: 'Serial 7s',
          instruction: 'Now, I will ask you to count backwards from 100 by 7s, so you will say 93, 86, and so on: 100-93-86-79-72-65',
          maxPoints: 3,
          type: MoCATaskType.serialSevens,
          correctAnswers: ['93', '86', '79', '72', '65'],
        ),
      ],
    ),
    MoCASection(
      title: 'Language',
      instructions: 'This section tests language abilities.',
      subsections: [
        MoCASubsection(
          title: 'Sentence Repetition 1',
          instruction: 'I am going to read you a sentence. Repeat it after me, exactly as I say it: "I only know that John is the one to help today."',
          maxPoints: 1,
          type: MoCATaskType.repetition,
          correctAnswers: ['I only know that John is the one to help today'],
        ),
        MoCASubsection(
          title: 'Sentence Repetition 2',
          instruction: 'Now repeat this sentence: "The cat always hid under the couch when dogs were in the room."',
          maxPoints: 1,
          type: MoCATaskType.repetition,
          correctAnswers: ['The cat always hid under the couch when dogs were in the room'],
        ),
        MoCASubsection(
          title: 'Phonemic Fluency',
          instruction: 'Tell me as many words as you can that begin with the letter F. You have one minute. (Record number of words)',
          maxPoints: 1,
          type: MoCATaskType.fluency,
          scoringDetails: ['≥11 words = 1 point', '<11 words = 0 points'],
        ),
      ],
    ),
    MoCASection(
      title: 'Abstraction',
      instructions: 'Tell me how these items are alike.',
      subsections: [
        MoCASubsection(
          title: 'Similarity 1',
          instruction: 'Tell me how a train and bicycle are alike.',
          maxPoints: 1,
          type: MoCATaskType.abstraction,
          correctAnswers: ['transportation', 'travel', 'move', 'vehicles'],
        ),
        MoCASubsection(
          title: 'Similarity 2',
          instruction: 'Tell me how a watch and ruler are alike.',
          maxPoints: 1,
          type: MoCATaskType.abstraction,
          correctAnswers: ['measuring instruments', 'measure', 'tools'],
        ),
      ],
    ),
    MoCASection(
      title: 'Delayed Recall',
      instructions: 'I read some words to you earlier, which I asked you to remember. Tell me as many of those words as you can remember.',
      subsections: [
        MoCASubsection(
          title: 'Free Recall',
          instruction: 'What were the words I asked you to remember?',
          maxPoints: 5,
          type: MoCATaskType.delayedRecall,
          correctAnswers: ['face', 'velvet', 'church', 'daisy', 'red'],
        ),
      ],
    ),
    MoCASection(
      title: 'Orientation',
      instructions: 'Tell me the date.',
      subsections: [
        MoCASubsection(
          title: 'Date Orientation',
          instruction: 'What is the date today? (Date, month, year, day, place, city)',
          maxPoints: 6,
          type: MoCATaskType.orientation,
          scoringDetails: [
            'Date (1 pt)', 'Month (1 pt)', 'Year (1 pt)',
            'Day of week (1 pt)', 'Place (1 pt)', 'City (1 pt)'
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    assessmentStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoCA Assessment'),
        backgroundColor: Colors.teal[800],
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
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
    final subsection = section.subsections[currentQuestion];

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
                    color: Colors.teal[800],
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

          // Current subsection
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.teal[800],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${currentQuestion + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                            subsection.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Max Points: ${subsection.maxPoints}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.teal[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Task instruction
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subsection.instruction,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ),

                // Special interfaces for specific tasks
                if (subsection.type == MoCATaskType.clockDrawing) ...[
                  const SizedBox(height: 16),
                  _buildClockDrawingInterface(),
                ],

                if (subsection.type == MoCATaskType.trailMaking) ...[
                  const SizedBox(height: 16),
                  _buildTrailMakingInterface(),
                ],

                if (subsection.scoringDetails != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Scoring Details:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...subsection.scoringDetails!.map((detail) =>
                          Padding(
                            padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
                            child: Text(
                              '• $detail',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontSize: 14,
                              ),
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
          if (subsection.maxPoints > 0)
            _buildScoringInterface(subsection),

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
                    backgroundColor: Colors.teal[800],
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

  Widget _buildClockDrawingInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Clock Drawing Area',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    'Patient draws clock here',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Observe the patient drawing and score based on accuracy of contour, numbers, and hands.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrailMakingInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Trail Making Test',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '1 → A → 2 → B → 3 → C → 4 → D → 5',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Patient should draw lines connecting numbers and letters in alternating sequence.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoringInterface(MoCASubsection subsection) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score this task:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Score selection
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(subsection.maxPoints + 1, (score) {
              return _ScoreChip(
                score: score,
                maxScore: subsection.maxPoints,
                isSelected: _getSelectedScore(subsection) == score,
                onTap: () => _selectScore(subsection, score),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Notes field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Clinical Notes (optional)',
              hintText: 'Observations, patient behavior, errors made...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => _updateNotes(subsection, value),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final results = MoCAResults(
      responses: responses,
      completedAt: DateTime.now(),
      totalTime: DateTime.now().difference(assessmentStartTime!),
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
                  'MoCA Assessment Complete',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Raw Score: ${results.totalScore}/30',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Education Adjusted Score: ${results.getEducationAdjustedScore(12)}/30',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            results.interpretation == MoCAInterpretation.normal
                                ? 'Normal Cognitive Function (≥26 points)'
                                : 'Cognitive Impairment Suspected (<26 points)',
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

  int? _getSelectedScore(MoCASubsection subsection) {
    final responseId = '${subsection.title}_${currentSection}_$currentQuestion';
    final response = responses.where((r) => r.questionId == responseId).firstOrNull;
    return response?.pointsAwarded;
  }

  void _selectScore(MoCASubsection subsection, int score) {
    setState(() {
      final responseId = '${subsection.title}_${currentSection}_$currentQuestion';

      responses.removeWhere((r) => r.questionId == responseId);

      responses.add(MMSEResponse(
        questionId: responseId,
        userResponse: score,
        pointsAwarded: score,
        responseTime: DateTime.now(),
      ));
    });
  }

  void _updateNotes(MoCASubsection subsection, String notes) {
    // Implementation for updating notes
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (currentQuestion > 0) {
        currentQuestion--;
      } else if (currentSection > 0) {
        currentSection--;
        currentQuestion = sections[currentSection].subsections.length - 1;
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (currentQuestion < sections[currentSection].subsections.length - 1) {
        currentQuestion++;
      } else if (currentSection < sections.length - 1) {
        currentSection++;
        currentQuestion = 0;
      } else {
        currentSection = sections.length;
      }
    });
  }

  bool _isLastQuestion() {
    return currentSection == sections.length - 1 &&
           currentQuestion == sections[currentSection].subsections.length - 1;
  }

  Color _getInterpretationColor(MoCAInterpretation interpretation) {
    switch (interpretation) {
      case MoCAInterpretation.normal:
        return Colors.green;
      case MoCAInterpretation.impaired:
        return Colors.red;
    }
  }

  IconData _getInterpretationIcon(MoCAInterpretation interpretation) {
    switch (interpretation) {
      case MoCAInterpretation.normal:
        return Icons.check_circle;
      case MoCAInterpretation.impaired:
        return Icons.warning;
    }
  }

  String _getInterpretationDetails(MoCAInterpretation interpretation) {
    switch (interpretation) {
      case MoCAInterpretation.normal:
        return 'Score suggests normal cognitive function. MoCA is more sensitive than MMSE for detecting mild cognitive impairment.';
      case MoCAInterpretation.impaired:
        return 'Score suggests possible cognitive impairment. Consider comprehensive neuropsychological evaluation and medical workup. MoCA scores <26 warrant further investigation.';
    }
  }

  void _saveResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('MoCA results saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class MoCASection {

  MoCASection({
    required this.title,
    required this.instructions,
    required this.subsections,
  });
  final String title;
  final String instructions;
  final List<MoCASubsection> subsections;
}

class MoCASubsection {

  MoCASubsection({
    required this.title,
    required this.instruction,
    required this.maxPoints,
    required this.type,
    this.correctAnswers,
    this.scoringDetails,
  });
  final String title;
  final String instruction;
  final int maxPoints;
  final MoCATaskType type;
  final List<String>? correctAnswers;
  final List<String>? scoringDetails;
}

enum MoCATaskType {
  trailMaking,
  drawing,
  clockDrawing,
  naming,
  wordRegistration,
  digitSpan,
  vigilance,
  serialSevens,
  repetition,
  fluency,
  abstraction,
  delayedRecall,
  orientation,
}

class _ScoreChip extends StatelessWidget {

  const _ScoreChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal[800] : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.teal[800]! : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$score pt${score == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}