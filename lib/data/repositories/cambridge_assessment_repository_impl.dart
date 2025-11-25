import 'dart:convert';
import 'package:drift/drift.dart';

import '../../data/datasources/database.dart' as database;
import '../../domain/entities/cambridge_assessment.dart';
import '../../domain/repositories/cambridge_assessment_repository.dart';

class CambridgeAssessmentRepositoryImpl implements CambridgeAssessmentRepository {
  final database.AppDatabase _database;

  CambridgeAssessmentRepositoryImpl(this._database);

  @override
  Future<int> insertAssessment(CambridgeAssessmentResult assessment) async {
    // Convert domain enum to database enum
    final dbTestType = _convertTestType(assessment.testType);

    final companion = database.CambridgeAssessmentTableCompanion.insert(
      testType: dbTestType,
      durationSeconds: assessment.durationSeconds,
      accuracy: assessment.accuracy,
      totalTrials: assessment.totalTrials,
      correctTrials: assessment.correctTrials,
      errorCount: assessment.errorCount,
      meanLatencyMs: assessment.meanLatencyMs,
      medianLatencyMs: assessment.medianLatencyMs,
      normScore: assessment.normScore,
      interpretation: assessment.interpretation,
      specificMetrics: jsonEncode(assessment.specificMetrics),
      completedAt: assessment.completedAt,
    );

    return await _database.into(_database.cambridgeAssessmentTable).insert(companion);
  }

  // Convert domain CambridgeTestType to database CambridgeTestType
  database.CambridgeTestType _convertTestType(CambridgeTestType domainType) {
    switch (domainType) {
      case CambridgeTestType.pal:
        return database.CambridgeTestType.pal;
      case CambridgeTestType.prm:
        return database.CambridgeTestType.prm;
      case CambridgeTestType.swm:
        return database.CambridgeTestType.swm;
      case CambridgeTestType.rvp:
        return database.CambridgeTestType.rvp;
      case CambridgeTestType.rti:
        return database.CambridgeTestType.rti;
      case CambridgeTestType.soc:
        return database.CambridgeTestType.ots; // Map soc to ots (planning test)
      // Map non-existent database enums to closest match
      case CambridgeTestType.mot:
      case CambridgeTestType.ied:
      case CambridgeTestType.sst:
      case CambridgeTestType.avlt:
        return database.CambridgeTestType.pal; // Fallback
    }
  }

  // Convert database CambridgeTestType to domain CambridgeTestType
  CambridgeTestType _convertFromDbType(database.CambridgeTestType dbType) {
    switch (dbType) {
      case database.CambridgeTestType.pal:
        return CambridgeTestType.pal;
      case database.CambridgeTestType.prm:
        return CambridgeTestType.prm;
      case database.CambridgeTestType.swm:
        return CambridgeTestType.swm;
      case database.CambridgeTestType.rvp:
        return CambridgeTestType.rvp;
      case database.CambridgeTestType.rti:
        return CambridgeTestType.rti;
      case database.CambridgeTestType.ots:
        return CambridgeTestType.soc; // Map ots to soc (planning test)
    }
  }

  @override
  Future<List<CambridgeAssessmentResult>> getAllAssessments() async {
    final entries = await _database.select(_database.cambridgeAssessmentTable).get();
    return entries.map(_entryToResult).toList();
  }

  @override
  Future<List<CambridgeAssessmentResult>> getAssessmentsByType(CambridgeTestType type) async {
    final dbType = _convertTestType(type);
    final query = _database.select(_database.cambridgeAssessmentTable)
      ..where((t) => t.testType.equals(dbType.name));
    final entries = await query.get();
    return entries.map(_entryToResult).toList();
  }

  @override
  Future<List<CambridgeAssessmentResult>> getAssessmentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final query = _database.select(_database.cambridgeAssessmentTable)
      ..where((t) => t.completedAt.isBiggerOrEqualValue(start) & t.completedAt.isSmallerOrEqualValue(end))
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)]);
    final entries = await query.get();
    return entries.map(_entryToResult).toList();
  }

  @override
  Future<CambridgeAssessmentResult?> getLatestAssessment() async {
    final query = _database.select(_database.cambridgeAssessmentTable)
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)])
      ..limit(1);
    final entries = await query.get();
    return entries.isEmpty ? null : _entryToResult(entries.first);
  }

  @override
  Future<CambridgeAssessmentResult?> getLatestAssessmentByType(CambridgeTestType type) async {
    final dbType = _convertTestType(type);
    final query = _database.select(_database.cambridgeAssessmentTable)
      ..where((t) => t.testType.equals(dbType.name))
      ..orderBy([(t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc)])
      ..limit(1);
    final entries = await query.get();
    return entries.isEmpty ? null : _entryToResult(entries.first);
  }

  @override
  Future<void> deleteAssessment(int id) async {
    await (_database.delete(_database.cambridgeAssessmentTable)
      ..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<bool> updateAssessment(CambridgeAssessmentResult assessment, int id) async {
    final dbTestType = _convertTestType(assessment.testType);

    final companion = database.CambridgeAssessmentTableCompanion.insert(
      testType: dbTestType,
      durationSeconds: assessment.durationSeconds,
      accuracy: assessment.accuracy,
      totalTrials: assessment.totalTrials,
      correctTrials: assessment.correctTrials,
      errorCount: assessment.errorCount,
      meanLatencyMs: assessment.meanLatencyMs,
      medianLatencyMs: assessment.medianLatencyMs,
      normScore: assessment.normScore,
      interpretation: assessment.interpretation,
      specificMetrics: jsonEncode(assessment.specificMetrics),
      completedAt: assessment.completedAt,
    );

    final result = await (_database.update(_database.cambridgeAssessmentTable)
      ..where((t) => t.id.equals(id))).write(companion);
    return result > 0;
  }

  /// Convert database entry to domain entity
  CambridgeAssessmentResult _entryToResult(database.CambridgeAssessmentEntry entry) {
    Map<String, dynamic> specificMetrics = {};
    try {
      specificMetrics = jsonDecode(entry.specificMetrics) as Map<String, dynamic>;
    } catch (e) {
      // If JSON decode fails, use empty map
      specificMetrics = {};
    }

    return CambridgeAssessmentResult(
      testType: _convertFromDbType(entry.testType),
      completedAt: entry.completedAt,
      durationSeconds: entry.durationSeconds,
      accuracy: entry.accuracy,
      totalTrials: entry.totalTrials,
      correctTrials: entry.correctTrials,
      errorCount: entry.errorCount,
      meanLatencyMs: entry.meanLatencyMs,
      medianLatencyMs: entry.medianLatencyMs,
      specificMetrics: specificMetrics,
      normScore: entry.normScore,
      interpretation: entry.interpretation,
    );
  }
}
