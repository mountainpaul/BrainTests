import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../lib/core/services/csv_export_service.dart';
import '../../../../lib/data/datasources/database.dart';
import '../../../../lib/domain/entities/assessment.dart';
import '../../../../lib/domain/entities/cognitive_exercise.dart';
import '../../../../lib/domain/entities/mood_entry.dart';
import '../../../helpers/mock_path_provider.dart';

void main() {
  late MockPathProviderPlatform mockPathProvider;

  setUp(() {
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;
  });

  group('CSV Export Service', () {
    test('should export assessments to CSV format', () async {
      final assessments = [
        Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime(2024, 1, 15, 10, 30),
          createdAt: DateTime(2024, 1, 15, 10, 0),
          notes: 'Good performance',
        ),
        Assessment(
          id: 2,
          type: AssessmentType.attentionFocus,
          score: 7,
          maxScore: 10,
          completedAt: DateTime(2024, 1, 16, 14, 20),
          createdAt: DateTime(2024, 1, 16, 14, 0),
          notes: 'Average',
        ),
      ];

      final csvContent = CSVExportService.exportAssessmentsToCSV(assessments);

      expect(csvContent, contains('Date,Time,Type,Score,Max Score,Percentage,Notes'));
      expect(csvContent, contains('2024-01-15,10:30,Memory Recall,8,10,80.0,Good performance'));
      expect(csvContent, contains('2024-01-16,14:20,Attention Focus,7,10,70.0,Average'));
    });

    test('should export mood entries to CSV format', () async {
      final moodEntries = [
        MoodEntry(
          id: 1,
          entryDate: DateTime(2024, 1, 15),
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 3,
          sleepQuality: 8,
          createdAt: DateTime(2024, 1, 15, 8, 0),
          notes: 'Feeling great',
        ),
        MoodEntry(
          id: 2,
          entryDate: DateTime(2024, 1, 16),
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 6,
          sleepQuality: 6,
          createdAt: DateTime(2024, 1, 16, 8, 0),
          notes: 'Tired',
        ),
      ];

      final csvContent = CSVExportService.exportMoodEntriesToCSV(moodEntries);

      expect(csvContent, contains('Date,Mood,Energy Level,Stress Level,Sleep Quality,Overall Wellness,Notes'));
      expect(csvContent, contains('2024-01-15,Good,7,3,8,'));
      expect(csvContent, contains(',Feeling great'));
      expect(csvContent, contains('2024-01-16,Neutral,5,6,6,'));
      expect(csvContent, contains(',Tired'));
    });

    test('should export cognitive exercises to CSV format', () async {
      final exercises = [
        CognitiveExercise(
          id: 1,
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          score: 9,
          maxScore: 10,
          completedAt: DateTime(2024, 1, 15, 11, 0),
          createdAt: DateTime(2024, 1, 15, 10, 30),
          timeSpentSeconds: 180,
          isCompleted: true,
        ),
        CognitiveExercise(
          id: 2,
          name: 'Math Challenge',
          type: ExerciseType.mathProblem,
          difficulty: ExerciseDifficulty.hard,
          score: 6,
          maxScore: 10,
          completedAt: DateTime(2024, 1, 16, 15, 30),
          createdAt: DateTime(2024, 1, 16, 15, 0),
          timeSpentSeconds: 240,
          isCompleted: true,
        ),
      ];

      final csvContent = CSVExportService.exportExercisesToCSV(exercises);

      expect(csvContent, contains('Date,Time,Exercise Name,Difficulty,Score,Max Score,Percentage,Duration (seconds)'));
      expect(csvContent, contains('2024-01-15,11:00,Memory Game,Medium,9,10,90.0,180'));
      expect(csvContent, contains('2024-01-16,15:30,Math Challenge,Hard,6,10,60.0,240'));
    });

    test('should save CSV file to device', () async {
      final csvContent = 'Date,Score\n2024-01-15,85\n2024-01-16,92';

      final filePath = await CSVExportService.saveCSVToDevice(
        csvContent: csvContent,
        filename: 'test_export',
      );

      expect(filePath, isNotNull);
      expect(filePath, contains('test_export'));
      expect(filePath, endsWith('.csv'));

      // Verify file exists
      final file = File(filePath);
      expect(await file.exists(), isTrue);

      // Verify content
      final content = await file.readAsString();
      expect(content, equals(csvContent));
    });

    test('should handle empty assessment list', () {
      final csvContent = CSVExportService.exportAssessmentsToCSV([]);

      expect(csvContent, equals('Date,Time,Type,Score,Max Score,Percentage,Notes\n'));
    });

    test('should handle empty mood entries list', () {
      final csvContent = CSVExportService.exportMoodEntriesToCSV([]);

      expect(csvContent, equals('Date,Mood,Energy Level,Stress Level,Sleep Quality,Overall Wellness,Notes\n'));
    });

    test('should handle empty exercises list', () {
      final csvContent = CSVExportService.exportExercisesToCSV([]);

      expect(csvContent, equals('Date,Time,Exercise Name,Difficulty,Score,Max Score,Percentage,Duration (seconds)\n'));
    });

    test('should escape commas in notes field', () {
      final assessments = [
        Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime(2024, 1, 15, 10, 30),
          createdAt: DateTime(2024, 1, 15, 10, 0),
          notes: 'Good, but could improve',
        ),
      ];

      final csvContent = CSVExportService.exportAssessmentsToCSV(assessments);

      expect(csvContent, contains('"Good, but could improve"'));
    });

    test('should escape quotes in notes field', () {
      final moodEntries = [
        MoodEntry(
          id: 1,
          entryDate: DateTime(2024, 1, 15),
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 3,
          sleepQuality: 8,
          createdAt: DateTime(2024, 1, 15, 8, 0),
          notes: 'Feeling "great" today',
        ),
      ];

      final csvContent = CSVExportService.exportMoodEntriesToCSV(moodEntries);

      expect(csvContent, contains('"Feeling ""great"" today"'));
    });
  });
}
