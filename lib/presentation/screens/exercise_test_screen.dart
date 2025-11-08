import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/user_profile_service.dart';
import '../../core/services/word_definition_service.dart';
import '../../core/services/word_dictionary_service.dart';
import '../../data/datasources/database.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/services/exercise_generator.dart';
import '../providers/cognitive_exercise_provider.dart';
import '../providers/database_provider.dart';
import '../widgets/custom_card.dart';

class ExerciseTestScreen extends ConsumerStatefulWidget {

  const ExerciseTestScreen({
    super.key,
    required this.exerciseType,
    this.difficulty = ExerciseDifficulty.medium,
  });
  final ExerciseType exerciseType;
  final ExerciseDifficulty difficulty;

  @override
  ConsumerState<ExerciseTestScreen> createState() => _ExerciseTestScreenState();
}

class _ExerciseTestScreenState extends ConsumerState<ExerciseTestScreen> {
  late DateTime testStartTime;
  Timer? countdownTimer;
  int remainingTimeSeconds = 0;
  bool testCompleted = false;
  bool isLoading = true;
  int? finalScore;
  int? timeSpentSeconds;

  @override
  void initState() {
    super.initState();
    testStartTime = DateTime.now();
    // Simulate brief loading for exercise generation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _completeExercise() {
    setState(() {
      testCompleted = true;
    });
    countdownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getExerciseTitle()),
        actions: [
          if (remainingTimeSeconds > 0 && !testCompleted)
            Container(
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
            ),
        ],
      ),
      body: testCompleted
          ? _buildCompletionScreen()
          : isLoading
              ? _buildLoadingScreen()
              : _buildExerciseContent(),
    );
  }

  Widget _buildExerciseContent() {
    switch (widget.exerciseType) {
      case ExerciseType.memoryGame:
        return MemoryGameWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
      case ExerciseType.wordPuzzle:
        return WordPuzzleWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
          wordType: WordType.anagram,
        );
      case ExerciseType.wordSearch:
        return WordPuzzleWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
          wordType: WordType.wordSearch,
        );
      case ExerciseType.spanishAnagram:
        return SpanishAnagramWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
      case ExerciseType.mathProblem:
        return MathProblemWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
      case ExerciseType.patternRecognition:
        return PatternRecognitionWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
      case ExerciseType.sequenceRecall:
        return SequenceRecallWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
      case ExerciseType.spatialAwareness:
        return SpatialAwarenessWidget(
          difficulty: widget.difficulty,
          onCompleted: _saveExerciseResult,
        );
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Preparing ${_getExerciseTitle()}...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Difficulty: ${_getDifficultyLabel(widget.difficulty)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getDifficultyColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final score = finalScore ?? 0;
    final time = timeSpentSeconds ?? 0;
    final minutes = time ~/ 60;
    final seconds = time % 60;

    // Determine performance level
    String performanceMessage;
    Color performanceColor;
    IconData performanceIcon;

    if (score >= 90) {
      performanceMessage = 'Excellent!';
      performanceColor = Colors.green;
      performanceIcon = Icons.emoji_events;
    } else if (score >= 75) {
      performanceMessage = 'Great Job!';
      performanceColor = Colors.blue;
      performanceIcon = Icons.thumb_up;
    } else if (score >= 60) {
      performanceMessage = 'Good Effort!';
      performanceColor = Colors.orange;
      performanceIcon = Icons.check_circle;
    } else {
      performanceMessage = 'Keep Practicing!';
      performanceColor = Colors.deepOrange;
      performanceIcon = Icons.trending_up;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CustomCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                performanceIcon,
                size: 72,
                color: performanceColor,
              ),
              const SizedBox(height: 16),
              Text(
                performanceMessage,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: performanceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Score Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: performanceColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score/100',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: performanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    context,
                    Icons.timer,
                    'Time',
                    minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s',
                  ),
                  _buildStatItem(
                    context,
                    Icons.signal_cellular_alt,
                    'Difficulty',
                    _getDifficultyLabel(widget.difficulty),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ExerciseTestScreen(
                        exerciseType: widget.exerciseType,
                        difficulty: widget.difficulty,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.difficulty != ExerciseDifficulty.expert)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final nextDifficulty = _getNextDifficulty(widget.difficulty);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ExerciseTestScreen(
                                exerciseType: widget.exerciseType,
                                difficulty: nextDifficulty,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Harder'),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.grid_view),
                      label: const Text('Exercises', overflow: TextOverflow.visible, softWrap: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  ExerciseDifficulty _getNextDifficulty(ExerciseDifficulty current) {
    switch (current) {
      case ExerciseDifficulty.easy:
        return ExerciseDifficulty.medium;
      case ExerciseDifficulty.medium:
        return ExerciseDifficulty.hard;
      case ExerciseDifficulty.hard:
        return ExerciseDifficulty.expert;
      case ExerciseDifficulty.expert:
        return ExerciseDifficulty.expert;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
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

  String _getExerciseTitle() {
    switch (widget.exerciseType) {
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

  Future<void> _saveExerciseResult(int score, int timeSpentSeconds) async {
    try {
      final exercise = CognitiveExercise(
        name: _getExerciseTitle(),
        type: widget.exerciseType,
        difficulty: widget.difficulty,
        score: score,
        maxScore: 100,
        timeSpentSeconds: timeSpentSeconds,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(cognitiveExerciseProvider.notifier).addExercise(exercise);

      // Use post-frame callback to ensure setState happens after current frame
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              finalScore = score;
              this.timeSpentSeconds = timeSpentSeconds;
              testCompleted = true;
            });
            countdownTimer?.cancel();
          }
        });
      }
    } catch (e) {
      print('Error saving exercise result: $e');
      // Use post-frame callback to ensure setState happens after current frame
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              finalScore = score;
              this.timeSpentSeconds = timeSpentSeconds;
              testCompleted = true;
            });
            countdownTimer?.cancel();
          }
        });
      }
    }
  }
}

/// Memory Game Widget - Card Matching
class MemoryGameWidget extends StatefulWidget {

  const MemoryGameWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  State<MemoryGameWidget> createState() => _MemoryGameWidgetState();
}

class _MemoryGameWidgetState extends State<MemoryGameWidget> {
  late MemoryGameData gameData;
  late List<bool> cardRevealed;
  late List<bool> cardMatched;
  int? firstCardIndex;
  int? secondCardIndex;
  int pairsMatched = 0;
  int moves = 0;
  late DateTime startTime;
  Timer? gameTimer;
  bool gameStarted = false;
  bool showingCards = true;
  int? userAge;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Get user age for age-adjusted show times
    userAge = await UserProfileService.getUserAge();

    setState(() {
      gameData = ExerciseGenerator.generateMemoryGame(
        difficulty: widget.difficulty,
        userAge: userAge,
      );
      cardRevealed = List.filled(gameData.cardSymbols.length, false);
      cardMatched = List.filled(gameData.cardSymbols.length, false);
      isInitializing = false;
    });

    _startShowPhase();
  }

  void _startShowPhase() {
    // Show all cards briefly
    setState(() {
      cardRevealed = List.filled(gameData.cardSymbols.length, true);
    });
    
    Timer(Duration(seconds: gameData.showTimeSeconds), () {
      setState(() {
        cardRevealed = List.filled(gameData.cardSymbols.length, false);
        showingCards = false;
        gameStarted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Game status
          CustomCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Moves: $moves'),
                Text('Pairs: $pairsMatched/${gameData.cardSymbols.length ~/ 2}'),
                if (showingCards)
                  const Text('Memorize!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                else if (!gameStarted)
                  const Text('Ready...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Game grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameData.gridSize,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gameData.cardSymbols.length,
              itemBuilder: (context, index) {
                final isRevealed = cardRevealed[index];
                final isMatched = cardMatched[index];
                
                return GestureDetector(
                  onTap: gameStarted && !isRevealed && !isMatched ? () => _onCardTapped(index) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isMatched ? Colors.green[100] : (isRevealed ? Colors.blue[100] : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMatched ? Colors.green : (isRevealed ? Colors.blue : Colors.grey),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isRevealed || isMatched ? gameData.cardSymbols[index] : '?',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onCardTapped(int index) {
    if (firstCardIndex == null) {
      setState(() {
        firstCardIndex = index;
        cardRevealed[index] = true;
      });
    } else if (secondCardIndex == null && index != firstCardIndex) {
      setState(() {
        secondCardIndex = index;
        cardRevealed[index] = true;
        moves++;
      });
      
      // Check for match after a delay
      Timer(const Duration(milliseconds: 1000), _checkForMatch);
    }
  }

  void _checkForMatch() {
    if (firstCardIndex != null && secondCardIndex != null) {
      final firstSymbol = gameData.cardSymbols[firstCardIndex!];
      final secondSymbol = gameData.cardSymbols[secondCardIndex!];
      
      if (firstSymbol == secondSymbol) {
        // Match found
        setState(() {
          cardMatched[firstCardIndex!] = true;
          cardMatched[secondCardIndex!] = true;
          pairsMatched++;
        });

        if (pairsMatched == gameData.cardSymbols.length ~/ 2) {
          // Schedule completion after build completes to avoid navigator assertion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _completeGame();
          });
        }
      } else {
        // No match, hide cards
        setState(() {
          cardRevealed[firstCardIndex!] = false;
          cardRevealed[secondCardIndex!] = false;
        });
      }
      
      setState(() {
        firstCardIndex = null;
        secondCardIndex = null;
      });
    }
  }

  void _completeGame() async {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final efficiency = (gameData.cardSymbols.length ~/ 2) / moves;
    final score = (efficiency * 100).clamp(10, 100).round();

    // Show age-adjusted performance feedback
    final feedback = UserProfileService.getPerformanceFeedback(
      score,
      userAge,
      widget.difficulty,
    );

    // Show feedback dialog
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                score >= 60 ? Icons.celebration : Icons.emoji_events,
                color: score >= 60 ? Colors.green : Colors.orange,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text('Game Complete!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score: $score%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: score >= 60 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text('Moves: $moves'),
              Text('Time: ${timeSpent}s'),
              const SizedBox(height: 16),
              Text(
                feedback,
                style: const TextStyle(fontSize: 16),
              ),
              if (userAge != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Age group: ${UserProfileService.getAgeGroup(userAge!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCompleted(score, timeSpent);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      widget.onCompleted(score, timeSpent);
    }
  }
}

/// Word Puzzle Widget - Anagrams and Word Search
class WordPuzzleWidget extends ConsumerStatefulWidget {

  const WordPuzzleWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
    this.wordType = WordType.anagram,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;
  final WordType wordType;

  @override
  ConsumerState<WordPuzzleWidget> createState() => _WordPuzzleWidgetState();
}

class _WordPuzzleWidgetState extends ConsumerState<WordPuzzleWidget> {
  WordPuzzleData? puzzleData;
  late DateTime startTime;
  String userAnswer = '';
  List<String> foundWords = [];
  List<List<bool>> selectedCells = [];
  List<int> currentSelection = [];
  String currentWord = '';
  bool isLoading = true;

  // For multiple anagram words
  List<String> anagramWords = [];
  List<List<String>> anagramScrambledLetters = [];
  List<bool> anagramSolved = [];
  int currentAnagramIndex = 0;
  final TextEditingController _textController = TextEditingController();

  // UI enhancement states
  String? feedbackMessage;
  Color? feedbackColor;
  bool showHint = false;
  int hintsUsed = 0;
  int skipsUsed = 0;
  Timer? feedbackTimer;

  // Track selected letters for tap-to-build interface
  List<int> selectedLetterIndices = [];

  // Track correctly answered words (not skipped)
  List<bool> anagramCorrect = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _loadPuzzleData();
  }
  
  @override
  void dispose() {
    _textController.dispose();
    feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPuzzleData() async {
    final database = ref.read(databaseProvider);
    final data = await ExerciseGenerator.generateWordPuzzle(
      difficulty: widget.difficulty,
      database: database,
      wordType: widget.wordType,
    );

    // If it's an anagram puzzle, generate 5 unique words
    if (data.type == WordPuzzleType.anagram) {
      // Get up to 5 unique anagram words from database
      final words = await WordDictionaryService.getRandomAnagramWords(
        database,
        WordLanguage.english,
        widget.difficulty,
        5, // Request 5 unique words
      );

      // Handle case where fewer than 5 words are available
      // Ensure we have at least 1 word to prevent crashes
      if (words.isEmpty) {
        // Fallback to single word from puzzleData if database is empty
        if (data.targetWord != null && data.scrambledLetters != null) {
          anagramWords.add(data.targetWord!);
          anagramScrambledLetters.add(data.scrambledLetters!);
          anagramSolved.add(false);
          anagramCorrect.add(false);
        }
      } else {
        // Generate scrambled letters for each word
        for (final word in words) {
          final scrambledLetters = ExerciseGenerator.ensureScrambled(word.split(''));
          anagramWords.add(word);
          anagramScrambledLetters.add(scrambledLetters);
          anagramSolved.add(false);
          anagramCorrect.add(false);
        }
      }
    }

    setState(() {
      puzzleData = data;
      isLoading = false;
    });
    _initializeGrid();
  }

  void _initializeGrid() {
    if (puzzleData?.grid != null) {
      selectedCells = List.generate(
        puzzleData!.grid!.length,
        (i) => List.generate(puzzleData!.grid![i].length, (j) => false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || puzzleData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (puzzleData!.type == WordPuzzleType.anagram) {
      return _buildAnagramPuzzle();
    } else {
      return _buildWordSearchPuzzle();
    }
  }

  Widget _buildAnagramPuzzle() {
    // Use multiple anagram data if available, otherwise fall back to single word
    final isMultipleAnagrams = anagramWords.isNotEmpty;
    final currentScrambled = isMultipleAnagrams
        ? anagramScrambledLetters[currentAnagramIndex]
        : puzzleData!.scrambledLetters!;
    final solvedCount = isMultipleAnagrams ? anagramSolved.where((s) => s).length : 0;
    final timeElapsed = DateTime.now().difference(startTime).inSeconds;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // Issue #8: Fix keyboard covering puzzle
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Issue #6: Display difficulty level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getDifficultyColor(), width: 2),
              ),
              child: Text(
                'Difficulty: ${widget.difficulty.name.toUpperCase()}',
                style: TextStyle(
                  color: _getDifficultyColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Issue #7: Timer and scoring
            if (isMultipleAnagrams) ...[
              CustomCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(Icons.timer, '$timeElapsed s', Colors.blue),
                    _buildStatChip(Icons.lightbulb, '$hintsUsed hints', Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Issue #4: Detailed progress with word review
            if (isMultipleAnagrams) ...[
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      'Progress: $solvedCount / ${anagramWords.length} words solved',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: anagramWords.isNotEmpty ? solvedCount / anagramWords.length : 0,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    // Issue #10: Review solved words
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(anagramWords.length, (index) {
                        final isSolved = anagramSolved[index];
                        final isCurrent = index == currentAnagramIndex;
                        return InkWell(
                          onTap: () => _navigateToWord(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.blue
                                  : (isSolved ? Colors.green : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${index + 1}${isSolved ? " ✓" : ""}',
                              style: TextStyle(
                                color: (isCurrent || isSolved) ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Main puzzle card
            CustomCard(
              child: Column(
                children: [
                  Text(
                    isMultipleAnagrams
                        ? 'Word ${currentAnagramIndex + 1} of 5'
                        : 'Unscramble the letters',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Issue #3: Tappable letter tiles in a single row (dynamically sized for up to 10 letters)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate box size based on number of letters and available width
                        final letterCount = currentScrambled.length;
                        final availableWidth = constraints.maxWidth;
                        // Reserve space for margins between letters
                        final totalMargin = (letterCount - 1) * 4; // 2px on each side
                        final boxWidth = ((availableWidth - totalMargin) / letterCount).clamp(24.0, 48.0);
                        final fontSize = (boxWidth * 0.5).clamp(14.0, 22.0);

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: currentScrambled.asMap().entries.map((entry) {
                            final index = entry.key;
                            final letter = entry.value;
                            final isSelected = selectedLetterIndices.contains(index);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedLetterIndices.remove(index);
                                  } else {
                                    selectedLetterIndices.add(index);
                                  }
                                  // Don't sort - keep tap order
                                  // Guard against index out of bounds during transitions
                                  if (selectedLetterIndices.isNotEmpty &&
                                      selectedLetterIndices.every((i) => i >= 0 && i < currentScrambled.length)) {
                                    try {
                                      userAnswer = selectedLetterIndices
                                          .map((i) => currentScrambled[i])
                                          .join('');
                                      _textController.text = userAnswer;
                                    } catch (e) {
                                      // Silently handle race condition during word transition
                                      selectedLetterIndices.clear();
                                      userAnswer = '';
                                      _textController.clear();
                                    }
                                  } else {
                                    // Clear if indices are invalid
                                    selectedLetterIndices.clear();
                                    userAnswer = '';
                                    _textController.clear();
                                  }
                                });
                              },
                              child: Container(
                                width: boxWidth,
                                height: boxWidth,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.green.shade700 : Colors.blue,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    letter.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  // Issue #2: Show hint if requested
                  if (showHint && isMultipleAnagrams) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Starts with: ${anagramWords[currentAnagramIndex][0]}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Issue #1: Feedback message
            if (feedbackMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feedbackColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: feedbackColor ?? Colors.grey, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      feedbackColor == Colors.green ? Icons.check_circle : Icons.info,
                      color: feedbackColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feedbackMessage!,
                        style: TextStyle(
                          color: feedbackColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Issue #5: Input with word length hint
            TextField(
              controller: _textController,
              onChanged: (value) => setState(() => userAnswer = value),
              onSubmitted: (_) => _checkAnagramAnswer(),
              decoration: InputDecoration(
                labelText: 'Your answer',
                hintText: '${"_" * currentScrambled.length} (${currentScrambled.length} letters)',
                border: const OutlineInputBorder(),
                suffixIcon: userAnswer.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            userAnswer = '';
                            _textController.clear();
                            selectedLetterIndices.clear();
                          });
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 18),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Issue #2: Hint button
                if (isMultipleAnagrams && !anagramSolved[currentAnagramIndex]) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: showHint ? null : _showHint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('Hint'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Submit button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: userAnswer.trim().isEmpty ? null : _checkAnagramAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Issue #2: Skip button
                if (isMultipleAnagrams && !anagramSolved[currentAnagramIndex]) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _skipWord,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Complete button for multiple anagrams
            if (isMultipleAnagrams && solvedCount == anagramWords.length) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeAnagramTest,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWordSearchPuzzle() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Compact word list
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find these words:', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: puzzleData!.targetWords!.map((word) => Chip(
                      label: Text(
                        word,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: foundWords.contains(word) ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: foundWords.contains(word)
                          ? Colors.green.shade600
                          : Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Minimal spacing
          const SizedBox(height: 6),
          // Current selection (always show, even if empty)
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentWord.isEmpty
                          ? 'Tap letters to form words'
                          : 'Selected: $currentWord',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: currentWord.isEmpty ? Colors.grey.shade600 : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (currentWord.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentSelection.clear();
                          currentWord = '';
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Clear', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ),
          ),
          // Minimal spacing
          const SizedBox(height: 6),
          // Grid takes remaining space but with better constraints
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridSize = puzzleData!.grid!.length;
                final maxCellSize = (constraints.maxWidth - 32) / gridSize;
                final cellSize = maxCellSize.clamp(24.0, 48.0);

                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: cellSize * gridSize,
                      height: cellSize * gridSize,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ gridSize;
                          final col = index % gridSize;
                          final isSelected = selectedCells[row][col];
                          final isInCurrentSelection = currentSelection.contains(index);

                          return GestureDetector(
                            onTap: () => _toggleLetterSelection(index, row, col),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                                color: isSelected
                                    ? Colors.green.shade300
                                    : isInCurrentSelection
                                        ? Colors.blue.shade300
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Center(
                                child: Text(
                                  puzzleData!.grid![row][col],
                                  style: TextStyle(
                                    fontSize: (cellSize * 0.5).clamp(12.0, 18.0),
                                    fontWeight: FontWeight.bold,
                                    color: isSelected || isInCurrentSelection
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom button with padding
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _completeWordSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _checkAnagramAnswer() async {
    if (userAnswer.trim().isEmpty) {
      _showFeedback('Please enter an answer', Colors.orange);
      return;
    }

    final isMultipleAnagrams = anagramWords.isNotEmpty;

    if (isMultipleAnagrams) {
      final currentScrambledLetters = anagramScrambledLetters[currentAnagramIndex];
      final correctWord = anagramWords[currentAnagramIndex];
      final isCorrect = await _isValidAnagram(userAnswer, currentScrambledLetters);

      if (isCorrect) {
        // Find next unsolved word index
        int? nextIndex;
        for (int i = 0; i < anagramSolved.length; i++) {
          if (i != currentAnagramIndex && !anagramSolved[i]) {
            nextIndex = i;
            break;
          }
        }

        setState(() {
          anagramSolved[currentAnagramIndex] = true;
          anagramCorrect[currentAnagramIndex] = true; // Mark as correctly answered
          userAnswer = '';
          _textController.clear();
          selectedLetterIndices.clear();
          showHint = false;

          // Move to next unsolved word if available
          if (nextIndex != null) {
            currentAnagramIndex = nextIndex;
          }
        });

        // Celebrate correct answer
        _showFeedback(
          '🎉 Correct! The word was "$correctWord"',
          Colors.green,
          celebrate: true,
        );

        // Auto-complete if all words are solved
        final solvedCount = anagramSolved.where((s) => s).length;
        if (solvedCount == anagramWords.length) {
          // Delay to show the success message before auto-completing
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _completeAnagramTest();
            }
          });
        }
      } else {
        // Detailed feedback for wrong answer
        String feedback = 'Incorrect!';

        // Check if they used wrong letters
        final inputLetters = userAnswer.toUpperCase().split('');
        final availableLetters = currentScrambledLetters.map((s) => s.toUpperCase()).toList();

        if (inputLetters.length != availableLetters.length) {
          feedback += ' Wrong number of letters (need ${availableLetters.length}).';
        } else {
          // Check if letters match (they should since we passed validation)
          bool lettersMatch = true;
          final inputCount = <String, int>{};
          final availableCount = <String, int>{};

          for (final letter in inputLetters) {
            inputCount[letter] = (inputCount[letter] ?? 0) + 1;
          }
          for (final letter in availableLetters) {
            availableCount[letter] = (availableCount[letter] ?? 0) + 1;
          }

          for (final letter in inputCount.keys) {
            if (inputCount[letter] != availableCount[letter]) {
              lettersMatch = false;
              break;
            }
          }

          if (!lettersMatch) {
            feedback += ' You used wrong letters or wrong quantities.';
          } else {
            final definition = WordDefinitionService.getDefinition(correctWord);
            feedback += ' "$userAnswer" is not in our dictionary. The answer we were looking for is "$correctWord"';
            if (definition != null) {
              feedback += ' ($definition)';
            }
            feedback += '. Try typing that!';
          }
        }

        _showFeedback(feedback, Colors.red);
      }
    } else {
      // Single word logic (fallback)
      final isCorrect = puzzleData!.scrambledLetters != null
          ? await _isValidAnagram(userAnswer, puzzleData!.scrambledLetters!)
          : userAnswer.toUpperCase() == puzzleData!.targetWord!.toUpperCase();
      final timeSpent = DateTime.now().difference(startTime).inSeconds;
      final score = isCorrect ? 100 : 0;

      widget.onCompleted(score, timeSpent);
    }
  }

  Future<bool> _isValidWordInDatabase(String word) async {
    final database = ref.read(databaseProvider);
    final results = await (database.select(database.wordDictionaryTable)
          ..where((tbl) => tbl.word.equals(word.toUpperCase()))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    return results.isNotEmpty;
  }

  Future<bool> _isValidAnagram(String userInput, List<String> scrambledLetters) async {
    if (userInput.trim().isEmpty) return false;

    final inputLetters = userInput.toUpperCase().split('');
    final availableLetters = scrambledLetters.map((s) => s.toUpperCase()).toList();

    // Check if total letter count matches
    if (inputLetters.length != availableLetters.length) return false;

    // Check if input uses only available letters and correct count
    final inputLetterCount = <String, int>{};
    final availableLetterCount = <String, int>{};

    // Count letters in user input
    for (final letter in inputLetters) {
      inputLetterCount[letter] = (inputLetterCount[letter] ?? 0) + 1;
    }

    // Count available letters
    for (final letter in availableLetters) {
      availableLetterCount[letter] = (availableLetterCount[letter] ?? 0) + 1;
    }

    // Check if each letter appears the correct number of times
    for (final letter in inputLetterCount.keys) {
      if (inputLetterCount[letter] != availableLetterCount[letter]) {
        return false;
      }
    }

    // Check if user didn't use any extra letters
    for (final letter in availableLetterCount.keys) {
      if (!inputLetterCount.containsKey(letter)) {
        return false;
      }
    }

    // Check if the formed word is valid (exists in our word dictionary database)
    return await _isValidWordInDatabase(userInput.toUpperCase());
  }

  bool _isValidWord(String word) {
    // This is a simplified validation. In a production app, you might want to 
    // check against a more comprehensive dictionary or the database.
    // For now, we'll check against common English words.
    final validWords = {
      // 3-letter words
      'CAT', 'DOG', 'BAT', 'HAT', 'RAT', 'SUN', 'CAR', 'BAR', 'FAR', 'WAR',
      'BOX', 'FOX', 'MIX', 'FIX', 'SIX', 'BUY', 'TRY', 'FRY', 'DRY', 'SPY',
      'KEY', 'BOY', 'TOY', 'JOY', 'DAY', 'WAY', 'SAY', 'PAY', 'LAY', 'MAY',
      'BAD', 'SAD', 'MAD', 'HAD', 'LAD', 'PAD', 'BIG', 'DIG', 'FIG', 'PIG',
      'WIG', 'BAG', 'TAG', 'RAG', 'SAG', 'WAG', 'LAG', 'NAG', 'HOT', 'POT',
      'COT', 'DOT', 'GOT', 'LOT', 'NOT', 'ROT', 'HIT', 'BIT', 'FIT', 'SIT',
      'KIT', 'PIT', 'WIT', 'GET', 'BET', 'LET', 'MET', 'NET', 'PET', 'SET',
      'VET', 'WET', 'YET', 'CUT', 'BUT', 'HUT', 'NUT', 'PUT', 'GUT', 'RUT',
      
      // 4-letter words
      'CATS', 'DOGS', 'BATS', 'HATS', 'RATS', 'CARS', 'BARS', 'WARS', 'ARTS',
      'STAR', 'PART', 'CART', 'DART', 'HART', 'MART', 'TART', 'FAST', 'PAST',
      'LAST', 'CAST', 'VAST', 'MAST', 'BEST', 'TEST', 'REST', 'NEST', 'WEST',
      'PEST', 'EAST', 'COST', 'POST', 'HOST', 'MOST', 'LOST', 'SOFT', 'LIFT',
      'GIFT', 'SIFT', 'LEFT', 'DEFT', 'HEFT', 'BOAT', 'COAT', 'GOAT', 'MOAT',
      'HEAT', 'BEAT', 'FEAT', 'MEAT', 'NEAT', 'PEAT', 'SEAT', 'DEAR', 'FEAR',
      'GEAR', 'HEAR', 'NEAR', 'PEAR', 'REAR', 'TEAR', 'WEAR', 'YEAR', 'BEAR',
      'HAIR', 'FAIR', 'PAIR', 'MAIN', 'PAIN', 'RAIN', 'GAIN', 'VAIN', 'WAIN',
      
      // 5-letter words
      'HOUSE', 'MOUSE', 'HORSE', 'NURSE', 'PURSE', 'CURSE', 'FIRST', 'BURST',
      'THIRST', 'WORST', 'ROAST', 'COAST', 'TOAST', 'BEAST', 'FEAST', 'LEAST',
      'HEART', 'START', 'SMART', 'CHART', 'CRAFT', 'DRAFT', 'SHAFT', 'PLANT',
      'GRAND', 'BRAND', 'STAND', 'BLAND', 'GLAND', 'WOMAN', 'HUMAN', 'ROMAN',
      'LEMON', 'MELON', 'WAGON', 'OCEAN', 'CLEAN', 'DREAM', 'CREAM', 'STEAM',
      'PHONE', 'STONE', 'ALONE', 'DANCE', 'FENCE', 'HENCE', 'PENCE', 'SINCE',
      'PRICE', 'TWICE', 'SLICE', 'VOICE', 'CHOICE', 'PLACE', 'SPACE', 'GRACE',
      'TRACE', 'BRACE', 'PEACE', 'PIECE', 'NIECE', 'JUICE', 'BRUCE', 'TRUCE',
      'PALMS', 'LAMPS', 'PLEAS', 'LEAPS', 'PALES', 'PEALS', 'MAPLE',

      // 6-letter words including anagram examples
      'NICEST', 'INSECT', 'LISTEN', 'SILENT', 'ENLIST', 'TINSEL', 'INLETS',
      'CASTLE', 'CLEATS', 'LACETS', 'ECLATS', 'MASTER', 'STREAM', 'TAMERS',
      'ARMEST', 'SMATER', 'TERMAS', 'DANGER', 'RANGED', 'GANDER', 'GARDEN',
      'GRADED', 'GRACED', 'CRAGED', 'THREAD', 'HATED', 'DEATH', 'HEADS',
      'SHADES', 'DASHES', 'SADHE', 'FRIEND', 'FINDER', 'FRIED', 'FIRED',
      'RIDER', 'CIDER', 'CRIED', 'RICED', 'DRICE', 'DICER', 'SAMPLE', 'MAPLES',
      'SIMPLE', 'IMPALE', 'CLAIMS', 'GIMBAL', 'STOLEN', 'OSTLER', 'LENTOS',

      // 7+ letter words
      'HAPPIEST', 'ELEPHANT', 'TRIANGLE', 'DOWNLOAD', 'KEYBOARD', 'MONITOR',
      'COMPUTER', 'INTERNET', 'SOFTWARE', 'HARDWARE', 'SYSTEMS', 'NETWORK',
    };

    return validWords.contains(word) || word.length >= 3;
  }

  Future<bool> _isValidSpanishAnagram(String userInput, List<String> scrambledLetters) async {
    if (userInput.trim().isEmpty) return false;

    final inputLetters = userInput.toUpperCase().split('');
    final availableLetters = scrambledLetters.map((s) => s.toUpperCase()).toList();

    // Check if total letter count matches
    if (inputLetters.length != availableLetters.length) return false;

    // Check if input uses only available letters and correct count
    final inputLetterCount = <String, int>{};
    final availableLetterCount = <String, int>{};

    // Count letters in user input
    for (final letter in inputLetters) {
      inputLetterCount[letter] = (inputLetterCount[letter] ?? 0) + 1;
    }

    // Count available letters
    for (final letter in availableLetters) {
      availableLetterCount[letter] = (availableLetterCount[letter] ?? 0) + 1;
    }

    // Check if each letter appears the correct number of times
    for (final letter in inputLetterCount.keys) {
      if (inputLetterCount[letter] != availableLetterCount[letter]) {
        return false;
      }
    }

    // Check if user didn't use any extra letters
    for (final letter in availableLetterCount.keys) {
      if (!inputLetterCount.containsKey(letter)) {
        return false;
      }
    }

    // Check if the formed word is valid (exists in our word dictionary database)
    return await _isValidWordInDatabase(userInput.toUpperCase());
  }

  bool _isValidSpanishWord(String word) {
    // Common Spanish words for anagram validation
    final validSpanishWords = {
      // 3-letter words
      'SOL', 'MAR', 'PAN', 'VER', 'SER', 'LUZ', 'VOZ', 'PAZ', 'FIN', 'SIN',
      'CON', 'POR', 'DOS', 'TEN', 'VEN', 'DAR', 'HAY', 'HOY', 'LEY', 'REY',
      'PIE', 'TÚ', 'ÉL', 'SÍ', 'NO', 'YO', 'MI', 'TI', 'SU', 'SE',
      
      // 4-letter words
      'CASA', 'AMOR', 'VIDA', 'AGUA', 'MESA', 'GATO', 'PERO', 'NIÑO', 'NIÑA',
      'LUNA', 'HIJO', 'HIJA', 'MAMA', 'PAPÁ', 'TREN', 'AUTO', 'AZUL', 'ROJO',
      'LEER', 'OJOS', 'MANO', 'PIES', 'DÍAS', 'AÑOS', 'HORA', 'VEZ', 'BIEN',
      'AQUÍ', 'ALLÍ', 'HOLA', 'ADIÓS', 'SÓLO', 'COMO', 'PARA', 'ESTE', 'ESTA',
      
      // 5-letter words
      'MUNDO', 'MUJER', 'MADRE', 'PADRE', 'AMIGO', 'NEGRO', 'BLANCO', 'VERDE',
      'LIBRO', 'COCHE', 'PERRO', 'GENTE', 'TIEMPO', 'PARTE', 'LUGAR', 'FORMA',
      'GRUPO', 'PUNTO', 'PODER', 'CABEZA', 'MANOS', 'NOCHE', 'TARDE', 'MAÑANA',
      'AHORA', 'ANTES', 'NUNCA', 'SIEMPRE', 'NUEVO', 'VIEJO', 'LARGO', 'CORTO',
      
      // 6-letter words
      'AMIGOS', 'FAMILIA', 'ESCUELA', 'TRABAJO', 'CIUDAD', 'PUEBLO', 'COLORES',
      'NÚMEROS', 'LETRAS', 'PALABRAS', 'MÚSICA', 'COMIDA', 'DINERO', 'REGALO',
      'FIESTA', 'VIAJES', 'HOTELES', 'PARQUE', 'PLAYA', 'MONTAÑA', 'FLORES',
      'ANIMALES', 'CAMISAS', 'ZAPATOS', 'LIBROS', 'PELÍCULAS', 'DEPORTES',
      
      // 7+ letter words  
      'ESPAÑOL', 'ESTUDIAR', 'TRABAJAR', 'UNIVERSIDAD', 'BIBLIOTECA', 'HOSPITAL',
      'RESTAURANTE', 'SUPERMERCADO', 'AEROPUERTO', 'ESTACIÓN', 'COMPUTADORA',
    };
    
    return validSpanishWords.contains(word) || word.length >= 3;
  }
  
  void _moveToNextUnsolvedWord() {
    for (int i = 0; i < anagramSolved.length; i++) {
      if (!anagramSolved[i]) {
        setState(() {
          currentAnagramIndex = i;
        });
        return;
      }
    }
    // All words are solved - stay at current index
  }
  
  // Helper method to show hint (first letter)
  void _showHint() {
    if (anagramWords.isEmpty) return;

    final correctWord = anagramWords[currentAnagramIndex];
    setState(() {
      showHint = true;
      hintsUsed++;
      _showFeedback(
        'Hint: Word starts with "${correctWord[0]}"',
        Colors.blue,
      );
    });
  }

  // Helper method to skip current word
  void _skipWord() {
    if (anagramWords.isEmpty) return;

    setState(() {
      anagramSolved[currentAnagramIndex] = true; // Mark as "solved" but with penalty
      skipsUsed++;

      // Find next unsolved word
      int? nextIndex;
      for (int i = 0; i < anagramSolved.length; i++) {
        if (i != currentAnagramIndex && !anagramSolved[i]) {
          nextIndex = i;
          break;
        }
      }

      userAnswer = '';
      _textController.clear();
      showHint = false;

      if (nextIndex != null) {
        currentAnagramIndex = nextIndex;
      }
    });
  }

  // Helper method to navigate to a specific word
  void _navigateToWord(int index) {
    setState(() {
      currentAnagramIndex = index;
      userAnswer = '';
      _textController.clear();
      selectedLetterIndices.clear();
      showHint = false;
      feedbackMessage = null;
    });
  }

  // Helper method to show feedback with auto-dismiss
  void _showFeedback(String message, Color color, {bool celebrate = false}) {
    feedbackTimer?.cancel();

    setState(() {
      feedbackMessage = message;
      feedbackColor = color;
    });

    if (celebrate) {
      // Show celebration animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Auto-dismiss feedback after 10 seconds
    feedbackTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          feedbackMessage = null;
          feedbackColor = null;
        });
      }
    });
  }

  void _completeAnagramTest() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final correctCount = anagramCorrect.where((s) => s).length;
    final score = (correctCount / 5 * 100).round();

    widget.onCompleted(score, timeSpent);
  }

  void _toggleLetterSelection(int index, int row, int col) {
    setState(() {
      if (currentSelection.contains(index)) {
        // Remove letter and rebuild word
        currentSelection.remove(index);
        _rebuildCurrentWord();
      } else {
        // Add letter to selection
        currentSelection.add(index);
        currentWord += puzzleData!.grid![row][col];
        
        // Check if current word matches any target word
        _checkCurrentWord();
      }
    });
  }

  void _rebuildCurrentWord() {
    currentWord = '';
    for (final int index in currentSelection) {
      final row = index ~/ puzzleData!.grid!.length;
      final col = index % puzzleData!.grid!.length;
      currentWord += puzzleData!.grid![row][col];
    }
  }

  void _checkCurrentWord() {
    final word = currentWord.toUpperCase();
    if (puzzleData!.targetWords!.any((targetWord) => targetWord.toUpperCase() == word) && 
        !foundWords.contains(word)) {
      // Found a word!
      setState(() {
        foundWords.add(word);
        // Mark selected cells as found
        for (final int index in currentSelection) {
          final row = index ~/ puzzleData!.grid!.length;
          final col = index % puzzleData!.grid!.length;
          selectedCells[row][col] = true;
        }
        // Clear current selection
        currentSelection.clear();
        currentWord = '';
      });
    }
  }

  void _completeWordSearch() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final score = (foundWords.length / puzzleData!.targetWords!.length * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }
}

/// Spanish Anagram Widget - Spanish Word Puzzles
class SpanishAnagramWidget extends ConsumerStatefulWidget {

  const SpanishAnagramWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  ConsumerState<SpanishAnagramWidget> createState() => _SpanishAnagramWidgetState();
}

class _SpanishAnagramWidgetState extends ConsumerState<SpanishAnagramWidget> {
  WordPuzzleData? puzzleData;
  late DateTime startTime;
  String userAnswer = '';
  bool isLoading = true;

  // For multiple anagram words
  List<String> anagramWords = [];
  List<List<String>> anagramScrambledLetters = [];
  List<bool> anagramSolved = [];
  int currentAnagramIndex = 0;
  final TextEditingController _textController = TextEditingController();

  // Track selected letters for tap-to-build interface
  List<int> selectedLetterIndices = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _loadPuzzleData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPuzzleData() async {
    final database = ref.read(databaseProvider);

    // Get up to 5 unique Spanish anagram words from database
    final words = await WordDictionaryService.getRandomAnagramWords(
      database,
      WordLanguage.spanish,
      widget.difficulty,
      5, // Request 5 unique words
    );

    // Handle case where fewer than 5 words are available
    if (words.isEmpty) {
      // Fallback to generating a single word
      final anagramData = await ExerciseGenerator.generateSpanishAnagram(
        difficulty: widget.difficulty,
        database: database,
      );
      if (anagramData.targetWord != null && anagramData.scrambledLetters != null) {
        anagramWords.add(anagramData.targetWord!);
        anagramScrambledLetters.add(anagramData.scrambledLetters!);
        anagramSolved.add(false);
      }
    } else {
      // Generate scrambled letters for each word
      for (final word in words) {
        final scrambledLetters = ExerciseGenerator.ensureScrambled(word.split(''));
        anagramWords.add(word);
        anagramScrambledLetters.add(scrambledLetters);
        anagramSolved.add(false);
      }
    }

    final data = await ExerciseGenerator.generateSpanishAnagram(
      difficulty: widget.difficulty,
      database: database,
    );
    setState(() {
      puzzleData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final currentScrambled = anagramScrambledLetters[currentAnagramIndex];
    final solvedCount = anagramSolved.where((s) => s).length;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress indicator
          CustomCard(
            child: Column(
              children: [
                Text(
                  'Progreso: $solvedCount / ${anagramWords.length} palabras resueltas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: anagramWords.isNotEmpty ? solvedCount / anagramWords.length : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                Text(
                  'Palabra ${currentAnagramIndex + 1} de 5: Toca las letras para formar la palabra',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Tappable letter tiles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final letterCount = currentScrambled.length;
                      final availableWidth = constraints.maxWidth;
                      final totalMargin = (letterCount - 1) * 4;
                      final boxWidth = ((availableWidth - totalMargin) / letterCount).clamp(24.0, 48.0);
                      final fontSize = (boxWidth * 0.5).clamp(14.0, 22.0);

                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: currentScrambled.asMap().entries.map((entry) {
                          final index = entry.key;
                          final letter = entry.value;
                          final isSelected = selectedLetterIndices.contains(index);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  // Remove from selection
                                  selectedLetterIndices.remove(index);
                                } else {
                                  // Add to selection
                                  selectedLetterIndices.add(index);
                                }
                                // Don't sort - keep tap order
                                // Guard against index out of bounds during transitions
                                if (selectedLetterIndices.isNotEmpty &&
                                    selectedLetterIndices.every((i) => i >= 0 && i < currentScrambled.length)) {
                                  try {
                                    userAnswer = selectedLetterIndices
                                        .map((i) => currentScrambled[i])
                                        .join('');
                                    _textController.text = userAnswer;
                                  } catch (e) {
                                    // Silently handle race condition during word transition
                                    selectedLetterIndices.clear();
                                    userAnswer = '';
                                    _textController.clear();
                                  }
                                } else {
                                  // Clear if indices are invalid
                                  selectedLetterIndices.clear();
                                  userAnswer = '';
                                  _textController.clear();
                                }
                              });
                            },
                            child: Container(
                              width: boxWidth,
                              height: boxWidth,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green : Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.green.shade700 : Colors.blue,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  letter.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selected letters display
          if (selectedLetterIndices.isNotEmpty) ...[
            CustomCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tu palabra: $userAnswer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedLetterIndices.clear();
                        userAnswer = '';
                        _textController.clear();
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: userAnswer.isNotEmpty ? _checkAnswer : null,
                  icon: const Icon(Icons.check),
                  label: Text(solvedCount < anagramWords.length ? 'Enviar Palabra' : 'Enviar Respuesta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          
          // Complete button
          if (solvedCount == 5) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _completeSpanishAnagramTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Completar Prueba'),
            ),
          ],
        ],
      ),
    );
  }

  void _checkAnswer() async {
    final currentScrambledLetters = anagramScrambledLetters[currentAnagramIndex];
    final isCorrect = await _isValidSpanishAnagram(userAnswer, currentScrambledLetters);

    if (isCorrect) {
      // Find next unsolved word index
      int? nextIndex;
      for (int i = 0; i < anagramSolved.length; i++) {
        if (i != currentAnagramIndex && !anagramSolved[i]) {
          nextIndex = i;
          break;
        }
      }

      setState(() {
        anagramSolved[currentAnagramIndex] = true;
        userAnswer = '';
        _textController.clear();
        selectedLetterIndices.clear();

        // Move to next unsolved word if available
        if (nextIndex != null) {
          currentAnagramIndex = nextIndex;
        }
      });

      // Auto-complete if all words are solved
      final solvedCount = anagramSolved.where((s) => s).length;
      if (solvedCount == anagramWords.length) {
        // Delay to show the success message before auto-completing
        Future.delayed(const Duration(seconds: 2), _completeSpanishAnagramTest);
      }
    } else {
      // Show incorrect feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta incorrecta. ¡Inténtalo de nuevo!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _moveToNextUnsolvedWord() {
    for (int i = 0; i < anagramSolved.length; i++) {
      if (!anagramSolved[i]) {
        setState(() {
          currentAnagramIndex = i;
        });
        return;
      }
    }
    // All words are solved - stay at current index
  }
  
  void _completeSpanishAnagramTest() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final solvedCount = anagramSolved.where((s) => s).length;
    final score = (solvedCount / 5 * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }

  Future<bool> _isValidSpanishAnagram(String userInput, List<String> scrambledLetters) async {
    if (userInput.trim().isEmpty) return false;

    final inputLetters = userInput.toUpperCase().split('');
    final availableLetters = scrambledLetters.map((s) => s.toUpperCase()).toList();

    // Check if total letter count matches
    if (inputLetters.length != availableLetters.length) return false;

    // Check if input uses only available letters and correct count
    final inputLetterCount = <String, int>{};
    final availableLetterCount = <String, int>{};

    // Count letters in user input
    for (final letter in inputLetters) {
      inputLetterCount[letter] = (inputLetterCount[letter] ?? 0) + 1;
    }

    // Count available letters
    for (final letter in availableLetters) {
      availableLetterCount[letter] = (availableLetterCount[letter] ?? 0) + 1;
    }

    // Check if each letter appears the correct number of times
    for (final letter in inputLetterCount.keys) {
      if (inputLetterCount[letter] != availableLetterCount[letter]) {
        return false;
      }
    }

    // Check if user didn't use any extra letters
    for (final letter in availableLetterCount.keys) {
      if (!inputLetterCount.containsKey(letter)) {
        return false;
      }
    }

    // Check if the formed word is valid (exists in our word dictionary database)
    return await _isValidWordInDatabase(userInput.toUpperCase());
  }

  Future<bool> _isValidWordInDatabase(String word) async {
    final database = ref.read(databaseProvider);
    final results = await (database.select(database.wordDictionaryTable)
          ..where((tbl) => tbl.word.equals(word.toUpperCase()))
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
    return results.isNotEmpty;
  }

  bool _isValidWord(String word) {
    // This is a simplified validation. In a production app, you might want to
    // check against a more comprehensive dictionary or the database.
    // For now, we'll check against common English words.
    final validWords = {
      // 3-letter words
      'CAT', 'DOG', 'BAT', 'HAT', 'RAT', 'SUN', 'CAR', 'BAR', 'FAR', 'WAR',
      'BOX', 'FOX', 'MIX', 'FIX', 'SIX', 'BUY', 'TRY', 'FRY', 'DRY', 'SPY',
      'KEY', 'BOY', 'TOY', 'JOY', 'DAY', 'WAY', 'SAY', 'PAY', 'LAY', 'MAY',
      'BAD', 'SAD', 'MAD', 'HAD', 'LAD', 'PAD', 'BIG', 'DIG', 'FIG', 'PIG',
      'WIG', 'BAG', 'TAG', 'RAG', 'SAG', 'WAG', 'LAG', 'NAG', 'HOT', 'POT',
      'COT', 'DOT', 'GOT', 'LOT', 'NOT', 'ROT', 'HIT', 'BIT', 'FIT', 'SIT',
      'KIT', 'PIT', 'WIT', 'GET', 'BET', 'LET', 'MET', 'NET', 'PET', 'SET',
      'VET', 'WET', 'YET', 'CUT', 'BUT', 'HUT', 'NUT', 'PUT', 'GUT', 'RUT',
      
      // 4-letter words
      'CATS', 'DOGS', 'BATS', 'HATS', 'RATS', 'CARS', 'BARS', 'WARS', 'ARTS',
      'STAR', 'PART', 'CART', 'DART', 'HART', 'MART', 'TART', 'FAST', 'PAST',
      'LAST', 'CAST', 'VAST', 'MAST', 'BEST', 'TEST', 'REST', 'NEST', 'WEST',
      'PEST', 'EAST', 'COST', 'POST', 'HOST', 'MOST', 'LOST', 'SOFT', 'LIFT',
      'GIFT', 'SIFT', 'LEFT', 'DEFT', 'HEFT', 'BOAT', 'COAT', 'GOAT', 'MOAT',
      'HEAT', 'BEAT', 'FEAT', 'MEAT', 'NEAT', 'PEAT', 'SEAT', 'DEAR', 'FEAR',
      'GEAR', 'HEAR', 'NEAR', 'PEAR', 'REAR', 'TEAR', 'WEAR', 'YEAR', 'BEAR',
      'HAIR', 'FAIR', 'PAIR', 'MAIN', 'PAIN', 'RAIN', 'GAIN', 'VAIN', 'WAIN',
      
      // 5-letter words
      'HOUSE', 'MOUSE', 'HORSE', 'NURSE', 'PURSE', 'CURSE', 'FIRST', 'BURST',
      'THIRST', 'WORST', 'ROAST', 'COAST', 'TOAST', 'BEAST', 'FEAST', 'LEAST',
      'HEART', 'START', 'SMART', 'CHART', 'CRAFT', 'DRAFT', 'SHAFT', 'PLANT',
      'GRAND', 'BRAND', 'STAND', 'BLAND', 'GLAND', 'WOMAN', 'HUMAN', 'ROMAN',
      'LEMON', 'MELON', 'WAGON', 'OCEAN', 'CLEAN', 'DREAM', 'CREAM', 'STEAM',
      'PHONE', 'STONE', 'ALONE', 'DANCE', 'FENCE', 'HENCE', 'PENCE', 'SINCE',
      'PRICE', 'TWICE', 'SLICE', 'VOICE', 'CHOICE', 'PLACE', 'SPACE', 'GRACE',
      'TRACE', 'BRACE', 'PEACE', 'PIECE', 'NIECE', 'JUICE', 'BRUCE', 'TRUCE',
      'PALMS', 'LAMPS', 'PLEAS', 'LEAPS', 'PALES', 'PEALS', 'MAPLE',

      // 6-letter words including anagram examples
      'NICEST', 'INSECT', 'LISTEN', 'SILENT', 'ENLIST', 'TINSEL', 'INLETS',
      'CASTLE', 'CLEATS', 'LACETS', 'ECLATS', 'MASTER', 'STREAM', 'TAMERS',
      'ARMEST', 'SMATER', 'TERMAS', 'DANGER', 'RANGED', 'GANDER', 'GARDEN',
      'GRADED', 'GRACED', 'CRAGED', 'THREAD', 'HATED', 'DEATH', 'HEADS',
      'SHADES', 'DASHES', 'SADHE', 'FRIEND', 'FINDER', 'FRIED', 'FIRED',
      'RIDER', 'CIDER', 'CRIED', 'RICED', 'DRICE', 'DICER', 'SAMPLE', 'MAPLES',
      'SIMPLE', 'IMPALE', 'CLAIMS', 'GIMBAL', 'STOLEN', 'OSTLER', 'LENTOS',

      // 7+ letter words
      'HAPPIEST', 'ELEPHANT', 'TRIANGLE', 'DOWNLOAD', 'KEYBOARD', 'MONITOR',
      'COMPUTER', 'INTERNET', 'SOFTWARE', 'HARDWARE', 'SYSTEMS', 'NETWORK',
    };

    return validWords.contains(word) || word.length >= 3;
  }
}

/// Math Problem Widget - Arithmetic and Number Problems
class MathProblemWidget extends StatefulWidget {

  const MathProblemWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  State<MathProblemWidget> createState() => _MathProblemWidgetState();
}

class _MathProblemWidgetState extends State<MathProblemWidget> {
  late MathProblemData problemData;
  late DateTime startTime;
  int? selectedAnswer;
  int correctAnswers = 0;
  int totalProblems = 0;
  List<MathProblemData> problems = [];
  int currentProblemIndex = 0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateProblems();
  }

  void _generateProblems() {
    final problemCount = _getProblemCount();
    for (int i = 0; i < problemCount; i++) {
      problems.add(ExerciseGenerator.generateMathProblem(difficulty: widget.difficulty));
    }
    problemData = problems[0];
    totalProblems = problems.length;
  }

  int _getProblemCount() {
    switch (widget.difficulty) {
      case ExerciseDifficulty.easy:
        return 5;
      case ExerciseDifficulty.medium:
        return 7;
      case ExerciseDifficulty.hard:
        return 10;
      case ExerciseDifficulty.expert:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              children: [
                Text('Problem ${currentProblemIndex + 1} of $totalProblems'),
                Text('Score: $correctAnswers/$totalProblems'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scrollable question text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          problemData.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Answer options with better layout
                      ...problemData.options.map((option) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ElevatedButton(
                          onPressed: () => _selectAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedAnswer == option
                                ? Colors.blue.shade600
                                : Colors.white,
                            foregroundColor: selectedAnswer == option
                                ? Colors.white
                                : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: selectedAnswer == option
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            option.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      // Always visible submit button area
                      SizedBox(
                        height: 60,
                        child: selectedAnswer != null
                            ? ElevatedButton(
                                onPressed: _submitAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Submit Answer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Center(
                                  child: Text(
                                    'Select an answer above',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (selectedAnswer == problemData.answer) {
      correctAnswers++;
    }
    
    currentProblemIndex++;
    
    if (currentProblemIndex >= problems.length) {
      _completeTest();
    } else {
      setState(() {
        problemData = problems[currentProblemIndex];
        selectedAnswer = null;
      });
    }
  }

  void _completeTest() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final score = (correctAnswers / totalProblems * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }
}

/// Pattern Recognition Widget - Visual and Logic Patterns
class PatternRecognitionWidget extends StatefulWidget {

  const PatternRecognitionWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  State<PatternRecognitionWidget> createState() => _PatternRecognitionWidgetState();
}

class _PatternRecognitionWidgetState extends State<PatternRecognitionWidget> {
  late PatternRecognitionData patternData;
  late DateTime startTime;
  String? selectedAnswer;
  int correctAnswers = 0;
  int totalPatterns = 0;
  List<PatternRecognitionData> patterns = [];
  int currentPatternIndex = 0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generatePatterns();
  }

  void _generatePatterns() {
    final patternCount = _getPatternCount();
    for (int i = 0; i < patternCount; i++) {
      patterns.add(ExerciseGenerator.generatePatternRecognition(difficulty: widget.difficulty));
    }
    patternData = patterns[0];
    totalPatterns = patterns.length;
  }

  int _getPatternCount() {
    switch (widget.difficulty) {
      case ExerciseDifficulty.easy:
        return 5;
      case ExerciseDifficulty.medium:
        return 8;
      case ExerciseDifficulty.hard:
        return 10;
      case ExerciseDifficulty.expert:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              children: [
                Text('Pattern ${currentPatternIndex + 1} of $totalPatterns'),
                Text('Score: $correctAnswers/$totalPatterns'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        const Text(
                          'What comes next in this pattern?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Pattern items
                          ...patternData.pattern.map((item) => Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black87,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )),
                          // Question mark - always visible
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              border: Border.all(
                                color: Colors.red.shade800,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CustomCard(
                  child: Column(
                    children: [
                      const Text('Choose the correct answer:'),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                        ),
                        itemCount: patternData.options.length,
                        itemBuilder: (context, index) {
                          final option = patternData.options[index];
                          final isSelected = selectedAnswer == option;
                          
                          return GestureDetector(
                            onTap: () => _selectAnswer(option),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade600
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.black87,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (selectedAnswer != null)
                        ElevatedButton(
                          onPressed: _submitAnswer,
                          child: const Text('Submit Answer'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (selectedAnswer == patternData.correctAnswer) {
      correctAnswers++;
    }
    
    currentPatternIndex++;
    
    if (currentPatternIndex >= patterns.length) {
      _completeTest();
    } else {
      setState(() {
        patternData = patterns[currentPatternIndex];
        selectedAnswer = null;
      });
    }
  }

  void _completeTest() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final score = (correctAnswers / totalPatterns * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }
}

/// Sequence Recall Widget - Memory Sequences
class SequenceRecallWidget extends StatefulWidget {

  const SequenceRecallWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  State<SequenceRecallWidget> createState() => _SequenceRecallWidgetState();
}

class _SequenceRecallWidgetState extends State<SequenceRecallWidget> {
  late SequenceRecallData sequenceData;
  late DateTime startTime;
  List<String> userSequence = [];
  bool showingSequence = false;
  bool canInput = false;
  int currentDisplayIndex = 0;

  @override
  void initState() {
    super.initState();
    sequenceData = ExerciseGenerator.generateSequenceRecall(difficulty: widget.difficulty);
    startTime = DateTime.now();
    _startSequenceDisplay();
  }

  void _startSequenceDisplay() {
    setState(() {
      showingSequence = true;
      currentDisplayIndex = 0;
    });
    
    _displayNextItem();
  }

  void _displayNextItem() {
    if (currentDisplayIndex < sequenceData.sequence.length) {
      setState(() {
        currentDisplayIndex++;
      });
      
      Timer(Duration(milliseconds: sequenceData.displayTimeMs), _displayNextItem);
    } else {
      setState(() {
        showingSequence = false;
        canInput = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (showingSequence) _buildSequenceDisplay(),
          if (canInput) _buildInputInterface(),
          if (!showingSequence && !canInput) _buildWaitingScreen(),
        ],
      ),
    );
  }

  Widget _buildSequenceDisplay() {
    return Expanded(
      child: Center(
        child: CustomCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Watch carefully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              if (currentDisplayIndex > 0)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getColorForItem(sequenceData.sequence[currentDisplayIndex - 1]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      sequenceData.sequence[currentDisplayIndex - 1],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTextColorForBackground(sequenceData.sequence[currentDisplayIndex - 1]),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text('$currentDisplayIndex/${sequenceData.sequence.length}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputInterface() {
    return Expanded(
      child: Column(
        children: [
          CustomCard(
            child: Column(
              children: [
                const Text(
                  'Repeat the sequence:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Your sequence: ${userSequence.join(' → ')}'),
                Text('Expected length: ${sequenceData.sequence.length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _getAvailableItems().length,
              itemBuilder: (context, index) {
                final item = _getAvailableItems()[index];
                
                return GestureDetector(
                  onTap: () => _addToSequence(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorForItem(item),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getTextColorForBackground(item),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: userSequence.isNotEmpty ? _removeLastItem : null,
                  child: const Text('Remove Last'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: userSequence.length == sequenceData.sequence.length ? _submitSequence : null,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return const Expanded(
      child: Center(
        child: Text(
          'Get ready...',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  List<String> _getAvailableItems() {
    if (sequenceData.type == SequenceType.visual) {
      return ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
    } else if (sequenceData.type == SequenceType.spatial) {
      return ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    } else {
      return ['beep', 'click', 'ding', 'buzz', 'chime'];
    }
  }

  Color _getColorForItem(String item) {
    switch (item) {
      case 'red':
        return Colors.red.shade600;
      case 'blue':
        return Colors.blue.shade600;
      case 'green':
        return Colors.green.shade600;
      case 'yellow':
        return Colors.yellow.shade600;
      case 'purple':
        return Colors.purple.shade600;
      case 'orange':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getTextColorForBackground(String item) {
    // Return high-contrast text color based on background
    switch (item) {
      case 'yellow':
        return Colors.black87; // Dark text on yellow background
      default:
        return Colors.white; // White text on darker backgrounds
    }
  }

  void _addToSequence(String item) {
    if (userSequence.length < sequenceData.sequence.length) {
      setState(() {
        userSequence.add(item);
      });
    }
  }

  void _removeLastItem() {
    if (userSequence.isNotEmpty) {
      setState(() {
        userSequence.removeLast();
      });
    }
  }

  void _submitSequence() {
    int correctCount = 0;
    for (int i = 0; i < sequenceData.sequence.length; i++) {
      if (i < userSequence.length && userSequence[i] == sequenceData.sequence[i]) {
        correctCount++;
      }
    }
    
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final score = (correctCount / sequenceData.sequence.length * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }
}

/// Spatial Awareness Widget - 3D Visualization and Spatial Reasoning
class SpatialAwarenessWidget extends StatefulWidget {

  const SpatialAwarenessWidget({
    super.key,
    required this.difficulty,
    required this.onCompleted,
  });
  final ExerciseDifficulty difficulty;
  final Function(int score, int timeSpent) onCompleted;

  @override
  State<SpatialAwarenessWidget> createState() => _SpatialAwarenessWidgetState();
}

class _SpatialAwarenessWidgetState extends State<SpatialAwarenessWidget> {
  late SpatialAwarenessData spatialData;
  late DateTime startTime;
  String? selectedAnswer;
  int correctAnswers = 0;
  int totalProblems = 0;
  List<SpatialAwarenessData> problems = [];
  int currentProblemIndex = 0;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _generateProblems();
  }

  void _generateProblems() {
    final problemCount = _getProblemCount();
    for (int i = 0; i < problemCount; i++) {
      problems.add(ExerciseGenerator.generateSpatialAwareness(difficulty: widget.difficulty));
    }
    spatialData = problems[0];
    totalProblems = problems.length;
  }

  int _getProblemCount() {
    switch (widget.difficulty) {
      case ExerciseDifficulty.easy:
        return 5;
      case ExerciseDifficulty.medium:
        return 7;
      case ExerciseDifficulty.hard:
        return 10;
      case ExerciseDifficulty.expert:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomCard(
              child: Column(
                children: [
                  Text('Problem ${currentProblemIndex + 1} of $totalProblems'),
                  Text('Score: $correctAnswers/$totalProblems'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  Text(
                    _getProblemDescription(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _buildSpatialProblem(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  const Text('Choose your answer:'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2,
                    ),
                    itemCount: spatialData.options.length,
                    itemBuilder: (context, index) {
                      final option = spatialData.options[index];
                      final isSelected = selectedAnswer == option;

                      return GestureDetector(
                        onTap: () => _selectAnswer(option),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue.shade800
                                  : Colors.black87,
                              width: isSelected ? 4 : 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? Colors.blue.shade200 : Colors.black12,
                                blurRadius: isSelected ? 6 : 2,
                                offset: Offset(0, isSelected ? 2 : 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: spatialData.type == SpatialType.folding || spatialData.type == SpatialType.rotation ? 36 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedAnswer != null)
                    ElevatedButton(
                      onPressed: _submitAnswer,
                      child: const Text('Submit Answer'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProblemDescription() {
    switch (spatialData.type) {
      case SpatialType.rotation:
        return 'What does this look like when rotated clockwise?';
      case SpatialType.folding:
        return 'What 3D shape does this create when folded?';
      case SpatialType.navigation:
        return 'Where would you end up?';
    }
  }

  Widget _buildSpatialProblem() {
    switch (spatialData.type) {
      case SpatialType.rotation:
        return Column(
          children: [
            const Text(
              'Original Shape:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black87,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  spatialData.targetShape,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            if (spatialData.targetRotation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Rotated ${spatialData.targetRotation}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        );
      case SpatialType.folding:
        return Column(
          children: [
            const Text(
              'Flat pattern (net):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black87,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  spatialData.targetShape,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        );
      case SpatialType.navigation:
        return Container(
          width: 220,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black87,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              spatialData.targetShape,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
        );
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (selectedAnswer == spatialData.correctAnswer) {
      correctAnswers++;
    }
    
    currentProblemIndex++;
    
    if (currentProblemIndex >= problems.length) {
      _completeTest();
    } else {
      setState(() {
        spatialData = problems[currentProblemIndex];
        selectedAnswer = null;
      });
    }
  }

  void _completeTest() {
    final timeSpent = DateTime.now().difference(startTime).inSeconds;
    final score = (correctAnswers / totalProblems * 100).round();
    
    widget.onCompleted(score, timeSpent);
  }
}