import '../../data/datasources/database.dart';
import '../entities/assessment.dart';

abstract class AssessmentRepository {
  Future<List<Assessment>> getAllAssessments();
  Future<List<Assessment>> getAssessmentsByType(AssessmentType type);
  Future<List<Assessment>> getAssessmentsByDateRange(DateTime start, DateTime end);
  Future<Assessment?> getAssessmentById(int id);
  Future<int> insertAssessment(Assessment assessment);
  Future<bool> updateAssessment(Assessment assessment);
  Future<bool> deleteAssessment(int id);
  Future<Map<AssessmentType, double>> getAverageScoresByType();
  Future<List<Assessment>> getRecentAssessments({int limit = 10});
}