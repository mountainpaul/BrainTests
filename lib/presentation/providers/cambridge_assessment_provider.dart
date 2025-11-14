import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/cambridge_assessment.dart';
import '../../domain/repositories/cambridge_assessment_repository.dart';
import 'repository_providers.dart';

part 'cambridge_assessment_provider.g.dart';

@riverpod
class CambridgeAssessment extends _$CambridgeAssessment {
  @override
  Future<List<CambridgeAssessmentResult>> build() async {
    final repository = ref.watch(cambridgeAssessmentRepositoryProvider);
    return await repository.getAllAssessments();
  }

  /// Add a new Cambridge assessment
  Future<void> addAssessment(CambridgeAssessmentResult assessment) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    await repository.insertAssessment(assessment);
    ref.invalidateSelf();
  }

  /// Get assessments by test type
  Future<List<CambridgeAssessmentResult>> getAssessmentsByType(CambridgeTestType type) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    return await repository.getAssessmentsByType(type);
  }

  /// Get assessments within date range
  Future<List<CambridgeAssessmentResult>> getAssessmentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    return await repository.getAssessmentsByDateRange(start, end);
  }

  /// Get the most recent assessment
  Future<CambridgeAssessmentResult?> getLatestAssessment() async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    return await repository.getLatestAssessment();
  }

  /// Get the most recent assessment for a specific test type
  Future<CambridgeAssessmentResult?> getLatestAssessmentByType(CambridgeTestType type) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    return await repository.getLatestAssessmentByType(type);
  }

  /// Delete an assessment
  Future<void> deleteAssessment(int id) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    await repository.deleteAssessment(id);
    ref.invalidateSelf();
  }

  /// Update an assessment
  Future<void> updateAssessment(CambridgeAssessmentResult assessment, int id) async {
    final repository = ref.read(cambridgeAssessmentRepositoryProvider);
    await repository.updateAssessment(assessment, id);
    ref.invalidateSelf();
  }
}
