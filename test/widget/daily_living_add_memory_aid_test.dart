import 'package:brain_tests/presentation/screens/daily_living_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Add Memory Aid Dialog Tests', () {
    testWidgets('should display add memory aid dialog with all fields', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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
      expect(find.text('Add Memory Aid'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<MemoryCategory>), findsOneWidget);
      expect(find.text('Content (Key-Value pairs):'), findsOneWidget);
      expect(find.text('Add Row'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should start with one content row by default', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Assert - Should have 1 title field + 2 content fields (key + value) = 3 text fields
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('should add new content row when Add Row button is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Act - Tap Add Row button
      await tester.tap(find.text('Add Row'));
      await tester.pumpAndSettle();

      // Assert - Should now have 1 title + 4 content fields (2 rows x 2 fields) = 5 text fields
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('should remove content row when remove button is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Add a second row
      await tester.tap(find.text('Add Row'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(5));

      // Act - Remove one row by tapping the remove icon
      final removeButton = find.byIcon(Icons.remove_circle).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Assert - Should be back to 3 text fields
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('should allow entering title', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Important Contacts');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Important Contacts'), findsOneWidget);
    });

    testWidgets('should allow selecting memory category', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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
      await tester.tap(find.byType(DropdownButtonFormField<MemoryCategory>));
      await tester.pumpAndSettle();

      // Assert - Check all categories are available
      expect(find.text('contacts'), findsWidgets);
      expect(find.text('medical'), findsWidgets);
      expect(find.text('routine'), findsWidgets);
      expect(find.text('important'), findsWidgets);
    });

    testWidgets('should return null when Cancel is pressed', (tester) async {
      // Arrange
      MemoryAid? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MemoryAid>(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

    testWidgets('should return MemoryAid when Add is pressed with valid data', (tester) async {
      // Arrange
      MemoryAid? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MemoryAid>(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Phone Numbers');
      await tester.pumpAndSettle();

      // Enter key-value pair (after title, there are 2 more fields: key and value)
      final allFields = find.byType(TextField);
      await tester.enterText(allFields.at(1), 'Doctor');  // Key field
      await tester.pumpAndSettle();

      await tester.enterText(allFields.at(2), '555-1234');  // Value field
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isNotNull);
      expect(result!.title, 'Phone Numbers');
      expect(result!.content['Doctor'], '555-1234');
      expect(result!.category, MemoryCategory.important); // Default category
    });

    testWidgets('should not return memory aid when Add is pressed without title', (tester) async {
      // Arrange
      MemoryAid? result;
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MemoryAid>(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Act - Try to add without entering a title (but with content)
      final allFields = find.byType(TextField);
      await tester.enterText(allFields.at(1), 'Doctor');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - Dialog should still be open
      expect(find.text('Add Memory Aid'), findsOneWidget);
      expect(dialogClosed, isFalse);
    });

    testWidgets('should not return memory aid when Add is pressed without content', (tester) async {
      // Arrange
      MemoryAid? result;
      bool dialogClosed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MemoryAid>(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Act - Try to add with title but without content
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Phone Numbers');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - Dialog should still be open
      expect(find.text('Add Memory Aid'), findsOneWidget);
      expect(dialogClosed, isFalse);
    });

    testWidgets('should ignore empty key-value pairs', (tester) async {
      // Arrange
      MemoryAid? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<MemoryAid>(
                    context: context,
                    builder: (context) => const AddMemoryAidDialog(),
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

      // Add a second row
      await tester.tap(find.text('Add Row'));
      await tester.pumpAndSettle();

      // Act - Fill in title and first row, leave second row empty
      final allFields = find.byType(TextField);
      await tester.enterText(allFields.first, 'Phone Numbers');
      await tester.pumpAndSettle();

      // Fill first row key-value
      await tester.enterText(allFields.at(1), 'Doctor');
      await tester.pumpAndSettle();

      await tester.enterText(allFields.at(2), '555-1234');
      await tester.pumpAndSettle();

      // Leave second row empty (fields at index 3 and 4)
      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert - Should only have one entry in content map
      expect(result, isNotNull);
      expect(result!.content.length, 1);
      expect(result!.content['Doctor'], '555-1234');
    });
  });
}
