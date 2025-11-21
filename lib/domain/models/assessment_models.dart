import 'dart:math' as Math;

import 'package:equatable/equatable.dart';

/// Base class for all assessment questions
abstract class AssessmentQuestion extends Equatable { // in seconds, 0 = no time limit
  
  const AssessmentQuestion({
    required this.id,
    required this.instruction,
    this.timeLimit = 0,
  });
  final String id;
  final String instruction;
  final int timeLimit;

  @override
  List<Object?> get props => [id, instruction, timeLimit];
}

/// Memory Recall Assessment - Word List Memory
class MemoryRecallQuestion extends AssessmentQuestion { // for recognition phase
  
  const MemoryRecallQuestion({
    required super.id,
    required super.instruction,
    required this.wordsToMemorize,
    required this.studyTimeSeconds,
    required this.recognitionOptions,
    super.timeLimit = 0,
  });
  final List<String> wordsToMemorize;
  final int studyTimeSeconds;
  final List<String> recognitionOptions;

  @override
  List<Object?> get props => [...super.props, wordsToMemorize, studyTimeSeconds, recognitionOptions];
}

/// Attention Focus Assessment - Sustained Attention to Response Task (SART)
class AttentionFocusQuestion extends AssessmentQuestion {
  
  const AttentionFocusQuestion({
    required super.id,
    required super.instruction,
    required this.stimulusSequence,
    required this.targetNumber,
    required this.stimulusDurationMs,
    required this.interStimulusIntervalMs,
    super.timeLimit = 0,
  });
  final List<int> stimulusSequence; // sequence of numbers to display
  final int targetNumber; // number to NOT respond to
  final int stimulusDurationMs;
  final int interStimulusIntervalMs;

  @override
  List<Object?> get props => [...super.props, stimulusSequence, targetNumber, stimulusDurationMs, interStimulusIntervalMs];
}

/// Executive Function Assessment - Tower of Hanoi simplified
class ExecutiveFunctionQuestion extends AssessmentQuestion {
  
  const ExecutiveFunctionQuestion({
    required super.id,
    required super.instruction,
    required this.numberOfDisks,
    required this.initialState,
    required this.targetState,
    required this.maxMoves,
    super.timeLimit = 300, // 5 minutes
  });
  final int numberOfDisks;
  final List<List<int>> initialState; // [tower1, tower2, tower3]
  final List<List<int>> targetState;
  final int maxMoves;

  @override
  List<Object?> get props => [...super.props, numberOfDisks, initialState, targetState, maxMoves];
}

/// Language Skills Assessment - Word Fluency
class LanguageSkillsQuestion extends AssessmentQuestion {
  
  const LanguageSkillsQuestion({
    required super.id,
    required super.instruction,
    required this.category,
    required this.prompt,
    required this.responseTimeSeconds,
    super.timeLimit = 60,
  });
  final String category; // e.g., "animals", "words starting with F"
  final String prompt;
  final int responseTimeSeconds;

  @override
  List<Object?> get props => [...super.props, category, prompt, responseTimeSeconds];
}

/// Visuospatial Skills Assessment - Mental Rotation
class VisuospatialQuestion extends AssessmentQuestion {
  
  const VisuospatialQuestion({
    required super.id,
    required super.instruction,
    required this.targetShape,
    required this.optionShapes,
    required this.correctOptionIndex,
    required this.rotationDegrees,
    super.timeLimit = 30,
  });
  final String targetShape; // base64 encoded image or shape description
  final List<String> optionShapes; // rotated versions + distractors
  final int correctOptionIndex;
  final double rotationDegrees;

  @override
  List<Object?> get props => [...super.props, targetShape, optionShapes, correctOptionIndex, rotationDegrees];
}

/// Processing Speed Assessment - Symbol Digit Modalities Test
class ProcessingSpeedQuestion extends AssessmentQuestion {
  
  const ProcessingSpeedQuestion({
    required super.id,
    required super.instruction,
    required this.symbolToNumberMap,
    required this.symbolSequence,
    required this.correctAnswers,
    super.timeLimit = 90,
  });
  final Map<String, int> symbolToNumberMap; // symbol -> number mapping
  final List<String> symbolSequence; // symbols to convert
  final List<int> correctAnswers;

  @override
  List<Object?> get props => [...super.props, symbolToNumberMap, symbolSequence, correctAnswers];
}

/// Assessment response models
abstract class AssessmentResponse extends Equatable {
  
  const AssessmentResponse({
    required this.questionId,
    required this.startTime,
    required this.endTime,
    required this.isCorrect,
  });
  final String questionId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCorrect;

  int get responseTimeMs => endTime.difference(startTime).inMilliseconds;

  @override
  List<Object?> get props => [questionId, startTime, endTime, isCorrect];
}

class MemoryRecallResponse extends AssessmentResponse {
  
  const MemoryRecallResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.recalledWords,
    required this.recognizedWords,
    required this.freeRecallScore,
    required this.recognitionScore,
  });
  final List<String> recalledWords;
  final List<String> recognizedWords;
  final int freeRecallScore;
  final int recognitionScore;

  @override
  List<Object?> get props => [...super.props, recalledWords, recognizedWords, freeRecallScore, recognitionScore];
}

class AttentionFocusResponse extends AssessmentResponse {
  
  const AttentionFocusResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.responses,
    required this.reactionTimes,
    required this.hits,
    required this.misses,
    required this.falseAlarms,
    required this.correctRejections,
  });
  final List<bool> responses; // true = responded, false = didn't respond
  final List<int> reactionTimes; // in milliseconds
  final int hits; // correct responses
  final int misses; // missed targets
  final int falseAlarms; // incorrect responses
  final int correctRejections;

  double get dPrime {
    // Signal detection theory d' calculation
    final hitRate = hits / (hits + misses);
    final falseAlarmRate = falseAlarms / (falseAlarms + correctRejections);
    
    // Avoid extreme values
    final adjustedHitRate = hitRate == 1.0 ? 0.99 : (hitRate == 0.0 ? 0.01 : hitRate);
    final adjustedFARate = falseAlarmRate == 1.0 ? 0.99 : (falseAlarmRate == 0.0 ? 0.01 : falseAlarmRate);
    
    return _inverseNormalCDF(adjustedHitRate) - _inverseNormalCDF(adjustedFARate);
  }
  
  double get criterion {
    // Response bias criterion
    final hitRate = hits / (hits + misses);
    final falseAlarmRate = falseAlarms / (falseAlarms + correctRejections);
    
    final adjustedHitRate = hitRate == 1.0 ? 0.99 : (hitRate == 0.0 ? 0.01 : hitRate);
    final adjustedFARate = falseAlarmRate == 1.0 ? 0.99 : (falseAlarmRate == 0.0 ? 0.01 : falseAlarmRate);
    
    return -0.5 * (_inverseNormalCDF(adjustedHitRate) + _inverseNormalCDF(adjustedFARate));
  }
  
  // Approximation of inverse normal CDF
  double _inverseNormalCDF(double p) {
    // Simple approximation - in production, use a proper statistics library
    if (p <= 0.5) {
      return -_inverseNormalCDF(1 - p);
    }
    final t = Math.sqrt(-2 * Math.log(1 - p));
    return t - (2.515517 + 0.802853 * t + 0.010328 * t * t) / 
           (1 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t);
  }

  @override
  List<Object?> get props => [...super.props, responses, reactionTimes, hits, misses, falseAlarms, correctRejections];
}

class ExecutiveFunctionResponse extends AssessmentResponse { // time before first move
  
  const ExecutiveFunctionResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.moves,
    required this.totalMoves,
    required this.solved,
    required this.planningTime,
    required this.numberOfDisks,
  });
  final List<Move> moves;
  final int totalMoves;
  final bool solved;
  final int planningTime;
  final int numberOfDisks;

  @override
  List<Object?> get props => [...super.props, moves, totalMoves, solved, planningTime, numberOfDisks];
}

class Move extends Equatable {
  
  const Move({
    required this.fromTower,
    required this.toTower,
    required this.timestamp,
  });
  final int fromTower;
  final int toTower;
  final DateTime timestamp;

  @override
  List<Object?> get props => [fromTower, toTower, timestamp];
}

class LanguageSkillsResponse extends AssessmentResponse { // semantic categories identified
  
  const LanguageSkillsResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.words,
    required this.validWords,
    required this.invalidWords,
    required this.repetitions,
    required this.categories,
  });
  final List<String> words;
  final int validWords;
  final int invalidWords;
  final int repetitions;
  final List<String> categories;

  @override
  List<Object?> get props => [...super.props, words, validWords, invalidWords, repetitions, categories];
}

class VisuospatialResponse extends AssessmentResponse { // 0-100
  
  const VisuospatialResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.selectedOption,
    required this.correctOption,
    required this.confidence,
  });
  final int selectedOption;
  final int correctOption;
  final double confidence;

  @override
  List<Object?> get props => [...super.props, selectedOption, correctOption, confidence];
}

class ProcessingSpeedResponse extends AssessmentResponse {
  
  const ProcessingSpeedResponse({
    required super.questionId,
    required super.startTime,
    required super.endTime,
    required super.isCorrect,
    required this.userAnswers,
    required this.correctAnswers,
    required this.correctCount,
    required this.totalAttempted,
    required this.averageTimePerItem,
  });
  final List<int> userAnswers;
  final List<int> correctAnswers;
  final int correctCount;
  final int totalAttempted;
  final double averageTimePerItem;

  @override
  List<Object?> get props => [...super.props, userAnswers, correctAnswers, correctCount, totalAttempted, averageTimePerItem];
}

