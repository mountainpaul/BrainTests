import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/assessment_repository_impl.dart';
import '../../data/repositories/cognitive_exercise_repository_impl.dart';
import '../../data/repositories/mood_entry_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/assessment_repository.dart';
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