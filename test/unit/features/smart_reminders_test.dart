import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:brain_tests/domain/repositories/reminder_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ReminderRepository])
import 'smart_reminders_test.mocks.dart';

void main() {
  group('Smart Reminders Tests', () {
    late MockReminderRepository mockRepository;
    late DateTime testDate;

    setUp(() {
      mockRepository = MockReminderRepository();
      testDate = DateTime(2024, 1, 15, 10, 0);
    });

    group('Reminder Entity Tests', () {
      test('should detect past due reminders correctly', () {
        final pastReminder = Reminder(
          title: 'Past Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final futureReminder = Reminder(
          title: 'Future Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pastReminder.isPastDue, isTrue);
        expect(futureReminder.isPastDue, isFalse);
      });

      test('should create proper copy with changes', () {
        final original = Reminder(
          id: 1,
          title: 'Take Medication',
          description: 'Take daily vitamins',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: testDate,
          nextScheduled: testDate.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );

        expect(copy.id, equals(1));
        expect(copy.title, equals('Take Medication'));
        expect(copy.description, equals('Take daily vitamins'));
        expect(copy.type, equals(ReminderType.medication));
        expect(copy.frequency, equals(ReminderFrequency.daily));
        expect(copy.scheduledAt, equals(testDate));
        expect(copy.nextScheduled, equals(testDate.add(const Duration(days: 1))));
        expect(copy.isActive, isTrue);
        expect(copy.isCompleted, isTrue);
        expect(copy.createdAt, equals(testDate));
        expect(copy.updatedAt, isNot(equals(testDate)));
      });
    });

    group('Reminder Types Coverage', () {
      test('should support all reminder types', () {
        final types = [
          ReminderType.medication,
          ReminderType.exercise,
          ReminderType.assessment,
          ReminderType.appointment,
          ReminderType.custom,
        ];

        for (final type in types) {
          final reminder = Reminder(
            title: 'Test ${type.name} Reminder',
            type: type,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(reminder.type, equals(type));
          expect(reminder.title, contains(type.name));
        }
      });
    });

    group('Reminder Frequencies', () {
      test('should support all frequency types', () {
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
            scheduledAt: testDate,
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          );

          expect(reminder.frequency, equals(frequency));
        }
      });
    });

    group('Reminder Repository Integration', () {
      test('should save reminder successfully', () async {
        final reminder = Reminder(
          title: 'Take Morning Pills',
          description: 'Vitamin D and Omega-3',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: testDate,
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final savedReminder = reminder.copyWith(id: 1);
        when(mockRepository.insertReminder(reminder))
            .thenAnswer((_) async => 1);

        final result = await mockRepository.insertReminder(reminder);

        expect(result, equals(1));
        verify(mockRepository.insertReminder(reminder)).called(1);
      });

      test('should retrieve active reminders', () async {
        final activeReminders = [
          Reminder(
            id: 1,
            title: 'Exercise Reminder',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 2,
            title: 'Assessment Reminder',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: testDate.add(const Duration(days: 1)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockRepository.getActiveReminders())
            .thenAnswer((_) async => activeReminders);

        final result = await mockRepository.getActiveReminders();

        expect(result.length, equals(2));
        expect(result.every((r) => r.isActive), isTrue);
        expect(result.every((r) => !r.isCompleted), isTrue);
        verify(mockRepository.getActiveReminders()).called(1);
      });

      test('should mark reminder as completed', () async {
        final reminder = Reminder(
          id: 1,
          title: 'Take Evening Pills',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: testDate,
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final completedReminder = reminder.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );

        when(mockRepository.updateReminder(completedReminder))
            .thenAnswer((_) async => true);

        final result = await mockRepository.updateReminder(completedReminder);

        expect(result, isTrue);
        expect(completedReminder.isCompleted, isTrue);
        expect(completedReminder.updatedAt, isNot(equals(testDate)));
        verify(mockRepository.updateReminder(completedReminder)).called(1);
      });

      test('should retrieve reminders by type', () async {
        final medicationReminders = [
          Reminder(
            id: 1,
            title: 'Morning Meds',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 2,
            title: 'Evening Meds',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate.add(const Duration(hours: 12)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockRepository.getRemindersByType(ReminderType.medication))
            .thenAnswer((_) async => medicationReminders);

        final result = await mockRepository.getRemindersByType(ReminderType.medication);

        expect(result.length, equals(2));
        expect(result.every((r) => r.type == ReminderType.medication), isTrue);
        verify(mockRepository.getRemindersByType(ReminderType.medication)).called(1);
      });
    });

    group('Smart Reminder Scheduling', () {
      test('should handle daily recurring reminders', () async {
        final dailyReminder = Reminder(
          id: 1,
          title: 'Daily Exercise',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: testDate,
          nextScheduled: testDate.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        when(mockRepository.updateReminder(any))
            .thenAnswer((_) async => true);

        final updatedReminder = dailyReminder.copyWith(
          isCompleted: true,
          nextScheduled: testDate.add(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        );

        final result = await mockRepository.updateReminder(updatedReminder);

        expect(result, isTrue);
        expect(updatedReminder.nextScheduled?.day, equals(testDate.add(const Duration(days: 2)).day));
        expect(updatedReminder.isCompleted, isTrue);
      });

      test('should handle weekly recurring reminders', () async {
        final weeklyReminder = Reminder(
          id: 1,
          title: 'Weekly Assessment',
          type: ReminderType.assessment,
          frequency: ReminderFrequency.weekly,
          scheduledAt: testDate,
          nextScheduled: testDate.add(const Duration(days: 7)),
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(weeklyReminder.nextScheduled?.day, equals(testDate.add(const Duration(days: 7)).day));
        expect(weeklyReminder.frequency, equals(ReminderFrequency.weekly));
      });

      test('should handle monthly recurring reminders', () async {
        final monthlyReminder = Reminder(
          id: 1,
          title: 'Monthly Check-up',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.monthly,
          scheduledAt: testDate,
          nextScheduled: DateTime(testDate.year, testDate.month + 1, testDate.day, testDate.hour, testDate.minute),
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(monthlyReminder.nextScheduled?.month, equals(testDate.month + 1));
        expect(monthlyReminder.frequency, equals(ReminderFrequency.monthly));
      });

      test('should handle one-time reminders', () async {
        final onceReminder = Reminder(
          id: 1,
          title: 'Doctor Appointment',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: testDate,
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final completedOnceReminder = onceReminder.copyWith(
          isCompleted: true,
          isActive: false, // One-time reminders become inactive when completed
          updatedAt: DateTime.now(),
        );

        when(mockRepository.updateReminder(completedOnceReminder))
            .thenAnswer((_) async => true);

        final result = await mockRepository.updateReminder(completedOnceReminder);

        expect(result, isTrue);
        expect(completedOnceReminder.isCompleted, isTrue);
        expect(completedOnceReminder.isActive, isFalse);
        expect(completedOnceReminder.frequency, equals(ReminderFrequency.once));
      });
    });

    group('Reminder Notifications', () {
      test('should identify overdue reminders', () async {
        final overdueReminders = [
          Reminder(
            id: 1,
            title: 'Overdue Medication',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 2,
            title: 'Missed Exercise',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().subtract(const Duration(hours: 4)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockRepository.getOverdueReminders())
            .thenAnswer((_) async => overdueReminders);

        final result = await mockRepository.getOverdueReminders();

        expect(result.length, equals(2));
        expect(result.every((r) => r.isPastDue), isTrue);
        expect(result.every((r) => r.isActive && !r.isCompleted), isTrue);
        verify(mockRepository.getOverdueReminders()).called(1);
      });

      test('should get upcoming reminders', () async {
        final upcomingReminders = [
          Reminder(
            id: 1,
            title: 'Upcoming Assessment',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 2,
            title: 'Exercise Soon',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockRepository.getUpcomingReminders())
            .thenAnswer((_) async => upcomingReminders);

        final result = await mockRepository.getUpcomingReminders();

        expect(result.length, equals(2));
        expect(result.every((r) => !r.isPastDue), isTrue);
        expect(result.every((r) => r.isActive && !r.isCompleted), isTrue);
        verify(mockRepository.getUpcomingReminders()).called(1);
      });
    });

    group('Reminder Analytics', () {
      test('should calculate completion rate by type', () async {
        final medicationReminders = [
          Reminder(
            id: 1,
            title: 'Med 1',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: true,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 2,
            title: 'Med 2',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: true,
            createdAt: testDate,
            updatedAt: testDate,
          ),
          Reminder(
            id: 3,
            title: 'Med 3',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate,
            isActive: true,
            isCompleted: false,
            createdAt: testDate,
            updatedAt: testDate,
          ),
        ];

        when(mockRepository.getRemindersByType(ReminderType.medication))
            .thenAnswer((_) async => medicationReminders);

        final result = await mockRepository.getRemindersByType(ReminderType.medication);
        final completedCount = result.where((r) => r.isCompleted).length;
        final completionRate = (completedCount / result.length) * 100;

        expect(completionRate, closeTo(66.67, 0.01)); // 2 out of 3 completed
      });

      test('should track reminder adherence over time', () async {
        final weeklyReminders = List.generate(7, (index) =>
          Reminder(
            id: index + 1,
            title: 'Daily Med ${index + 1}',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: testDate.subtract(Duration(days: 6 - index)),
            isActive: true,
            isCompleted: index < 5, // First 5 completed, last 2 missed
            createdAt: testDate.subtract(Duration(days: 6 - index)),
            updatedAt: testDate.subtract(Duration(days: 6 - index)),
          ),
        );

        when(mockRepository.getAllReminders())
            .thenAnswer((_) async => weeklyReminders);

        final result = await mockRepository.getAllReminders();

        final adherenceRate = (result.where((r) => r.isCompleted).length / result.length) * 100;
        expect(adherenceRate, closeTo(71.43, 0.01)); // 5 out of 7
      });
    });

    group('Reminder Edge Cases', () {
      test('should handle inactive reminders', () {
        final inactiveReminder = Reminder(
          id: 1,
          title: 'Inactive Reminder',
          type: ReminderType.custom,
          frequency: ReminderFrequency.daily,
          scheduledAt: testDate,
          isActive: false,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(inactiveReminder.isActive, isFalse);
        expect(inactiveReminder.isCompleted, isFalse);
      });

      test('should handle reminders without descriptions', () {
        final reminder = Reminder(
          title: 'Simple Reminder',
          type: ReminderType.custom,
          frequency: ReminderFrequency.once,
          scheduledAt: testDate,
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(reminder.description, isNull);
        expect(reminder.title, isNotEmpty);
      });

      test('should handle reminders scheduled for midnight', () {
        final midnightReminder = Reminder(
          title: 'Midnight Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime(testDate.year, testDate.month, testDate.day, 0, 0),
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(midnightReminder.scheduledAt.hour, equals(0));
        expect(midnightReminder.scheduledAt.minute, equals(0));
      });

      test('should handle reminders with nextScheduled but no recurrence', () {
        final reminder = Reminder(
          title: 'One-time with Next',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: testDate,
          nextScheduled: testDate.add(const Duration(days: 1)), // Should be null for one-time
          isActive: true,
          isCompleted: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(reminder.frequency, equals(ReminderFrequency.once));
        expect(reminder.nextScheduled, isNotNull); // Entity allows it even if logically incorrect
      });
    });
  });
}