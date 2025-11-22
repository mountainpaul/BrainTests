import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/assessment.dart';
import 'cambridge_assessment_provider.dart';
import 'cognitive_activity_provider.dart';
import 'repository_providers.dart';

part 'assessment_provider.g.dart';

final assessmentsProvider = FutureProvider<List<Assessment>>((ref) async {
  final repository = ref.read(assessmentRepositoryProvider);
  return await repository.getAllAssessments();
});

final recentAssessmentsProvider = FutureProvider<List<Assessment>>((ref) async {
  final repository = ref.read(assessmentRepositoryProvider);
  return await repository.getRecentAssessments(limit: 5);
});

final assessmentsByTypeProvider = FutureProvider.family<List<Assessment>, AssessmentType>((ref, type) async {
  final repository = ref.read(assessmentRepositoryProvider);
  return await repository.getAssessmentsByType(type);
});

final averageScoresByTypeProvider = FutureProvider<Map<AssessmentType, double>>((ref) async {
  final repository = ref.read(assessmentRepositoryProvider);
  return await repository.getAverageScoresByType();
});

/// Provider to count MCI tests completed this week
/// MCI tests include all assessment types:
/// - Processing Speed (Trail Making Test A)
/// - Executive Function (Trail Making Test B)
/// - Language Skills
/// - Visuospatial Skills
/// - Memory Recall
/// Refresh trigger - increments every time assessments change
@riverpod
class AssessmentRefreshTrigger extends _$AssessmentRefreshTrigger {
  @override
  int build() => 0;

  void increment() => state++;
}

final weeklyMCITestCountProvider = FutureProvider.autoDispose<int>((ref) async {
  // Watch the refresh trigger to rebuild when assessments change
  ref.watch(assessmentRefreshTriggerProvider);

  final assessmentRepository = ref.read(assessmentRepositoryProvider);
  final cambridgeRepository = ref.read(cambridgeAssessmentRepositoryProvider);

  // Get both regular and Cambridge assessments
  final regularAssessments = await assessmentRepository.getAllAssessments();
  final cambridgeAssessments = await cambridgeRepository.getAllAssessments();

  // Calculate this week's Monday at midnight
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);

  // Filter for regular MCI tests from this week
  final thisWeekRegularMCITests = regularAssessments.where((assessment) {
    final isThisWeek = assessment.completedAt.isAfter(weekStartMidnight) ||
                       assessment.completedAt.isAtSameMomentAs(weekStartMidnight);
    final isMCITest = assessment.type == AssessmentType.processingSpeed ||
                      assessment.type == AssessmentType.executiveFunction ||
                      assessment.type == AssessmentType.languageSkills ||
                      assessment.type == AssessmentType.visuospatialSkills ||
                      assessment.type == AssessmentType.memoryRecall;
    return isThisWeek && isMCITest;
  }).toList();

  // Filter for Cambridge tests from this week
  final thisWeekCambridgeTests = cambridgeAssessments.where((result) {
    final isThisWeek = result.completedAt.isAfter(weekStartMidnight) ||
                       result.completedAt.isAtSameMomentAs(weekStartMidnight);
    return isThisWeek;
  }).toList();

  return thisWeekRegularMCITests.length + thisWeekCambridgeTests.length;
});

@riverpod
class AssessmentNotifier extends _$AssessmentNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addAssessment(Assessment assessment) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(assessmentRepositoryProvider);
      await repository.insertAssessment(assessment);

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      // Trigger refresh by incrementing the trigger
      ref.read(assessmentRefreshTriggerProvider.notifier).increment();

      // Invalidate related providers
      ref.invalidate(assessmentsProvider);
      ref.invalidate(recentAssessmentsProvider);
      ref.invalidate(averageScoresByTypeProvider);
      ref.invalidate(recentCognitiveActivityProvider);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAssessment(Assessment assessment) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(assessmentRepositoryProvider);
      await repository.updateAssessment(assessment);

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      ref.invalidate(assessmentsProvider);
      ref.invalidate(recentAssessmentsProvider);
      ref.invalidate(averageScoresByTypeProvider);
      ref.invalidate(weeklyMCITestCountProvider);
      ref.invalidate(recentCognitiveActivityProvider);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAssessment(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(assessmentRepositoryProvider);
      await repository.deleteAssessment(id);

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);

      ref.invalidate(assessmentsProvider);
      ref.invalidate(recentAssessmentsProvider);
      ref.invalidate(averageScoresByTypeProvider);
      ref.invalidate(weeklyMCITestCountProvider);
      ref.invalidate(recentCognitiveActivityProvider);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}