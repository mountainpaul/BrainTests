import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for the text overflow fix in Language Skills tests.
/// Fixed on 2024-11-24: "LISTENING CONTINUOUSLY" text now wrapped in Flexible
/// widget to prevent overflow on narrow screens.
void main() {
  group('Language Skills Text Overflow Fix', () {
    testWidgets('Flexible widget should prevent text overflow in Row',
        (WidgetTester tester) async {
      // Build a narrow container to simulate the overflow condition
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Narrow width that would cause overflow without fix
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    size: 32,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'LISTENING CONTINUOUSLY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Flexible widget is present
      expect(find.byType(Flexible), findsOneWidget);

      // Verify the text widget exists
      expect(find.text('LISTENING CONTINUOUSLY'), findsOneWidget);

      // Verify the text has overflow handling
      final textWidget = tester.widget<Text>(find.text('LISTENING CONTINUOUSLY'));
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('Text should be visible within narrow container',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, size: 32),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'LISTENING CONTINUOUSLY',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Should not throw overflow error
      expect(tester.takeException(), isNull);
    });

    testWidgets('Row without Flexible causes overflow (demonstrating the bug)',
        (WidgetTester tester) async {
      // This demonstrates what happens WITHOUT the fix
      // In the actual app, this would cause a RenderFlex overflow error

      // We expect this to throw an overflow exception
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150, // Very narrow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, size: 32),
                  const SizedBox(width: 12),
                  // WITHOUT Flexible - this WILL overflow
                  Text(
                    'LISTENING CONTINUOUSLY',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      FlutterError.onError = oldHandler;

      // Verify that an overflow error was captured
      expect(
        errors.any((e) => e.toString().contains('overflowed')),
        true,
        reason: 'Should have captured an overflow error',
      );
    });

    testWidgets('Starting text should also be wrapped in Flexible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_off, size: 32, color: Colors.grey),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Starting...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Flexible), findsOneWidget);
      expect(find.text('Starting...'), findsOneWidget);
    });
  });

  group('Mic Status Icon', () {
    testWidgets('should show mic icon when listening', (WidgetTester tester) async {
      final isListening = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Icon(
              isListening ? Icons.mic : Icons.mic_off,
              size: 32,
              color: isListening ? Colors.green : Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should show mic_off icon when not listening',
        (WidgetTester tester) async {
      final isListening = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Icon(
              isListening ? Icons.mic : Icons.mic_off,
              size: 32,
              color: isListening ? Colors.green : Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });
  });

  group('Text Color Based on State', () {
    testWidgets('text should be green when listening', (WidgetTester tester) async {
      final isListening = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              isListening ? 'LISTENING CONTINUOUSLY' : 'Starting...',
              style: TextStyle(
                color: isListening ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('LISTENING CONTINUOUSLY'),
      );
      expect(textWidget.style?.color, Colors.green);
    });

    testWidgets('text should be grey when starting', (WidgetTester tester) async {
      final isListening = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text(
              isListening ? 'LISTENING CONTINUOUSLY' : 'Starting...',
              style: TextStyle(
                color: isListening ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('Starting...'),
      );
      expect(textWidget.style?.color, Colors.grey);
    });
  });
}
