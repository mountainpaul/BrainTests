import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../widgets/custom_card.dart';
import 'exercise_test_screen.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseType,
    this.initialDifficulty,
  });
  final ExerciseType exerciseType;
  final ExerciseDifficulty? initialDifficulty;

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  late ExerciseDifficulty selectedDifficulty;

  @override
  void initState() {
    super.initState();
    selectedDifficulty = widget.initialDifficulty ?? ExerciseDifficulty.medium;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getExerciseTitle(widget.exerciseType)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(context),
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

  Widget _buildExerciseHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getExerciseIcon(widget.exerciseType),
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getExerciseTitle(widget.exerciseType),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExerciseSubtitle(widget.exerciseType),
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
            'About This Exercise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            _getExerciseDescription(widget.exerciseType),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final instructions = _getExerciseInstructions(widget.exerciseType);

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
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Difficulty: ${_getDifficultyLabel(selectedDifficulty)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _getDifficultyColor(selectedDifficulty),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can adjust this at any time',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startExercise(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          'Start Exercise',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _startExercise(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseTestScreen(
          exerciseType: widget.exerciseType,
          difficulty: selectedDifficulty,
        ),
      ),
    );
  }

  String _getDifficultyLabel(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Easy';
      case ExerciseDifficulty.medium:
        return 'Medium';
      case ExerciseDifficulty.hard:
        return 'Hard';
      case ExerciseDifficulty.expert:
        return 'Expert';
    }
  }

  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return Colors.green;
      case ExerciseDifficulty.medium:
        return Colors.orange;
      case ExerciseDifficulty.hard:
        return Colors.red;
      case ExerciseDifficulty.expert:
        return Colors.purple;
    }
  }

  String _getExerciseTitle(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return 'Memory Game';
      case ExerciseType.wordPuzzle:
        return 'Word Anagram';
      case ExerciseType.wordSearch:
        return 'Word Search';
      case ExerciseType.spanishAnagram:
        return 'Spanish Anagram';
      case ExerciseType.mathProblem:
        return 'Math Problem';
      case ExerciseType.patternRecognition:
        return 'Pattern Recognition';
      case ExerciseType.sequenceRecall:
        return 'Sequence Recall';
      case ExerciseType.spatialAwareness:
        return 'Spatial Awareness';
    }
  }

  String _getExerciseSubtitle(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return 'Match cards and remember locations';
      case ExerciseType.wordPuzzle:
        return 'Unscramble letters to form words';
      case ExerciseType.wordSearch:
        return 'Find hidden words in a grid';
      case ExerciseType.spanishAnagram:
        return 'Unscramble Spanish words';
      case ExerciseType.mathProblem:
        return 'Mental arithmetic and problem solving';
      case ExerciseType.patternRecognition:
        return 'Identify and complete patterns';
      case ExerciseType.sequenceRecall:
        return 'Remember and repeat sequences';
      case ExerciseType.spatialAwareness:
        return 'Spatial reasoning and visualization';
    }
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return Icons.memory;
      case ExerciseType.wordPuzzle:
        return Icons.shuffle;
      case ExerciseType.wordSearch:
        return Icons.grid_on;
      case ExerciseType.spanishAnagram:
        return Icons.translate;
      case ExerciseType.mathProblem:
        return Icons.calculate;
      case ExerciseType.patternRecognition:
        return Icons.pattern;
      case ExerciseType.sequenceRecall:
        return Icons.list;
      case ExerciseType.spatialAwareness:
        return Icons.view_in_ar;
    }
  }

  String _getExerciseDescription(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return 'This exercise enhances your visual and spatial memory. You\'ll see cards '
            'laid out in a grid, then they\'ll flip over. Your task is to find matching pairs '
            'by remembering where each card is located.';
      case ExerciseType.wordPuzzle:
        return 'Challenge your language processing and vocabulary skills. You\'ll unscramble '
            'jumbled letters to form valid words, improving pattern recognition and '
            'verbal fluency.';
      case ExerciseType.wordSearch:
        return 'Test your visual scanning and word recognition abilities. You\'ll search '
            'for hidden words in a grid of letters, improving attention to detail and '
            'visual processing speed.';
      case ExerciseType.spanishAnagram:
        return 'Improve your Spanish vocabulary and pattern recognition skills. You\'ll '
            'unscramble jumbled Spanish words to form valid words, enhancing both '
            'language learning and cognitive flexibility.';
      case ExerciseType.mathProblem:
        return 'Strengthen your numerical reasoning and arithmetic skills. You\'ll solve '
            'mental math problems, number sequences, and logical puzzles that challenge '
            'your quantitative thinking abilities.';
      case ExerciseType.patternRecognition:
        return 'Develop your ability to identify visual and logical patterns. You\'ll '
            'analyze sequences of shapes, colors, and numbers to predict what comes next '
            'or identify the missing element.';
      case ExerciseType.sequenceRecall:
        return 'Train your sequential memory and attention. You\'ll watch sequences of '
            'lights, sounds, or symbols, then reproduce them in the correct order. '
            'This improves working memory and concentration.';
      case ExerciseType.spatialAwareness:
        return 'Enhance your spatial reasoning and visualization skills. You\'ll work '
            'with 3D objects, mental rotation, and spatial relationships to improve '
            'your ability to navigate and understand space.';
    }
  }

  List<String> _getExerciseInstructions(ExerciseType type) {
    switch (type) {
      case ExerciseType.memoryGame:
        return [
          'Cards will be briefly shown face up',
          'Memorize the location of each card',
          'Tap cards to flip them and find matching pairs',
          'Complete all pairs to finish the game',
        ];
      case ExerciseType.wordPuzzle:
        return [
          'Look at the scrambled letters carefully',
          'Tap letters to build your word',
          'Rearrange the letters to form valid words',
          'Complete all 5 anagrams to finish',
        ];
      case ExerciseType.wordSearch:
        return [
          'Find all the words listed at the top',
          'Tap letters in the grid to select them',
          'Words can be horizontal, vertical, or diagonal',
          'Found words will be highlighted in green',
        ];
      case ExerciseType.spanishAnagram:
        return [
          'Study the scrambled Spanish word carefully',
          'Rearrange the letters to form a valid Spanish word',
          'Type or select your answer from the options',
          'Work as quickly and accurately as possible',
        ];
      case ExerciseType.mathProblem:
        return [
          'Read each math problem carefully',
          'Solve the calculation mentally if possible',
          'Select or enter your answer',
          'Work as quickly and accurately as you can',
        ];
      case ExerciseType.patternRecognition:
        return [
          'Study the pattern sequence carefully',
          'Identify the rule or logic behind the pattern',
          'Choose the option that continues the pattern',
          'Consider shape, color, size, and position changes',
        ];
      case ExerciseType.sequenceRecall:
        return [
          'Watch the sequence of items as they appear',
          'Pay close attention to the order',
          'Repeat the sequence in the exact same order',
          'Sequences will get longer as you progress',
        ];
      case ExerciseType.spatialAwareness:
        return [
          'Examine the 3D object or spatial problem',
          'Visualize how it would look from different angles',
          'Consider rotations and transformations',
          'Select the answer that matches your mental image',
        ];
    }
  }
}

/// Exercise difficulty selector widget
class ExerciseDifficultySelector extends StatefulWidget {

  const ExerciseDifficultySelector({
    super.key,
    this.initialDifficulty = ExerciseDifficulty.medium,
    required this.onDifficultyChanged,
  });
  final ExerciseDifficulty initialDifficulty;
  final ValueChanged<ExerciseDifficulty> onDifficultyChanged;

  @override
  State<ExerciseDifficultySelector> createState() => _ExerciseDifficultySelectorState();
}

class _ExerciseDifficultySelectorState extends State<ExerciseDifficultySelector> {
  late ExerciseDifficulty selectedDifficulty;

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
            children: ExerciseDifficulty.values.map((difficulty) {
              final isSelected = difficulty == selectedDifficulty;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                  widget.onDifficultyChanged(difficulty);
                },
                child: Container(
                  width: 60,
                  height: 60,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDifficultyIcon(difficulty),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getDifficultyShortLabel(difficulty),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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

  String _getDifficultyIcon(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return '🙂';
      case ExerciseDifficulty.medium:
        return '😐';
      case ExerciseDifficulty.hard:
        return '😤';
      case ExerciseDifficulty.expert:
        return '🤯';
    }
  }

  String _getDifficultyShortLabel(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Easy';
      case ExerciseDifficulty.medium:
        return 'Med';
      case ExerciseDifficulty.hard:
        return 'Hard';
      case ExerciseDifficulty.expert:
        return 'Expert';
    }
  }

  String _getDifficultyDescription(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Perfect for beginners - relaxed pace and simple challenges';
      case ExerciseDifficulty.medium:
        return 'Standard difficulty - good balance of challenge and achievability';
      case ExerciseDifficulty.hard:
        return 'Challenging - requires focus and mental effort';
      case ExerciseDifficulty.expert:
        return 'Expert level - maximum challenge for experienced users';
    }
  }
}