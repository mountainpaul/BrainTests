import 'package:brain_tests/presentation/widgets/common/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfirmationDialog Widget Tests', () {
    testWidgets('should display title and message', (tester) async {
      const title = 'Delete Item?';
      const message = 'This action cannot be undone.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: title,
                      message: message,
                      onConfirm: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should display confirm and cancel buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Test',
                      message: 'Message',
                      onConfirm: () {},
                      confirmText: 'Yes',
                      cancelText: 'No',
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('should call onConfirm when confirm button tapped', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Test',
                      message: 'Message',
                      onConfirm: () => confirmed = true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmed, true);
    });

    testWidgets('should close dialog when cancel button tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Test',
                      message: 'Message',
                      onConfirm: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should style destructive button as red', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Delete',
                      message: 'Are you sure?',
                      onConfirm: () {},
                      isDestructive: true,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm'),
      );

      expect(
        confirmButton.style?.backgroundColor?.resolve({}),
        equals(Colors.red),
      );
    });

    testWidgets('should have accessible button sizes (min 48dp)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Test',
                      message: 'Message',
                      onConfirm: () {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm'),
      );
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Cancel'),
      );

      expect(
        confirmButton.style?.minimumSize?.resolve({}),
        equals(const Size(88, 48)),
      );
      expect(
        cancelButton.style?.minimumSize?.resolve({}),
        equals(const Size(88, 48)),
      );
    });
  });

  group('ConfirmationDialog.show() Static Method Tests', () {
    testWidgets('should return true when confirmed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ConfirmationDialog.show(
                    context: context,
                    title: 'Test',
                    message: 'Message',
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, false); // onConfirm not called in static method
    });

    testWidgets('should return false when cancelled', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ConfirmationDialog.show(
                    context: context,
                    title: 'Test',
                    message: 'Message',
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });

  group('Helper Functions Tests', () {
    testWidgets('confirmDelete should show appropriate message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => confirmDelete(context, 'reminder'),
                child: const Text('Delete'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete reminder?'), findsOneWidget);
      expect(find.textContaining('cannot be undone'), findsOneWidget);
    });

    testWidgets('confirmCancelTest should show appropriate message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => confirmCancelTest(context),
                child: const Text('Cancel Test'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel Test'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Test?'), findsOneWidget);
      expect(find.textContaining('progress will be lost'), findsOneWidget);
    });

    testWidgets('confirmClearData should show appropriate message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => confirmClearData(context, 'assessments'),
                child: const Text('Clear'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Clear All assessments?'), findsOneWidget);
      expect(find.textContaining('permanently delete'), findsOneWidget);
    });

    testWidgets('confirmResetSettings should show appropriate message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => confirmResetSettings(context),
                child: const Text('Reset'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Settings?'), findsOneWidget);
      expect(find.textContaining('default values'), findsOneWidget);
    });
  });
}
