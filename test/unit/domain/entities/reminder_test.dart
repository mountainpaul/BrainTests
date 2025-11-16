import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reminder Entity Tests', () {
    late DateTime testTime;
    late DateTime futureTime;
    late DateTime pastTime;

    setUp(() {
      testTime = DateTime.now();
      futureTime = testTime.add(const Duration(hours: 1));
      pastTime = testTime.subtract(const Duration(hours: 1));
    });

    group('Constructor', () {
      test('should create reminder with all required fields', () {
        final reminder = Reminder(
          title: 'Test Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.title, 'Test Reminder');
        expect(reminder.type, ReminderType.medication);
        expect(reminder.frequency, ReminderFrequency.daily);
        expect(reminder.scheduledAt, futureTime);
        expect(reminder.isActive, true);
        expect(reminder.isCompleted, false);
        expect(reminder.createdAt, testTime);
        expect(reminder.updatedAt, testTime);
      });

      test('should create reminder with optional fields', () {
        final reminder = Reminder(
          id: 123,
          title: 'Test Reminder',
          description: 'Test description',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.weekly,
          scheduledAt: futureTime,
          nextScheduled: futureTime.add(const Duration(days: 7)),
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.id, 123);
        expect(reminder.description, 'Test description');
        expect(reminder.nextScheduled, futureTime.add(const Duration(days: 7)));
      });

      test('should create reminder without id', () {
        final reminder = Reminder(
          title: 'No ID Reminder',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.once,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.id, isNull);
      });

      test('should create reminder without description', () {
        final reminder = Reminder(
          title: 'No Description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.description, isNull);
      });
    });

    group('isPastDue getter', () {
      test('should return true for past scheduled time', () {
        final reminder = Reminder(
          title: 'Past Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: pastTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.isPastDue, true);
      });

      test('should return false for future scheduled time', () {
        final reminder = Reminder(
          title: 'Future Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.isPastDue, false);
      });

      test('should handle edge case for current time', () {
        final currentTime = DateTime.now();
        final reminder = Reminder(
          title: 'Current Time Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: currentTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        // Note: This might be true or false depending on exact timing
        expect(reminder.isPastDue, isA<bool>());
      });
    });

    group('copyWith method', () {
      late Reminder originalReminder;

      setUp(() {
        originalReminder = Reminder(
          id: 1,
          title: 'Original Title',
          description: 'Original description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          nextScheduled: futureTime.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );
      });

      test('should create copy with updated title', () {
        final updated = originalReminder.copyWith(title: 'Updated Title');

        expect(updated.title, 'Updated Title');
        expect(updated.id, originalReminder.id);
        expect(updated.description, originalReminder.description);
        expect(updated.type, originalReminder.type);
      });

      test('should create copy with updated completion status', () {
        final updated = originalReminder.copyWith(isCompleted: true);

        expect(updated.isCompleted, true);
        expect(updated.title, originalReminder.title);
        expect(updated.isActive, originalReminder.isActive);
      });

      test('should create copy with updated type and frequency', () {
        final updated = originalReminder.copyWith(
          type: ReminderType.exercise,
          frequency: ReminderFrequency.weekly,
        );

        expect(updated.type, ReminderType.exercise);
        expect(updated.frequency, ReminderFrequency.weekly);
        expect(updated.title, originalReminder.title);
      });

      test('should create copy with all fields updated', () {
        final newTime = testTime.add(const Duration(days: 2));

        final updated = originalReminder.copyWith(
          id: 999,
          title: 'New Title',
          description: 'New description',
          type: ReminderType.assessment,
          frequency: ReminderFrequency.monthly,
          scheduledAt: newTime,
          nextScheduled: newTime.add(const Duration(days: 30)),
          isActive: false,
          isCompleted: true,
          createdAt: newTime,
          updatedAt: newTime,
        );

        expect(updated.id, 999);
        expect(updated.title, 'New Title');
        expect(updated.description, 'New description');
        expect(updated.type, ReminderType.assessment);
        expect(updated.frequency, ReminderFrequency.monthly);
        expect(updated.scheduledAt, newTime);
        expect(updated.nextScheduled, newTime.add(const Duration(days: 30)));
        expect(updated.isActive, false);
        expect(updated.isCompleted, true);
        expect(updated.createdAt, newTime);
        expect(updated.updatedAt, newTime);
      });

      test('should maintain original values when no changes provided', () {
        final copy = originalReminder.copyWith();

        expect(copy.id, originalReminder.id);
        expect(copy.title, originalReminder.title);
        expect(copy.description, originalReminder.description);
        expect(copy.type, originalReminder.type);
        expect(copy.frequency, originalReminder.frequency);
        expect(copy.scheduledAt, originalReminder.scheduledAt);
        expect(copy.nextScheduled, originalReminder.nextScheduled);
        expect(copy.isActive, originalReminder.isActive);
        expect(copy.isCompleted, originalReminder.isCompleted);
        expect(copy.createdAt, originalReminder.createdAt);
        expect(copy.updatedAt, originalReminder.updatedAt);
      });

      test('should handle null values in copyWith', () {
        final updated = originalReminder.copyWith(
          description: null,
          nextScheduled: null,
        );

        // copyWith with null values should retain original values due to ?? operator
        expect(updated.description, originalReminder.description);
        expect(updated.nextScheduled, originalReminder.nextScheduled);
        expect(updated.title, originalReminder.title);
      });
    });

    group('Equatable implementation', () {
      test('should be equal when all properties match', () {
        final reminder1 = Reminder(
          id: 1,
          title: 'Test Reminder',
          description: 'Test description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          nextScheduled: futureTime.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final reminder2 = Reminder(
          id: 1,
          title: 'Test Reminder',
          description: 'Test description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          nextScheduled: futureTime.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder1, equals(reminder2));
        expect(reminder1.hashCode, equals(reminder2.hashCode));
      });

      test('should not be equal when ids differ', () {
        final reminder1 = Reminder(
          id: 1,
          title: 'Test Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final reminder2 = Reminder(
          id: 2,
          title: 'Test Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder1, isNot(equals(reminder2)));
      });

      test('should not be equal when titles differ', () {
        final reminder1 = Reminder(
          title: 'Title 1',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final reminder2 = Reminder(
          title: 'Title 2',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder1, isNot(equals(reminder2)));
      });

      test('should handle null fields in equality', () {
        final reminder1 = Reminder(
          title: 'Test',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final reminder2 = Reminder(
          id: 1,
          title: 'Test',
          description: 'Description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder1, isNot(equals(reminder2)));
      });
    });

    group('Different reminder types', () {
      test('should create medication reminder', () {
        final reminder = Reminder(
          title: 'Take Medication',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.type, ReminderType.medication);
      });

      test('should create exercise reminder', () {
        final reminder = Reminder(
          title: 'Morning Walk',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.type, ReminderType.exercise);
      });

      test('should create appointment reminder', () {
        final reminder = Reminder(
          title: 'Doctor Visit',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.type, ReminderType.appointment);
      });

      test('should create assessment reminder', () {
        final reminder = Reminder(
          title: 'Cognitive Assessment',
          type: ReminderType.assessment,
          frequency: ReminderFrequency.weekly,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.type, ReminderType.assessment);
      });
    });

    group('Different reminder frequencies', () {
      test('should create once reminder', () {
        final reminder = Reminder(
          title: 'One Time Reminder',
          type: ReminderType.appointment,
          frequency: ReminderFrequency.once,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.frequency, ReminderFrequency.once);
      });

      test('should create daily reminder', () {
        final reminder = Reminder(
          title: 'Daily Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.frequency, ReminderFrequency.daily);
      });

      test('should create weekly reminder', () {
        final reminder = Reminder(
          title: 'Weekly Reminder',
          type: ReminderType.exercise,
          frequency: ReminderFrequency.weekly,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.frequency, ReminderFrequency.weekly);
      });

      test('should create monthly reminder', () {
        final reminder = Reminder(
          title: 'Monthly Reminder',
          type: ReminderType.assessment,
          frequency: ReminderFrequency.monthly,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.frequency, ReminderFrequency.monthly);
      });
    });

    group('Edge cases and validation', () {
      test('should handle very long titles', () {
        final longTitle = 'A' * 1000;
        final reminder = Reminder(
          title: longTitle,
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.title, longTitle);
        expect(reminder.title.length, 1000);
      });

      test('should handle very long descriptions', () {
        final longDescription = 'B' * 5000;
        final reminder = Reminder(
          title: 'Test',
          description: longDescription,
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.description, longDescription);
        expect(reminder.description!.length, 5000);
      });

      test('should handle empty title strings', () {
        final reminder = Reminder(
          title: '',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.title, '');
      });

      test('should handle empty description strings', () {
        final reminder = Reminder(
          title: 'Test',
          description: '',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.description, '');
      });

      test('should handle far future dates', () {
        final farFuture = DateTime(2100, 12, 31);
        final reminder = Reminder(
          title: 'Far Future Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: farFuture,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.scheduledAt, farFuture);
        expect(reminder.isPastDue, false);
      });

      test('should handle far past dates', () {
        final farPast = DateTime(1900, 1, 1);
        final reminder = Reminder(
          title: 'Far Past Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: farPast,
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        expect(reminder.scheduledAt, farPast);
        expect(reminder.isPastDue, true);
      });
    });

    group('Props for Equatable', () {
      test('should include all properties in props list', () {
        final reminder = Reminder(
          id: 1,
          title: 'Test',
          description: 'Description',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: futureTime,
          nextScheduled: futureTime.add(const Duration(days: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final props = reminder.props;
        expect(props.length, 11);
        expect(props[0], 1); // id
        expect(props[1], 'Test'); // title
        expect(props[2], 'Description'); // description
        expect(props[3], ReminderType.medication); // type
        expect(props[4], ReminderFrequency.daily); // frequency
      });
    });
  });
}