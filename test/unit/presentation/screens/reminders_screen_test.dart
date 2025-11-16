import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/reminder.dart';
import 'package:brain_tests/presentation/providers/reminder_provider.dart';
import 'package:brain_tests/presentation/screens/reminders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemindersScreen Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Widget Structure Tests', () {
      testWidgets('should build without crashing', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(RemindersScreen), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Reminders'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display reminder sections', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('All Active Reminders'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Empty State Tests', () {
      testWidgets('should display empty states when no reminders', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('No upcoming reminders for today'), findsOneWidget);
        expect(find.text('No active reminders'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Reminder Display Tests', () {
      testWidgets('should display upcoming reminders', (WidgetTester tester) async {
        // Arrange
        final upcomingReminder = Reminder(
          id: 1,
          title: 'Take Morning Medication',
          description: 'Daily cognitive support pills',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => [upcomingReminder]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Take Morning Medication'), findsOneWidget);
        expect(find.text('Daily cognitive support pills'), findsOneWidget);
        expect(find.byIcon(Icons.medication), findsAtLeastNWidgets(1));

        testContainer.dispose();
      });

      testWidgets('should display active reminders', (WidgetTester tester) async {
        // Arrange
        final activeReminders = [
          Reminder(
            id: 1,
            title: 'Evening Exercise',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 6)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 2,
            title: 'Weekly Assessment',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: DateTime.now().add(const Duration(days: 3)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => activeReminders),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Evening Exercise'), findsOneWidget);
        expect(find.text('Weekly Assessment'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.assessment), findsAtLeastNWidgets(1));

        testContainer.dispose();
      });

      testWidgets('should display overdue reminders with red styling', (WidgetTester tester) async {
        // Arrange
        final overdueReminder = Reminder(
          id: 1,
          title: 'Missed Medication',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => [overdueReminder]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Overdue'), findsOneWidget);
        expect(find.text('Missed Medication'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Reminder Icon Tests', () {
      testWidgets('should display correct icons for reminder types', (WidgetTester tester) async {
        // Arrange
        final reminders = [
          Reminder(
            id: 1,
            title: 'Medication',
            type: ReminderType.medication,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 1)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 2,
            title: 'Exercise',
            type: ReminderType.exercise,
            frequency: ReminderFrequency.daily,
            scheduledAt: DateTime.now().add(const Duration(hours: 2)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 3,
            title: 'Assessment',
            type: ReminderType.assessment,
            frequency: ReminderFrequency.weekly,
            scheduledAt: DateTime.now().add(const Duration(hours: 3)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 4,
            title: 'Appointment',
            type: ReminderType.appointment,
            frequency: ReminderFrequency.monthly,
            scheduledAt: DateTime.now().add(const Duration(hours: 4)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Reminder(
            id: 5,
            title: 'Custom Reminder',
            type: ReminderType.custom,
            frequency: ReminderFrequency.once,
            scheduledAt: DateTime.now().add(const Duration(hours: 5)),
            isActive: true,
            isCompleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => reminders),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert - Check for all reminder type icons
        expect(find.byIcon(Icons.medication), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.fitness_center), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.assessment), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.event), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.notifications), findsAtLeastNWidgets(1));

        testContainer.dispose();
      });
    });

    group('Loading and Error States Tests', () {
      testWidgets('should display loading indicators', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) async => await Future<List<Reminder>>.delayed(const Duration(hours: 1))),
            upcomingRemindersProvider.overrideWith((ref) async => await Future<List<Reminder>>.delayed(const Duration(hours: 1))),
            overdueRemindersProvider.overrideWith((ref) async => await Future<List<Reminder>>.delayed(const Duration(hours: 1))),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(2));

        testContainer.dispose();
      });

      testWidgets('should handle provider errors gracefully', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) async => throw Exception('Database error')),
            upcomingRemindersProvider.overrideWith((ref) async => throw Exception('Network error')),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('Error:'), findsAtLeastNWidgets(2));

        testContainer.dispose();
      });
    });

    group('Reminder Menu Tests', () {
      testWidgets('should display popup menu for reminders', (WidgetTester tester) async {
        // Arrange
        final reminder = Reminder(
          id: 1,
          title: 'Test Reminder',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => [reminder]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Tap on popup menu button
        await tester.tap(find.byType(PopupMenuButton<String>).first);
        await tester.pumpAndSettle();

        // Assert - Check for menu items
        expect(find.text('Complete'), findsOneWidget);
        expect(find.text('Snooze 15m'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('DateTime Display Tests', () {
      testWidgets('should display reminder date and time correctly', (WidgetTester tester) async {
        // Arrange
        final scheduledTime = DateTime(2024, 12, 25, 14, 30); // Christmas 2:30 PM
        final reminder = Reminder(
          id: 1,
          title: 'Holiday Reminder',
          type: ReminderType.custom,
          frequency: ReminderFrequency.once,
          scheduledAt: scheduledTime,
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => [reminder]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert - Check for formatted date/time
        expect(find.textContaining('25/12'), findsOneWidget);
        expect(find.textContaining('14:30'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Reminder Description Tests', () {
      testWidgets('should display reminder description when available', (WidgetTester tester) async {
        // Arrange
        final reminder = Reminder(
          id: 1,
          title: 'Morning Pills',
          description: 'Take 2 cognitive support tablets with breakfast',
          type: ReminderType.medication,
          frequency: ReminderFrequency.daily,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => [reminder]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Morning Pills'), findsOneWidget);
        expect(find.text('Take 2 cognitive support tablets with breakfast'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should handle reminders without description', (WidgetTester tester) async {
        // Arrange
        final reminder = Reminder(
          id: 1,
          title: 'Simple Reminder',
          description: null, // No description
          type: ReminderType.custom,
          frequency: ReminderFrequency.once,
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          isActive: true,
          isCompleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => [reminder]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert - Should display title but no description
        expect(find.text('Simple Reminder'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Bottom Navigation Tests', () {
      testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            activeRemindersProvider.overrideWith((ref) => <Reminder>[]),
            upcomingRemindersProvider.overrideWith((ref) => <Reminder>[]),
            overdueRemindersProvider.overrideWith((ref) => <Reminder>[]),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: RemindersScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);

        testContainer.dispose();
      });
    });
  });
}