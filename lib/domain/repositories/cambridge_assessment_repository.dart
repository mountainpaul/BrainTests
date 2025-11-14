import '../entities/cambridge_assessment.dart';

abstract class CambridgeAssessmentRepository {
  /// Insert a new Cambridge assessment result
  Future<int> insertAssessment(CambridgeAssessmentResult assessment);

  /// Get all Cambridge assessments
  Future<List<CambridgeAssessmentResult>> getAllAssessments();

  /// Get Cambridge assessments by test type
  Future<List<CambridgeAssessmentResult>> getAssessmentsByType(CambridgeTestType type);

  /// Get Cambridge assessments within a date range
  Future<List<CambridgeAssessmentResult>> getAssessmentsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get the most recent Cambridge assessment
  Future<CambridgeAssessmentResult?> getLatestAssessment();

  /// Get the most recent assessment for a specific test type
  Future<CambridgeAssessmentResult?> getLatestAssessmentByType(CambridgeTestType type);

  /// Delete a Cambridge assessment
  Future<void> deleteAssessment(int id);

  /// Update a Cambridge assessment
  Future<bool> updateAssessment(CambridgeAssessmentResult assessment, int id);
}
