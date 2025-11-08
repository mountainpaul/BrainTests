import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database.dart';
import '../widgets/custom_card.dart';
import 'assessment_test_screen.dart';

class AssessmentDetailScreen extends ConsumerWidget {

  const AssessmentDetailScreen({
    super.key,
    required this.assessmentType,
  });
  final AssessmentType assessmentType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAssessmentTitle(assessmentType)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssessmentHeader(context),
            const SizedBox(height: 24),
            _buildDescription(context),
            const SizedBox(height: 24),
            _buildInstructions(context),
            const SizedBox(height: 24),
            _buildDifficultySelector(context),
            const SizedBox(height: 32),
            _buildStartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getAssessmentIcon(assessmentType),
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAssessmentTitle(assessmentType),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getAssessmentSubtitle(assessmentType),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Assessment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            _getAssessmentDescription(assessmentType),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final instructions = _getAssessmentInstructions(assessmentType);
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
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
                    child: Text(
                      instruction,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    return DifficultySelector(
      onDifficultyChanged: (difficulty) {
        // Store selected difficulty for use when starting assessment
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _startAssessment(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Start Assessment',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _startAssessment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssessmentTestScreen(
          assessmentType: assessmentType,
          difficulty: 1, // Default difficulty, could be made configurable
        ),
      ),
    );
  }

  String _getAssessmentTitle(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall Test';
      case AssessmentType.attentionFocus:
        return 'Attention Focus Test';
      case AssessmentType.executiveFunction:
        return 'Executive Function Test';
      case AssessmentType.languageSkills:
        return 'Language Skills Test';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Skills Test';
      case AssessmentType.processingSpeed:
        return 'Processing Speed Test';
    }
  }

  String _getAssessmentSubtitle(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Word list learning and recall';
      case AssessmentType.attentionFocus:
        return 'Sustained attention task';
      case AssessmentType.executiveFunction:
        return 'Problem-solving and planning';
      case AssessmentType.languageSkills:
        return 'Word fluency and vocabulary';
      case AssessmentType.visuospatialSkills:
        return 'Spatial reasoning and mental rotation';
      case AssessmentType.processingSpeed:
        return 'Speed of cognitive processing';
    }
  }

  IconData _getAssessmentIcon(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return Icons.psychology;
      case AssessmentType.attentionFocus:
        return Icons.visibility;
      case AssessmentType.executiveFunction:
        return Icons.account_tree;
      case AssessmentType.languageSkills:
        return Icons.record_voice_over;
      case AssessmentType.visuospatialSkills:
        return Icons.rotate_right;
      case AssessmentType.processingSpeed:
        return Icons.speed;
    }
  }

  String _getAssessmentDescription(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'This assessment evaluates your ability to learn and remember new information. '
            'You\'ll be shown a list of words to memorize, then asked to recall them. '
            'This tests both immediate memory and recognition abilities.';
      case AssessmentType.attentionFocus:
        return 'This test measures your ability to sustain attention over time. '
            'Numbers will appear on screen, and you need to respond to most of them while '
            'withholding responses to a specific target number.';
      case AssessmentType.executiveFunction:
        return 'This assessment evaluates planning, problem-solving, and cognitive flexibility. '
            'You\'ll solve a Tower of Hanoi puzzle, which requires strategic thinking '
            'and the ability to plan multiple steps ahead.';
      case AssessmentType.languageSkills:
        return 'This test measures verbal fluency and language processing. '
            'You\'ll generate words from specific categories or starting with certain letters, '
            'testing both semantic and phonemic fluency.';
      case AssessmentType.visuospatialSkills:
        return 'This assessment evaluates spatial reasoning and mental rotation abilities. '
            'You\'ll identify shapes that match a target when mentally rotated, '
            'testing visuospatial processing skills.';
      case AssessmentType.processingSpeed:
        return 'This test measures how quickly you can process simple cognitive tasks. '
            'You\'ll match symbols to numbers using a key, testing both speed and accuracy '
            'of information processing.';
    }
  }

  List<String> _getAssessmentInstructions(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return [
          'A list of words will be displayed for you to study',
          'Pay close attention and try to remember all the words',
          'After the study phase, write down all words you remember',
          'Then complete a recognition task to identify the words',
        ];
      case AssessmentType.attentionFocus:
        return [
          'Numbers from 1-9 will appear on the screen one at a time',
          'Tap the button when you see any number EXCEPT the target number',
          'Do NOT tap when you see the target number (you\'ll be told which one)',
          'Stay focused throughout the entire task',
        ];
      case AssessmentType.executiveFunction:
        return [
          'Move all disks from the left tower to the right tower',
          'You can only move one disk at a time',
          'Never place a larger disk on top of a smaller disk',
          'Plan your moves carefully to solve efficiently',
        ];
      case AssessmentType.languageSkills:
        return [
          'You\'ll be given a category or letter prompt',
          'Generate as many valid words as possible',
          'Speak clearly or type your responses',
          'Avoid repetitions and invalid words',
        ];
      case AssessmentType.visuospatialSkills:
        return [
          'Look at the target shape at the top of the screen',
          'Select which of the options matches the target when rotated',
          'Consider the shape carefully before responding',
          'Work as quickly as possible while staying accurate',
        ];
      case AssessmentType.processingSpeed:
        return [
          'Use the symbol-number key at the top of the screen',
          'Convert each symbol in the sequence to its corresponding number',
          'Work as quickly and accurately as possible',
          'Don\'t spend too long on any single item',
        ];
    }
  }
}

/// Difficulty selector widget
class DifficultySelector extends StatefulWidget {

  const DifficultySelector({
    super.key,
    this.initialDifficulty = 1,
    required this.onDifficultyChanged,
  });
  final int initialDifficulty;
  final ValueChanged<int> onDifficultyChanged;

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  late int selectedDifficulty;

  @override
  void initState() {
    super.initState();
    selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Level',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final difficulty = index + 1;
              final isSelected = difficulty == selectedDifficulty;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                  widget.onDifficultyChanged(difficulty);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$difficulty',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getDifficultyDescription(selectedDifficulty),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDifficultyDescription(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Very Easy - Perfect for beginners';
      case 2:
        return 'Easy - Suitable for most people';
      case 3:
        return 'Medium - Standard difficulty level';
      case 4:
        return 'Hard - Challenging but manageable';
      case 5:
        return 'Very Hard - For experienced users';
      default:
        return '';
    }
  }
}