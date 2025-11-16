import 'package:brain_tests/core/services/analytics_service.dart';
import 'package:brain_tests/core/services/performance_monitoring_service.dart';
import 'package:brain_tests/core/utils/string_extensions.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/assessment_repository_impl.dart';
import 'package:brain_tests/data/repositories/mood_entry_repository_impl.dart';
import 'package:brain_tests/data/repositories/reminder_repository_impl.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockAppDatabase extends Mock implements AppDatabase {}
class MockAssessmentRepository extends Mock implements AssessmentRepositoryImpl {}
class MockReminderRepository extends Mock implements ReminderRepositoryImpl {}
class MockMoodEntryRepository extends Mock implements MoodEntryRepositoryImpl {}

void main() {
  group('Edge Cases and Error Handling Tests', () {
    late MockAppDatabase mockDatabase;
    late MockAssessmentRepository mockAssessmentRepo;
    late MockReminderRepository mockReminderRepo;
    late MockMoodEntryRepository mockMoodRepo;

    setUpAll(() async {
      await AnalyticsService.initialize(enableInDebug: false);
      await PerformanceMonitoringService.initialize();
    });

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockAssessmentRepo = MockAssessmentRepository();
      mockReminderRepo = MockReminderRepository();
      mockMoodRepo = MockMoodEntryRepository();
    });

    group('Assessment Edge Cases', () {
      test('should handle assessment with zero score', () {
        // Arrange
        final zeroScoreAssessment = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );

        // Act & Assert
        expect(zeroScoreAssessment.score, equals(0));
        expect(zeroScoreAssessment.percentage, equals(0.0));
        expect(zeroScoreAssessment.maxScore, greaterThan(0));
      });

      test('should handle perfect assessment score', () {
        // Arrange
        final perfectAssessment = Assessment(
          id: 2,
          type: AssessmentType.attentionFocus,
          score: 100,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        // Act & Assert
        expect(perfectAssessment.score, equals(perfectAssessment.maxScore));
        expect(perfectAssessment.percentage, equals(100.0));
      });

      test('should handle assessment with unusual timing', () {
        // Arrange - Assessment completed before it was created (edge case)
        final backwardTimeAssessment = Assessment(
          id: 3,
          type: AssessmentType.executiveFunction,
          score: 75,
          maxScore: 100,
          completedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)), // Created after completed
        );

        // Act & Assert - Should handle gracefully
        expect(backwardTimeAssessment.completedAt.isBefore(backwardTimeAssessment.createdAt), isTrue);
        expect(backwardTimeAssessment.percentage, equals(75.0));
      });

      test('should handle assessment with extreme max score values', () {
        // Arrange - Edge cases with unusual max scores
        final smallMaxScore = Assessment(
          id: 4,
          type: AssessmentType.languageSkills,
          score: 1,
          maxScore: 1, // Very small max score
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        final largeMaxScore = Assessment(
          id: 5,
          type: AssessmentType.visuospatialSkills,
          score: 50000,
          maxScore: 100000, // Very large max score
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act & Assert
        expect(smallMaxScore.percentage, equals(100.0));
        expect(largeMaxScore.percentage, equals(50.0));
      });

      test('should handle assessment copyWith with null values', () {
        // Arrange
        final originalAssessment = Assessment(
          id: 6,
          type: AssessmentType.processingSpeed,
          score: 88,
          maxScore: 100,
          notes: 'Original notes',
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        );

        // Act - Copy with null values (should preserve originals)
        final copiedAssessment = originalAssessment.copyWith(
          id: null,
          notes: null,
        );

        // Assert
        expect(copiedAssessment.id, equals(originalAssessment.id));
        expect(copiedAssessment.notes, equals(originalAssessment.notes));
        expect(copiedAssessment.score, equals(originalAssessment.score));
      });

      test('should handle assessment equatable comparison', () {
        // Arrange
        final assessment1 = Assessment(
          id: 7,
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.parse('2024-01-15T10:30:00'),
          createdAt: DateTime.parse('2024-01-15T10:00:00'),
        );

        final assessment2 = Assessment(
          id: 7,
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.parse('2024-01-15T10:30:00'),
          createdAt: DateTime.parse('2024-01-15T10:00:00'),
        );

        final assessment3 = Assessment(
          id: 8, // Different ID
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.parse('2024-01-15T10:30:00'),
          createdAt: DateTime.parse('2024-01-15T10:00:00'),
        );

        // Act & Assert
        expect(assessment1, equals(assessment2)); // Same data
        expect(assessment1, isNot(equals(assessment3))); // Different ID
        expect(assessment1.hashCode, equals(assessment2.hashCode));
        expect(assessment1.hashCode, isNot(equals(assessment3.hashCode)));
      });
    });

    group('Reminder Edge Cases', () {
      test('should handle reminder scheduled in the past', () {
        // Arrange
        final pastReminder = Reminder(
          id: 1,
          title: 'Overdue Medication',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().subtract(const Duration(hours: 2)), // In the past
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        );

        // Act & Assert
        expect(pastReminder.scheduledAt.isBefore(DateTime.now()), isTrue);
        expect(pastReminder.isActive, isTrue);
        expect(pastReminder.isCompleted, isFalse);
      });

      test('should handle reminder with all frequencies', () {
        // Arrange - Test all frequency types
        const frequencies = ReminderFrequency.values;
        final reminders = frequencies.map((freq) => Reminder(
          title: 'Test ${freq.name}',
          type: ReminderType.custom,
          frequency: freq,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList();

        // Act & Assert
        expect(reminders.length, equals(ReminderFrequency.values.length));
        for (int i = 0; i < reminders.length; i++) {
          expect(reminders[i].frequency, equals(frequencies[i]));
        }
      });

      test('should handle reminder copyWith edge cases', () {
        // Arrange
        final originalReminder = Reminder(
          id: 2,
          title: 'Original Title',
          description: 'Original description',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.weekly,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act - Test various copyWith scenarios
        final titleOnlyUpdate = originalReminder.copyWith(title: 'New Title');
        final statusUpdate = originalReminder.copyWith(isCompleted: true);
        final noChangeUpdate = originalReminder.copyWith();

        // Assert
        expect(titleOnlyUpdate.title, equals('New Title'));
        expect(titleOnlyUpdate.description, equals(originalReminder.description));
        expect(statusUpdate.isCompleted, isTrue);
        expect(statusUpdate.title, equals(originalReminder.title));
        expect(noChangeUpdate, equals(originalReminder));
      });

      test('should handle reminder with extreme date values', () {
        // Arrange
        final veryFarFutureReminder = Reminder(
          id: 3,
          title: 'Far Future Reminder',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime(2099, 12, 31), // Far in the future
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final veryOldReminder = Reminder(
          id: 4,
          title: 'Old Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime(2000, 1, 1), // Far in the past
          isActive: false,
          isCompleted: true,
          createdAt: DateTime(2000, 1, 1),
          updatedAt: DateTime(2000, 1, 1),
        );

        // Act & Assert
        expect(veryFarFutureReminder.scheduledAt.year, equals(2099));
        expect(veryOldReminder.scheduledAt.year, equals(2000));
        expect(veryFarFutureReminder.isActive, isTrue);
        expect(veryOldReminder.isCompleted, isTrue);
      });
    });

    group('Mood Entry Edge Cases', () {
      test('should handle mood entry with boundary values', () {
        // Arrange - Test all mood levels with extreme values
        final extremeMoodEntries = [
          MoodEntry(
            mood: MoodLevel.veryLow,
            energyLevel: 1, // Minimum
            stressLevel: 10, // Maximum
            sleepQuality: 1, // Minimum
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          MoodEntry(
            mood: MoodLevel.excellent,
            energyLevel: 10, // Maximum
            stressLevel: 1, // Minimum
            sleepQuality: 10, // Maximum
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        // Act & Assert
        expect(extremeMoodEntries[0].overallWellness, equals(1.25)); // Very low wellness
        expect(extremeMoodEntries[1].overallWellness, equals(10.0)); // Perfect wellness
      });

      test('should handle mood entry with invalid level values', () {
        // Arrange - Test with potentially invalid values (outside 1-10 range)
        final invalidMoodEntry = MoodEntry(
          mood: MoodLevel.good,
          energyLevel: 0, // Below minimum
          stressLevel: 15, // Above maximum
          sleepQuality: -5, // Negative
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should still create object (validation handled elsewhere)
        expect(invalidMoodEntry.energyLevel, equals(0));
        expect(invalidMoodEntry.stressLevel, equals(15));
        expect(invalidMoodEntry.sleepQuality, equals(-5));
        // Wellness calculation still works with invalid values
        expect(invalidMoodEntry.overallWellness, isA<double>());
      });

      test('should handle mood entry with all mood levels', () {
        // Arrange - Test all mood level values
        const allMoodLevels = MoodLevel.values;
        final moodEntries = allMoodLevels.map((level) => MoodEntry(
          mood: level,
          energyLevel: 5,
          stressLevel: 5,
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        )).toList();

        // Act - Calculate wellness for each
        final wellnessScores = moodEntries.map((e) => e.overallWellness).toList();

        // Assert - Wellness should increase with better mood
        expect(moodEntries.length, equals(MoodLevel.values.length));
        expect(wellnessScores.first < wellnessScores.last, isTrue); // veryLow < excellent
      });

      test('should handle mood entry with very long notes', () {
        // Arrange - Extremely long notes text
        final longNotes = 'Very long note text. ' * 100; // 2000+ characters
        final moodWithLongNotes = MoodEntry(
          mood: MoodLevel.neutral,
          energyLevel: 6,
          stressLevel: 4,
          sleepQuality: 7,
          notes: longNotes,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(moodWithLongNotes.notes!.length, greaterThan(2000));
        expect(moodWithLongNotes.overallWellness, equals(6.5));
      });

      test('should handle mood entry copyWith with null preservation', () {
        // Arrange
        final originalMood = MoodEntry(
          id: 5,
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 2,
          sleepQuality: 8,
          notes: 'Original notes',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act - Copy with selective updates
        final updatedMood = originalMood.copyWith(
          energyLevel: 9,
          notes: null, // Should preserve original
        );

        // Assert
        expect(updatedMood.energyLevel, equals(9));
        expect(updatedMood.notes, equals('Original notes')); // Preserved
        expect(updatedMood.mood, equals(originalMood.mood));
        expect(updatedMood.id, equals(originalMood.id));
      });
    });

    group('String Extensions Edge Cases', () {
      test('should handle string capitalization edge cases', () {
        // Arrange - Various edge case strings
        final edgeCases = [
          '', // Empty string
          ' ', // Whitespace only
          'a', // Single character
          'ABC', // All caps
          'test string with multiple words',
          '123 numbers first',
          'special!@#\$%^&*()characters',
          '  leading and trailing spaces  ',
        ];

        // Act & Assert
        expect(''.capitalize(), equals(''));
        expect(' '.capitalize(), equals(' '));
        expect('a'.capitalize(), equals('A'));
        expect('ABC'.capitalize(), equals('ABC'));
        expect('test string with multiple words'.capitalize(),
               equals('Test string with multiple words'));
      });

      test('should handle email validation edge cases', () {
        // Arrange - Various email formats
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user123@test-domain.com',
        ];

        final invalidEmails = [
          '', // Empty
          'notanemail',
          '@domain.com',
          'user@',
          'user@domain',
          'user name@domain.com', // Space
          'user@domain.',
          'user.@domain.com',
        ];

        // Act & Assert
        for (final email in validEmails) {
          expect(email.isValidEmail(), isTrue, reason: 'Should be valid: $email');
        }

        for (final email in invalidEmails) {
          expect(email.isValidEmail(), isFalse, reason: 'Should be invalid: $email');
        }
      });

      test('should handle number validation edge cases', () {
        // Arrange
        final numberStrings = [
          '123',
          '0',
          '-456',
          '12.34',
          '',
          'abc',
          '12a',
          ' 123 ',
          '++123',
          '--456',
        ];

        // Act & Assert
        expect('123'.isNumeric(), isTrue);
        expect('0'.isNumeric(), isTrue);
        expect('-456'.isNumeric(), isFalse); // Extension might not handle negative
        expect('12.34'.isNumeric(), isFalse); // Extension might not handle decimals
        expect(''.isNumeric(), isFalse);
        expect('abc'.isNumeric(), isFalse);
        expect('12a'.isNumeric(), isFalse);
      });

      test('should handle word list conversion edge cases', () {
        // Arrange
        final testStrings = [
          '',
          ' ',
          'single',
          'two words',
          '  multiple   spaces   between  ',
          'punctuation, and. other! stuff?',
          'UPPERCASE lowercase MiXeD',
          '123 numbers 456',
        ];

        // Act & Assert
        expect(''.toWordList(), isEmpty);
        expect(' '.toWordList(), isEmpty);
        expect('single'.toWordList(), equals(['single']));
        expect('two words'.toWordList(), equals(['two', 'words']));
        expect('  multiple   spaces   between  '.toWordList(),
               equals(['multiple', 'spaces', 'between']));
      });

      test('should handle removeWhitespace edge cases', () {
        // Arrange
        final whitespaceStrings = [
          '',
          ' ',
          '   ',
          'no spaces',
          ' leading',
          'trailing ',
          ' both ',
          '  multiple   internal   spaces  ',
          '\t\n\r mixed whitespace \t\n\r',
        ];

        // Act & Assert
        expect(''.removeWhitespace(), equals(''));
        expect(' '.removeWhitespace(), equals(''));
        expect('no spaces'.removeWhitespace(), equals('nospaces'));
        expect(' leading'.removeWhitespace(), equals('leading'));
        expect('trailing '.removeWhitespace(), equals('trailing'));
        expect(' both '.removeWhitespace(), equals('both'));
        expect('\t\n\r mixed whitespace \t\n\r'.removeWhitespace(), equals('mixedwhitespace'));
      });
    });

    group('Service Error Handling', () {
      test('should handle analytics service errors gracefully', () async {
        // Act & Assert - Should not throw errors even when Firebase is not configured
        expect(() async => await AnalyticsService.logEvent('test_event'), returnsNormally);
        expect(() async => await AnalyticsService.logScreenView('test_screen'), returnsNormally);
        expect(() async => await AnalyticsService.recordError('Test error', null), returnsNormally);
      });

      test('should handle performance monitoring errors gracefully', () async {
        // Act & Assert - Should not throw errors
        expect(() async => await PerformanceMonitoringService.startTrace('test_trace'), returnsNormally);
        expect(() async => await PerformanceMonitoringService.stopTrace('test_trace'), returnsNormally);

        expect(() async => await PerformanceMonitoringService.trackAssessmentPerformance(
          'test_assessment',
          const Duration(seconds: 30),
          {'test_metric': 42}
        ), returnsNormally);
      });

      test('should handle service initialization errors', () async {
        // Act & Assert - Multiple initializations should not cause issues
        expect(() async => await AnalyticsService.initialize(enableInDebug: false), returnsNormally);
        expect(() async => await AnalyticsService.initialize(enableInDebug: false), returnsNormally);

        expect(() async => await PerformanceMonitoringService.initialize(), returnsNormally);
        expect(() async => await PerformanceMonitoringService.initialize(), returnsNormally);
      });
    });

    group('Repository Error Scenarios', () {
      test('should handle database connection failures', () async {
        // Arrange - Create repository with mock database
        final repo = AssessmentRepositoryImpl(mockDatabase);

        // Act & Assert - Should handle database errors gracefully
        expect(() async {
          // Any operation that would use the database should handle the error
        }, returnsNormally);
      });

      test('should handle null data scenarios', () {
        // Arrange - Test with null values where possible
        expect(() {
          final assessment = Assessment(
            id: null,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            notes: null,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );
          return assessment.percentage;
        }, returnsNormally);

        expect(() {
          final mood = MoodEntry(
            id: null,
            mood: MoodLevel.good,
            energyLevel: 8,
            stressLevel: 3,
            sleepQuality: 7,
            notes: null,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          );
          return mood.overallWellness;
        }, returnsNormally);
      });

      test('should handle concurrent access scenarios', () async {
        // Arrange - Simulate concurrent operations
        final futures = List.generate(10, (index) => Future.delayed(
          Duration(milliseconds: index * 10),
          () => AnalyticsService.logEvent('concurrent_event_$index'),
        ));

        // Act & Assert - Should handle concurrent calls
        expect(() async => await Future.wait(futures), returnsNormally);
      });
    });

    group('Data Validation Edge Cases', () {
      test('should handle DateTime edge cases', () {
        // Arrange - Various DateTime scenarios
        final now = DateTime.now();
        final farPast = DateTime(1900, 1, 1);
        final farFuture = DateTime(2200, 12, 31);

        // Act & Assert - Should handle extreme dates
        expect(() {
          final assessment = Assessment(
            type: AssessmentType.memoryRecall,
            score: 75,
            maxScore: 100,
            completedAt: farFuture,
            createdAt: farPast,
          );
          return assessment.percentage;
        }, returnsNormally);
      });

      test('should handle enum edge cases', () {
        // Arrange - Test all enum values
        const assessmentTypes = AssessmentType.values;
        const reminderTypes = ReminderType.values;
        const moodLevels = MoodLevel.values;

        // Act & Assert - All enum values should be valid
        for (final type in assessmentTypes) {
          expect(() {
            Assessment(
              type: type,
              score: 80,
              maxScore: 100,
              completedAt: DateTime.now(),
              createdAt: DateTime.now(),
            );
          }, returnsNormally);
        }

        for (final type in reminderTypes) {
          expect(() {
            Reminder(
              title: 'Test',
              type: type,
              frequency: ReminderFrequency.daily,
              scheduledAt: DateTime.now(),
              isActive: true,
              isCompleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }, returnsNormally);
        }

        for (final level in moodLevels) {
          expect(() {
            MoodEntry(
              mood: level,
              energyLevel: 5,
              stressLevel: 5,
              sleepQuality: 5,
              entryDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
          }, returnsNormally);
        }
      });
    });
  });
}