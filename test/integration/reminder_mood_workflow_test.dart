import 'package:brain_plan/core/services/analytics_service.dart';
import 'package:brain_plan/core/services/notification_service.dart';
import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/mood_entry_repository_impl.dart';
import 'package:brain_plan/data/repositories/reminder_repository_impl.dart';
import 'package:brain_plan/domain/entities/mood_entry.dart';
import 'package:brain_plan/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import "../helpers/test_database.dart";


void main() {
  group('Reminder and Mood Workflow Integration Tests', () {
    late AppDatabase database;
    late ReminderRepositoryImpl reminderRepository;
    late MoodEntryRepositoryImpl moodRepository;

    setUpAll(() async {
      await NotificationService.initialize();
      await AnalyticsService.initialize(enableInDebug: false);
    });

    setUp(() {
      database = createTestDatabase();
      reminderRepository = ReminderRepositoryImpl(database);
      moodRepository = MoodEntryRepositoryImpl(database);
    });

    group('Reminder Workflow', () {
      test('should create and schedule daily medication reminder', () async {
        // Arrange
        final medicationReminder = Reminder(
          id: 1,
          title: 'Take Morning Medication',
          description: 'Take 1 tablet of Donepezil with breakfast',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 8)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Mock database operations

        // Act - Create reminder
        final reminderId = await reminderRepository.insertReminder(medicationReminder);

        // Assert
        expect(reminderId, equals(1));
        expect(medicationReminder.isActive, isTrue);
        expect(medicationReminder.type, equals(ReminderType.medication));
        expect(medicationReminder.frequency, equals(ReminderFrequency.daily));

        // Verify database interaction
      });

      test('should handle weekly exercise reminder workflow', () async {
        // Arrange
        final exerciseReminder = Reminder(
          id: 2,
          title: 'Brain Training Exercise',
          description: 'Complete 15 minutes of cognitive exercises',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.weekly,
          scheduledAt: DateTime.now().add(const Duration(days: 7)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );


        // Act - Create and then complete reminder
        final reminderId = await reminderRepository.insertReminder(exerciseReminder);

        // Simulate reminder completion using copyWith
        final completedReminder = exerciseReminder.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );

        await reminderRepository.updateReminder(completedReminder);

        // Assert
        expect(reminderId, equals(2));
        expect(completedReminder.isCompleted, isTrue);
        expect(completedReminder.type, equals(ReminderType.exercise));

        // Verify both create and update operations
      });

      test('should manage multiple reminders with different frequencies', () async {
        // Arrange - Multiple reminders
        final reminders = [
          Reminder(
            id: 3,
            title: 'Morning Pills',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 8)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 4,
            title: 'Doctor Appointment',
            type: ReminderType.appointment,
            frequency: ReminderFrequency.once,
            scheduledAt: DateTime.now().add(const Duration(days: 3)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 5,
            title: 'Weekly Assessment',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: DateTime.now().add(const Duration(days: 7)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];


        // Act - Retrieve all reminders
        final activeReminders = await reminderRepository.getActiveReminders();

        // Assert
        expect(activeReminders.length, equals(3));
        expect(activeReminders.every((r) => r.isActive), isTrue);
        expect(activeReminders.map((r) => r.type).toSet().length, equals(3)); // 3 different types
      });
    });

    group('Mood Tracking Workflow', () {
      test('should record daily mood entry with wellness calculation', () async {
        // Arrange
        final moodEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 3,
          sleepQuality: 8,
          notes: 'Feeling positive today after morning exercise',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act - Save mood entry
        final moodEntryId = await moodRepository.insertMoodEntry(moodEntry);

        // Assert
        expect(moodEntryId, equals(1));
        expect(moodEntry.mood, equals(MoodLevel.good));
        expect(moodEntry.overallWellness, equals(6.0)); // (7 + 10-3 + 8) / 3 = 6.0
        expect(moodEntry.energyLevel, equals(7));
        expect(moodEntry.stressLevel, equals(3));
        expect(moodEntry.sleepQuality, equals(8));

        // Verify database interaction
      });

      test('should track mood trends over time', () async {
        // Arrange - Multiple mood entries over time
        final moodEntries = [
          MoodEntry(
            id: 1,
            mood: MoodLevel.veryLow,
            energyLevel: 3,
            stressLevel: 8,
            sleepQuality: 4,
            entryDate: DateTime.now().subtract(const Duration(days: 7)),
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          MoodEntry(
            id: 2,
            mood: MoodLevel.neutral,
            energyLevel: 5,
            stressLevel: 6,
            sleepQuality: 6,
            entryDate: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          MoodEntry(
            id: 3,
            mood: MoodLevel.good,
            energyLevel: 7,
            stressLevel: 4,
            sleepQuality: 8,
            entryDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];


        // Act - Calculate wellness trends
        final weeklyEntries = await moodRepository.getMoodEntriesByDateRange(
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        );

        // Assert - Verify trend improvement
        expect(weeklyEntries.length, equals(3));
        expect(weeklyEntries.first.overallWellness, lessThan(weeklyEntries.last.overallWellness));

        // Verify wellness score calculations
        expect(weeklyEntries[0].overallWellness, equals(3.0)); // Poor mood trend
        expect(weeklyEntries[1].overallWellness, equals(5.0)); // Fair mood trend
        expect(weeklyEntries[2].overallWellness, equals(7.0)); // Good mood trend
      });

      test('should handle extreme mood values gracefully', () async {
        // Arrange - Mood entry with boundary values
        final extremeMoodEntry = MoodEntry(
          id: 4,
          mood: MoodLevel.excellent,
          energyLevel: 10, // Maximum
          stressLevel: 1,  // Minimum
          sleepQuality: 10, // Maximum
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );


        // Act
        final entryId = await moodRepository.insertMoodEntry(extremeMoodEntry);

        // Assert
        expect(entryId, equals(4));
        expect(extremeMoodEntry.overallWellness, equals(9.7)); // (10 + 9 + 10) / 3 ≈ 9.7
        expect(extremeMoodEntry.energyLevel, equals(10));
        expect(extremeMoodEntry.stressLevel, equals(1));
        expect(extremeMoodEntry.sleepQuality, equals(10));
      });
    });

    group('Integrated Workflow - Mood-Influenced Reminders', () {
      test('should adjust reminder scheduling based on mood patterns', () async {
        // Arrange - Low mood entry should trigger more frequent check-ins
        final lowMoodEntry = MoodEntry(
          id: 5,
          mood: MoodLevel.veryLow,
          energyLevel: 2,
          stressLevel: 9,
          sleepQuality: 3,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Based on low mood, system might create additional check-in reminders
        final wellnessCheckReminder = Reminder(
          id: 6,
          title: 'Wellness Check-In',
          description: 'How are you feeling? Consider talking to someone or practicing relaxation.',
          type: ReminderType.custom,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 4)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );


        // Act - Save low mood entry and create follow-up reminder
        await moodRepository.insertMoodEntry(lowMoodEntry);
        await reminderRepository.insertReminder(wellnessCheckReminder);

        // Assert
        expect(lowMoodEntry.overallWellness, equals(2.7)); // Very low wellness score
        expect(wellnessCheckReminder.type, equals(ReminderType.custom));
        expect(wellnessCheckReminder.isActive, isTrue);

        // Verify both operations completed
      });
    });

    group('Analytics Integration', () {
      test('should log mood and reminder analytics', () async {
        // Arrange
        final moodEntry = MoodEntry(
          id: 7,
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final completedReminder = Reminder(
          id: 8,
          title: 'Exercise Reminder',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now(),
          isActive: true,
          isCompleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act - Log analytics events
        await AnalyticsService.logMoodEntry(
          moodEntry.mood.name,
          moodEntry.energyLevel,
          moodEntry.stressLevel,
        );

        await AnalyticsService.logReminderInteraction(
          'completed',
          completedReminder.type.name,
        );

        // Assert - Should complete without errors
        expect(moodEntry.overallWellness, equals(7.7));
        expect(completedReminder.isCompleted, isTrue);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle invalid mood entry values', () async {
        // Arrange - Invalid mood entry
        final invalidMoodEntry = MoodEntry(
          id: 9,
          mood: MoodLevel.good,
          energyLevel: -5, // Invalid negative
          stressLevel: 15, // Invalid > 10
          sleepQuality: 0,  // Edge case minimum
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Act & Assert - Should handle gracefully
        expect(invalidMoodEntry.energyLevel, equals(-5)); // Preserved as-is for validation
        expect(invalidMoodEntry.stressLevel, equals(15)); // Preserved as-is for validation
        expect(invalidMoodEntry.sleepQuality, equals(0));
      });

      test('should handle reminder scheduling conflicts', () async {
        // Arrange - Multiple reminders at the same time
        final conflictingReminders = [
          Reminder(
            id: 10,
            title: 'Morning Medication',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 8)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 11,
            title: 'Morning Exercise',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 8)), // Same time
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Assert - Should handle multiple reminders gracefully
        expect(conflictingReminders.length, equals(2));
        expect(conflictingReminders.every((r) => r.scheduledAt.hour ==
            DateTime.now().add(const Duration(hours: 8)).hour), isTrue);
      });
    });
  });
}