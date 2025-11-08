import 'package:drift/drift.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/database.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {

  AssessmentRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<Assessment>> getAllAssessments() async {
    final assessments = await _database.select(_database.assessmentTable).get();
    return assessments.map(_mapToEntity).toList();
  }

  @override
  Future<List<Assessment>> getAssessmentsByType(AssessmentType type) async {
    final assessments = await (_database.select(_database.assessmentTable)
          ..where((t) => t.type.equals(type.name)))
        .get();
    return assessments.map(_mapToEntity).toList();
  }

  @override
  Future<List<Assessment>> getAssessmentsByDateRange(
      DateTime start, DateTime end) async {
    final assessments = await (_database.select(_database.assessmentTable)
          ..where((t) => t.completedAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
    return assessments.map(_mapToEntity).toList();
  }

  @override
  Future<Assessment?> getAssessmentById(int id) async {
    final assessment = await (_database.select(_database.assessmentTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return assessment != null ? _mapToEntity(assessment) : null;
  }

  @override
  Future<int> insertAssessment(Assessment assessment) async {
    return await _database.into(_database.assessmentTable).insert(
      AssessmentTableCompanion.insert(
        type: assessment.type,
        score: assessment.score,
        maxScore: assessment.maxScore,
        notes: Value(assessment.notes),
        completedAt: assessment.completedAt,
        createdAt: Value(assessment.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateAssessment(Assessment assessment) async {
    if (assessment.id == null) return false;
    final rowsUpdated = await (_database.update(_database.assessmentTable)
          ..where((t) => t.id.equals(assessment.id!)))
        .write(
      AssessmentTableCompanion(
        type: Value(assessment.type),
        score: Value(assessment.score),
        maxScore: Value(assessment.maxScore),
        notes: Value(assessment.notes),
        completedAt: Value(assessment.completedAt),
      ),
    );
    return rowsUpdated > 0;
  }

  @override
  Future<bool> deleteAssessment(int id) async {
    final rowsDeleted = await (_database.delete(_database.assessmentTable)
          ..where((t) => t.id.equals(id)))
        .go();
    return rowsDeleted > 0;
  }

  @override
  Future<Map<AssessmentType, double>> getAverageScoresByType() async {
    final Map<AssessmentType, double> averages = {};
    
    for (final type in AssessmentType.values) {
      final assessments = await getAssessmentsByType(type);
      if (assessments.isNotEmpty) {
        final totalPercentage = assessments
            .map((a) => a.percentage)
            .reduce((a, b) => a + b);
        averages[type] = totalPercentage / assessments.length;
      }
    }
    
    return averages;
  }

  @override
  Future<List<Assessment>> getRecentAssessments({int limit = 10}) async {
    final assessments = await (_database.select(_database.assessmentTable)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
    return assessments.map(_mapToEntity).toList();
  }

  Assessment _mapToEntity(AssessmentEntry entry) {
    return Assessment(
      id: entry.id,
      type: entry.type,
      score: entry.score,
      maxScore: entry.maxScore,
      notes: entry.notes,
      completedAt: entry.completedAt,
      createdAt: entry.createdAt,
    );
  }
}