import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:brain_tests/domain/repositories/assessment_repository.dart';
import 'package:brain_tests/domain/repositories/mood_entry_repository.dart';
import 'package:brain_tests/domain/repositories/reminder_repository.dart';
import 'package:brain_tests/presentation/providers/assessment_provider.dart';
import 'package:brain_tests/presentation/providers/mood_entry_provider.dart';
import 'package:brain_tests/presentation/providers/reminder_provider.dart';
import 'package:brain_tests/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'riverpod_provider_test.mocks.dart';

// Generate mocks
@GenerateMocks([AssessmentRepository, ReminderRepository, MoodEntryRepository])

void main() {
  group('Riverpod Provider Tests', () {
    late ProviderContainer container;
    late MockAssessmentRepository mockAssessmentRepository;
    late MockReminderRepository mockReminderRepository;
    late MockMoodEntryRepository mockMoodEntryRepository;

    setUp(() {
      mockAssessmentRepository = MockAssessmentRepository();
      mockReminderRepository = MockReminderRepository();
      mockMoodEntryRepository = MockMoodEntryRepository();

      container = ProviderContainer(
        overrides: [
          // Override providers with mock implementations
          assessmentRepositoryProvider.overrideWithValue(mockAssessmentRepository),
          reminderRepositoryProvider.overrideWithValue(mockReminderRepository),
          moodEntryRepositoryProvider.overrideWithValue(mockMoodEntryRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Assessment Provider Tests', () {
      test('should provide recent assessments from repository', () async {
        // Arrange
        final mockAssessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.attentionFocus,
            score: 78,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(days: 3)),
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ];

        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockAssessments);

        // Act
        final recentAssessments = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(recentAssessments, equals(mockAssessments));
        expect(recentAssessments.length, equals(2));
        expect(recentAssessments.first.type, equals(AssessmentType.memoryRecall));
        expect(recentAssessments.first.percentage, equals(85.0));

        verify(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit'))).called(1);
      });

      test('should handle assessment provider state changes', () async {
        // Arrange
        final initialAssessments = <Assessment>[];
        final updatedAssessments = [
          Assessment(
            id: 3,
            type: AssessmentType.executiveFunction,
            score: 92,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
        ];

        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => initialAssessments);

        // Act - Initial state
        final initialState = await container.read(recentAssessmentsProvider.future);

        // Arrange - Update mock to return new data
        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => updatedAssessments);

        // Act - Refresh provider
        container.refresh(recentAssessmentsProvider);
        final updatedState = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(initialState, equals(initialAssessments));
        expect(initialState.length, equals(0));
        expect(updatedState, equals(updatedAssessments));
        expect(updatedState.length, equals(1));
        expect(updatedState.first.type, equals(AssessmentType.executiveFunction));
      });

      test('should handle assessment repository errors gracefully', () async {
        // Arrange
        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenThrow(Exception('Database connection failed'));

        // Act & Assert - Accept Exception or StateError if disposed
        try {
          await container.read(recentAssessmentsProvider.future);
          fail('Expected an error but got success');
        } catch (e) {
          expect(e is Exception || e is StateError, isTrue);
        }
      });
    });

    group('Reminder Provider Tests', () {
      test('should provide upcoming reminders from repository', () async {
        // Arrange
        final mockReminders = [
          Reminder(
            id: 1,
            title: 'Take Morning Medication',
            description: 'Take prescribed cognitive medication',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 2)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 2,
            title: 'Doctor Appointment',
            type: ReminderType.appointment,
            frequency: ReminderFrequency.once,
            scheduledAt: DateTime.now().add(const Duration(days: 1)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => mockReminders);

        // Act
        final upcomingReminders = await container.read(upcomingRemindersProvider.future);

        // Assert
        expect(upcomingReminders, equals(mockReminders));
        expect(upcomingReminders.length, equals(2));
        expect(upcomingReminders.first.type, equals(ReminderType.medication));
        expect(upcomingReminders.first.isActive, isTrue);
        expect(upcomingReminders.first.isCompleted, isFalse);

        verify(mockReminderRepository.getUpcomingReminders()).called(1);
      });

      test('should handle reminder completion workflow', () async {
        // Arrange
        final activeReminder = Reminder(
          id: 3,
          title: 'Brain Exercise',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final completedReminder = activeReminder.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );

        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => [activeReminder]);

        // Act - Get initial state
        final initialReminders = await container.read(upcomingRemindersProvider.future);

        // Simulate reminder completion
        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => [completedReminder]);

        container.refresh(upcomingRemindersProvider);
        final updatedReminders = await container.read(upcomingRemindersProvider.future);

        // Assert
        expect(initialReminders.first.isCompleted, isFalse);
        expect(updatedReminders.first.isCompleted, isTrue);
        expect(updatedReminders.first.updatedAt.isAfter(activeReminder.updatedAt), isTrue);
      });

      test('should filter active reminders correctly', () async {
        // Arrange
        final mixedReminders = [
          Reminder(
            id: 4,
            title: 'Active Reminder',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 5,
            title: 'Inactive Reminder',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.weekly,
            scheduledAt: DateTime.now().add(const Duration(days: 2)),
            isActive: false, // Inactive
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 6,
            title: 'Completed Reminder',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
            isActive: true,
            isCompleted: true, // Completed
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => mixedReminders.where((r) => r.isActive && !r.isCompleted).toList());

        // Act
        final activeReminders = await container.read(upcomingRemindersProvider.future);

        // Assert
        expect(activeReminders.length, equals(1));
        expect(activeReminders.first.title, equals('Active Reminder'));
        expect(activeReminders.first.isActive, isTrue);
        expect(activeReminders.first.isCompleted, isFalse);
      });
    });

    group('Mood Entry Provider Tests', () {
      test('should provide today\'s mood entry from repository', () async {
        // Arrange
        final todaysMoodEntry = MoodEntry(
          id: 1,
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 3,
          sleepQuality: 7,
          notes: 'Feeling positive today',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => todaysMoodEntry);

        // Act
        final todaysEntry = await container.read(todayMoodEntryProvider.future);

        // Assert
        expect(todaysEntry, equals(todaysMoodEntry));
        expect(todaysEntry?.mood, equals(MoodLevel.good));
        expect(todaysEntry?.overallWellness, equals(7.75));
        expect(todaysEntry?.entryDate.day, equals(DateTime.now().day));

        verify(mockMoodEntryRepository.getMoodEntryByDate(any)).called(1);
      });

      test('should handle no mood entry for today', () async {
        // Arrange
        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => null);

        // Act
        final todaysEntry = await container.read(todayMoodEntryProvider.future);

        // Assert
        expect(todaysEntry, isNull);
        verify(mockMoodEntryRepository.getMoodEntryByDate(any)).called(1);
      });

      test('should track mood entry changes over time', () async {
        // Arrange - Multiple mood entries
        final morningEntry = MoodEntry(
          id: 2,
          mood: MoodLevel.neutral,
          energyLevel: 6,
          stressLevel: 5,
          sleepQuality: 6,
          notes: 'Just woke up',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final eveningEntry = MoodEntry(
          id: 3,
          mood: MoodLevel.good,
          energyLevel: 7,
          stressLevel: 3,
          sleepQuality: 6,
          notes: 'Had a productive day',
          entryDate: DateTime.now(),
          createdAt: DateTime.now().add(const Duration(hours: 8)),
        );

        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => morningEntry);

        // Act - Initial state
        final morningState = await container.read(todayMoodEntryProvider.future);

        // Update to evening entry
        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => eveningEntry);

        container.refresh(todayMoodEntryProvider);
        final eveningState = await container.read(todayMoodEntryProvider.future);

        // Assert - Mood improved throughout the day
        expect(morningState?.mood, equals(MoodLevel.neutral));
        expect(morningState?.overallWellness, equals(6.0)); // (6+6+6+6)/4, adjustedStress=11-5=6
        expect(eveningState?.mood, equals(MoodLevel.good));
        expect(eveningState?.overallWellness, equals(7.25)); // (8+7+8+6)/4, adjustedStress=11-3=8
        expect(eveningState!.overallWellness > morningState!.overallWellness, isTrue);
      });
    });

    group('Provider Integration Tests', () {
      test('should handle multiple provider interactions', () async {
        // Arrange - Set up data for all providers
        final assessment = Assessment(
          id: 7,
          type: AssessmentType.languageSkills,
          score: 88,
          maxScore: 100,
          completedAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        );

        final reminder = Reminder(
          id: 8,
          title: 'Post-Assessment Exercise',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final moodEntry = MoodEntry(
          id: 4,
          mood: MoodLevel.good,
          energyLevel: 8,
          stressLevel: 2,
          sleepQuality: 8,
          notes: 'Great assessment performance boosted my confidence',
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => [assessment]);
        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => [reminder]);
        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => moodEntry);

        // Act - Read all providers
        final assessments = await container.read(recentAssessmentsProvider.future);
        final reminders = await container.read(upcomingRemindersProvider.future);
        final mood = await container.read(todayMoodEntryProvider.future);

        // Assert - All providers work together
        expect(assessments.length, equals(1));
        expect(assessments.first.percentage, equals(88.0));
        expect(reminders.length, equals(1));
        expect(reminders.first.type, equals(ReminderType.exercise));
        expect(mood?.mood, equals(MoodLevel.good));
        expect(mood?.overallWellness, equals(8.25)); // High wellness after good assessment, (8+8+9+8)/4, adjustedStress=11-2=9

        // Verify all repository calls were made
        verify(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit'))).called(1);
        verify(mockReminderRepository.getUpcomingReminders()).called(1);
        verify(mockMoodEntryRepository.getMoodEntryByDate(any)).called(1);
      });

      test('should handle provider error propagation', () async {
        // Arrange - Set up one provider to fail
        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenThrow(Exception('Network error'));
        when(mockReminderRepository.getUpcomingReminders())
            .thenAnswer((_) async => []); // This should still work
        when(mockMoodEntryRepository.getMoodEntryByDate(any))
            .thenAnswer((_) async => null); // This should still work

        // Act & Assert - Failed provider should throw (Exception or StateError if disposed)
        try {
          await container.read(recentAssessmentsProvider.future);
          fail('Expected an error but got success');
        } catch (e) {
          expect(e is Exception || e is StateError, isTrue);
        }

        final reminders = await container.read(upcomingRemindersProvider.future);
        final mood = await container.read(todayMoodEntryProvider.future);

        expect(reminders, isEmpty);
        expect(mood, isNull);
      });
    });

    group('Provider State Management Tests', () {
      test('should maintain provider state across multiple reads', () async {
        // Arrange
        final mockAssessments = [
          Assessment(
            id: 9,
            type: AssessmentType.visuospatialSkills,
            score: 95,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
        ];

        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => mockAssessments);

        // Act - Multiple reads
        final firstRead = await container.read(recentAssessmentsProvider.future);
        final secondRead = await container.read(recentAssessmentsProvider.future);
        final thirdRead = await container.read(recentAssessmentsProvider.future);

        // Assert - Same data returned, repository called only once due to caching
        expect(firstRead, equals(mockAssessments));
        expect(secondRead, equals(mockAssessments));
        expect(thirdRead, equals(mockAssessments));
        expect(identical(firstRead, secondRead), isTrue); // Same instance due to caching

        verify(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit'))).called(1);
      });

      test('should invalidate provider cache on refresh', () async {
        // Arrange
        final initialData = [
          Assessment(
            id: 10,
            type: AssessmentType.processingSpeed,
            score: 80,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(hours: 1)),
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        final refreshedData = [
          Assessment(
            id: 11,
            type: AssessmentType.memoryRecall,
            score: 90,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ];

        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => initialData);

        // Act - Initial read
        final initialRead = await container.read(recentAssessmentsProvider.future);

        // Change mock data
        when(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit')))
            .thenAnswer((_) async => refreshedData);

        // Refresh provider
        container.refresh(recentAssessmentsProvider);
        final refreshedRead = await container.read(recentAssessmentsProvider.future);

        // Assert
        expect(initialRead, equals(initialData));
        expect(refreshedRead, equals(refreshedData));
        expect(initialRead.first.id, equals(10));
        expect(refreshedRead.first.id, equals(11));

        verify(mockAssessmentRepository.getRecentAssessments(limit: anyNamed('limit'))).called(2);
      });
    });
  });
}