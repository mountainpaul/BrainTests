import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/reminder_repository_impl.dart';
import 'package:brain_plan/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('ReminderRepositoryImpl Integration Tests', () {
    late AppDatabase database;
    late ReminderRepositoryImpl repository;

    setUp(() async {
      database = createTestDatabase();
      repository = ReminderRepositoryImpl(database);
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    group('CRUD Operations', () {
      test('should insert and retrieve reminder', () async {
        final reminder = Reminder(
          title: 'Take Morning Pills',
          description: 'Vitamin D and Omega-3',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          nextScheduled: DateTime.now().add(const Duration(days: 1, hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await repository.insertReminder(reminder);

        expect(id, greaterThan(0));

        final retrieved = await repository.getReminderById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals('Take Morning Pills'));
        expect(retrieved.description, equals('Vitamin D and Omega-3'));
        expect(retrieved.type, equals(ReminderType.medication));
        expect(retrieved.frequency, equals(ReminderFrequency.daily));
        expect(retrieved.isActive, isTrue);
        expect(retrieved.isCompleted, isFalse);
        expect(retrieved.isPastDue, isFalse);
      });

      test('should update existing reminder', () async {
        final reminder = Reminder(
          title: 'Doctor Appointment',
          description: 'Annual check-up',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime.now().add(const Duration(days: 7)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await repository.insertReminder(reminder);
        final inserted = await repository.getReminderById(id);

        final updated = inserted!.copyWith(
          title: 'Updated Doctor Appointment',
          description: 'Annual check-up with Dr. Smith',
        );

        final result = await repository.updateReminder(updated);

        expect(result, isTrue);

        final retrieved = await repository.getReminderById(id);

        expect(retrieved!.title, equals('Updated Doctor Appointment'));
        expect(retrieved.description, equals('Annual check-up with Dr. Smith'));
      });

      test('should delete reminder', () async {
        final reminder = Reminder(
          title: 'Temporary Reminder',
          type: ReminderType.custom,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await repository.insertReminder(reminder);

        final retrieved = await repository.getReminderById(id);
        expect(retrieved, isNotNull);

        final result = await repository.deleteReminder(id);
        expect(result, isTrue);

        final afterDelete = await repository.getReminderById(id);
        expect(afterDelete, isNull);
      });

      test('should mark reminder as completed', () async {
        final reminder = Reminder(
          title: 'Exercise Session',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await repository.insertReminder(reminder);

        final result = await repository.markReminderCompleted(id);
        expect(result, isTrue);

        final retrieved = await repository.getReminderById(id);
        expect(retrieved!.isCompleted, isTrue);
      });

      test('should snooze reminder', () async {
        final originalTime = DateTime.now().add(const Duration(minutes: 30));
        final reminder = Reminder(
          title: 'Snooze Test',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: originalTime,
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final id = await repository.insertReminder(reminder);

        final result = await repository.snoozeReminder(id, const Duration(minutes: 15));
        expect(result, isTrue);

        final retrieved = await repository.getReminderById(id);
        expect(retrieved!.scheduledAt.isAfter(originalTime), isTrue);
      });
    });

    group('Query Operations', () {
      setUp(() async {
        final now = DateTime.now();

        final testReminders = [
          // Past overdue reminder
          Reminder(
            title: 'Overdue Medication',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: now.subtract(const Duration(hours: 2)),
            isActive: true,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          // Upcoming today
          Reminder(
            title: 'Upcoming Exercise',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: now.add(const Duration(hours: 2)),
            isActive: true,
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ),
          // Completed reminder
          Reminder(
            title: 'Completed Assessment',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: now.subtract(const Duration(hours: 1)),
            isActive: true,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(hours: 1)),
          ),
          // Inactive reminder
          Reminder(
            title: 'Inactive Reminder',
            type: ReminderType.custom,
            frequency: ReminderFrequency.once,
            scheduledAt: now.add(const Duration(hours: 1)),
            isActive: false,
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        for (final reminder in testReminders) {
          await repository.insertReminder(reminder);
        }
      });

      test('should get all reminders', () async {
        final result = await repository.getAllReminders();

        expect(result.length, equals(4));
      });

      test('should get active reminders only', () async {
        final result = await repository.getActiveReminders();

        expect(result.length, equals(3)); // Excludes inactive reminder
        expect(result.every((r) => r.isActive), isTrue);
      });

      test('should get reminders by type', () async {
        final medicationReminders = await repository.getRemindersByType(
          ReminderType.medication);

        expect(medicationReminders.length, equals(1));
        expect(medicationReminders.first.type, equals(ReminderType.medication));
        expect(medicationReminders.first.title, equals('Overdue Medication'));
      });

      test('should get upcoming reminders for today', () async {
        final result = await repository.getUpcomingReminders();

        expect(result.length, equals(1));
        expect(result.first.title, equals('Upcoming Exercise'));
        expect(result.first.isActive, isTrue);
        expect(result.first.isCompleted, isFalse);
      });

      test('should get overdue reminders', () async {
        final result = await repository.getOverdueReminders();

        expect(result.length, equals(1));
        expect(result.first.title, equals('Overdue Medication'));
        expect(result.first.isActive, isTrue);
        expect(result.first.isCompleted, isFalse);
        expect(result.first.isPastDue, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty database', () async {
        final allReminders = await repository.getAllReminders();
        final activeReminders = await repository.getActiveReminders();
        final upcomingReminders = await repository.getUpcomingReminders();
        final overdueReminders = await repository.getOverdueReminders();

        expect(allReminders.isEmpty, isTrue);
        expect(activeReminders.isEmpty, isTrue);
        expect(upcomingReminders.isEmpty, isTrue);
        expect(overdueReminders.isEmpty, isTrue);
      });

      test('should handle snoozing non-existent reminder', () async {
        final result = await repository.snoozeReminder(999, const Duration(minutes: 15));

        expect(result, isFalse);
      });

      test('should return false when updating reminder without ID', () async {
        final reminder = Reminder(
          title: 'No ID',
          type: ReminderType.custom,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime.now(),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await repository.updateReminder(reminder);

        expect(result, isFalse);
      });
    });
  });
}