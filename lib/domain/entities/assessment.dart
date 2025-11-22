import 'package:equatable/equatable.dart';
import 'enums.dart';

class Assessment extends Equatable {

  const Assessment({
    this.id,
    required this.type,
    required this.score,
    required this.maxScore,
    this.notes,
    required this.completedAt,
    required this.createdAt,
  });
  final int? id;
  final AssessmentType type;
  final int score;
  final int maxScore;
  final String? notes;
  final DateTime completedAt;
  final DateTime createdAt;

  double get percentage => (score / maxScore) * 100;

  Assessment copyWith({
    int? id,
    AssessmentType? type,
    int? score,
    int? maxScore,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Assessment(
      id: id ?? this.id,
      type: type ?? this.type,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    score,
    maxScore,
    notes,
    completedAt,
    createdAt,
  ];
}