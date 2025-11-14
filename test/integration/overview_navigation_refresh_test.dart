import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/data/repositories/assessment_repository_impl.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/presentation/providers/assessment_provider.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/providers/repository_providers.dart';
import 'package:brain_plan/presentation/screens/cognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test for Overview screen refresh bug
/// Bug: After completing Trail Making tests and navigating back to Overview,
/// the MCI weekly count shows 0, but clicking info shows the tests
/// Root cause: FutureProvider caching - not invalidating on navigation
void main() {
  group('Overview Navigation Refresh Tests', () {
    late AppDatabase testDb;

    setUp(() async {
      testDb = AppDatabase.memory();
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('Overview MCI count MUST refresh when navigating back from test screen', (tester) async {
      // GIVEN: App is showing Overview with 0 tests
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            assessmentRepositoryProvider.overrideWithValue(AssessmentRepositoryImpl(testDb)),
          ],
          child: MaterialApp(
            home: const CognitionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Overview tab
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Verify initial state shows 0 MCI tests
      expect(find.textContaining('0/5'), findsOneWidget,
          reason: 'Initially should show 0/5 weekly MCI tests');

      // WHEN: User navigates to Trail Making test, completes it
      await tester.tap(find.text('MCI Tests'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trail Making Test'));
      await tester.pumpAndSettle();

      // Start and complete Test A (simulated)
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Complete the test by tapping all circles 1-25 in order
      for (int i = 1; i <= 25; i++) {
        final circleFinder = find.text(i.toString());
        if (circleFinder.evaluate().isNotEmpty) {
          await tester.tap(circleFinder);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate back to Overview using back button
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // THEN: Overview MCI count MUST show 1/5 (not 0/5)
      expect(find.textContaining('1/5'), findsOneWidget,
          reason: 'After completing Trail Making Test A, Overview MUST show 1/5 immediately');
      expect(find.textContaining('0/5'), findsNothing,
          reason: 'Stale cache showing 0/5 is the bug we are testing for');
    });

    testWidgets('Clicking info icon MUST show same count as Overview display', (tester) async {
      // GIVEN: User has completed 2 Trail Making tests
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
          assessmentRepositoryProvider.overrideWithValue(AssessmentRepositoryImpl(testDb)),
        ],
      );

      final tests = [
        Assessment(
          type: AssessmentType.executiveFunction,
          score: 45,
          maxScore: 120,
          notes: 'Trail Making Test A',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Assessment(
          type: AssessmentType.executiveFunction,
          score: 90,
          maxScore: 180,
          notes: 'Trail Making Test B',
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      for (final test in tests) {
        await container.read(assessmentProvider.notifier).addAssessment(test);
      }

      // WHEN: Show Overview
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const CognitionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Overview tab
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // THEN: Overview should show 2/5
      expect(find.textContaining('2/5'), findsOneWidget,
          reason: 'Overview must show correct count of 2 MCI tests');

      // WHEN: Click info icon to open dialog
      final infoButton = find.widgetWithIcon(IconButton, Icons.info_outline).first;
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // THEN: Dialog should show 2 tests
      expect(find.text('Trail Making Test A'), findsOneWidget,
          reason: 'Dialog must show Trail Making Test A');
      expect(find.text('Trail Making Test B'), findsOneWidget,
          reason: 'Dialog must show Trail Making Test B');

      container.dispose();
    });
  });
}
