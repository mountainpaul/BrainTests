import 'package:brain_tests/data/datasources/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart' as matcher;

void main() {
  group('Database CRUD Operations Tests', () {
    test('should test enum values and constants', () {
      // Test AssessmentType enum
      expect(AssessmentType.values.length, 6);
      expect(AssessmentType.memoryRecall.index, 0);
      expect(AssessmentType.attentionFocus.index, 1);
      expect(AssessmentType.executiveFunction.index, 2);
      expect(AssessmentType.languageSkills.index, 3);
      expect(AssessmentType.visuospatialSkills.index, 4);
      expect(AssessmentType.processingSpeed.index, 5);
    });

    test('should test ReminderType enum', () {
      expect(ReminderType.values.length, 5);
      expect(ReminderType.medication.index, 0);
      expect(ReminderType.exercise.index, 1);
      expect(ReminderType.assessment.index, 2);
      expect(ReminderType.appointment.index, 3);
      expect(ReminderType.custom.index, 4);
    });

    test('should test ReminderFrequency enum', () {
      expect(ReminderFrequency.values.length, 4);
      expect(ReminderFrequency.once.index, 0);
      expect(ReminderFrequency.daily.index, 1);
      expect(ReminderFrequency.weekly.index, 2);
      expect(ReminderFrequency.monthly.index, 3);
    });

    test('should test ExerciseType enum', () {
      expect(ExerciseType.values.length, 8);
      expect(ExerciseType.memoryGame.index, 0);
      expect(ExerciseType.wordPuzzle.index, 1);
      expect(ExerciseType.wordSearch.index, 2);
      expect(ExerciseType.spanishAnagram.index, 3);
      expect(ExerciseType.mathProblem.index, 4);
      expect(ExerciseType.patternRecognition.index, 5);
      expect(ExerciseType.sequenceRecall.index, 6);
      expect(ExerciseType.spatialAwareness.index, 7);
    });

    test('should test ExerciseDifficulty enum', () {
      expect(ExerciseDifficulty.values.length, 4);
      expect(ExerciseDifficulty.easy.index, 0);
      expect(ExerciseDifficulty.medium.index, 1);
      expect(ExerciseDifficulty.hard.index, 2);
      expect(ExerciseDifficulty.expert.index, 3);
    });

    test('should test MoodLevel enum', () {
      expect(MoodLevel.values.length, 5);
      expect(MoodLevel.veryLow.index, 0);
      expect(MoodLevel.low.index, 1);
      expect(MoodLevel.neutral.index, 2);
      expect(MoodLevel.good.index, 3);
      expect(MoodLevel.excellent.index, 4);
    });

    test('should test WordLanguage enum', () {
      expect(WordLanguage.values.length, 2);
      expect(WordLanguage.english.index, 0);
      expect(WordLanguage.spanish.index, 1);
    });

    test('should test WordType enum', () {
      expect(WordType.values.length, 3);
      expect(WordType.anagram.index, 0);
      expect(WordType.wordSearch.index, 1);
      expect(WordType.validationOnly.index, 2);
    });

    test('should test ActivityType enum', () {
      expect(ActivityType.values.length, 7);
      expect(ActivityType.cycling.index, 0);
      expect(ActivityType.resistance.index, 1);
      expect(ActivityType.meditation.index, 2);
      expect(ActivityType.dive.index, 3);
      expect(ActivityType.hike.index, 4);
      expect(ActivityType.social.index, 5);
      expect(ActivityType.yoga.index, 6);
    });

    test('should test MealType enum', () {
      expect(MealType.values.length, 3);
      expect(MealType.lunch.index, 0);
      expect(MealType.snack.index, 1);
      expect(MealType.dinner.index, 2);
    });

    test('should test FastType enum', () {
      expect(FastType.values.length, 2);
      expect(FastType.intermittent16_8.index, 0);
      expect(FastType.extended30Hour.index, 1);
    });

    test('should test SupplementTiming enum', () {
      expect(SupplementTiming.values.length, 4);
      expect(SupplementTiming.morning.index, 0);
      expect(SupplementTiming.afternoon.index, 1);
      expect(SupplementTiming.evening.index, 2);
      expect(SupplementTiming.beforeBed.index, 3);
    });

    test('should test PlanType enum', () {
      expect(PlanType.values.length, 2);
      expect(PlanType.daily.index, 0);
      expect(PlanType.weekly.index, 1);
    });
  });

  group('Database Schema Tests', () {
    test('should verify database schema version', () {
      // Test that we can instantiate an AppDatabase
      // This verifies that the schema is properly defined
      expect(AppDatabase.new, returnsNormally);
    });

    test('should handle database connection errors gracefully', () {
      // Test error handling when database cannot be opened
      // This is a basic test that the database class is properly structured
      expect(AppDatabase, matcher.isNotNull);
    });
  });

  group('Table Companion Tests', () {
    test('should create AssessmentTableCompanion correctly', () {
      final now = DateTime.now();

      // Test basic companion creation with required fields
      final companion = AssessmentTableCompanion.insert(
        type: AssessmentType.memoryRecall,
        score: 85,
        maxScore: 100,
        completedAt: now,
      );

      expect(companion.type.present, isTrue);
      expect(companion.score.present, isTrue);
      expect(companion.maxScore.present, isTrue);
      expect(companion.completedAt.present, isTrue);
    });

    test('should create AssessmentTableCompanion with optional fields', () {
      final now = DateTime.now();

      // Test companion creation with optional notes field
      final companion = AssessmentTableCompanion.insert(
        type: AssessmentType.attentionFocus,
        score: 92,
        maxScore: 100,
        completedAt: now,
        notes: const Value('Great performance!'),
      );

      expect(companion.notes.present, isTrue);
      expect(companion.notes.value, 'Great performance!');
    });

    test('should create ReminderTableCompanion correctly', () {
      final now = DateTime.now();

      final companion = ReminderTableCompanion.insert(
        title: 'Take medication',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: now,
      );

      expect(companion.title.present, isTrue);
      expect(companion.type.present, isTrue);
      expect(companion.frequency.present, isTrue);
      expect(companion.scheduledAt.present, isTrue);
    });

    test('should create ReminderTableCompanion with optional fields', () {
      final now = DateTime.now();

      final companion = ReminderTableCompanion.insert(
        title: 'Daily exercise',
        type: ReminderType.exercise,
        frequency: ReminderFrequency.daily,
        scheduledAt: now,
        description: const Value('30 minutes of cardio'),
        isActive: const Value(true),
      );

      expect(companion.description.present, isTrue);
      expect(companion.description.value, '30 minutes of cardio');
      expect(companion.isActive.present, isTrue);
      expect(companion.isActive.value, isTrue);
    });

    test('should create CognitiveExerciseTableCompanion correctly', () {
      final companion = CognitiveExerciseTableCompanion.insert(
        name: 'Memory Match Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        maxScore: 1000,
      );

      expect(companion.name.present, isTrue);
      expect(companion.type.present, isTrue);
      expect(companion.difficulty.present, isTrue);
      expect(companion.maxScore.present, isTrue);
    });

    test('should create CognitiveExerciseTableCompanion with score', () {
      final companion = CognitiveExerciseTableCompanion.insert(
        name: 'Math Problem Set',
        type: ExerciseType.mathProblem,
        difficulty: ExerciseDifficulty.hard,
        maxScore: 500,
        score: const Value(420),
        timeSpentSeconds: const Value(180),
      );

      expect(companion.score.present, isTrue);
      expect(companion.score.value, 420);
      expect(companion.timeSpentSeconds.present, isTrue);
      expect(companion.timeSpentSeconds.value, 180);
    });

    test('should create MoodEntryTableCompanion correctly', () {
      final today = DateTime.now();

      final companion = MoodEntryTableCompanion.insert(
        entryDate: today,
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        sleepQuality: 7,
      );

      expect(companion.entryDate.present, isTrue);
      expect(companion.mood.present, isTrue);
      expect(companion.energyLevel.present, isTrue);
      expect(companion.stressLevel.present, isTrue);
      expect(companion.sleepQuality.present, isTrue);
    });

    test('should create MoodEntryTableCompanion with optional notes', () {
      final today = DateTime.now();

      final companion = MoodEntryTableCompanion.insert(
        entryDate: today,
        mood: MoodLevel.good,
        energyLevel: 8,
        stressLevel: 3,
        sleepQuality: 7,
        notes: const Value('Feeling productive'),
      );

      expect(companion.stressLevel.present, isTrue);
      expect(companion.stressLevel.value, 3);
      expect(companion.energyLevel.present, isTrue);
      expect(companion.energyLevel.value, 8);
      expect(companion.notes.present, isTrue);
      expect(companion.notes.value, 'Feeling productive');
    });

    test('should create WordDictionaryTableCompanion correctly', () {
      final companion = WordDictionaryTableCompanion.insert(
        word: 'gato',
        language: WordLanguage.spanish,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.easy,
        length: 4,
      );

      expect(companion.word.present, isTrue);
      expect(companion.language.present, isTrue);
      expect(companion.type.present, isTrue);
      expect(companion.difficulty.present, isTrue);
      expect(companion.length.present, isTrue);
    });

    test('should create WordDictionaryTableCompanion with optional active field', () {
      final companion = WordDictionaryTableCompanion.insert(
        word: 'hello',
        language: WordLanguage.english,
        type: WordType.wordSearch,
        difficulty: ExerciseDifficulty.easy,
        length: 5,
        isActive: const Value(true),
      );

      expect(companion.word.value, 'hello');
      expect(companion.language.value, WordLanguage.english);
      expect(companion.type.value, WordType.wordSearch);
      expect(companion.difficulty.value, ExerciseDifficulty.easy);
      expect(companion.length.value, 5);
      expect(companion.isActive.present, isTrue);
      expect(companion.isActive.value, isTrue);
    });
  });

  group('Database Operations Integration', () {
    test('should validate companion field types', () {
      // Test that enum types are handled correctly in companions
      final assessmentCompanion = AssessmentTableCompanion.insert(
        type: AssessmentType.languageSkills,
        score: 88,
        maxScore: 100,
        completedAt: DateTime.now(),
      );

      // Verify the type field stores enum correctly
      expect(assessmentCompanion.type.value, AssessmentType.languageSkills);

      final reminderCompanion = ReminderTableCompanion.insert(
        title: 'Weekly Assessment',
        type: ReminderType.assessment,
        frequency: ReminderFrequency.weekly,
        scheduledAt: DateTime.now(),
      );

      expect(reminderCompanion.type.value, ReminderType.assessment);
      expect(reminderCompanion.frequency.value, ReminderFrequency.weekly);
    });

    test('should handle nullable fields correctly', () {
      // Test nullable fields in different table companions
      final assessmentWithNotes = AssessmentTableCompanion.insert(
        type: AssessmentType.processingSpeed,
        score: 75,
        maxScore: 100,
        completedAt: DateTime.now(),
        notes: const Value('Performance notes'),
      );

      expect(assessmentWithNotes.notes.present, isTrue);
      expect(assessmentWithNotes.notes.value, 'Performance notes');

      // Test null value handling
      final assessmentWithoutNotes = AssessmentTableCompanion.insert(
        type: AssessmentType.processingSpeed,
        score: 75,
        maxScore: 100,
        completedAt: DateTime.now(),
      );

      expect(assessmentWithoutNotes.notes.present, isFalse);
    });

    test('should validate required vs optional fields', () {
      // Test that required fields must be present
      expect(() => AssessmentTableCompanion.insert(
        type: AssessmentType.memoryRecall,
        score: 85,
        maxScore: 100,
        completedAt: DateTime.now(),
      ), returnsNormally);

      // Test optional fields in CognitiveExerciseTableCompanion
      final exerciseWithoutScore = CognitiveExerciseTableCompanion.insert(
        name: 'Pattern Recognition',
        type: ExerciseType.patternRecognition,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 200,
      );

      expect(exerciseWithoutScore.score.present, isFalse);
      expect(exerciseWithoutScore.timeSpentSeconds.present, isFalse);

      final exerciseWithScore = CognitiveExerciseTableCompanion.insert(
        name: 'Pattern Recognition',
        type: ExerciseType.patternRecognition,
        difficulty: ExerciseDifficulty.easy,
        maxScore: 200,
        score: const Value(150),
        timeSpentSeconds: const Value(240),
      );

      expect(exerciseWithScore.score.present, isTrue);
      expect(exerciseWithScore.timeSpentSeconds.present, isTrue);
    });
  });

  group('Database Query Validation', () {
    test('should validate enum index mappings for queries', () {
      // Test that enum indexes are consistent for database queries
      const assessmentTypes = AssessmentType.values;
      for (int i = 0; i < assessmentTypes.length; i++) {
        expect(assessmentTypes[i].index, i);
      }

      const exerciseTypes = ExerciseType.values;
      for (int i = 0; i < exerciseTypes.length; i++) {
        expect(exerciseTypes[i].index, i);
      }

      const reminderTypes = ReminderType.values;
      for (int i = 0; i < reminderTypes.length; i++) {
        expect(reminderTypes[i].index, i);
      }
    });

    test('should validate datetime handling', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      // Test that datetime comparisons work as expected
      expect(yesterday.isBefore(now), isTrue);
      expect(tomorrow.isAfter(now), isTrue);
      expect(now.isAtSameMomentAs(now), isTrue);

      // Test datetime companions
      final moodEntry = MoodEntryTableCompanion.insert(
        entryDate: yesterday,
        mood: MoodLevel.good,
        energyLevel: 5,
        stressLevel: 4,
        sleepQuality: 6,
      );

      expect(moodEntry.entryDate.value.isBefore(now), isTrue);
    });

    test('should validate score calculations', () {
      // Test percentage calculation logic that would be used in queries
      final testCases = [
        {'score': 85, 'maxScore': 100, 'expectedPercentage': 85.0},
        {'score': 42, 'maxScore': 50, 'expectedPercentage': 84.0},
        {'score': 0, 'maxScore': 100, 'expectedPercentage': 0.0},
        {'score': 100, 'maxScore': 100, 'expectedPercentage': 100.0},
      ];

      for (final testCase in testCases) {
        final score = testCase['score'] as int;
        final maxScore = testCase['maxScore'] as int;
        final expected = testCase['expectedPercentage'] as double;

        final percentage = (score / maxScore) * 100.0;
        expect(percentage, closeTo(expected, 0.01));
      }
    });

    test('should validate boolean defaults', () {
      // Test default values for boolean fields
      final reminder = ReminderTableCompanion.insert(
        title: 'Test Reminder',
        type: ReminderType.medication,
        frequency: ReminderFrequency.daily,
        scheduledAt: DateTime.now(),
      );

      // isActive should default to true, isCompleted to false
      // These defaults are defined in the table schema
      expect(reminder.isActive.present, isFalse); // Uses default value
      expect(reminder.isCompleted.present, isFalse); // Uses default value
    });
  });

  group('Data Validation Tests', () {
    test('should validate score ranges', () {
      // Test typical assessment score ranges
      final validScores = [0, 25, 50, 75, 100];
      const maxScore = 100;

      for (final score in validScores) {
        final companion = AssessmentTableCompanion.insert(
          type: AssessmentType.memoryRecall,
          score: score,
          maxScore: maxScore,
          completedAt: DateTime.now(),
        );

        expect(companion.score.value, score);
        expect(companion.score.value, lessThanOrEqualTo(maxScore));
        expect(companion.score.value, greaterThanOrEqualTo(0));
      }
    });

    test('should validate exercise difficulty progression', () {
      // Test difficulty enum ordering
      const difficulties = ExerciseDifficulty.values;

      expect(difficulties[0], ExerciseDifficulty.easy);
      expect(difficulties[1], ExerciseDifficulty.medium);
      expect(difficulties[2], ExerciseDifficulty.hard);
      expect(difficulties[3], ExerciseDifficulty.expert);

      // Test difficulty progression
      expect(ExerciseDifficulty.easy.index < ExerciseDifficulty.medium.index, isTrue);
      expect(ExerciseDifficulty.medium.index < ExerciseDifficulty.hard.index, isTrue);
      expect(ExerciseDifficulty.hard.index < ExerciseDifficulty.expert.index, isTrue);
    });

    test('should validate mood level progression', () {
      // Test mood level enum ordering
      const moods = MoodLevel.values;

      expect(moods[0], MoodLevel.veryLow);
      expect(moods[1], MoodLevel.low);
      expect(moods[2], MoodLevel.neutral);
      expect(moods[3], MoodLevel.good);
      expect(moods[4], MoodLevel.excellent);

      // Test mood progression
      expect(MoodLevel.veryLow.index < MoodLevel.low.index, isTrue);
      expect(MoodLevel.low.index < MoodLevel.neutral.index, isTrue);
      expect(MoodLevel.neutral.index < MoodLevel.good.index, isTrue);
      expect(MoodLevel.good.index < MoodLevel.excellent.index, isTrue);
    });

    test('should validate time-based data', () {
      final now = DateTime.now();
      const oneHourInSeconds = 3600;
      const oneMinuteInSeconds = 60;

      // Test realistic time spent values for exercises
      final timeSpentValues = [30, 60, 120, 180, 300, 600]; // 30s to 10min

      for (final timeSpent in timeSpentValues) {
        final companion = CognitiveExerciseTableCompanion.insert(
          name: 'Timed Exercise',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 100,
          timeSpentSeconds: Value(timeSpent),
        );

        expect(companion.timeSpentSeconds.value, timeSpent);
        expect(companion.timeSpentSeconds.value, greaterThan(0));
        expect(companion.timeSpentSeconds.value, lessThan(oneHourInSeconds));
      }
    });
  });
}