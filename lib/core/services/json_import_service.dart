import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/entities/mood_entry.dart';

/// Service for importing data from JSON files
class JsonImportService {
  /// Validates if a file has valid JSON format
  static bool isValidJsonFile(String filename) {
    return filename.toLowerCase().endsWith('.json');
  }

  /// Parses and validates JSON data structure
  static Future<Map<String, dynamic>> parseJsonFile(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileSystemException('JSON file does not exist', filePath);
    }

    final contents = await file.readAsString();

    try {
      final data = jsonDecode(contents) as Map<String, dynamic>;

      // Validate required fields
      if (!data.containsKey('assessments') &&
          !data.containsKey('mood_entries') &&
          !data.containsKey('exercises')) {
        throw FormatException('Invalid JSON format: missing data fields');
      }

      return data;
    } catch (e) {
      throw FormatException('Invalid JSON format: ${e.toString()}');
    }
  }

  /// Imports assessments from JSON data
  static Future<int> importAssessments(
    AppDatabase database,
    List<dynamic> assessmentsData,
  ) async {
    int imported = 0;

    for (final item in assessmentsData) {
      try {
        final assessmentMap = item as Map<String, dynamic>;

        // Parse assessment type
        final typeString = assessmentMap['type'] as String;
        final type = AssessmentType.values.firstWhere(
          (e) => e.toString() == typeString,
          orElse: () => throw FormatException('Invalid assessment type: $typeString'),
        );

        final notesValue = assessmentMap['notes'] as String?;
        final assessment = AssessmentTableCompanion.insert(
          type: type,
          score: assessmentMap['score'] as int,
          maxScore: assessmentMap['max_score'] as int,
          completedAt: DateTime.parse(assessmentMap['completed_at'] as String),
          notes: notesValue != null ? Value(notesValue) : const Value.absent(),
        );

        await database.into(database.assessmentTable).insert(assessment);
        imported++;
      } catch (e) {
        print('Error importing assessment: $e');
      }
    }

    return imported;
  }

  /// Imports mood entries from JSON data
  static Future<int> importMoodEntries(
    AppDatabase database,
    List<dynamic> moodEntriesData,
  ) async {
    // Mood tracking feature removed - skip import
    return 0;
  }

  /// Imports exercises from JSON data
  static Future<int> importExercises(
    AppDatabase database,
    List<dynamic> exercisesData,
  ) async {
    int imported = 0;

    for (final item in exercisesData) {
      try {
        final exerciseMap = item as Map<String, dynamic>;

        // Parse difficulty
        final difficultyString = exerciseMap['difficulty'] as String;
        final difficulty = ExerciseDifficulty.values.firstWhere(
          (e) => e.toString() == difficultyString,
          orElse: () => throw FormatException('Invalid difficulty: $difficultyString'),
        );

        final scoreValue = exerciseMap['score'] as int?;
        final timeValue = exerciseMap['time_spent_seconds'] as int?;
        final completedAtValue = exerciseMap['completed_at'] as String?;

        final exercise = CognitiveExerciseTableCompanion.insert(
          name: exerciseMap['name'] as String,
          type: ExerciseType.memoryGame, // Default type
          difficulty: difficulty,
          maxScore: exerciseMap['max_score'] as int,
          score: scoreValue != null ? Value(scoreValue) : const Value.absent(),
          timeSpentSeconds: timeValue != null ? Value(timeValue) : const Value.absent(),
          completedAt: completedAtValue != null
              ? Value(DateTime.parse(completedAtValue))
              : const Value.absent(),
        );

        await database.into(database.cognitiveExerciseTable).insert(exercise);
        imported++;
      } catch (e) {
        print('Error importing exercise: $e');
      }
    }

    return imported;
  }

  /// Imports all data from JSON file
  static Future<Map<String, dynamic>> importFromJson({
    required AppDatabase database,
    required String jsonPath,
    bool clearExisting = false,
  }) async {
    try {
      // Validate file format
      if (!isValidJsonFile(jsonPath)) {
        throw ArgumentError('Invalid file format. Only .json files are allowed.');
      }

      // Parse JSON file
      final data = await parseJsonFile(jsonPath);

      int assessmentsImported = 0;
      int moodEntriesImported = 0;
      int exercisesImported = 0;

      // Optionally clear existing data
      if (clearExisting) {
        await database.delete(database.assessmentTable).go();
        await database.delete(database.cognitiveExerciseTable).go();
      }

      // Import assessments
      if (data.containsKey('assessments')) {
        assessmentsImported = await importAssessments(
          database,
          data['assessments'] as List<dynamic>,
        );
      }

      // Import mood entries
      if (data.containsKey('mood_entries')) {
        moodEntriesImported = await importMoodEntries(
          database,
          data['mood_entries'] as List<dynamic>,
        );
      }

      // Import exercises
      if (data.containsKey('exercises')) {
        exercisesImported = await importExercises(
          database,
          data['exercises'] as List<dynamic>,
        );
      }

      return {
        'success': true,
        'assessments_imported': assessmentsImported,
        'mood_entries_imported': moodEntriesImported,
        'exercises_imported': exercisesImported,
        'total_imported': assessmentsImported + moodEntriesImported + exercisesImported,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
