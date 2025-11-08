import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/screens/cycling_logging_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'cycling_logging_screen_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('Cycling Logging Screen - Garmin Data Entry', () {
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
          home: CyclingLoggingScreen(),
        ),
      );
    }

    testWidgets('should display all Garmin cycling fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for all required Garmin cycling fields
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Total Time'), findsOneWidget);
      expect(find.text('Avg Moving Speed'), findsOneWidget);
      expect(find.text('Avg Heart Rate'), findsOneWidget);
      expect(find.text('Max Heart Rate'), findsOneWidget);
    });

    testWidgets('should have input fields for all cycling metrics', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have 5 main input fields
      expect(find.byType(TextField), findsAtLeastNWidgets(5));
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Save Cycling Data'), findsOneWidget);
    });

    testWidgets('should show Garmin branding or mention', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should mention Garmin or indicate data source
      expect(find.textContaining('Garmin', findRichText: true), findsWidgets);
    });

    testWidgets('should accept numeric input for distance', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final distanceField = find.widgetWithText(TextField, '').first;
      await tester.enterText(distanceField, '15.5');

      expect(find.text('15.5'), findsOneWidget);
    });

    testWidgets('should display units for distance (km)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show "km" for distance
      expect(find.textContaining('km', findRichText: true), findsWidgets);
    });

    testWidgets('should display units for time (minutes or hours)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show time units
      expect(find.textContaining('min', findRichText: true), findsWidgets);
    });

    testWidgets('should display units for speed (km/h)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show "km/h" for speed
      expect(find.textContaining('km/h', findRichText: true), findsWidgets);
    });

    testWidgets('should display units for heart rate (bpm)', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show "bpm" for heart rate
      expect(find.textContaining('bpm', findRichText: true), findsWidgets);
    });
  });
}
