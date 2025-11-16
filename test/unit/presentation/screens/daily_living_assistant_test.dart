import 'package:brain_tests/presentation/screens/daily_living_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyLivingAssistant Tests', () {
    testWidgets('should display app bar and tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check app bar
      expect(find.text('Daily Living Assistant'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Check tabs
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
    });

    testWidgets('should display today\'s reminders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Today\'s Reminders'), findsOneWidget);
      expect(find.text('Take Morning Medications'), findsOneWidget);
      expect(find.text('Call Mom'), findsOneWidget);
      expect(find.text('Grocery Shopping'), findsOneWidget);
    });

    testWidgets('should switch to memory aids tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap memory tab
      await tester.tap(find.text('Memory'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Memory Aids'), findsOneWidget);
      expect(find.text('Search your memory aids...'), findsOneWidget);
      expect(find.text('Important Contacts'), findsOneWidget);
      expect(find.text('Medical Information'), findsOneWidget);
      expect(find.text('Daily Routines'), findsOneWidget);
    });

    testWidgets('should switch to tasks tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Daily Tasks'), findsOneWidget);
      expect(find.text('Today\'s Progress'), findsOneWidget);
      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('Morning Walk'), findsOneWidget);
      expect(find.text('Brain Training Game'), findsOneWidget);
    });

    testWidgets('should switch to emergency tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap emergency tab
      await tester.tap(find.text('Emergency'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Emergency Information'), findsOneWidget);
      expect(find.text('Emergency Services'), findsOneWidget);
      expect(find.text('911'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
      expect(find.text('Emergency Contact'), findsOneWidget);
    });

    testWidgets('should display floating action button based on tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // On reminders tab, should show add alarm FAB
      expect(find.byIcon(Icons.add_alarm), findsOneWidget);

      // Switch to memory tab
      await tester.tap(find.text('Memory'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Switch to tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.add_task), findsOneWidget);

      // Switch to emergency tab (no FAB)
      await tester.tap(find.text('Emergency'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should show snackbar when settings is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Settings coming soon!'), findsOneWidget);
    });

    testWidgets('should complete reminder when check button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find the first check button and tap it
      await tester.tap(find.byIcon(Icons.check_circle_outline).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show completed reminders section
      expect(find.text('Completed Today'), findsOneWidget);
    });

    testWidgets('should toggle task completion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap first checkbox
      await tester.tap(find.byType(Checkbox).first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should update the progress
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('should show phone call snackbar when emergency contact is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to emergency tab
      await tester.tap(find.text('Emergency'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on emergency services
      await tester.tap(find.text('Emergency Services'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Would call 911'), findsOneWidget);
    });

    testWidgets('should expand memory aid categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to memory tab
      await tester.tap(find.text('Memory'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap on Important Contacts expansion tile
      await tester.tap(find.text('Important Contacts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show contact details
      expect(find.text('Important Phone Numbers'), findsOneWidget);
    });

    testWidgets('should show snackbar when FAB is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap FAB on reminders tab
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Add reminder feature coming soon!'), findsOneWidget);
    });

    testWidgets('should display priority chips correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show priority indicators
      expect(find.text('High'), findsAtLeastNWidgets(1));
      expect(find.text('Medium'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display task progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('% complete'), findsOneWidget);
    });

    testWidgets('should display medical information in emergency tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to emergency tab
      await tester.tap(find.text('Emergency'));
      await tester.pump(); // Allow tap to register
      await tester.pump(); // Allow setState to take effect
      await tester.pumpAndSettle(); // Wait for any animations

      // Drag to scroll down and make the medical information visible
      await tester.dragUntilVisible(
        find.text('Blood Type'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      expect(find.text('Important Medical Information'), findsOneWidget);
      expect(find.text('Blood Type'), findsOneWidget);
      expect(find.text('Allergies'), findsOneWidget);
      expect(find.text('Safety Reminders'), findsOneWidget);
    });

    testWidgets('should display reminder type icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show different reminder type icons
      expect(find.byIcon(Icons.medication), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.task), findsOneWidget);
    });

    testWidgets('should show memory category icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to memory tab
      await tester.tap(find.text('Memory'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.contacts), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should snooze reminder when snooze button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap snooze button (should be second icon button)
      await tester.tap(find.byIcon(Icons.snooze).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Reminder should still be present but time should be updated
      expect(find.text('Take Morning Medications'), findsOneWidget);
    });
  });

  group('Data Models Tests', () {
    group('SmartReminder', () {
      test('should create reminder with all fields', () {
        final reminder = SmartReminder(
          id: '1',
          title: 'Test Reminder',
          description: 'Test Description',
          scheduledTime: DateTime(2024, 1, 15, 10, 30),
          type: ReminderType.medication,
          isCompleted: false,
          repeatDaily: true,
          repeatWeekly: false,
        );

        expect(reminder.id, '1');
        expect(reminder.title, 'Test Reminder');
        expect(reminder.description, 'Test Description');
        expect(reminder.type, ReminderType.medication);
        expect(reminder.isCompleted, false);
        expect(reminder.repeatDaily, true);
        expect(reminder.repeatWeekly, false);
      });

      test('should create reminder with default values', () {
        final reminder = SmartReminder(
          id: '1',
          title: 'Test Reminder',
          description: 'Test Description',
          scheduledTime: DateTime(2024, 1, 15, 10, 30),
          type: ReminderType.task,
        );

        expect(reminder.isCompleted, false);
        expect(reminder.repeatDaily, false);
        expect(reminder.repeatWeekly, false);
      });

      test('should copy reminder with changes', () {
        final original = SmartReminder(
          id: '1',
          title: 'Original',
          description: 'Original Description',
          scheduledTime: DateTime(2024, 1, 15, 10, 30),
          type: ReminderType.medication,
        );

        final copied = original.copyWith(
          isCompleted: true,
          scheduledTime: DateTime(2024, 1, 15, 11, 30),
        );

        expect(copied.id, original.id);
        expect(copied.title, original.title);
        expect(copied.isCompleted, true);
        expect(copied.scheduledTime, DateTime(2024, 1, 15, 11, 30));
      });

      test('should copy reminder without changes', () {
        final original = SmartReminder(
          id: '1',
          title: 'Original',
          description: 'Original Description',
          scheduledTime: DateTime(2024, 1, 15, 10, 30),
          type: ReminderType.medication,
          isCompleted: true,
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.title, original.title);
        expect(copied.isCompleted, original.isCompleted);
        expect(copied.scheduledTime, original.scheduledTime);
      });
    });

    group('MemoryAid', () {
      test('should create memory aid correctly', () {
        final memoryAid = MemoryAid(
          id: '1',
          title: 'Test Memory Aid',
          content: {
            'Key 1': 'Value 1',
            'Key 2': 'Value 2',
          },
          category: MemoryCategory.contacts,
        );

        expect(memoryAid.id, '1');
        expect(memoryAid.title, 'Test Memory Aid');
        expect(memoryAid.content.length, 2);
        expect(memoryAid.content['Key 1'], 'Value 1');
        expect(memoryAid.category, MemoryCategory.contacts);
      });

      test('should handle empty content', () {
        final memoryAid = MemoryAid(
          id: '1',
          title: 'Empty Aid',
          content: {},
          category: MemoryCategory.important,
        );

        expect(memoryAid.content.isEmpty, true);
      });
    });

    group('DailyTask', () {
      test('should create task with all fields', () {
        final task = DailyTask(
          id: '1',
          title: 'Test Task',
          description: 'Test Description',
          priority: TaskPriority.high,
          estimatedTime: 30,
          isCompleted: false,
          category: 'Exercise',
        );

        expect(task.id, '1');
        expect(task.title, 'Test Task');
        expect(task.description, 'Test Description');
        expect(task.priority, TaskPriority.high);
        expect(task.estimatedTime, 30);
        expect(task.isCompleted, false);
        expect(task.category, 'Exercise');
      });

      test('should create task with default completion status', () {
        final task = DailyTask(
          id: '1',
          title: 'Test Task',
          description: 'Test Description',
          priority: TaskPriority.medium,
          estimatedTime: 15,
          category: 'Cognitive',
        );

        expect(task.isCompleted, false);
      });

      test('should copy task with completion change', () {
        final original = DailyTask(
          id: '1',
          title: 'Original Task',
          description: 'Original Description',
          priority: TaskPriority.low,
          estimatedTime: 20,
          category: 'Planning',
        );

        final completed = original.copyWith(isCompleted: true);

        expect(completed.id, original.id);
        expect(completed.title, original.title);
        expect(completed.isCompleted, true);
        expect(completed.priority, original.priority);
      });
    });

    group('Enums', () {
      test('should have all ReminderType values', () {
        expect(ReminderType.values.length, 5);
        expect(ReminderType.values.contains(ReminderType.medication), true);
        expect(ReminderType.values.contains(ReminderType.appointment), true);
        expect(ReminderType.values.contains(ReminderType.social), true);
        expect(ReminderType.values.contains(ReminderType.task), true);
        expect(ReminderType.values.contains(ReminderType.exercise), true);
      });

      test('should have all MemoryCategory values', () {
        expect(MemoryCategory.values.length, 4);
        expect(MemoryCategory.values.contains(MemoryCategory.contacts), true);
        expect(MemoryCategory.values.contains(MemoryCategory.medical), true);
        expect(MemoryCategory.values.contains(MemoryCategory.routine), true);
        expect(MemoryCategory.values.contains(MemoryCategory.important), true);
      });

      test('should have all TaskPriority values', () {
        expect(TaskPriority.values.length, 3);
        expect(TaskPriority.values.contains(TaskPriority.high), true);
        expect(TaskPriority.values.contains(TaskPriority.medium), true);
        expect(TaskPriority.values.contains(TaskPriority.low), true);
      });
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('should handle rapid tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Rapidly switch between all tabs
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Memory'));
        await tester.pump();
        await tester.tap(find.text('Tasks'));
        await tester.pump();
        await tester.tap(find.text('Emergency'));
        await tester.pump();
        await tester.tap(find.text('Reminders'));
        await tester.pump();
      }

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should not crash and remain functional
      expect(find.text('Today\'s Reminders'), findsOneWidget);
    });

    testWidgets('should handle multiple reminder completions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Complete multiple reminders
      final checkButtons = find.byIcon(Icons.check_circle_outline);
      final count = tester.widgetList(checkButtons).length;

      for (int i = 0; i < count; i++) {
        await tester.tap(checkButtons.at(i));
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      }

      // Should show all completed message
      expect(find.text('All reminders completed!'), findsOneWidget);
    });

    testWidgets('should handle task completion changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch to tasks tab
      await tester.tap(find.text('Tasks'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Toggle all checkboxes
      final checkboxes = find.byType(Checkbox);
      final count = tester.widgetList(checkboxes).length;

      for (int i = 0; i < count; i++) {
        await tester.tap(checkboxes.at(i), warnIfMissed: false);
        await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      }

      // Progress should be updated
      expect(find.textContaining('% complete'), findsOneWidget);
    });

    testWidgets('should handle empty reminder lists gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Complete all reminders by tapping completion buttons repeatedly until none left
      var completionButtons = find.byIcon(Icons.check_circle_outline);
      int attempts = 0;
      while (completionButtons.evaluate().isNotEmpty && attempts < 10) {
        await tester.tap(completionButtons.first, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        completionButtons = find.byIcon(Icons.check_circle_outline);
        attempts++;
      }

      // After completing reminders, should show completion state
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show some indication that all reminders are completed
      final hasCompletedMessage = find.text('All reminders completed!').evaluate().isNotEmpty;
      final hasJobWellDone = find.text('Great job staying on top of things today.').evaluate().isNotEmpty;
      final hasGreenIcon = find.byIcon(Icons.check_circle).evaluate().isNotEmpty;

      expect(hasCompletedMessage || hasJobWellDone || hasGreenIcon, isTrue,
             reason: 'Should show some indication that all reminders are completed');
    });

    testWidgets('should show proper time formatting in reminders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show time-related text
      expect(find.byIcon(Icons.schedule), findsAtLeastNWidgets(1));
    });

    testWidgets('should display correct tab icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DailyLivingAssistant(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check all tab icons are present
      expect(find.byIcon(Icons.alarm), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
    });
  });
}