import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comprehensive tests for all entity domain objects
///
/// This test suite ensures high coverage of:
/// - Assessment entity (percentage calculation, copyWith, equality)
/// - CognitiveExercise entity (percentage, formattedTime, copyWith, equality)
/// - Reminder entity (isPastDue, copyWith, equality)
/// - MoodEntry entity (copyWith, equality)
void main() {
  group('Assessment Entity Comprehensive Tests', () {
    test('should calculate percentage correctly for various scores', () {
      final assessment1 = Assessment(
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(assessment1.percentage, 80.0);

      final assessment2 = Assessment(
        type: AssessmentType.attentionFocus,
        score: 15,
        maxScore: 20,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(assessment2.percentage, 75.0);

      final assessment3 = Assessment(
        type: AssessmentType.executiveFunction,
        score: 0,
        maxScore: 50,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(assessment3.percentage, 0.0);

      final assessment4 = Assessment(
        type: AssessmentType.languageSkills,
        score: 10,
        maxScore: 10,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      expect(assessment4.percentage, 100.0);
    });

    test('should create copy with updated values', () {
      final original = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
        notes: 'Original notes',
      );

      final updated = original.copyWith(
        score: 90,
        notes: 'Updated notes',
      );

      expect(updated.id, 1);
      expect(updated.score, 90);
      expect(updated.notes, 'Updated notes');
      expect(updated.type, AssessmentType.memoryRecall);
      expect(updated.maxScore, 100);
    });

    test('should maintain equality with same properties', () {
      final date1 = DateTime.now();
      final date2 = date1;

      final assessment1 = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: date1,
        createdAt: date2,
      );

      final assessment2 = Assessment(
        id: 1,
        type: AssessmentType.memoryRecall,
        score: 80,
        maxScore: 100,
        completedAt: date1,
        createdAt: date2,
      );

      expect(assessment1, equals(assessment2));
    });

    test('should handle all assessment types', () {
      final types = [
        AssessmentType.memoryRecall,
        AssessmentType.attentionFocus,
        AssessmentType.executiveFunction,
        AssessmentType.languageSkills,
        AssessmentType.visuospatialSkills,
        AssessmentType.processingSpeed,
      ];

      for (final type in types) {
        final assessment = Assessment(
          type: type,
          score: 50,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        expect(assessment.type, type);
        expect(assessment.percentage, 50.0);
      }
    });
  });

  group('CognitiveExercise Entity Comprehensive Tests', () {
    test('should calculate percentage correctly when score is available', () {
      final exercise1 = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 8,
        maxScore: 10,
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      expect(exercise1.percentage, 80.0);

      final exercise2 = CognitiveExercise(
        name: 'Word Puzzle',
        type: ExerciseType.wordPuzzle,
        difficulty: ExerciseDifficulty.easy,
        score: 0,
        maxScore: 5,
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      expect(exercise2.percentage, 0.0);
    });

    test('should return null percentage when score is not available', () {
      final exercise = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        maxScore: 10,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      expect(exercise.percentage, isNull);
    });

    test('should format time correctly', () {
      final exercise1 = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        maxScore: 10,
        timeSpentSeconds: 125, // 2 minutes 5 seconds
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      expect(exercise1.formattedTime, '2m 5s');

      final exercise2 = CognitiveExercise(
        name: 'Math Problem',
        type: ExerciseType.mathProblem,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 5,
        timeSpentSeconds: 60, // Exactly 1 minute
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      expect(exercise2.formattedTime, '1m 0s');

      final exercise3 = CognitiveExercise(
        name: 'Pattern',
        type: ExerciseType.patternRecognition,
        difficulty: ExerciseDifficulty.hard,
        maxScore: 15,
        timeSpentSeconds: 45, // Under 1 minute
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      expect(exercise3.formattedTime, '0m 45s');

      final exercise4 = CognitiveExercise(
        name: 'No Time',
        type: ExerciseType.sequenceRecall,
        difficulty: ExerciseDifficulty.expert,
        maxScore: 20,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      expect(exercise4.formattedTime, '--');
    });

    test('should create proper copy with changes', () {
      final original = CognitiveExercise(
        id: 1,
        name: 'Word Puzzle',
        type: ExerciseType.wordPuzzle,
        difficulty: ExerciseDifficulty.medium,
        score: 7,
        maxScore: 10,
        timeSpentSeconds: 300,
        isCompleted: false,
        exerciseData: 'original data',
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = original.copyWith(
        score: 9,
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(copy.id, 1);
      expect(copy.name, 'Word Puzzle');
      expect(copy.score, 9);
      expect(copy.isCompleted, true);
      expect(copy.completedAt, isNotNull);
      expect(copy.type, ExerciseType.wordPuzzle);
    });

    test('should support all exercise types', () {
      final types = [
        ExerciseType.memoryGame,
        ExerciseType.wordPuzzle,
        ExerciseType.spanishAnagram,
        ExerciseType.mathProblem,
        ExerciseType.patternRecognition,
        ExerciseType.sequenceRecall,
        ExerciseType.spatialAwareness,
      ];

      for (final type in types) {
        final exercise = CognitiveExercise(
          name: 'Test Exercise',
          type: type,
          difficulty: ExerciseDifficulty.medium,
          score: 5,
          maxScore: 10,
          isCompleted: true,
          createdAt: DateTime.now(),
        );
        expect(exercise.type, type);
        expect(exercise.percentage, 50.0);
      }
    });

    test('should support all difficulty levels', () {
      final difficulties = [
        ExerciseDifficulty.easy,
        ExerciseDifficulty.medium,
        ExerciseDifficulty.hard,
        ExerciseDifficulty.expert,
      ];

      for (final difficulty in difficulties) {
        final exercise = CognitiveExercise(
          name: 'Test Exercise',
          type: ExerciseType.memoryGame,
          difficulty: difficulty,
          maxScore: 10,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        expect(exercise.difficulty, difficulty);
      }
    });
  });

  group('Reminder Entity Comprehensive Tests', () {
    test('should correctly identify past due reminders', () {
      final pastReminder = Reminder(
        title: 'Past Reminder',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(pastReminder.isPastDue, true);

      final futureReminder = Reminder(
        title: 'Future Reminder',
        type: ReminderType.exercise,
        frequency: ReminderFrequency.weekly,
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(futureReminder.isPastDue, false);
    });

    test('should create copy with updated values', () {
      final original = Reminder(
        id: 1,
        title: 'Original Title',
        description: 'Original description',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: DateTime(2024, 1, 1, 10, 0),
        isActive: true,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        updatedAt: DateTime.now(),
      );

      expect(updated.id, 1);
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, true);
      expect(updated.type, ReminderType.medication);
      expect(updated.description, 'Original description');
    });

    test('should maintain equality with same properties', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);

      final reminder1 = Reminder(
        id: 1,
        title: 'Test Reminder',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: date1,
        isActive: true,
        isCompleted: false,
        createdAt: date2,
        updatedAt: date2,
      );

      final reminder2 = Reminder(
        id: 1,
        title: 'Test Reminder',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: date1,
        isActive: true,
        isCompleted: false,
        createdAt: date2,
        updatedAt: date2,
      );

      expect(reminder1, equals(reminder2));
    });

    test('should support all reminder types', () {
      final types = [
        ReminderType.medication,
        ReminderType.exercise,
        ReminderType.assessment,
        ReminderType.appointment,
      ];

      for (final type in types) {
        final reminder = Reminder(
          title: 'Test Reminder',
          type: type,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now(),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(reminder.type, type);
      }
    });

    test('should support all frequencies', () {
      final frequencies = [
        ReminderFrequency.once,
        ReminderFrequency.daily,
        ReminderFrequency.weekly,
        ReminderFrequency.monthly,
      ];

      for (final frequency in frequencies) {
        final reminder = Reminder(
          title: 'Test Reminder',
          type: ReminderType.medication,
          frequency: frequency,
          scheduledAt: DateTime.now(),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(reminder.frequency, frequency);
      }
    });
  });

  group('MoodEntry Entity Comprehensive Tests', () {
    test('should create mood entry with all properties', () {
      final moodEntry = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        sleepQuality: 9,
        notes: 'Feeling great today',
        entryDate: DateTime(2024, 1, 1),
        createdAt: DateTime.now(),
      );

      expect(moodEntry.id, 1);
      expect(moodEntry.mood, MoodLevel.good);
      expect(moodEntry.energyLevel, 8);
      expect(moodEntry.stressLevel, 3);
      expect(moodEntry.sleepQuality, 9);
      expect(moodEntry.notes, 'Feeling great today');
    });

    test('should calculate overall wellness correctly', () {
      final moodEntry = MoodEntry(
        mood: MoodLevel.good, // Score: 8
        energyLevel: 7,
        stressLevel: 4, // Inverted: 11 - 4 = 7
        sleepQuality: 8,
        entryDate: DateTime(2024, 1, 1),
        createdAt: DateTime.now(),
      );

      // (8 + 7 + 7 + 8) / 4 = 30 / 4 = 7.5
      expect(moodEntry.overallWellness, 7.5);
    });

    test('should create copy with updated values', () {
      final original = MoodEntry(
        id: 1,
        mood: MoodLevel.neutral,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 5,
        entryDate: DateTime(2024, 1, 1),
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        notes: 'Much better now',
      );

      expect(updated.id, 1);
      expect(updated.mood, MoodLevel.good);
      expect(updated.energyLevel, 8);
      expect(updated.stressLevel, 3);
      expect(updated.sleepQuality, 5); // Unchanged
      expect(updated.notes, 'Much better now');
      expect(updated.entryDate, original.entryDate);
    });

    test('should maintain equality with same properties', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);

      final mood1 = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        sleepQuality: 9,
        entryDate: date1,
        createdAt: date2,
      );

      final mood2 = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        sleepQuality: 9,
        entryDate: date1,
        createdAt: date2,
      );

      expect(mood1, equals(mood2));
    });

    test('should support all mood levels', () {
      final levels = [
        MoodLevel.veryLow,
        MoodLevel.low,
        MoodLevel.neutral,
        MoodLevel.good,
        MoodLevel.excellent,
      ];

      for (final level in levels) {
        final mood = MoodEntry(
          mood: level,
          energyLevel: 5,
          stressLevel: 5,
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        expect(mood.mood, level);
      }
    });

    test('should calculate wellness with stress inversion correctly', () {
      // High stress should lower wellness
      final highStressMood = MoodEntry(
        mood: MoodLevel.good, // 8
        energyLevel: 8,
        stressLevel: 10, // Inverted: 11 - 10 = 1
        sleepQuality: 8,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      // (8 + 8 + 1 + 8) / 4 = 25 / 4 = 6.25
      expect(highStressMood.overallWellness, 6.25);

      // Low stress should raise wellness
      final lowStressMood = MoodEntry(
        mood: MoodLevel.good, // 8
        energyLevel: 8,
        stressLevel: 1, // Inverted: 11 - 1 = 10
        sleepQuality: 8,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      // (8 + 8 + 10 + 8) / 4 = 34 / 4 = 8.5
      expect(lowStressMood.overallWellness, 8.5);
    });

    test('should handle different mood level scores in wellness calculation', () {
      final veryLowMood = MoodEntry(
        mood: MoodLevel.veryLow, // 2
        energyLevel: 5,
        stressLevel: 5, // Inverted: 6
        sleepQuality: 5,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      // (2 + 5 + 6 + 5) / 4 = 18 / 4 = 4.5
      expect(veryLowMood.overallWellness, 4.5);

      final excellentMood = MoodEntry(
        mood: MoodLevel.excellent, // 10
        energyLevel: 10,
        stressLevel: 1, // Inverted: 10
        sleepQuality: 10,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      // (10 + 10 + 10 + 10) / 4 = 40 / 4 = 10.0
      expect(excellentMood.overallWellness, 10.0);
    });
  });
}
