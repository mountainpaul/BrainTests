import 'dart:math';

import '../../data/datasources/database.dart';
import '../models/assessment_models.dart';

/// Service that generates actual cognitive assessment questions
class AssessmentGenerator {
  static final Random _random = Random();

  /// Generate Memory Recall Assessment - Word List Learning
  static MemoryRecallQuestion generateMemoryRecallQuestion({
    int difficulty = 1, // 1-5 scale
  }) {
    // Word lists based on difficulty
    final wordLists = {
      1: ['cat', 'dog', 'sun', 'car', 'book'], // 5 common words
      2: ['apple', 'chair', 'phone', 'water', 'happy', 'green'], // 6 words
      3: ['elephant', 'bicycle', 'kitchen', 'purple', 'doctor', 'mountain', 'ocean'], // 7 words
      4: ['telephone', 'butterfly', 'newspaper', 'hospital', 'vacation', 'chocolate', 'umbrella', 'calendar'], // 8 words
      5: ['refrigerator', 'gymnasium', 'photograph', 'restaurant', 'dictionary', 'calculator', 'basketball', 'television', 'helicopter'], // 9 words
    };

    final baseWords = wordLists[difficulty] ?? wordLists[3]!;
    final wordsToUse = baseWords.take(5 + difficulty).toList();
    
    // Create recognition options (target words + distractors)
    final distractors = [
      'table', 'window', 'flower', 'pencil', 'music', 'orange', 'castle', 'rabbit',
      'guitar', 'planet', 'diamond', 'forest', 'thunder', 'sandwich', 'volcano'
    ];
    
    final recognitionOptions = <String>[];
    recognitionOptions.addAll(wordsToUse);
    
    // Add distractors (equal number to target words)
    final shuffledDistractors = List<String>.from(distractors)..shuffle(_random);
    recognitionOptions.addAll(shuffledDistractors.take(wordsToUse.length));
    recognitionOptions.shuffle(_random);

    return MemoryRecallQuestion(
      id: 'memory_recall_${DateTime.now().millisecondsSinceEpoch}',
      instruction: 'You will see a list of ${wordsToUse.length} words. Study them carefully, then recall as many as you can.',
      wordsToMemorize: wordsToUse,
      studyTimeSeconds: 2 * wordsToUse.length, // 2 seconds per word
      recognitionOptions: recognitionOptions,
      timeLimit: 120, // 2 minutes for recall
    );
  }

  /// Generate Attention Focus Assessment - Sustained Attention to Response Task
  static AttentionFocusQuestion generateAttentionFocusQuestion({
    int difficulty = 1,
  }) {
    // Generate sequence of digits 1-9, with target digit (3) appearing 10% of time
    final sequenceLength = 100 + (difficulty * 20); // 120-200 items
    const targetNumber = 3;
    const targetFrequency = 0.1; // 10% targets
    
    final sequence = <int>[];
    final targetCount = (sequenceLength * targetFrequency).round();
    final nonTargetCount = sequenceLength - targetCount;
    
    // Add targets
    for (int i = 0; i < targetCount; i++) {
      sequence.add(targetNumber);
    }
    
    // Add non-targets (1,2,4-9)
    final nonTargets = [1, 2, 4, 5, 6, 7, 8, 9];
    for (int i = 0; i < nonTargetCount; i++) {
      sequence.add(nonTargets[_random.nextInt(nonTargets.length)]);
    }
    
    sequence.shuffle(_random);

    return AttentionFocusQuestion(
      id: 'attention_focus_${DateTime.now().millisecondsSinceEpoch}',
      instruction: 'Numbers will appear on screen. Press the button for every number EXCEPT $targetNumber. Stay focused!',
      stimulusSequence: sequence,
      targetNumber: targetNumber,
      stimulusDurationMs: 500, // 500ms display time
      interStimulusIntervalMs: 1000, // 1s between stimuli
    );
  }

  /// Generate Executive Function Assessment - Tower of Hanoi
  static ExecutiveFunctionQuestion generateExecutiveFunctionQuestion({
    int difficulty = 1,
  }) {
    final numberOfDisks = 2 + difficulty; // 3-7 disks
    final maxDifficulty = min(difficulty, 5);
    
    // Initial state: all disks on first tower, largest to smallest
    final initialState = <List<int>>[
      List.generate(numberOfDisks, (i) => numberOfDisks - i), // [3,2,1] for 3 disks
      <int>[],
      <int>[],
    ];
    
    // Target state: all disks on third tower
    final targetState = <List<int>>[
      <int>[],
      <int>[],
      List.generate(numberOfDisks, (i) => numberOfDisks - i),
    ];
    
    // Optimal number of moves is 2^n - 1
    final optimalMoves = (1 << numberOfDisks) - 1;
    final maxMoves = (optimalMoves * 1.5).round(); // Allow 50% extra moves

    return ExecutiveFunctionQuestion(
      id: 'executive_function_${DateTime.now().millisecondsSinceEpoch}',
      instruction: 'Move all disks from the left tower to the right tower. Rules: Only one disk at a time, never place a larger disk on a smaller one.',
      numberOfDisks: numberOfDisks,
      initialState: initialState,
      targetState: targetState,
      maxMoves: maxMoves,
      timeLimit: 60 * numberOfDisks, // 1 minute per disk
    );
  }

  /// Generate Language Skills Assessment - Category Fluency
  static LanguageSkillsQuestion generateLanguageSkillsQuestion({
    int difficulty = 1,
  }) {
    final categories = {
      1: {'category': 'animals', 'prompt': 'Name as many animals as you can'},
      2: {'category': 'foods', 'prompt': 'Name as many foods as you can'},
      3: {'category': 'countries', 'prompt': 'Name as many countries as you can'},
      4: {'category': 'words_f', 'prompt': 'Name words starting with the letter F'},
      5: {'category': 'professions', 'prompt': 'Name as many professions/jobs as you can'},
    };

    final categoryData = categories[difficulty] ?? categories[3]!;
    
    return LanguageSkillsQuestion(
      id: 'language_skills_${DateTime.now().millisecondsSinceEpoch}',
      instruction: '${categoryData['prompt']}. You have 60 seconds. Speak each word clearly.',
      category: categoryData['category']!,
      prompt: categoryData['prompt']!,
      responseTimeSeconds: 60,
      timeLimit: 60,
    );
  }

  /// Generate Visuospatial Skills Assessment - Mental Rotation
  static VisuospatialQuestion generateVisuospatialQuestion({
    int difficulty = 1,
  }) {
    // Simple geometric shapes for mental rotation
    final shapes = ['L_shape', 'F_shape', 'T_shape', 'plus_shape', 'arrow_shape'];
    final targetShape = shapes[_random.nextInt(shapes.length)];
    
    // Rotation angles based on difficulty
    final rotationAngles = {
      1: [90, 180, 270], // Easy angles
      2: [60, 120, 180, 240, 300], // Moderate angles
      3: [45, 90, 135, 180, 225, 270, 315], // More angles
      4: [30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330], // Many angles
      5: List.generate(12, (i) => i * 30.0), // Every 30 degrees
    };
    
    final angles = rotationAngles[difficulty] ?? rotationAngles[3]!;
    final rotationDegrees = angles[_random.nextInt(angles.length)].toDouble();
    
    // Generate options: 1 correct + 3 distractors
    final options = <String>[];
    final correctOption = '${targetShape}_${rotationDegrees}deg';
    options.add(correctOption);
    
    // Add distractors (different rotations of same shape + different shapes)
    while (options.length < 4) {
      if (_random.nextBool() && options.length < 3) {
        // Same shape, different rotation
        final wrongAngle = angles[_random.nextInt(angles.length)];
        if (wrongAngle != rotationDegrees) {
          options.add('${targetShape}_${wrongAngle}deg');
        }
      } else {
        // Different shape
        final wrongShape = shapes[_random.nextInt(shapes.length)];
        if (wrongShape != targetShape) {
          final someAngle = angles[_random.nextInt(angles.length)];
          options.add('${wrongShape}_${someAngle}deg');
        }
      }
    }
    
    options.shuffle(_random);
    final correctIndex = options.indexOf(correctOption);

    return VisuospatialQuestion(
      id: 'visuospatial_${DateTime.now().millisecondsSinceEpoch}',
      instruction: 'Which shape matches the target shape when rotated? Look carefully at the orientation.',
      targetShape: targetShape,
      optionShapes: options,
      correctOptionIndex: correctIndex,
      rotationDegrees: rotationDegrees,
      timeLimit: 30 + (difficulty * 10), // 30-80 seconds
    );
  }

  /// Generate Processing Speed Assessment - Symbol Digit Modalities
  static ProcessingSpeedQuestion generateProcessingSpeedQuestion({
    int difficulty = 1,
  }) {
    // Create symbol-to-number mapping
    final symbols = ['○', '□', '△', '◇', '☆', '♦', '♠', '♣', '♥'];
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    
    final symbolCount = 4 + difficulty; // 5-9 symbols
    final selectedSymbols = symbols.take(symbolCount).toList();
    final selectedNumbers = numbers.take(symbolCount).toList();
    
    final symbolToNumberMap = <String, int>{};
    for (int i = 0; i < symbolCount; i++) {
      symbolToNumberMap[selectedSymbols[i]] = selectedNumbers[i];
    }
    
    // Generate test sequence
    final sequenceLength = 20 + (difficulty * 10); // 30-70 items
    final symbolSequence = <String>[];
    final correctAnswers = <int>[];
    
    for (int i = 0; i < sequenceLength; i++) {
      final symbol = selectedSymbols[_random.nextInt(selectedSymbols.length)];
      symbolSequence.add(symbol);
      correctAnswers.add(symbolToNumberMap[symbol]!);
    }

    return ProcessingSpeedQuestion(
      id: 'processing_speed_${DateTime.now().millisecondsSinceEpoch}',
      instruction: 'Use the key above to convert symbols to numbers as quickly and accurately as possible.',
      symbolToNumberMap: symbolToNumberMap,
      symbolSequence: symbolSequence,
      correctAnswers: correctAnswers,
      timeLimit: 90, // 90 seconds
    );
  }

  /// Generate a complete assessment battery
  static List<AssessmentQuestion> generateAssessmentBattery({
    AssessmentType type = AssessmentType.memoryRecall,
    int difficulty = 1,
  }) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return [generateMemoryRecallQuestion(difficulty: difficulty)];
      case AssessmentType.attentionFocus:
        return [generateAttentionFocusQuestion(difficulty: difficulty)];
      case AssessmentType.executiveFunction:
        return [generateExecutiveFunctionQuestion(difficulty: difficulty)];
      case AssessmentType.languageSkills:
        return [generateLanguageSkillsQuestion(difficulty: difficulty)];
      case AssessmentType.visuospatialSkills:
        return [generateVisuospatialQuestion(difficulty: difficulty)];
      case AssessmentType.processingSpeed:
        return [generateProcessingSpeedQuestion(difficulty: difficulty)];
    }
  }

  /// Calculate score based on assessment type and responses
  static double calculateAssessmentScore(AssessmentType type, List<AssessmentResponse> responses) {
    if (responses.isEmpty) return 0.0;

    switch (type) {
      case AssessmentType.memoryRecall:
        final response = responses.first as MemoryRecallResponse;
        // Combine free recall (70%) and recognition (30%) scores
        return (response.freeRecallScore * 0.7 + response.recognitionScore * 0.3);
        
      case AssessmentType.attentionFocus:
        final response = responses.first as AttentionFocusResponse;
        // Use d-prime score normalized to 0-100
        return (response.dPrime.clamp(-3.0, 3.0) + 3.0) / 6.0 * 100.0;
        
      case AssessmentType.executiveFunction:
        final response = responses.first as ExecutiveFunctionResponse;
        // Score based on completion and efficiency
        if (!response.solved) return 0.0;
        final efficiency = 1.0 - (response.totalMoves - getOptimalMoves(response)) / response.totalMoves;
        return (efficiency * 100.0).clamp(0.0, 100.0);
        
      case AssessmentType.languageSkills:
        final response = responses.first as LanguageSkillsResponse;
        // Score based on valid words generated
        return ((response.validWords / 15.0) * 100.0).clamp(0.0, 100.0);
        
      case AssessmentType.visuospatialSkills:
        final response = responses.first as VisuospatialResponse;
        // Simple accuracy score with time bonus
        if (!response.isCorrect) return 0.0;
        final timeBonusMultiplier = (30000 - response.responseTimeMs).clamp(0, 30000) / 30000.0;
        return (75.0 + (25.0 * timeBonusMultiplier));
        
      case AssessmentType.processingSpeed:
        final response = responses.first as ProcessingSpeedResponse;
        // Score based on accuracy and speed
        final accuracy = response.correctCount / response.totalAttempted;
        final speedBonus = (1000.0 / response.averageTimePerItem).clamp(0.0, 1.0);
        return ((accuracy * 80.0) + (speedBonus * 20.0)).clamp(0.0, 100.0);
    }
  }
  
  static int getOptimalMoves(ExecutiveFunctionResponse response) {
    // For Tower of Hanoi, optimal moves = 2^n - 1 where n is number of disks
    // This is a simplified calculation - in practice you'd analyze the actual moves
    return 7; // Assuming 3 disks for simplicity
  }
}

/// Word validation service for language assessments
class WordValidator {
  // Common valid words for different categories
  static final _validWords = {
    'animals': {
      'cat', 'dog', 'bird', 'fish', 'horse', 'cow', 'pig', 'sheep', 'goat', 'chicken',
      'lion', 'tiger', 'bear', 'elephant', 'giraffe', 'zebra', 'monkey', 'rabbit',
      'mouse', 'rat', 'hamster', 'guinea pig', 'snake', 'lizard', 'turtle', 'frog',
      'butterfly', 'bee', 'ant', 'spider', 'fly', 'mosquito', 'whale', 'dolphin',
      'shark', 'octopus', 'crab', 'lobster', 'deer', 'moose', 'wolf', 'fox'
    },
    'foods': {
      'apple', 'banana', 'orange', 'grape', 'strawberry', 'blueberry', 'peach', 'pear',
      'bread', 'rice', 'pasta', 'potato', 'carrot', 'broccoli', 'spinach', 'tomato',
      'chicken', 'beef', 'pork', 'fish', 'egg', 'milk', 'cheese', 'butter',
      'pizza', 'hamburger', 'sandwich', 'salad', 'soup', 'cake', 'cookie', 'ice cream'
    },
    'countries': {
      'usa', 'canada', 'mexico', 'brazil', 'argentina', 'chile', 'colombia', 'peru',
      'uk', 'france', 'germany', 'italy', 'spain', 'russia', 'china', 'japan',
      'india', 'australia', 'new zealand', 'south africa', 'egypt', 'nigeria',
      'turkey', 'saudi arabia', 'iran', 'iraq', 'israel', 'jordan', 'lebanon'
    }
  };

  static bool isValidWord(String category, String word) {
    final normalizedWord = word.toLowerCase().trim();
    
    if (category.startsWith('words_')) {
      // Letter fluency - check if word starts with the letter
      final letter = category.split('_')[1].toLowerCase();
      return normalizedWord.startsWith(letter) && normalizedWord.length > 1;
    }
    
    return _validWords[category]?.contains(normalizedWord) ?? false;
  }

  static List<String> categorizeWords(List<String> words) {
    // Simple semantic categorization
    final categories = <String>[];
    // This would be more sophisticated in a real implementation
    // For now, just return basic categories
    if (words.any((w) => _validWords['animals']!.contains(w.toLowerCase()))) {
      categories.add('animals');
    }
    if (words.any((w) => _validWords['foods']!.contains(w.toLowerCase()))) {
      categories.add('foods');
    }
    return categories;
  }
}