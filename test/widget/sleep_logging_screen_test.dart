import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/screens/sleep_logging_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'sleep_logging_screen_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('Sleep Logging Screen - Garmin Data Entry', () {
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
        child: const MaterialApp(
          home: SleepLoggingScreen(),
        ),
      );
    }

    testWidgets('should display all Garmin sleep fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for all required Garmin fields
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Stress'), findsOneWidget);
      expect(find.text('Light Sleep'), findsOneWidget);
      expect(find.text('Deep Sleep'), findsOneWidget);
      expect(find.text('REM Sleep'), findsOneWidget);
    });

    testWidgets('should have input fields for all sleep metrics', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have 5 main input fields (Duration, Stress, Light, Deep, REM)
      expect(find.byType(TextField), findsAtLeastNWidgets(5));
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Save Sleep Data'), findsOneWidget);
    });

    testWidgets('should show Garmin branding or mention', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should mention Garmin or indicate data source
      expect(find.textContaining('Garmin', findRichText: true), findsWidgets);
    });

    testWidgets('should accept numeric input for duration', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final durationField = find.widgetWithText(TextField, '').first;
      await tester.enterText(durationField, '420');

      expect(find.text('420'), findsOneWidget);
    });

    testWidgets('should show helper text for stress range (0-100)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('0-100', findRichText: true), findsWidgets);
    });

    testWidgets('should display units for time fields (minutes)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show "minutes" or "min" for duration fields
      expect(find.textContaining('minutes', findRichText: true), findsWidgets);
    });
  });
}
