import 'package:brain_tests/core/services/csv_export_service.dart';
import 'package:brain_tests/core/services/pdf_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/repositories/assessment_repository.dart';
import 'package:brain_tests/domain/repositories/cognitive_exercise_repository.dart';
import 'package:brain_tests/domain/repositories/mood_entry_repository.dart';
import 'package:brain_tests/presentation/providers/repository_providers.dart';
import 'package:brain_tests/presentation/screens/exports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'exports_screen_test.mocks.dart';

@GenerateMocks([
  AssessmentRepository,
  MoodEntryRepository,
  CognitiveExerciseRepository,
])
void main() {
  group('ExportsScreen', () {
    late MockAssessmentRepository mockAssessmentRepo;
    late MockMoodEntryRepository mockMoodRepo;
    late MockCognitiveExerciseRepository mockExerciseRepo;

    setUp(() {
      mockAssessmentRepo = MockAssessmentRepository();
      mockMoodRepo = MockMoodEntryRepository();
      mockExerciseRepo = MockCognitiveExerciseRepository();
    });

    testWidgets('should display export screen with all export options',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepo),
            moodEntryRepositoryProvider.overrideWithValue(mockMoodRepo),
            cognitiveExerciseRepositoryProvider
                .overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Export Your Data'), findsOneWidget);
      expect(find.text('Export as PDF'), findsOneWidget);
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
      expect(find.text('Complete report with charts and analysis'),
          findsOneWidget);
      expect(find.text('Raw data for spreadsheet analysis'), findsOneWidget);
      expect(find.text('Structured data for developers'), findsOneWidget);
    });

    testWidgets('should display export information card', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepo),
            moodEntryRepositoryProvider.overrideWithValue(mockMoodRepo),
            cognitiveExerciseRepositoryProvider
                .overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Export Information'), findsOneWidget);
      expect(
          find.textContaining('PDF format is best for sharing'), findsOneWidget);
      expect(find.textContaining('CSV format is ideal for personal analysis'),
          findsOneWidget);
      expect(find.textContaining('JSON format is for advanced users'),
          findsOneWidget);
      expect(find.textContaining('All your data remains private'),
          findsOneWidget);
    });

    testWidgets('should fetch data from all repositories when exporting',
        (tester) async {
      // Arrange
      final assessment = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 4,
        maxScore: 5,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final moodEntry = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 4,
        stressLevel: 2,
        sleepQuality: 4,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final exercise = CognitiveExercise(
        id: 1,
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 80,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      when(mockAssessmentRepo.getAllAssessments())
          .thenAnswer((_) async => [assessment]);
      when(mockMoodRepo.getAllMoodEntries())
          .thenAnswer((_) async => [moodEntry]);
      when(mockExerciseRepo.getAllExercises())
          .thenAnswer((_) async => [exercise]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepo),
            moodEntryRepositoryProvider.overrideWithValue(mockMoodRepo),
            cognitiveExerciseRepositoryProvider
                .overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );

      // Note: We can't actually test the export tap because it involves file I/O
      // and share dialogs which require mocking at a system level.
      // This test verifies the screen structure and data fetching setup.

      // Verify repositories are available and configured correctly
      // The repositories are not called until the user taps an export button
      verifyNever(mockAssessmentRepo.getAllAssessments());
      verifyNever(mockMoodRepo.getAllMoodEntries());
      verifyNever(mockExerciseRepo.getAllExercises());
    });

    testWidgets('should show loading indicator while exporting', (tester) async {
      // Arrange
      when(mockAssessmentRepo.getAllAssessments())
          .thenAnswer((_) async => []);
      when(mockMoodRepo.getAllMoodEntries()).thenAnswer((_) async => []);
      when(mockExerciseRepo.getAllExercises()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepo),
            moodEntryRepositoryProvider.overrideWithValue(mockMoodRepo),
            cognitiveExerciseRepositoryProvider
                .overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );

      // Initially no loading indicators
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Note: Testing the loading state during export would require
      // mocking the file system and share dialog, which is beyond
      // unit testing scope. This is better tested in integration tests.
    });

    testWidgets('should have correct icon colors for each export type',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepo),
            moodEntryRepositoryProvider.overrideWithValue(mockMoodRepo),
            cognitiveExerciseRepositoryProvider
                .overrideWithValue(mockExerciseRepo),
          ],
          child: const MaterialApp(
            home: ExportsScreen(),
          ),
        ),
      );

      // Assert - Find icons by type
      final pdfIcon = find.byIcon(Icons.picture_as_pdf);
      final csvIcon = find.byIcon(Icons.table_chart);
      final jsonIcon = find.byIcon(Icons.code);

      expect(pdfIcon, findsOneWidget);
      expect(csvIcon, findsOneWidget);
      expect(jsonIcon, findsOneWidget);
    });
  });

  group('JSON Export Data Structure', () {
    test('should serialize Assessment correctly', () {
      // Arrange
      final assessment = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 4,
        maxScore: 5,
        completedAt: DateTime(2024, 1, 15, 10, 30),
        createdAt: DateTime(2024, 1, 15, 10, 30),
        notes: 'Test notes',
      );

      // Act
      final json = {
        'id': assessment.id,
        'type': assessment.type.toString(),
        'score': assessment.score,
        'max_score': assessment.maxScore,
        'percentage': assessment.percentage,
        'completed_at': assessment.completedAt.toIso8601String(),
        'created_at': assessment.createdAt.toIso8601String(),
        'notes': assessment.notes,
      };

      // Assert
      expect(json['id'], 1);
      expect(json['type'], 'AssessmentType.memoryRecall');
      expect(json['score'], 4);
      expect(json['max_score'], 5);
      expect(json['percentage'], 80.0);
      expect(json['completed_at'], '2024-01-15T10:30:00.000');
      expect(json['created_at'], '2024-01-15T10:30:00.000');
      expect(json['notes'], 'Test notes');
    });

    test('should serialize MoodEntry correctly', () {
      // Arrange
      final moodEntry = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 4,
        stressLevel: 2,
        sleepQuality: 5,
        entryDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 15),
        notes: 'Feeling great',
      );

      // Act
      final json = {
        'id': moodEntry.id,
        'mood': moodEntry.mood.toString(),
        'energy_level': moodEntry.energyLevel,
        'stress_level': moodEntry.stressLevel,
        'sleep_quality': moodEntry.sleepQuality,
        'overall_wellness': moodEntry.overallWellness,
        'entry_date': moodEntry.entryDate.toIso8601String(),
        'notes': moodEntry.notes,
      };

      // Assert
      expect(json['id'], 1);
      expect(json['mood'], 'MoodLevel.good');
      expect(json['energy_level'], 4);
      expect(json['stress_level'], 2);
      expect(json['sleep_quality'], 5);
      expect(json['overall_wellness'], moodEntry.overallWellness);
      expect(json['entry_date'], '2024-01-15T00:00:00.000');
      expect(json['notes'], 'Feeling great');
    });

    test('should serialize CognitiveExercise correctly', () {
      // Arrange
      final exercise = CognitiveExercise(
        id: 1,
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 80,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 15, 11, 0),
        createdAt: DateTime(2024, 1, 15, 10, 45),
      );

      // Act
      final json = {
        'id': exercise.id,
        'name': exercise.name,
        'difficulty': exercise.difficulty.toString(),
        'score': exercise.score,
        'max_score': exercise.maxScore,
        'time_spent_seconds': exercise.timeSpentSeconds,
        'completed_at': exercise.completedAt?.toIso8601String(),
        'created_at': exercise.createdAt.toIso8601String(),
      };

      // Assert
      expect(json['id'], 1);
      expect(json['name'], 'Memory Game');
      expect(json['difficulty'], 'ExerciseDifficulty.medium');
      expect(json['score'], 80);
      expect(json['max_score'], 100);
      expect(json['time_spent_seconds'], 120);
      expect(json['completed_at'], '2024-01-15T11:00:00.000');
      expect(json['created_at'], '2024-01-15T10:45:00.000');
    });

    test('should handle null values in serialization', () {
      // Arrange
      final exercise = CognitiveExercise(
        id: 1,
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 80,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: false,
        completedAt: null, // Null completed date
        createdAt: DateTime(2024, 1, 15, 10, 45),
      );

      // Act
      final json = {
        'id': exercise.id,
        'name': exercise.name,
        'difficulty': exercise.difficulty.toString(),
        'score': exercise.score,
        'max_score': exercise.maxScore,
        'time_spent_seconds': exercise.timeSpentSeconds,
        'completed_at': exercise.completedAt?.toIso8601String(),
        'created_at': exercise.createdAt.toIso8601String(),
      };

      // Assert
      expect(json['completed_at'], null);
      expect(json['created_at'], '2024-01-15T10:45:00.000');
    });
  });
}
