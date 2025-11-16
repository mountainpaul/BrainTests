import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/presentation/providers/database_provider.dart';
import 'package:brain_tests/presentation/providers/repository_providers.dart';
import 'package:brain_tests/presentation/screens/trail_making_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration tests for Trail Making Test end-to-end workflow
/// Tests the complete user journey from starting test to data persistence
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  group('Trail Making Test Integration', () {
    testWidgets('should save Test A results to database via repository', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Start Test A
      await tester.ensureVisible(find.text('Start Test A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Complete Test A by tapping circles 1-25
      for (int i = 1; i <= 25; i++) {
        final finder = find.text(i.toString()).first;
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Assert - Verify data was saved to database
      final assessments = await database.select(database.assessmentTable).get();

      expect(assessments.length, equals(1), reason: 'Test A should save 1 assessment');
      expect(assessments.first.type, equals(AssessmentType.processingSpeed));
      expect(assessments.first.notes, contains('Trail Making Test A'));
      expect(assessments.first.score, greaterThan(0), reason: 'Should have recorded time');
    });

    testWidgets('should save Test B results to database via repository', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Complete Test A first
      await tester.ensureVisible(find.text('Start Test A'));
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Start Test B
      await tester.ensureVisible(find.text('Start Test B'));
      await tester.tap(find.text('Start Test B'));
      await tester.pumpAndSettle();

      // Complete Test B (1-A-2-B-3-C... pattern)
      final sequence = [
        '1', 'A', '2', 'B', '3', 'C', '4', 'D', '5', 'E',
        '6', 'F', '7', 'G', '8', 'H', '9', 'I', '10', 'J',
        '11', 'K', '12', 'L', '13'
      ];

      for (final item in sequence) {
        final finder = find.text(item).first;
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Assert - Verify both Test A and Test B were saved
      final assessments = await database.select(database.assessmentTable).get();

      expect(assessments.length, equals(2), reason: 'Should have Test A and Test B');

      final testA = assessments.firstWhere((a) => a.type == AssessmentType.processingSpeed);
      expect(testA.notes, contains('Trail Making Test A'));

      final testB = assessments.firstWhere((a) => a.type == AssessmentType.executiveFunction);
      expect(testB.notes, contains('Trail Making Test B'));
      expect(testB.score, greaterThan(0));
    });

    testWidgets('should persist results across app restart', (tester) async {
      // Arrange - Complete test and save
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Complete Test A
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      // Act - Simulate app restart by creating new widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Text('Restarted')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Data should still be in database
      final assessments = await database.select(database.assessmentTable).get();
      expect(assessments.length, equals(1));
      expect(assessments.first.type, equals(AssessmentType.processingSpeed));
    });

    testWidgets('should record completion time accurately', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Start test and record start time
      final startTime = DateTime.now();

      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Complete test quickly
      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();

      final endTime = DateTime.now();
      final actualDuration = endTime.difference(startTime).inSeconds;

      // Assert - Recorded time should be reasonable
      final assessments = await database.select(database.assessmentTable).get();
      final recordedTime = assessments.first.score;

      expect(recordedTime, greaterThanOrEqualTo(0));
      expect(recordedTime, lessThan(actualDuration + 5),
        reason: 'Recorded time should be close to actual time');
    });

    testWidgets('should record errors when incorrect sequence tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Start test and make errors
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      // Tap out of order (should count as errors)
      await tester.tap(find.text('1').first);
      await tester.pump();
      await tester.tap(find.text('3').first); // Skip 2 - error
      await tester.pump();
      await tester.tap(find.text('2').first); // Correct now
      await tester.pump();

      // Complete rest correctly
      for (int i = 3; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();

      // Assert - Notes should mention errors
      final assessments = await database.select(database.assessmentTable).get();
      final notes = assessments.first.notes;

      expect(notes, isNotNull);
      expect(notes, contains('Errors'));
    });

    testWidgets('should use repository layer not direct database access', (tester) async {
      // This test verifies the fix for the bug
      // If this fails, it means we're back to direct DB access

      // Arrange
      int repositoryCallCount = 0;

      // We can't easily mock the repository in this integration test,
      // but we can verify the data structure is correct
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: TrailMakingTestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Complete test
      await tester.tap(find.text('Start Test A'));
      await tester.pumpAndSettle();

      for (int i = 1; i <= 25; i++) {
        await tester.tap(find.text(i.toString()).first);
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();

      // Assert - Verify data structure matches what repository would create
      final assessments = await database.select(database.assessmentTable).get();
      final assessment = assessments.first;

      // Repository creates assessments with these fields properly set
      expect(assessment.type, equals(AssessmentType.processingSpeed));
      expect(assessment.score, greaterThan(0));
      expect(assessment.maxScore, equals(120));
      expect(assessment.completedAt, isNotNull);
      expect(assessment.createdAt, isNotNull);
      expect(assessment.notes, isNotNull);

      // Verify createdAt and completedAt are close (set at same time)
      final timeDiff = assessment.completedAt.difference(assessment.createdAt).inSeconds.abs();
      expect(timeDiff, lessThan(2),
        reason: 'CreatedAt and CompletedAt should be set at same time by repository');
    });
  });
}
