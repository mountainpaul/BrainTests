import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/mood_entry_repository_impl.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('MoodEntryRepositoryImpl Integration Tests', () {
    late AppDatabase database;
    late MoodEntryRepositoryImpl repository;

    setUp(() async {
      database = createTestDatabase();
      repository = MoodEntryRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('CRUD Operations', () {
      test('should insert and retrieve mood entry', () async {
        final moodEntry = MoodEntry(
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          notes: 'Feeling great today!',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertMoodEntry(moodEntry);

        expect(id, greaterThan(0));

        final retrieved = await repository.getMoodEntryById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.mood, equals(MoodLevel.good));
        expect(retrieved.energyLevel, equals(8));
        expect(retrieved.stressLevel, equals(3));
        expect(retrieved.sleepQuality, equals(7));
        expect(retrieved.notes, equals('Feeling great today!'));
        expect(retrieved.overallWellness, equals(7.75)); // (8 + 8 + 8 + 7) / 4 = 7.75
      });

      test('should insert mood entry without notes', () async {
        final moodEntry = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 5,
          sleepQuality: 6,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertMoodEntry(moodEntry);
        final retrieved = await repository.getMoodEntryById(id);

        expect(retrieved!.notes, isNull);
        expect(retrieved.overallWellness, equals(5.75)); // (6 + 5 + 6 + 6) / 4 = 5.75
      });

      test('should update existing mood entry', () async {
        // Insert initial mood entry
        final moodEntry = MoodEntry(
          mood: MoodLevel.low,
          energyLevel: 3,
          stressLevel: 8,
          sleepQuality: 4,
          notes: 'Not feeling well',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertMoodEntry(moodEntry);
        final inserted = await repository.getMoodEntryById(id);

        // Update the mood entry
        final updated = inserted!.copyWith(
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 4,
          notes: 'Feeling much better now',
        );

        final result = await repository.updateMoodEntry(updated);

        expect(result, isTrue);

        final retrieved = await repository.getMoodEntryById(id);

        expect(retrieved!.mood, equals(MoodLevel.good));
        expect(retrieved.energyLevel, equals(7));
        expect(retrieved.stressLevel, equals(4));
        expect(retrieved.notes, equals('Feeling much better now'));
      });

      test('should delete mood entry', () async {
        final moodEntry = MoodEntry(
          mood: MoodLevel.excellent,
          energyLevel: 9,
          stressLevel: 2,
          sleepQuality: 9,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final id = await repository.insertMoodEntry(moodEntry);

        // Verify it exists
        final retrieved = await repository.getMoodEntryById(id);
        expect(retrieved, isNotNull);

        // Delete it
        final result = await repository.deleteMoodEntry(id);
        expect(result, isTrue);

        // Verify it's gone
        final afterDelete = await repository.getMoodEntryById(id);
        expect(afterDelete, isNull);
      });
    });

    group('Query Operations', () {
      setUp(() async {
        // Insert test data across different dates and moods
        final now = DateTime.now();
        final testEntries = [
          MoodEntry(
            mood: MoodLevel.excellent,
            energyLevel: 9,
            stressLevel: 2,
            sleepQuality: 9,
            notes: 'Perfect day',
            entryDate: now.subtract(const Duration(days: 6)),
            createdAt: now.subtract(const Duration(days: 6)),
          ),
          MoodEntry(
            mood: MoodLevel.good,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 8,
            notes: 'Good day overall',
            entryDate: now.subtract(const Duration(days: 4)),
            createdAt: now.subtract(const Duration(days: 4)),
          ),
          MoodEntry(
            mood: MoodLevel.neutral,
            energyLevel: 5,
            stressLevel: 5,
            sleepQuality: 6,
            entryDate: now.subtract(const Duration(days: 3)),
            createdAt: now.subtract(const Duration(days: 3)),
          ),
          MoodEntry(
            mood: MoodLevel.low,
            energyLevel: 3,
            stressLevel: 7,
            sleepQuality: 4,
            notes: 'Tough day',
            entryDate: now.subtract(const Duration(days: 2)),
            createdAt: now.subtract(const Duration(days: 2)),
          ),
          MoodEntry(
            mood: MoodLevel.good,
            energyLevel: 8,
            stressLevel: 3,
            sleepQuality: 7,
            notes: 'Recovering well',
            entryDate: now.subtract(const Duration(days: 1)),
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ];

        for (final entry in testEntries) {
          await repository.insertMoodEntry(entry);
        }
      });

      test('should get all mood entries ordered by date descending', () async {
        final result = await repository.getAllMoodEntries();

        expect(result.length, equals(5));

        // Should be ordered by entryDate descending (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(result[i].entryDate.isAfter(result[i + 1].entryDate), isTrue);
        }
      });

      test('should get mood entries by date range', () async {
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 4));
        final endDate = now.subtract(const Duration(days: 2));

        final result = await repository.getMoodEntriesByDateRange(startDate, endDate);

        expect(result.length, equals(3)); // Days 4, 3, and 2
        expect(result.every((entry) =>
          entry.entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.entryDate.isBefore(endDate.add(const Duration(days: 1)))
        ), isTrue);
      });

      test('should get mood entry by specific date', () async {
        final now = DateTime.now();
        final targetDate = now.subtract(const Duration(days: 2));

        final result = await repository.getMoodEntryByDate(targetDate);

        expect(result, isNotNull);
        expect(result!.mood, equals(MoodLevel.low));
        expect(result.notes, equals('Tough day'));
      });

      test('should calculate mood distribution correctly', () async {
        final distribution = await repository.getMoodDistribution();

        expect(distribution[MoodLevel.excellent], equals(1));
        expect(distribution[MoodLevel.good], equals(2));
        expect(distribution[MoodLevel.neutral], equals(1));
        expect(distribution[MoodLevel.low], equals(1));
        expect(distribution[MoodLevel.veryLow], equals(0));
      });

      test('should calculate average wellness score correctly', () async {
        final averageWellness = await repository.getAverageWellnessScore();

        expect(averageWellness, greaterThan(0.0));
        expect(averageWellness, lessThan(10.0));
      });
    });

    group('Edge Cases', () {
      test('should handle empty database', () async {
        final allEntries = await repository.getAllMoodEntries();
        final distribution = await repository.getMoodDistribution();
        final averageWellness = await repository.getAverageWellnessScore();

        expect(allEntries.isEmpty, isTrue);
        expect(averageWellness, equals(0.0));
        expect(distribution.values.every((count) => count == 0), isTrue);
      });

      test('should handle extreme wellness values', () async {
        // Perfect wellness
        final perfectEntry = MoodEntry(
          mood: MoodLevel.excellent, // 10 points
          energyLevel: 10,
          stressLevel: 1, // inverted to 10
          sleepQuality: 10,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Poor wellness
        final poorEntry = MoodEntry(
          mood: MoodLevel.veryLow, // 2 points
          energyLevel: 1,
          stressLevel: 10, // inverted to 1
          sleepQuality: 1,
          entryDate: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final id1 = await repository.insertMoodEntry(perfectEntry);
        final id2 = await repository.insertMoodEntry(poorEntry);

        final retrieved1 = await repository.getMoodEntryById(id1);
        final retrieved2 = await repository.getMoodEntryById(id2);

        expect(retrieved1!.overallWellness, equals(10.0));
        expect(retrieved2!.overallWellness, equals(1.25));
      });
    });
  });
}