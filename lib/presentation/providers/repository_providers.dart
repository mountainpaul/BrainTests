import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/database_export_service.dart';
import '../../data/repositories/assessment_repository_impl.dart';
import '../../data/repositories/cambridge_assessment_repository_impl.dart';
import '../../data/repositories/cognitive_exercise_repository_impl.dart';
import '../../data/repositories/mood_entry_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/repositories/cambridge_assessment_repository.dart';
import '../../domain/repositories/cognitive_exercise_repository.dart';
import '../../domain/repositories/mood_entry_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import 'database_provider.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final database = ref.read(databaseProvider);
  return AssessmentRepositoryImpl(database);
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final database = ref.read(databaseProvider);
  return ReminderRepositoryImpl(database);
});

final cognitiveExerciseRepositoryProvider = Provider<CognitiveExerciseRepository>((ref) {
  final database = ref.read(databaseProvider);
  return CognitiveExerciseRepositoryImpl(database);
});

final moodEntryRepositoryProvider = Provider<MoodEntryRepository>((ref) {
  final database = ref.read(databaseProvider);
  return MoodEntryRepositoryImpl(database);
});

final cambridgeAssessmentRepositoryProvider = Provider<CambridgeAssessmentRepository>((ref) {
  final database = ref.read(databaseProvider);
  return CambridgeAssessmentRepositoryImpl(database);
});

// Database export service provider
final databaseExportServiceProvider = Provider<DatabaseExportService>((ref) {
  return DatabaseExportService();
});

// Provider for database info
final databaseInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await DatabaseExportService.getDatabaseInfo();
});

// Provider for exporting database
final exportDatabaseProvider = FutureProvider.family<String, void>((ref, _) async {
  final database = ref.read(databaseProvider);
  return await DatabaseExportService.exportAndShareDatabase(database: database);
});