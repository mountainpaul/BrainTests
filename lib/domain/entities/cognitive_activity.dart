import '../../data/datasources/database.dart' show AssessmentType;
import 'assessment.dart';
import 'cognitive_exercise.dart';

/// Wrapper class to represent any cognitive activity (assessment or exercise)
/// Used for displaying combined recent activity
class CognitiveActivity {
  CognitiveActivity._({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.completedAt,
    required this.type,
    this.assessment,
    this.exercise,
  });

  /// Create from Assessment
  factory CognitiveActivity.fromAssessment(Assessment assessment) {
    final name = _getAssessmentName(assessment.type);
    final percentage = (assessment.score / assessment.maxScore * 100).round();

    return CognitiveActivity._(
      name: name,
      score: percentage,
      maxScore: 100,
      completedAt: assessment.completedAt,
      type: ActivityType.assessment,
      assessment: assessment,
    );
  }

  /// Create from CognitiveExercise
  factory CognitiveActivity.fromExercise(CognitiveExercise exercise) {
    final percentage = exercise.score != null && exercise.maxScore > 0
        ? (exercise.score! / exercise.maxScore * 100).round()
        : 0;

    return CognitiveActivity._(
      name: exercise.name,
      score: percentage,
      maxScore: 100,
      completedAt: exercise.completedAt ?? exercise.createdAt,
      type: ActivityType.exercise,
      exercise: exercise,
    );
  }

  final String name;
  final int score; // Percentage score (0-100)
  final int maxScore;
  final DateTime completedAt;
  final ActivityType type;
  final Assessment? assessment;
  final CognitiveExercise? exercise;

  /// Get friendly name for assessment type
  static String _getAssessmentName(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall Test';
      case AssessmentType.attentionFocus:
        return 'Attention Focus Test';
      case AssessmentType.executiveFunction:
        return 'Trail Making Test B';
      case AssessmentType.languageSkills:
        return 'Language Skills Test';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Test';
      case AssessmentType.processingSpeed:
        return 'Trail Making Test A';
    }
  }
}

enum ActivityType {
  assessment,
  exercise,
}
