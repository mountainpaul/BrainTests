import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cognitive_activity.dart';
import 'assessment_provider.dart';
import 'cognitive_exercise_provider.dart';
import 'repository_providers.dart';

/// Provider that combines recent assessments and exercises into a unified activity feed
final recentCognitiveActivityProvider = FutureProvider<List<CognitiveActivity>>((ref) async {
  final assessmentRepo = ref.read(assessmentRepositoryProvider);
  final exerciseRepo = ref.read(cognitiveExerciseRepositoryProvider);

  // Get recent assessments and exercises
  final assessments = await assessmentRepo.getAllAssessments();
  final exercises = await exerciseRepo.getRecentExercises(limit: 10);

  // Convert to CognitiveActivity
  final activities = <CognitiveActivity>[
    ...assessments.map((a) => CognitiveActivity.fromAssessment(a)),
    ...exercises.map((e) => CognitiveActivity.fromExercise(e)),
  ];

  // Sort by completion time (most recent first)
  activities.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  // Return top 5
  return activities.take(5).toList();
});
