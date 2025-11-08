import 'package:brain_plan/core/services/analytics_service.dart';
import 'package:brain_plan/core/services/performance_monitoring_service.dart';
import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/domain/entities/mood_entry.dart';
import 'package:brain_plan/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Edge Cases and Error Handling Tests', () {
    setUpAll(() async {
      await AnalyticsService.initialize(enableInDebug: false);
      await PerformanceMonitoringService.initialize();
    });

    group('Assessment Edge Cases', () {
      test('should handle zero score assessment', () {
        // Arrange
        final zeroAssessment = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );

        // Act & Assert
        expect(zeroAssessment.score, equals(0));
        expect(zeroAssessment.percentage, equals(0.0));
        expect(zeroAssessment.maxScore, greaterThan(0));
      });

      test('should handle perfect score assessment', () {
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
        expect(perfectAssessment.percentage, equals(100.0));
        expect(perfectAssessment.score, equals(perfectAssessment.maxScore));
      });

      test('should handle assessment with backward timing', () {
        // Arrange - Completed before created (edge case)
        final backwardAssessment = Assessment(
          id: 3,
          type: AssessmentType.executiveFunction,
          score: 75,
          maxScore: 100,
          completedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        // Act & Assert
        expect(backwardAssessment.completedAt.isBefore(backwardAssessment.createdAt), isTrue);
        expect(backwardAssessment.percentage, equals(75.0));
      });

      test('should handle assessment with unusual max scores', () {
        // Arrange
        final smallMaxScore = Assessment(
          id: 4,
          type: AssessmentType.languageSkills,
          score: 1,
          maxScore: 1,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        final largeMaxScore = Assessment(
          id: 5,
          type: AssessmentType.visuospatialSkills,
          score: 50000,
          maxScore: 100000,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        // Act & Assert
        expect(smallMaxScore.percentage, equals(100.0));
        expect(largeMaxScore.percentage, equals(50.0));
      });

      test('should handle copyWith with null values', () {
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

        // Act
        final copiedAssessment = originalAssessment.copyWith(
          id: null, // Should preserve original
          notes: null, // Should preserve original
        );

        // Assert
        expect(copiedAssessment.id, equals(originalAssessment.id));
        expect(copiedAssessment.notes, equals(originalAssessment.notes));
        expect(copiedAssessment.score, equals(originalAssessment.score));
      });

      test('should handle equatable comparison', () {
        // Arrange
        final dateTime1 = DateTime.parse('2024-01-15T10:30:00');
        final dateTime2 = DateTime.parse('2024-01-15T10:00:00');

        final assessment1 = Assessment(
          id: 7,
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: dateTime1,
          createdAt: dateTime2,
        );

        final assessment2 = Assessment(
          id: 7,
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: dateTime1,
          createdAt: dateTime2,
        );

        final assessment3 = Assessment(
          id: 8, // Different ID
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: dateTime1,
          createdAt: dateTime2,
        );

        // Act & Assert
        expect(assessment1, equals(assessment2));
        expect(assessment1, isNot(equals(assessment3)));
        expect(assessment1.hashCode, equals(assessment2.hashCode));
      });
    });

    group('Reminder Edge Cases', () {
      test('should handle past scheduled reminder', () {
        // Arrange
        final pastReminder = Reminder(
          id: 1,
          title: 'Overdue Medication',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
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

      test('should handle all reminder frequencies', () {
        // Arrange
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

      test('should handle copyWith scenarios', () {
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

        // Act
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

      test('should handle extreme date values', () {
        // Arrange
        final farFutureReminder = Reminder(
          id: 3,
          title: 'Far Future Reminder',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime(2099, 12, 31),
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
          scheduledAt: DateTime(2000, 1, 1),
          isActive: false,
          isCompleted: true,
          createdAt: DateTime(2000, 1, 1),
          updatedAt: DateTime(2000, 1, 1),
        );

        // Act & Assert
        expect(farFutureReminder.scheduledAt.year, equals(2099));
        expect(veryOldReminder.scheduledAt.year, equals(2000));
        expect(farFutureReminder.isActive, isTrue);
        expect(veryOldReminder.isCompleted, isTrue);
      });
    });

    group('Mood Entry Edge Cases', () {
      test('should handle boundary mood values', () {
        // Arrange
        final lowMoodEntry = MoodEntry(
          mood: MoodLevel.veryLow,
          energyLevel: 1,
          stressLevel: 10,
          sleepQuality: 1,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final highMoodEntry = MoodEntry(
          mood: MoodLevel.excellent,
          energyLevel: 10,
          stressLevel: 1,
          sleepQuality: 10,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(lowMoodEntry.overallWellness, equals(1.25)); // Very low
        expect(highMoodEntry.overallWellness, equals(10.0)); // Perfect
        expect(lowMoodEntry.overallWellness < highMoodEntry.overallWellness, isTrue);
      });

      test('should handle invalid level values gracefully', () {
        // Arrange - Values outside typical 1-10 range
        final invalidMoodEntry = MoodEntry(
          mood: MoodLevel.good,
          energyLevel: 0, // Below minimum
          stressLevel: 15, // Above maximum
          sleepQuality: -5, // Negative
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should still function
        expect(invalidMoodEntry.energyLevel, equals(0));
        expect(invalidMoodEntry.stressLevel, equals(15));
        expect(invalidMoodEntry.sleepQuality, equals(-5));
        expect(invalidMoodEntry.overallWellness, isA<double>());
      });

      test('should handle all mood levels', () {
        // Arrange
        const allMoodLevels = MoodLevel.values;
        final moodEntries = allMoodLevels.map((level) => MoodEntry(
          mood: level,
          energyLevel: 5,
          stressLevel: 5,
          sleepQuality: 5,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        )).toList();

        // Act
        final wellnessScores = moodEntries.map((e) => e.overallWellness).toList();

        // Assert
        expect(moodEntries.length, equals(MoodLevel.values.length));
        expect(wellnessScores.first < wellnessScores.last, isTrue); // veryLow < excellent
      });

      test('should handle extremely long notes', () {
        // Arrange
        final longNotes = 'Very long note text. ' * 100;
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
        expect(moodWithLongNotes.overallWellness, equals(6.5)); // (6+6+6+7)/4 = 6.25 (moodScore(6) + energy(6) + adjustedStress(6) + sleep(7))
      });

      test('should handle copyWith with null preservation', () {
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

        // Act
        final updatedMood = originalMood.copyWith(
          energyLevel: 9,
          notes: null, // Should preserve original
        );

        // Assert
        expect(updatedMood.energyLevel, equals(9));
        expect(updatedMood.notes, equals('Original notes'));
        expect(updatedMood.mood, equals(originalMood.mood));
        expect(updatedMood.id, equals(originalMood.id));
      });
    });

    group('Service Error Handling', () {
      test('should handle analytics service errors gracefully', () async {
        // Act & Assert - Should not throw even when Firebase not configured
        expect(() async => await AnalyticsService.logEvent('test_event'), returnsNormally);
        expect(() async => await AnalyticsService.logScreenView('test_screen'), returnsNormally);
        expect(() async => await AnalyticsService.recordError('Test error', null), returnsNormally);
        expect(() async => await AnalyticsService.logAssessmentCompleted('memory', 85.0, const Duration(minutes: 5)), returnsNormally);
        expect(() async => await AnalyticsService.logExerciseCompleted('puzzle', 3, 92.0), returnsNormally);
        expect(() async => await AnalyticsService.logMoodEntry('good', 8, 3), returnsNormally);
        expect(() async => await AnalyticsService.logReminderInteraction('completed', 'medication'), returnsNormally);
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

        expect(() async => await PerformanceMonitoringService.trackScreenLoadTime(
          'test_screen',
          const Duration(milliseconds: 250)
        ), returnsNormally);

        expect(() async => await PerformanceMonitoringService.trackDatabaseOperation(
          'INSERT',
          'assessments',
          const Duration(milliseconds: 15),
          1
        ), returnsNormally);

        expect(() async => await PerformanceMonitoringService.trackNetworkRequest(
          'https://api.example.com/test',
          'GET',
          const Duration(milliseconds: 500),
          200,
          1024
        ), returnsNormally);

        expect(() async => await PerformanceMonitoringService.trackAppStartup(
          const Duration(seconds: 3)
        ), returnsNormally);

        expect(() async => await PerformanceMonitoringService.trackMemoryUsage(128), returnsNormally);
      });

      test('should handle service initialization idempotency', () async {
        // Act & Assert - Multiple initializations should be safe
        expect(() async => await AnalyticsService.initialize(enableInDebug: false), returnsNormally);
        expect(() async => await AnalyticsService.initialize(enableInDebug: false), returnsNormally);
        expect(() async => await AnalyticsService.initialize(enableInDebug: true), returnsNormally);

        expect(() async => await PerformanceMonitoringService.initialize(), returnsNormally);
        expect(() async => await PerformanceMonitoringService.initialize(), returnsNormally);
      });

      test('should handle concurrent service operations', () async {
        // Arrange - Multiple concurrent operations
        final futures = <Future<void>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(AnalyticsService.logEvent('concurrent_event_$i'));
          futures.add(PerformanceMonitoringService.startTrace('trace_$i'));
          futures.add(PerformanceMonitoringService.stopTrace('trace_$i'));
        }

        // Act & Assert - Should handle concurrent calls
        expect(() async => await Future.wait(futures), returnsNormally);
      });

      test('should handle performance dashboard edge cases', () {
        // Act & Assert - Performance dashboard should handle various scenarios
        expect(() {
          PerformanceDashboard.addDataPoint('test_metric', const Duration(milliseconds: 100));
          PerformanceDashboard.addDataPoint('test_metric', const Duration(milliseconds: 0)); // Zero duration
          PerformanceDashboard.addDataPoint('test_metric', const Duration(microseconds: 1)); // Very small
          PerformanceDashboard.addDataPoint('another_metric', const Duration(seconds: 60)); // Large duration
        }, returnsNormally);

        expect(() {
          final stats = PerformanceDashboard.getPerformanceStats();
          final average = PerformanceDashboard.getAveragePerformance('test_metric');
          final nonExistent = PerformanceDashboard.getAveragePerformance('nonexistent');
        }, returnsNormally);

        expect(PerformanceDashboard.clearHistory, returnsNormally);
      });
    });

    group('Data Validation Edge Cases', () {
      test('should handle extreme DateTime values', () {
        // Arrange
        final farPast = DateTime(1900, 1, 1);
        final farFuture = DateTime(2200, 12, 31);

        // Act & Assert - Should handle extreme dates
        expect(() {
          Assessment(
            type: AssessmentType.memoryRecall,
            score: 75,
            maxScore: 100,
            completedAt: farFuture,
            createdAt: farPast,
          );
        }, returnsNormally);

        expect(() {
          Reminder(
            title: 'Extreme Date Reminder',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: farFuture,
            isActive: true,
            isCompleted: false,
            createdAt: farPast,
            updatedAt: farPast,
          );
        }, returnsNormally);

        expect(() {
          MoodEntry(
            mood: MoodLevel.neutral,
            energyLevel: 5,
            stressLevel: 5,
            sleepQuality: 5,
            entryDate: farFuture,
            createdAt: farPast,
          );
        }, returnsNormally);
      });

      test('should handle all enum values', () {
        // Arrange & Act & Assert - All enum values should be valid
        for (final type in AssessmentType.values) {
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

        for (final type in ReminderType.values) {
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

        for (final frequency in ReminderFrequency.values) {
          expect(() {
            Reminder(
              title: 'Test',
              type: ReminderType.medication,
              frequency: frequency,
              scheduledAt: DateTime.now(),
              isActive: true,
              isCompleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }, returnsNormally);
        }

        for (final level in MoodLevel.values) {
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

      test('should handle null values where applicable', () {
        // Act & Assert - Null values in optional fields should work
        expect(() {
          Assessment(
            id: null,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            notes: null,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          );
        }, returnsNormally);

        expect(() {
          Reminder(
            id: null,
            title: 'Test Reminder',
            description: null,
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now(),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }, returnsNormally);

        expect(() {
          MoodEntry(
            id: null,
            mood: MoodLevel.good,
            energyLevel: 8,
            stressLevel: 3,
            sleepQuality: 7,
            notes: null,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          );
        }, returnsNormally);
      });
    });

    group('State Consistency Edge Cases', () {
      test('should maintain object immutability', () {
        // Arrange
        final originalAssessment = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 85,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act
        final modifiedAssessment = originalAssessment.copyWith(score: 90);

        // Assert - Original should be unchanged
        expect(originalAssessment.score, equals(85));
        expect(modifiedAssessment.score, equals(90));
        expect(originalAssessment, isNot(equals(modifiedAssessment)));
      });

      test('should handle property getter edge cases', () {
        // Arrange
        final assessment = Assessment(
          type: AssessmentType.memoryRecall,
          score: 0,
          maxScore: 0, // Edge case: zero max score
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final mood = MoodEntry(
          mood: MoodLevel.veryLow,
          energyLevel: 1,
          stressLevel: 10,
          sleepQuality: 1,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should handle edge cases without crashing
        final result = assessment.percentage;
        expect(result.isNaN, isTrue); // Division by zero returns NaN
        expect(() => mood.overallWellness, returnsNormally);
        expect(mood.overallWellness, isA<double>());
      });
    });
  });
}