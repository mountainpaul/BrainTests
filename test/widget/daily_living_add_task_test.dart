import 'package:brain_tests/presentation/screens/daily_living_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Add Task Dialog Tests', () {
    testWidgets('should display add task dialog with all fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3)); // Title, Description, Category
      expect(find.byType(DropdownButtonFormField<TaskPriority>), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should allow entering title, description, and category', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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
      await tester.enterText(titleField, 'Morning Walk');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Morning Walk'), findsOneWidget);
    });

    testWidgets('should allow selecting task priority', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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
      await tester.tap(find.byType(DropdownButtonFormField<TaskPriority>));
      await tester.pumpAndSettle();

      // Assert - Check all priorities are available
      expect(find.text('high'), findsWidgets);
      expect(find.text('medium'), findsWidgets);
      expect(find.text('low'), findsWidgets);
    });

    testWidgets('should have default estimated time of 30 minutes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Assert - Check that default value of 30 is displayed
      expect(find.text('30'), findsWidgets); // Should appear at least once
    });

    testWidgets('should allow adjusting estimated time with slider', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Act - Move slider to a different value
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Assert - Value should have changed from default 30
      final sliderWidget = tester.widget<Slider>(slider);
      expect(sliderWidget.value, isNot(equals(30.0)));
    });

    testWidgets('should have default category of "general"', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Assert - Check that "general" is the default category
      final categoryField = find.widgetWithText(TextField, 'general');
      expect(categoryField, findsOneWidget);
    });

    testWidgets('should return null when Cancel is pressed', (tester) async {
      // Arrange
      DailyTask? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<DailyTask>(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

    testWidgets('should return DailyTask when Add is pressed with valid data', (tester) async {
      // Arrange
      DailyTask? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<DailyTask>(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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
      await tester.enterText(allFields.at(0), 'Morning Exercise');
      await tester.pumpAndSettle();

      await tester.enterText(allFields.at(1), '30-minute walk in the park');
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.title, 'Morning Exercise');
      expect(result!.description, '30-minute walk in the park');
      expect(result!.priority, TaskPriority.medium); // Default priority
      expect(result!.estimatedTime, 30); // Default time
      expect(result!.category, 'general'); // Default category
      expect(result!.isCompleted, isFalse);
    });

    testWidgets('should not return task when Add is pressed without title', (tester) async {
      // Arrange
      DailyTask? result;
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<DailyTask>(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Assert - Dialog should still be open
      expect(find.text('Add Task'), findsOneWidget);
      expect(dialogClosed, isFalse);
    });

    testWidgets('should set custom estimated time', (tester) async {
      // Arrange
      DailyTask? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<DailyTask>(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Act - Fill title and adjust slider
      final titleField = find.widgetWithText(TextField, '').first;
      await tester.enterText(titleField, 'Read Book');
      await tester.pumpAndSettle();

      // Move slider to the right to increase time
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(200, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - Time should be different from default 30
      expect(result, isNotNull);
      expect(result!.estimatedTime, isNot(equals(30)));
    });

    testWidgets('should allow changing priority from default', (tester) async {
      // Arrange
      DailyTask? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<DailyTask>(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
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

      // Act - Fill title
      final titleField = find.widgetWithText(TextField, '').first;
      await tester.enterText(titleField, 'Important Task');
      await tester.pumpAndSettle();

      // Change priority to high
      await tester.tap(find.byType(DropdownButtonFormField<TaskPriority>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('high').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.priority, TaskPriority.high);
    });
  });
}
