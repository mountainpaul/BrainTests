import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/repositories/mood_entry_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MoodEntryRepository])
import 'mood_tracking_test.mocks.dart';

void main() {
  group('Mood Tracking Tests', () {
    late MockMoodEntryRepository mockRepository;

    setUp(() {
      mockRepository = MockMoodEntryRepository();
    });

    group('MoodEntry Entity Tests', () {
      test('should calculate overall wellness correctly', () {
        final moodEntry = MoodEntry(
          mood: MoodLevel.good, // 8 points
          energyLevel: 7,
          stressLevel: 4, // inverted to 7
          sleepQuality: 6,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // (8 + 7 + 7 + 6) / 4 = 7.0
        expect(moodEntry.overallWellness, equals(7.0));
      });

      test('should handle all mood levels correctly', () {
        final moodLevels = [
          (MoodLevel.veryLow, 2),
          (MoodLevel.low, 4),
          (MoodLevel.neutral, 6),
          (MoodLevel.good, 8),
          (MoodLevel.excellent, 10),
        ];

        for (final (mood, expectedScore) in moodLevels) {
          final moodEntry = MoodEntry(
            mood: mood,
            energyLevel: 5,
            stressLevel: 5, // inverted to 6
            sleepQuality: 5,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          );

          final expectedWellness = (expectedScore + 5 + 6 + 5) / 4;
          expect(moodEntry.overallWellness, equals(expectedWellness));
        }
      });

      test('should invert stress level correctly', () {
        final highStressMoodEntry = MoodEntry(
          mood: MoodLevel.neutral, // 6 points
          energyLevel: 5,
          stressLevel: 10, // inverted to 1
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final lowStressMoodEntry = MoodEntry(
          mood: MoodLevel.neutral, // 6 points
          energyLevel: 5,
          stressLevel: 1, // inverted to 10
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // High stress: (6 + 5 + 1 + 5) / 4 = 4.25
        expect(highStressMoodEntry.overallWellness, equals(4.25));

        // Low stress: (6 + 5 + 10 + 5) / 4 = 6.5
        expect(lowStressMoodEntry.overallWellness, equals(6.5));
      });

      test('should create proper copy with changes', () {
        final original = MoodEntry(
          id: 1,
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 3,
          sleepQuality: 8,
          notes: 'Original notes',
          entryDate: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(
          mood: MoodLevel.excellent,
          notes: 'Updated notes',
        );

        expect(copy.id, equals(1));
        expect(copy.mood, equals(MoodLevel.excellent));
        expect(copy.energyLevel, equals(7));
        expect(copy.stressLevel, equals(3));
        expect(copy.sleepQuality, equals(8));
        expect(copy.notes, equals('Updated notes'));
        expect(copy.entryDate, equals(DateTime(2024, 1, 1)));
        expect(copy.createdAt, equals(DateTime(2024, 1, 1)));
      });
    });

    group('Mood Entry Repository Integration', () {
      test('should save mood entry successfully', () async {
        final moodEntry = MoodEntry(
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          notes: 'Feeling good today',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final savedMoodEntry = moodEntry.copyWith(id: 1);
        when(mockRepository.insertMoodEntry(moodEntry))
            .thenAnswer((_) async => 1);

        final result = await mockRepository.insertMoodEntry(moodEntry);

        expect(result, equals(1));
        verify(mockRepository.insertMoodEntry(moodEntry)).called(1);
      });

      test('should retrieve mood entries by date range', () async {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 7);

        final moodEntries = [
          MoodEntry(
            id: 1,
            mood: MoodLevel.good,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 8,
            entryDate: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
          MoodEntry(
            id: 2,
            mood: MoodLevel.excellent,
            energyLevel: 9,
            stressLevel: 2,
            sleepQuality: 9,
            entryDate: DateTime(2024, 1, 5),
            createdAt: DateTime(2024, 1, 5),
          ),
        ];

        when(mockRepository.getMoodEntriesByDateRange(startDate, endDate))
            .thenAnswer((_) async => moodEntries);

        final result = await mockRepository.getMoodEntriesByDateRange(startDate, endDate);

        expect(result.length, equals(2));
        expect(result.every((entry) =>
          entry.entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.entryDate.isBefore(endDate.add(const Duration(days: 1)))
        ), isTrue);
        verify(mockRepository.getMoodEntriesByDateRange(startDate, endDate)).called(1);
      });

      test('should calculate weekly wellness average', () async {
        final weeklyEntries = [
          MoodEntry(
            mood: MoodLevel.good, // 8 points
            energyLevel: 7,
            stressLevel: 3, // inverted to 8
            sleepQuality: 7,
            entryDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ), // wellness: 7.5
          MoodEntry(
            mood: MoodLevel.excellent, // 10 points
            energyLevel: 8,
            stressLevel: 2, // inverted to 9
            sleepQuality: 9,
            entryDate: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ), // wellness: 9.0
          MoodEntry(
            mood: MoodLevel.neutral, // 6 points
            energyLevel: 5,
            stressLevel: 6, // inverted to 5
            sleepQuality: 6,
            entryDate: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ), // wellness: 5.5
        ];

        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        when(mockRepository.getMoodEntriesByDateRange(startDate, endDate))
            .thenAnswer((_) async => weeklyEntries);

        final result = await mockRepository.getMoodEntriesByDateRange(startDate, endDate);
        final averageWellness = result
            .map((entry) => entry.overallWellness)
            .reduce((a, b) => a + b) / result.length;

        // (7.5 + 9.0 + 5.5) / 3 = 7.33...
        expect(averageWellness, closeTo(7.33, 0.01));
      });
    });

    group('Mood Tracking Analytics', () {
      test('should identify mood patterns', () async {
        final moodEntries = [
          MoodEntry(
            mood: MoodLevel.low,
            energyLevel: 3,
            stressLevel: 8,
            sleepQuality: 4,
            entryDate: DateTime.now().subtract(const Duration(days: 6)),
            createdAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
          MoodEntry(
            mood: MoodLevel.neutral,
            energyLevel: 5,
            stressLevel: 6,
            sleepQuality: 6,
            entryDate: DateTime.now().subtract(const Duration(days: 5)),
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          MoodEntry(
            mood: MoodLevel.good,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 7,
            entryDate: DateTime.now().subtract(const Duration(days: 4)),
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          MoodEntry(
            mood: MoodLevel.excellent,
            energyLevel: 9,
            stressLevel: 2,
            sleepQuality: 9,
            entryDate: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ];

        when(mockRepository.getMoodEntriesByDateRange(any, any))
            .thenAnswer((_) async => moodEntries);

        final result = await mockRepository.getMoodEntriesByDateRange(
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        );

        final sortedByDate = result
          ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

        // Check improvement trend
        expect(sortedByDate[0].overallWellness < sortedByDate[1].overallWellness, isTrue);
        expect(sortedByDate[1].overallWellness < sortedByDate[2].overallWellness, isTrue);
        expect(sortedByDate[2].overallWellness < sortedByDate[3].overallWellness, isTrue);
      });

      test('should track sleep quality correlation with mood', () async {
        final entriesWithGoodSleep = [
          MoodEntry(
            mood: MoodLevel.good,
            energyLevel: 8,
            stressLevel: 3,
            sleepQuality: 9,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          MoodEntry(
            mood: MoodLevel.excellent,
            energyLevel: 9,
            stressLevel: 2,
            sleepQuality: 8,
            entryDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        final entriesWithPoorSleep = [
          MoodEntry(
            mood: MoodLevel.low,
            energyLevel: 3,
            stressLevel: 7,
            sleepQuality: 3,
            entryDate: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          MoodEntry(
            mood: MoodLevel.veryLow,
            energyLevel: 2,
            stressLevel: 9,
            sleepQuality: 2,
            entryDate: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ];

        final goodSleepWellness = entriesWithGoodSleep
            .map((e) => e.overallWellness)
            .reduce((a, b) => a + b) / entriesWithGoodSleep.length;

        final poorSleepWellness = entriesWithPoorSleep
            .map((e) => e.overallWellness)
            .reduce((a, b) => a + b) / entriesWithPoorSleep.length;

        expect(goodSleepWellness, greaterThan(poorSleepWellness));
      });
    });

    group('Mood Entry Notes and Context', () {
      test('should handle detailed notes', () {
        final moodEntry = MoodEntry(
          mood: MoodLevel.low,
          energyLevel: 4,
          stressLevel: 7,
          sleepQuality: 3,
          notes: 'Had trouble sleeping due to work stress. Feeling anxious about upcoming presentation.',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(moodEntry.notes, contains('work stress'));
        expect(moodEntry.notes, contains('anxious'));
        expect(moodEntry.stressLevel, equals(7));
        expect(moodEntry.sleepQuality, equals(3));
      });

      test('should handle entries without notes', () {
        final moodEntry = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 5,
          sleepQuality: 6,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(moodEntry.notes, isNull);
        expect(moodEntry.overallWellness, equals(5.75));
      });
    });

    group('Mood Entry Edge Cases', () {
      test('should handle extreme wellness scores', () {
        final perfectWellness = MoodEntry(
          mood: MoodLevel.excellent, // 10 points
          energyLevel: 10,
          stressLevel: 1, // inverted to 10
          sleepQuality: 10,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final poorWellness = MoodEntry(
          mood: MoodLevel.veryLow, // 2 points
          energyLevel: 1,
          stressLevel: 10, // inverted to 1
          sleepQuality: 1,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(perfectWellness.overallWellness, equals(10.0));
        expect(poorWellness.overallWellness, equals(1.25));
      });

      test('should handle boundary stress values', () {
        final minStress = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 1, // inverted to 10
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final maxStress = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 10, // inverted to 1
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Min stress: (6 + 5 + 10 + 5) / 4 = 6.5
        expect(minStress.overallWellness, equals(6.5));

        // Max stress: (6 + 5 + 1 + 5) / 4 = 4.25
        expect(maxStress.overallWellness, equals(4.25));
      });

      test('should handle same-day entries', () {
        final today = DateTime.now();
        final morning = DateTime(today.year, today.month, today.day, 8, 0);
        final evening = DateTime(today.year, today.month, today.day, 20, 0);

        final morningEntry = MoodEntry(
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          notes: 'Morning entry - feeling refreshed',
          entryDate: morning,
          createdAt: morning,
        );

        final eveningEntry = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 5,
          stressLevel: 6,
          sleepQuality: 7,
          notes: 'Evening entry - tired from work',
          entryDate: evening,
          createdAt: evening,
        );

        expect(morningEntry.entryDate.day, equals(eveningEntry.entryDate.day));
        expect(morningEntry.overallWellness, greaterThan(eveningEntry.overallWellness));
      });
    });
  });
}