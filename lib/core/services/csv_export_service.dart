import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/entities/cognitive_exercise.dart';
import '../../domain/entities/mood_entry.dart';

/// Service for exporting data to CSV format
class CSVExportService {
  /// Export assessments to CSV format
  static String exportAssessmentsToCSV(List<Assessment> assessments) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Time,Type,Score,Max Score,Percentage,Notes');

    // Data rows
    for (final assessment in assessments) {
      final date = _formatDate(assessment.completedAt);
      final time = _formatTime(assessment.completedAt);
      final type = _getAssessmentTypeString(assessment.type);
      final notes = _escapeCSVField(assessment.notes ?? '');

      buffer.writeln(
        '$date,$time,$type,${assessment.score},${assessment.maxScore},'
        '${assessment.percentage.toStringAsFixed(1)},$notes'
      );
    }

    return buffer.toString();
  }

  /// Export mood entries to CSV format
  static String exportMoodEntriesToCSV(List<MoodEntry> moodEntries) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Mood,Energy Level,Stress Level,Sleep Quality,Overall Wellness,Notes');

    // Data rows
    for (final entry in moodEntries) {
      final date = _formatDate(entry.entryDate);
      final mood = _getMoodLevelString(entry.mood);
      final wellness = entry.overallWellness.toStringAsFixed(1);
      final notes = _escapeCSVField(entry.notes ?? '');

      buffer.writeln(
        '$date,$mood,${entry.energyLevel},${entry.stressLevel},'
        '${entry.sleepQuality},$wellness,$notes'
      );
    }

    return buffer.toString();
  }

  /// Export cognitive exercises to CSV format
  static String exportExercisesToCSV(List<CognitiveExercise> exercises) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Time,Exercise Name,Difficulty,Score,Max Score,Percentage,Duration (seconds)');

    // Data rows
    for (final exercise in exercises) {
      if (exercise.completedAt != null) {
        final date = _formatDate(exercise.completedAt!);
        final time = _formatTime(exercise.completedAt!);
        final difficulty = _getDifficultyString(exercise.difficulty);
        final name = _escapeCSVField(exercise.name);
        final percentage = exercise.score != null && exercise.maxScore > 0
            ? (exercise.score! / exercise.maxScore * 100).toStringAsFixed(1)
            : '0.0';

        buffer.writeln(
          '$date,$time,$name,$difficulty,${exercise.score ?? 0},'
          '${exercise.maxScore},$percentage,${exercise.timeSpentSeconds ?? 0}'
        );
      }
    }

    return buffer.toString();
  }

  /// Save CSV content to device storage
  static Future<String> saveCSVToDevice({
    required String csvContent,
    required String filename,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename.csv');
    await file.writeAsString(csvContent);
    return file.path;
  }

  /// Export all data to a ZIP file containing multiple CSV files
  static Future<String> exportAllDataToCSV({
    required List<Assessment> assessments,
    required List<MoodEntry> moodEntries,
    required List<CognitiveExercise> exercises,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Export each type to separate CSV
    final assessmentCSV = exportAssessmentsToCSV(assessments);
    final moodCSV = exportMoodEntriesToCSV(moodEntries);
    final exerciseCSV = exportExercisesToCSV(exercises);

    // Save files
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports_$timestamp');
    await exportDir.create(recursive: true);

    await File('${exportDir.path}/assessments.csv').writeAsString(assessmentCSV);
    await File('${exportDir.path}/mood_entries.csv').writeAsString(moodCSV);
    await File('${exportDir.path}/exercises.csv').writeAsString(exerciseCSV);

    return exportDir.path;
  }

  // Helper methods

  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String _escapeCSVField(String field) {
    // If field contains comma, quote, or newline, wrap in quotes and escape quotes
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static String _getAssessmentTypeString(AssessmentType type) {
    switch (type) {
      case AssessmentType.memoryRecall:
        return 'Memory Recall';
      case AssessmentType.attentionFocus:
        return 'Attention Focus';
      case AssessmentType.executiveFunction:
        return 'Executive Function';
      case AssessmentType.languageSkills:
        return 'Language Skills';
      case AssessmentType.visuospatialSkills:
        return 'Visuospatial Skills';
      case AssessmentType.processingSpeed:
        return 'Processing Speed';
    }
  }

  static String _getMoodLevelString(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.excellent:
        return 'Excellent';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.low:
        return 'Low';
      case MoodLevel.veryLow:
        return 'Very Low';
    }
  }

  static String _getDifficultyString(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.easy:
        return 'Easy';
      case ExerciseDifficulty.medium:
        return 'Medium';
      case ExerciseDifficulty.hard:
        return 'Hard';
      case ExerciseDifficulty.expert:
        return 'Expert';
    }
  }
}
