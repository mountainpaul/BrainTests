import 'package:brain_plan/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingIndicator Widget Tests', () {
    testWidgets('should display circular progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading message when provided', (tester) async {
      const testMessage = 'Loading data...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: testMessage),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should have accessible size of at least 48dp', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, greaterThanOrEqualTo(48.0));
      expect(sizedBox.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('should have semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });

    testWidgets('should allow custom size', (tester) async {
      const customSize = 64.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });
  });

  group('LoadingOverlay Widget Tests', () {
    testWidgets('should show child when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading overlay when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading message in overlay', (tester) async {
      const message = 'Saving...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              message: message,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });
  });

  group('InlineLoadingIndicator Widget Tests', () {
    testWidgets('should display small progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineLoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, equals(24.0));
      expect(sizedBox.height, equals(24.0));
    });

    testWidgets('should display message next to spinner', (tester) async {
      const message = 'Loading more...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineLoadingIndicator(message: message),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should arrange spinner and message horizontally', (tester) async {
      const message = 'Loading...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineLoadingIndicator(message: message),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });
  });
}
