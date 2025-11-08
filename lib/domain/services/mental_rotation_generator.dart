import 'dart:math' as math;
import 'package:brain_plan/domain/models/block_3d_shape.dart';

/// Data class for a mental rotation task
class MentalRotationTask {

  MentalRotationTask({
    required this.referenceShape,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.rotationApplied,
    required this.timeLimit,
    required this.metadata,
  });
  final Block3DShape referenceShape;
  final List<Block3DShape> options;
  final int correctAnswerIndex;
  final DifficultyLevel difficulty;
  final List<double> rotationApplied; // [x, y, z] rotation angles
  final Duration timeLimit;
  final Map<String, dynamic> metadata;
}

/// Generator for mental rotation cognitive tasks
class MentalRotationGenerator {
  static final _random = math.Random();

  /// Generate a mental rotation task for the given difficulty level
  static MentalRotationTask generateTask(DifficultyLevel difficulty) {
    // Select a random base shape for this difficulty
    final baseShapes = Block3DShapes.getShapesForDifficulty(difficulty);
    final baseShape = baseShapes[_random.nextInt(baseShapes.length)];

    // Select a rotation for this difficulty
    final rotations = RotationAngles.getRotationsForDifficulty(difficulty);
    final rotation = rotations[_random.nextInt(rotations.length)];

    // Create the reference shape (rotated version)
    final referenceShape = baseShape.rotate(rotation[0], rotation[1], rotation[2]);

    // Generate options: 1 correct + 3 distractors
    final options = _generateOptions(baseShape, rotation, difficulty);

    // Shuffle options and track correct answer index
    // Create a list of (option, isCorrect) pairs to track the correct answer through shuffling
    final optionsWithFlags = List.generate(
      options.length,
      (i) => (option: options[i], isCorrect: i == 0),
    );

    // Shuffle
    optionsWithFlags.shuffle(_random);

    // Find correct index after shuffle
    final correctIndex = optionsWithFlags.indexWhere((pair) => pair.isCorrect);
    final shuffledOptions = optionsWithFlags.map((pair) => pair.option).toList();

    // Calculate time limit based on difficulty
    final timeLimit = _getTimeLimit(difficulty);

    return MentalRotationTask(
      referenceShape: referenceShape,
      options: shuffledOptions,
      correctAnswerIndex: correctIndex,
      difficulty: difficulty,
      rotationApplied: rotation,
      timeLimit: timeLimit,
      metadata: {
        'baseShapeId': baseShape.id,
        'rotationDegrees': [
          _radToDeg(rotation[0]),
          _radToDeg(rotation[1]),
          _radToDeg(rotation[2]),
        ],
        'hasMultiAxisRotation': rotation.where((r) => r.abs() > 0.01).length > 1,
      },
    );
  }

  /// Generate 4 options: 1 correct rotation + 3 distractors
  static List<Block3DShape> _generateOptions(
    Block3DShape baseShape,
    List<double> correctRotation,
    DifficultyLevel difficulty,
  ) {
    final options = <Block3DShape>[];

    // Add correct answer (same shape, rotated)
    options.add(baseShape.rotate(correctRotation[0], correctRotation[1], correctRotation[2]));

    // Generate distractors based on difficulty
    switch (difficulty) {
      case DifficultyLevel.easy:
        options.addAll(_generateEasyDistractors(baseShape, correctRotation));
        break;
      case DifficultyLevel.medium:
        options.addAll(_generateMediumDistractors(baseShape, correctRotation));
        break;
      case DifficultyLevel.hard:
        options.addAll(_generateHardDistractors(baseShape, correctRotation));
        break;
    }

    return options;
  }

  /// Easy distractors: different rotations + 1 mirror image
  static List<Block3DShape> _generateEasyDistractors(
    Block3DShape baseShape,
    List<double> correctRotation,
  ) {
    final distractors = <Block3DShape>[];

    // Distractor 1: Different simple rotation
    final altRotation1 = [0.0, math.pi, 0.0]; // 180° Y (if not already used)
    if (!_rotationsEqual(altRotation1, correctRotation)) {
      distractors.add(baseShape.rotate(altRotation1[0], altRotation1[1], altRotation1[2]));
    } else {
      distractors.add(baseShape.rotate(0.0, math.pi / 2, 0.0)); // 90° Y
    }

    // Distractor 2: Another different rotation
    final altRotation2 = [math.pi / 2, 0.0, 0.0]; // 90° X
    distractors.add(baseShape.rotate(altRotation2[0], altRotation2[1], altRotation2[2]));

    // Distractor 3: Mirror image (hardest distractor)
    distractors.add(baseShape.mirror(Axis.x));

    return distractors;
  }

  /// Medium distractors: subtle rotations + mirror + different shape
  static List<Block3DShape> _generateMediumDistractors(
    Block3DShape baseShape,
    List<double> correctRotation,
  ) {
    final distractors = <Block3DShape>[];

    // Distractor 1: Close but different rotation (45° off)
    final altRotation1 = [
      correctRotation[0] + math.pi / 4,
      correctRotation[1],
      correctRotation[2],
    ];
    distractors.add(baseShape.rotate(altRotation1[0], altRotation1[1], altRotation1[2]));

    // Distractor 2: Mirror image with rotation
    final mirrored = baseShape.mirror(Axis.y);
    distractors.add(mirrored.rotate(correctRotation[0], correctRotation[1], correctRotation[2]));

    // Distractor 3: Different but similar shape from same difficulty
    final allMediumShapes = Block3DShapes.getShapesForDifficulty(DifficultyLevel.medium);
    final differentShape = allMediumShapes.firstWhere(
      (s) => s.id != baseShape.id,
      orElse: () => allMediumShapes.first,
    );
    distractors.add(differentShape.rotate(correctRotation[0], correctRotation[1], correctRotation[2]));

    return distractors;
  }

  /// Hard distractors: very subtle differences (mirror, near-rotation, shape variants)
  static List<Block3DShape> _generateHardDistractors(
    Block3DShape baseShape,
    List<double> correctRotation,
  ) {
    final distractors = <Block3DShape>[];

    // Distractor 1: Very close rotation (30° off)
    final altRotation1 = [
      correctRotation[0] + math.pi / 6,
      correctRotation[1] - math.pi / 12,
      correctRotation[2],
    ];
    distractors.add(baseShape.rotate(altRotation1[0], altRotation1[1], altRotation1[2]));

    // Distractor 2: Mirror on different axis + similar rotation
    final mirrored = baseShape.mirror(Axis.z);
    distractors.add(mirrored.rotate(
      correctRotation[0] + math.pi / 8,
      correctRotation[1],
      correctRotation[2],
    ));

    // Distractor 3: Same shape, mirror + exact rotation (classic trap!)
    final mirroredExact = baseShape.mirror(Axis.x);
    distractors.add(mirroredExact.rotate(correctRotation[0], correctRotation[1], correctRotation[2]));

    return distractors;
  }

  /// Get time limit based on difficulty level and age adjustment
  /// Based on research showing ~10ms per degree rotation (Heinen et al. 2016)
  /// Reference: https://openpsychologydata.metajnl.com/articles/10.5334/jopd.ai
  static Duration _getTimeLimit(DifficultyLevel difficulty, {int? userAge}) {
    // Base time limits (in milliseconds) based on rotation angles
    // Formula: RT = 9.56 * angle + 1891.3 (from research)
    int baseTime;
    switch (difficulty) {
      case DifficultyLevel.easy:
        // 90° rotation: ~2800ms base + buffer
        baseTime = 7500; // 7.5 seconds (research used this limit)
        break;
      case DifficultyLevel.medium:
        // 135° rotation: ~3200ms base + buffer
        baseTime = 10000; // 10 seconds
        break;
      case DifficultyLevel.hard:
        // 150° rotation: ~3400ms base + buffer
        baseTime = 12000; // 12 seconds
        break;
    }

    // Age adjustment: older adults show ~30% slower processing
    // Research shows mental rotation decline with age (peak at 20s)
    if (userAge != null) {
      if (userAge >= 70) {
        baseTime = (baseTime * 1.5).round(); // +50% for 70+
      } else if (userAge >= 60) {
        baseTime = (baseTime * 1.3).round(); // +30% for 60-69
      } else if (userAge >= 50) {
        baseTime = (baseTime * 1.15).round(); // +15% for 50-59
      }
    }

    return Duration(milliseconds: baseTime);
  }

  /// Check if two rotation arrays are approximately equal
  static bool _rotationsEqual(List<double> rot1, List<double> rot2, {double tolerance = 0.1}) {
    if (rot1.length != rot2.length) return false;
    for (int i = 0; i < rot1.length; i++) {
      if ((rot1[i] - rot2[i]).abs() > tolerance) return false;
    }
    return true;
  }

  /// Convert radians to degrees
  static double _radToDeg(double rad) => rad * 180 / math.pi;

  /// Generate a full set of practice trials (easier versions for familiarization)
  static List<MentalRotationTask> generatePracticeSet() {
    return [
      generateTask(DifficultyLevel.easy),
      generateTask(DifficultyLevel.easy),
      generateTask(DifficultyLevel.easy),
    ];
  }

  /// Generate a test battery (mix of all difficulty levels)
  static List<MentalRotationTask> generateTestBattery({
    int easyCount = 3,
    int mediumCount = 4,
    int hardCount = 3,
  }) {
    final tasks = <MentalRotationTask>[];

    for (int i = 0; i < easyCount; i++) {
      tasks.add(generateTask(DifficultyLevel.easy));
    }
    for (int i = 0; i < mediumCount; i++) {
      tasks.add(generateTask(DifficultyLevel.medium));
    }
    for (int i = 0; i < hardCount; i++) {
      tasks.add(generateTask(DifficultyLevel.hard));
    }

    tasks.shuffle(_random);
    return tasks;
  }
}

/// Results tracking for mental rotation assessment
class MentalRotationResults {

  MentalRotationResults({
    required this.totalTrials,
    required this.correctTrials,
    required this.responseTimes,
    required this.accuracyByDifficulty,
    required this.totalErrors,
    required this.averageResponseTime,
  });
  final int totalTrials;
  final int correctTrials;
  final List<Duration> responseTimes;
  final Map<DifficultyLevel, double> accuracyByDifficulty;
  final int totalErrors;
  final double averageResponseTime;

  double get overallAccuracy => (correctTrials / totalTrials) * 100;

  /// Calculate age-adjusted z-score for visuospatial ability
  double calculateZScore({int? userAge}) {
    // Normative data: average accuracy decreases with age
    // Based on research showing ~15% decline between ages 60-80 in mental rotation
    final expectedAccuracy = _getExpectedAccuracy(userAge);
    const expectedSD = 15.0; // Standard deviation ~15% for spatial tasks

    return (overallAccuracy - expectedAccuracy) / expectedSD;
  }

  double _getExpectedAccuracy(int? age) {
    if (age == null) return 70.0; // General population average

    // Age-adjusted normative data
    if (age < 40) return 78.0;  // Peak performance
    if (age < 50) return 75.0;  // -3%
    if (age < 60) return 72.0;  // -6%
    if (age < 70) return 68.0;  // -10%
    if (age < 80) return 63.0;  // -15%
    return 58.0;                // -20% for 80+
  }

  String get interpretation {
    if (overallAccuracy >= 80) return 'Excellent - Above average visuospatial ability';
    if (overallAccuracy >= 70) return 'Good - Average visuospatial ability';
    if (overallAccuracy >= 60) return 'Fair - Below average, consider cognitive exercises';
    if (overallAccuracy >= 50) return 'Mild difficulty - Recommend consultation';
    return 'Significant difficulty - Recommend professional assessment';
  }
}
