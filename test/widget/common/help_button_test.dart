import 'package:brain_tests/presentation/widgets/common/help_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HelpButton Widget Tests', () {
    testWidgets('should display help icon button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HelpButton(
              helpText: 'This is help text',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });

    testWidgets('should have accessible size (min 48dp)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HelpButton(
              helpText: 'Help',
              onTap: () {},
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(
        find.byType(IconButton),
      );

      final constraints = iconButton.constraints;
      expect(constraints?.minWidth, greaterThanOrEqualTo(48.0));
      expect(constraints?.minHeight, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should call onTap when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HelpButton(
              helpText: 'Help',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should have semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HelpButton(
              helpText: 'Help',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Help'), findsOneWidget);
    });
  });

  group('HelpDialog Widget Tests', () {
    testWidgets('should display title and content', (tester) async {
      const title = 'Help Title';
      const content = 'This is helpful information.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(
                      title: title,
                      content: content,
                    ),
                  );
                },
                child: const Text('Show Help'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Help'));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.text(content), findsOneWidget);
    });

    testWidgets('should display close button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(
                      title: 'Help',
                      content: 'Content',
                    ),
                  );
                },
                child: const Text('Show Help'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Help'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should close dialog when close button pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(
                      title: 'Help',
                      content: 'Content',
                    ),
                  );
                },
                child: const Text('Show Help'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Help'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should display optional steps list', (tester) async {
      const steps = [
        '1. First step',
        '2. Second step',
        '3. Third step',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HelpDialog(
                      title: 'Help',
                      content: 'Content',
                      steps: steps,
                    ),
                  );
                },
                child: const Text('Show Help'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Help'));
      await tester.pumpAndSettle();

      for (final step in steps) {
        expect(find.text(step), findsOneWidget);
      }
    });
  });

  group('showHelp() Helper Function Tests', () {
    testWidgets('should show help dialog with provided content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showHelp(
                  context: context,
                  title: 'Test Help',
                  content: 'Test content',
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Test Help'), findsOneWidget);
      expect(find.text('Test content'), findsOneWidget);
    });
  });
}
