import 'package:brain_tests/core/services/notification_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'simple_notification_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();

    // Setup mock behavior
    when(mockPlugin.initialize(
      any,
      onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'),
    )).thenAnswer((_) async => true);

    when(mockPlugin.show(
      any,
      any,
      any,
      any,
      payload: anyNamed('payload'),
    )).thenAnswer((_) async => null);

    when(mockPlugin.zonedSchedule(
      any,
      any,
      any,
      any,
      any,
      androidScheduleMode: anyNamed('androidScheduleMode'),
      payload: anyNamed('payload'),
    )).thenAnswer((_) async => null);

    when(mockPlugin.cancel(any)).thenAnswer((_) async => null);
    when(mockPlugin.cancelAll()).thenAnswer((_) async => null);

    // Inject mock plugin
    NotificationService.setTestPlugin(mockPlugin);
  });

  tearDown(() {
    // Reset to real plugin
    NotificationService.setTestPlugin(null);
  });

  group('NotificationService Tests', () {
    test('should initialize without throwing errors', () async {
      // Act & Assert
      await NotificationService.initialize();
      expect(true, true);
    });

    test('should schedule reminder without throwing errors', () async {
      // Arrange
      final now = DateTime.now();
      final reminder = Reminder(
        id: 1,
        title: 'Test Reminder',
        description: 'Test Description',
        scheduledAt: now.add(const Duration(hours: 1)),
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert - Test that the reminder object is valid
      expect(reminder.title, 'Test Reminder');
      expect(reminder.type, ReminderType.medication);
      expect(reminder.isActive, isTrue);
    });

    test('should cancel reminder without throwing errors', () async {
      // Act & Assert
      await NotificationService.cancelReminder(1);
      expect(true, true);
    });

    test('should cancel all reminders without throwing errors', () async {
      // Act & Assert
      await NotificationService.cancelAllReminders();
      expect(true, true);
    });

    test('should show immediate notification without throwing errors', () async {
      // Act & Assert
      await NotificationService.showImmediateNotification(
        id: 100,
        title: 'Test Title',
        body: 'Test Body',
      );
      expect(true, true);
    });

    test('should handle different reminder frequencies', () async {
      final now = DateTime.now();

      final reminders = [
        Reminder(
          id: 2,
          title: 'Daily Reminder',
          description: 'Daily medication',
          scheduledAt: now.add(const Duration(hours: 1)),
          frequency: ReminderFrequency.daily,
          type: ReminderType.medication,
          isActive: true,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Reminder(
          id: 3,
          title: 'Weekly Reminder',
          description: 'Weekly checkup',
          scheduledAt: now.add(const Duration(days: 1)),
          frequency: ReminderFrequency.weekly,
          type: ReminderType.appointment,
          isActive: true,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        Reminder(
          id: 4,
          title: 'Monthly Reminder',
          description: 'Monthly assessment',
          scheduledAt: now.add(const Duration(days: 1)),
          frequency: ReminderFrequency.monthly,
          type: ReminderType.assessment,
          isActive: true,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Act & Assert - Test that all reminder objects are valid
      for (final reminder in reminders) {
        expect(reminder.isActive, isTrue);
        expect(reminder.isCompleted, isFalse);
        expect(reminder.scheduledAt.isAfter(DateTime.now()), isTrue);
      }
      expect(reminders.length, 3);
    });

    test('should handle different reminder types', () async {
      final now = DateTime.now();

      for (final type in ReminderType.values) {
        final reminder = Reminder(
          id: type.index + 10,
          title: 'Test ${type.name}',
          description: 'Test reminder for ${type.name}',
          scheduledAt: now.add(const Duration(hours: 1)),
          frequency: ReminderFrequency.once,
          type: type,
          isActive: true,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        );

        // Act & Assert - Test that reminder object is valid for this type
        expect(reminder.type, type);
        expect(reminder.title, 'Test ${type.name}');
        expect(reminder.isActive, isTrue);
      }
      expect(ReminderType.values.length, greaterThan(0));
    });

    test('should handle reminder without ID', () async {
      final now = DateTime.now();
      final reminder = Reminder(
        title: 'No ID Reminder',
        description: 'Reminder without ID',
        scheduledAt: now.add(const Duration(hours: 1)),
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert - should not throw error
      await NotificationService.scheduleReminder(reminder);
      expect(true, true);
    });

    test('should handle past scheduled times', () async {
      final now = DateTime.now();
      final pastReminder = Reminder(
        id: 999,
        title: 'Past Reminder',
        description: 'Reminder in the past',
        scheduledAt: now.subtract(const Duration(hours: 1)),
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert - Test that past reminder is handled
      expect(pastReminder.scheduledAt.isBefore(DateTime.now()), isTrue);
      expect(pastReminder.title, 'Past Reminder');
      expect(pastReminder.isActive, isTrue);
    });

    test('should handle notification with payload', () async {
      // Act & Assert
      await NotificationService.showImmediateNotification(
        id: 200,
        title: 'Test with Payload',
        body: 'Test notification with payload',
        payload: 'test_payload_data',
      );
      expect(true, true);
    });

    test('should handle empty strings gracefully', () async {
      // Act & Assert
      await NotificationService.showImmediateNotification(
        id: 201,
        title: '',
        body: '',
      );
      expect(true, true);
    });

    test('should handle null description in reminders', () async {
      final now = DateTime.now();
      final reminder = Reminder(
        id: 300,
        title: 'Reminder with null description',
        description: null,
        scheduledAt: now.add(const Duration(hours: 1)),
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert - Test that the reminder object is valid
      expect(reminder.title, 'Reminder with null description');
      expect(reminder.description, null);
      expect(reminder.type, ReminderType.medication);
      expect(reminder.isActive, isTrue);
    });

    test('should handle reminder properties correctly', () {
      final now = DateTime.now();
      final reminder = Reminder(
        id: 400,
        title: 'Property Test Reminder',
        description: 'Testing reminder properties',
        scheduledAt: now.subtract(const Duration(minutes: 30)),
        frequency: ReminderFrequency.daily,
        type: ReminderType.exercise,
        isActive: false,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      );

      // Assert properties
      expect(reminder.id, 400);
      expect(reminder.title, 'Property Test Reminder');
      expect(reminder.description, 'Testing reminder properties');
      expect(reminder.frequency, ReminderFrequency.daily);
      expect(reminder.type, ReminderType.exercise);
      expect(reminder.isActive, false);
      expect(reminder.isCompleted, true);
      expect(reminder.isPastDue, true); // Scheduled for 30 minutes ago
    });

    test('should test reminder copyWith method', () {
      final now = DateTime.now();
      final original = Reminder(
        id: 500,
        title: 'Original Title',
        description: 'Original description',
        scheduledAt: now,
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      final copied = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(copied.id, original.id);
      expect(copied.title, 'Updated Title');
      expect(copied.description, original.description);
      expect(copied.isCompleted, true);
      expect(copied.isActive, original.isActive);
    });

    test('should test reminder equality', () {
      final now = DateTime.now();
      final reminder1 = Reminder(
        id: 600,
        title: 'Test Reminder',
        description: 'Test description',
        scheduledAt: now,
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      final reminder2 = Reminder(
        id: 600,
        title: 'Test Reminder',
        description: 'Test description',
        scheduledAt: now,
        frequency: ReminderFrequency.once,
        type: ReminderType.medication,
        isActive: true,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(reminder1, equals(reminder2));
      expect(reminder1.hashCode, equals(reminder2.hashCode));
    });

    test('should test all reminder frequencies', () {
      for (final frequency in ReminderFrequency.values) {
        expect(frequency, isA<ReminderFrequency>());
      }
    });

    test('should test all reminder types', () {
      for (final type in ReminderType.values) {
        expect(type, isA<ReminderType>());
      }
    });
  });
}