import 'package:brain_plan/data/datasources/database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_database.dart';

/// Comprehensive tests for database.dart to improve coverage
///
/// This file tests:
/// - Database initialization and table creation
/// - Enum definitions and usage
/// - Schema validation
/// - Table structure verification
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Database Initialization', () {
    test('should create database with all tables', () async {
      // Verify all tables are accessible
      expect(database.assessmentTable, isNotNull);
      expect(database.reminderTable, isNotNull);
      expect(database.cognitiveExerciseTable, isNotNull);
      expect(database.moodEntryTable, isNotNull);
      expect(database.dailyTrackingTable, isNotNull);
      expect(database.sleepTrackingTable, isNotNull);
      expect(database.cyclingTrackingTable, isNotNull);
      expect(database.wordDictionaryTable, isNotNull);
      expect(database.userProfileTable, isNotNull);
      expect(database.cambridgeAssessmentTable, isNotNull);
      expect(database.mealPlanTable, isNotNull);
      expect(database.feedingWindowTable, isNotNull);
      expect(database.fastingTable, isNotNull);
      expect(database.supplementsTable, isNotNull);
      expect(database.supplementLogsTable, isNotNull);
      expect(database.planningTable, isNotNull);
      expect(database.journalTable, isNotNull);
    });

    test('should have correct schema version', () {
      expect(database.schemaVersion, 8);
    });

    test('should create memory database successfully', () {
      final memDb = AppDatabase.memory();
      expect(memDb, isNotNull);
      expect(memDb.schemaVersion, 8);
      memDb.close();
    });
  });

  group('Assessment Table and Enums', () {
    test('should insert and retrieve assessment with all AssessmentType values', () async {
      final types = [
        AssessmentType.memoryRecall,
        AssessmentType.attentionFocus,
        AssessmentType.executiveFunction,
        AssessmentType.languageSkills,
        AssessmentType.visuospatialSkills,
        AssessmentType.processingSpeed,
      ];

      for (final type in types) {
        final id = await database.into(database.assessmentTable).insert(
          AssessmentTableCompanion.insert(
            type: type,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final assessments = await database.select(database.assessmentTable).get();
      expect(assessments.length, types.length);

      // Verify all types were stored correctly
      final retrievedTypes = assessments.map((a) => a.type).toSet();
      expect(retrievedTypes, containsAll(types));
    });
  });

  group('Reminder Table and Enums', () {
    test('should insert and retrieve reminders with all ReminderType values', () async {
      final types = [
        ReminderType.medication,
        ReminderType.exercise,
        ReminderType.assessment,
        ReminderType.appointment,
        ReminderType.custom,
      ];

      for (final type in types) {
        final id = await database.into(database.reminderTable).insert(
          ReminderTableCompanion.insert(
            title: 'Test Reminder',
            type: type,
            frequency: ReminderFrequency.once,
            scheduledAt: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final reminders = await database.select(database.reminderTable).get();
      expect(reminders.length, types.length);
    });

    test('should handle all ReminderFrequency values', () async {
      final frequencies = [
        ReminderFrequency.once,
        ReminderFrequency.daily,
        ReminderFrequency.weekly,
        ReminderFrequency.monthly,
      ];

      for (final freq in frequencies) {
        final id = await database.into(database.reminderTable).insert(
          ReminderTableCompanion.insert(
            title: 'Test Reminder',
            type: ReminderType.medication,
            frequency: freq,
            scheduledAt: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final reminders = await database.select(database.reminderTable).get();
      expect(reminders.length, frequencies.length);
    });
  });

  group('Cognitive Exercise Table and Enums', () {
    test('should insert exercises with all ExerciseType values', () async {
      final types = [
        ExerciseType.memoryGame,
        ExerciseType.wordPuzzle,
        ExerciseType.mathProblem,
        ExerciseType.patternRecognition,
        ExerciseType.sequenceRecall,
        ExerciseType.spatialAwareness,
        ExerciseType.wordSearch,
        ExerciseType.spanishAnagram,
      ];

      for (final type in types) {
        final id = await database.into(database.cognitiveExerciseTable).insert(
          CognitiveExerciseTableCompanion.insert(
            name: 'Test Exercise',
            type: type,
            difficulty: ExerciseDifficulty.medium,
            maxScore: 100,
          ),
        );
        expect(id, greaterThan(0));
      }

      final exercises = await database.select(database.cognitiveExerciseTable).get();
      expect(exercises.length, types.length);
    });

    test('should handle all ExerciseDifficulty values', () async {
      final difficulties = [
        ExerciseDifficulty.easy,
        ExerciseDifficulty.medium,
        ExerciseDifficulty.hard,
        ExerciseDifficulty.expert,
      ];

      for (final difficulty in difficulties) {
        final id = await database.into(database.cognitiveExerciseTable).insert(
          CognitiveExerciseTableCompanion.insert(
            name: 'Test Exercise',
            type: ExerciseType.memoryGame,
            difficulty: difficulty,
            maxScore: 100,
          ),
        );
        expect(id, greaterThan(0));
      }

      final exercises = await database.select(database.cognitiveExerciseTable).get();
      expect(exercises.length, difficulties.length);
    });
  });

  group('Mood Entry Table and Enums', () {
    test('should insert mood entries with all MoodLevel values', () async {
      final moods = [
        MoodLevel.veryLow,
        MoodLevel.low,
        MoodLevel.neutral,
        MoodLevel.good,
        MoodLevel.excellent,
      ];

      for (final mood in moods) {
        final id = await database.into(database.moodEntryTable).insert(
          MoodEntryTableCompanion.insert(
            mood: mood,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 8,
            entryDate: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final entries = await database.select(database.moodEntryTable).get();
      expect(entries.length, moods.length);
    });
  });

  group('Sleep Tracking Table and Enums', () {
    test('should insert sleep entries with all SleepQuality values', () async {
      final qualities = [
        SleepQuality.poor,
        SleepQuality.fair,
        SleepQuality.good,
        SleepQuality.excellent,
      ];

      for (final quality in qualities) {
        final id = await database.into(database.sleepTrackingTable).insert(
          SleepTrackingTableCompanion.insert(
            sleepDate: DateTime.now(),
            quality: Value(quality),
            score: const Value(75),
          ),
        );
        expect(id, greaterThan(0));
      }

      final entries = await database.select(database.sleepTrackingTable).get();
      expect(entries.length, qualities.length);
    });

    test('should handle all RestlessnessLevel values', () async {
      final levels = [
        RestlessnessLevel.poor,
        RestlessnessLevel.fair,
        RestlessnessLevel.good,
        RestlessnessLevel.excellent,
      ];

      for (final level in levels) {
        final id = await database.into(database.sleepTrackingTable).insert(
          SleepTrackingTableCompanion.insert(
            sleepDate: DateTime.now(),
            restlessness: Value(level),
          ),
        );
        expect(id, greaterThan(0));
      }

      final entries = await database.select(database.sleepTrackingTable).get();
      expect(entries.length, levels.length);
    });
  });

  group('Meal Plan Table and Enums', () {
    test('should insert meal plans with all MealType values', () async {
      final mealTypes = [
        MealType.lunch,
        MealType.dinner,
        MealType.snack,
      ];

      for (final mealType in mealTypes) {
        final id = await database.into(database.mealPlanTable).insert(
          MealPlanTableCompanion.insert(
            dayNumber: 1,
            mealType: mealType,
            mealName: 'Test Meal',
          ),
        );
        expect(id, greaterThan(0));
      }

      final meals = await database.select(database.mealPlanTable).get();
      expect(meals.length, mealTypes.length);
    });
  });

  group('Fasting Table and Enums', () {
    test('should insert fasting entries with all FastType values', () async {
      final fastTypes = [
        FastType.intermittent16_8,
        FastType.extended30Hour,
      ];

      for (final fastType in fastTypes) {
        final id = await database.into(database.fastingTable).insert(
          FastingTableCompanion.insert(
            fastType: fastType,
            startTime: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final entries = await database.select(database.fastingTable).get();
      expect(entries.length, fastTypes.length);
    });
  });

  group('Supplements Table and Enums', () {
    test('should insert supplements with all SupplementTiming values', () async {
      final timings = [
        SupplementTiming.morning,
        SupplementTiming.afternoon,
        SupplementTiming.evening,
        SupplementTiming.beforeBed,
      ];

      for (final timing in timings) {
        final id = await database.into(database.supplementsTable).insert(
          SupplementsTableCompanion.insert(
            name: 'Test Supplement',
            dosage: '500mg',
            timing: timing,
          ),
        );
        expect(id, greaterThan(0));
      }

      final supplements = await database.select(database.supplementsTable).get();
      expect(supplements.length, timings.length);
    });
  });

  group('Planning Table and Enums', () {
    test('should insert plans with all PlanType values', () async {
      final planTypes = [
        PlanType.daily,
        PlanType.weekly,
      ];

      for (final planType in planTypes) {
        final id = await database.into(database.planningTable).insert(
          PlanningTableCompanion.insert(
            planType: planType,
            planDate: DateTime.now(),
            title: 'Test Plan',
          ),
        );
        expect(id, greaterThan(0));
      }

      final plans = await database.select(database.planningTable).get();
      expect(plans.length, planTypes.length);
    });
  });

  group('Journal Table and Enums', () {
    test('should insert journals with all JournalType values', () async {
      final journalTypes = [
        JournalType.daily,
        JournalType.weekly,
      ];

      for (final journalType in journalTypes) {
        final id = await database.into(database.journalTable).insert(
          JournalTableCompanion.insert(
            journalType: journalType,
            entryDate: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final journals = await database.select(database.journalTable).get();
      expect(journals.length, journalTypes.length);
    });
  });

  group('Word Dictionary Table and Enums', () {
    test('should insert words with all WordLanguage values', () async {
      final languages = [
        WordLanguage.english,
        WordLanguage.spanish,
      ];

      for (final language in languages) {
        final id = await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'TEST',
            language: language,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 4,
          ),
        );
        expect(id, greaterThan(0));
      }

      final words = await database.select(database.wordDictionaryTable).get();
      expect(words.length, languages.length);
    });

    test('should handle all WordType values', () async {
      final wordTypes = [
        WordType.anagram,
        WordType.wordSearch,
      ];

      for (final wordType in wordTypes) {
        final id = await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'TEST',
            language: WordLanguage.english,
            type: wordType,
            difficulty: ExerciseDifficulty.easy,
            length: 4,
          ),
        );
        expect(id, greaterThan(0));
      }

      final words = await database.select(database.wordDictionaryTable).get();
      expect(words.length, wordTypes.length);
    });
  });

  group('Cambridge Assessment Table and Enums', () {
    test('should insert cambridge assessments with all CambridgeTestType values', () async {
      final testTypes = [
        CambridgeTestType.pal,
        CambridgeTestType.prm,
        CambridgeTestType.swm,
        CambridgeTestType.rvp,
        CambridgeTestType.rti,
        CambridgeTestType.ots,
      ];

      for (final testType in testTypes) {
        final id = await database.into(database.cambridgeAssessmentTable).insert(
          CambridgeAssessmentTableCompanion.insert(
            testType: testType,
            durationSeconds: 300,
            accuracy: 0.85,
            totalTrials: 20,
            correctTrials: 17,
            errorCount: 3,
            meanLatencyMs: 450.5,
            medianLatencyMs: 420.0,
            normScore: 100.0,
            interpretation: 'Good performance',
            specificMetrics: '{}',
            completedAt: DateTime.now(),
          ),
        );
        expect(id, greaterThan(0));
      }

      final assessments = await database.select(database.cambridgeAssessmentTable).get();
      expect(assessments.length, testTypes.length);
    });
  });

  group('Daily Tracking Table', () {
    test('should insert and retrieve daily tracking entries', () async {
      final id = await database.into(database.dailyTrackingTable).insert(
        DailyTrackingTableCompanion.insert(
          entryDate: DateTime.now(),
          cycleDay: 1,
          meditation: const Value(true),
          yoga: const Value(true),
        ),
      );
      expect(id, greaterThan(0));

      final entries = await database.select(database.dailyTrackingTable).get();
      expect(entries.length, 1);
      expect(entries.first.meditation, true);
      expect(entries.first.yoga, true);
    });
  });

  group('Cycling Tracking Table', () {
    test('should insert and retrieve cycling tracking entries', () async {
      final id = await database.into(database.cyclingTrackingTable).insert(
        CyclingTrackingTableCompanion.insert(
          rideDate: DateTime.now(),
          distanceKm: const Value(25.5),
          totalTimeSeconds: const Value(3600),
          avgMovingSpeedKmh: const Value(25.5),
          avgHeartRate: const Value(145),
          maxHeartRate: const Value(170),
        ),
      );
      expect(id, greaterThan(0));

      final entries = await database.select(database.cyclingTrackingTable).get();
      expect(entries.length, 1);
      expect(entries.first.distanceKm, 25.5);
      expect(entries.first.avgHeartRate, 145);
    });
  });

  group('Feeding Window Table', () {
    test('should insert and retrieve feeding windows', () async {
      final id = await database.into(database.feedingWindowTable).insert(
        FeedingWindowTableCompanion.insert(
          startHour: 12,
          startMinute: 0,
          endHour: 20,
          endMinute: 0,
        ),
      );
      expect(id, greaterThan(0));

      final windows = await database.select(database.feedingWindowTable).get();
      expect(windows.length, 1);
      expect(windows.first.startHour, 12);
      expect(windows.first.endHour, 20);
    });
  });

  group('Supplement Logs Table', () {
    test('should insert supplement log with foreign key reference', () async {
      // First insert a supplement
      final supplementId = await database.into(database.supplementsTable).insert(
        SupplementsTableCompanion.insert(
          name: 'Vitamin D',
          dosage: '1000 IU',
          timing: SupplementTiming.morning,
        ),
      );

      // Then insert a log for that supplement
      final logId = await database.into(database.supplementLogsTable).insert(
        SupplementLogsTableCompanion.insert(
          supplementId: supplementId,
          logDate: DateTime.now(),
        ),
      );
      expect(logId, greaterThan(0));

      final logs = await database.select(database.supplementLogsTable).get();
      expect(logs.length, 1);
      expect(logs.first.supplementId, supplementId);
    });
  });

  group('User Profile Table', () {
    test('should insert and retrieve user profile', () async {
      final id = await database.into(database.userProfileTable).insert(
        UserProfileTableCompanion.insert(
          name: const Value('Test User'),
          age: const Value(65),
          gender: const Value('Male'),
        ),
      );
      expect(id, greaterThan(0));

      final profiles = await database.select(database.userProfileTable).get();
      expect(profiles.length, 1);
      expect(profiles.first.name, 'Test User');
      expect(profiles.first.age, 65);
    });
  });
}
