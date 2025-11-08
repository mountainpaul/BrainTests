import 'package:equatable/equatable.dart';
import '../../data/datasources/database.dart';

class CognitiveExercise extends Equatable {

  const CognitiveExercise({
    this.id,
    required this.name,
    required this.type,
    required this.difficulty,
    this.score,
    required this.maxScore,
    this.timeSpentSeconds,
    required this.isCompleted,
    this.exerciseData,
    this.completedAt,
    required this.createdAt,
  });
  final int? id;
  final String name;
  final ExerciseType type;
  final ExerciseDifficulty difficulty;
  final int? score;
  final int maxScore;
  final int? timeSpentSeconds;
  final bool isCompleted;
  final String? exerciseData;
  final DateTime? completedAt;
  final DateTime createdAt;

  double? get percentage => score != null ? (score! / maxScore) * 100 : null;

  String get formattedTime {
    if (timeSpentSeconds == null) return '--';
    final minutes = timeSpentSeconds! ~/ 60;
    final seconds = timeSpentSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }

  CognitiveExercise copyWith({
    int? id,
    String? name,
    ExerciseType? type,
    ExerciseDifficulty? difficulty,
    int? score,
    int? maxScore,
    int? timeSpentSeconds,
    bool? isCompleted,
    String? exerciseData,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return CognitiveExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      exerciseData: exerciseData ?? this.exerciseData,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    difficulty,
    score,
    maxScore,
    timeSpentSeconds,
    isCompleted,
    exerciseData,
    completedAt,
    createdAt,
  ];
}