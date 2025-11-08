import 'package:brain_plan/presentation/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('should display icon, title, and message', (tester) async {
      const title = 'No Data';
      const message = 'You have no items yet.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: title,
              message: message,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display action button when provided', (tester) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Data',
              message: 'Add your first item',
              actionLabel: 'Add Item',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();

      expect(actionCalled, true);
    });

    testWidgets('should not display action button when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Data',
              message: 'Message',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('should have large accessible text for elderly users', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(
        find.text('Title'),
      );

      expect(titleText.style?.fontSize, greaterThanOrEqualTo(20.0));
    });

    testWidgets('should have large icon (min 64dp)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.inbox),
      );

      expect(icon.size, greaterThanOrEqualTo(64.0));
    });

    testWidgets('should center all content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Message',
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('action button should have accessible size (min 48dp height)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Title',
              message: 'Message',
              actionLabel: 'Action',
              onAction: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(
        button.style?.minimumSize?.resolve({}),
        equals(const Size(120, 48)),
      );
    });
  });

  group('Common Empty State Widgets Tests', () {
    testWidgets('EmptyAssessmentsList should have appropriate content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyAssessmentsList(onStartAssessment: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.assessment), findsOneWidget);
      expect(find.textContaining('Assessments'), findsOneWidget);
      expect(find.text('Start Assessment'), findsOneWidget);
    });

    testWidgets('EmptyRemindersList should have appropriate content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyRemindersList(onAddReminder: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.textContaining('Reminders'), findsOneWidget);
      expect(find.text('Add Reminder'), findsOneWidget);
    });

    testWidgets('EmptyExercisesList should have appropriate content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyExercisesList(onStartExercise: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.textContaining('Exercises'), findsOneWidget);
      expect(find.text('Start Exercise'), findsOneWidget);
    });

    testWidgets('EmptyMoodEntries should have appropriate content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyMoodEntries(onLogMood: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.mood), findsOneWidget);
      expect(find.text('No Mood Entries'), findsOneWidget);
      expect(find.text('Log Mood'), findsOneWidget);
    });

    testWidgets('EmptySearchResults should not have action button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySearchResults(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.textContaining('Results'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
