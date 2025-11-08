import 'package:brain_plan/presentation/screens/daily_living_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Add Reminder Dialog Tests', () {
    testWidgets('should display add reminder dialog with all fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add Reminder'), findsOneWidget);
      expect(find.widgetWithText(TextField, '').first, findsOneWidget); // Title field
      expect(find.byType(DropdownButtonFormField<ReminderType>), findsOneWidget);
      expect(find.text('Repeat Daily'), findsOneWidget);
      expect(find.text('Repeat Weekly'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should allow entering title and description', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Enter title
      final titleField = find.widgetWithText(TextField, '').first;
      await tester.enterText(titleField, 'Take Medicine');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Take Medicine'), findsOneWidget);
    });

    testWidgets('should allow selecting reminder type', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<ReminderType>));
      await tester.pumpAndSettle();

      // Assert - Check all reminder types are available
      expect(find.text('medication'), findsWidgets);
      expect(find.text('appointment'), findsWidgets);
      expect(find.text('social'), findsWidgets);
      expect(find.text('task'), findsWidgets);
      expect(find.text('exercise'), findsWidgets);
    });

    testWidgets('should toggle repeat daily checkbox', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Find and tap the checkbox
      final checkbox = find.widgetWithText(CheckboxListTile, 'Repeat Daily');
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Assert - Checkbox should be checked
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('should toggle repeat weekly checkbox', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act
      final checkbox = find.widgetWithText(CheckboxListTile, 'Repeat Weekly');
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Assert
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('should return null when Cancel is pressed', (tester) async {
      // Arrange
      SmartReminder? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<SmartReminder>(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNull);
    });

    testWidgets('should return SmartReminder when Add is pressed with valid data', (tester) async {
      // Arrange
      SmartReminder? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<SmartReminder>(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Fill in the form
      final allFields = find.byType(TextField);
      await tester.enterText(allFields.at(0), 'Morning Medication');
      await tester.pumpAndSettle();

      await tester.enterText(allFields.at(1), 'Take blood pressure medicine');
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.title, 'Morning Medication');
      expect(result!.description, 'Take blood pressure medicine');
      expect(result!.type, ReminderType.task); // Default type
    });

    testWidgets('should not return reminder when Add is pressed without title', (tester) async {
      // Arrange
      SmartReminder? result;
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<SmartReminder>(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                  dialogClosed = true;
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Try to add without entering a title
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - Dialog should still be open (not closed)
      expect(find.text('Add Reminder'), findsOneWidget);
      expect(dialogClosed, isFalse);
    });

    testWidgets('should show time picker when time field is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddReminderDialog(),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Tap on time field
      final timeField = find.byType(ListTile).first;
      await tester.tap(timeField);
      await tester.pumpAndSettle();

      // Assert - Time picker should appear
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });
  });
}
