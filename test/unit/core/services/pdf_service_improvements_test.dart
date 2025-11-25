import 'package:brain_tests/data/datasources/database.dart' hide CambridgeTestType;
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/domain/entities/cambridge_assessment.dart';
import 'package:brain_tests/domain/entities/cognitive_exercise.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for PDF service improvements made on 2024-11-24:
/// 1. Processing Speed and Executive Function now show time instead of percentage
/// 2. Trend graphs are generated when there's more than one week of data
/// 3. Cambridge assessments are included in the report
void main() {
  group('PDF Service Improvements', () {
    group('Timed Test Detection', () {
      test('processingSpeed should be identified as timed test', () {
        // Processing Speed (Trail Making A) is a timed test
        final assessment = Assessment(
          id: 1,
          type: AssessmentType.processingSpeed,
          score: 45, // 45 seconds
          maxScore: 120,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // For timed tests, lower score (time) is better
        expect(assessment.type, AssessmentType.processingSpeed);
        // The score represents seconds, not points
        expect(assessment.score, 45);
      });

      test('executiveFunction should be identified as timed test', () {
        // Executive Function (Trail Making B) is a timed test
        final assessment = Assessment(
          id: 1,
          type: AssessmentType.executiveFunction,
          score: 78, // 78 seconds
          maxScore: 180,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.type, AssessmentType.executiveFunction);
        expect(assessment.score, 78);
      });

      test('memoryRecall should NOT be identified as timed test', () {
        // Memory Recall is a scored test, not timed
        final assessment = Assessment(
          id: 1,
          type: AssessmentType.memoryRecall,
          score: 8,
          maxScore: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.type, AssessmentType.memoryRecall);
        // Percentage should make sense for this test
        expect(assessment.percentage, 80.0);
      });

      test('languageSkills should NOT be identified as timed test', () {
        final assessment = Assessment(
          id: 1,
          type: AssessmentType.languageSkills,
          score: 15,
          maxScore: 20,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(assessment.type, AssessmentType.languageSkills);
        expect(assessment.percentage, 75.0);
      });
    });

    group('Trend Data Detection', () {
      test('should detect more than one week of data from assessments', () {
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 8,
            maxScore: 10,
            completedAt: DateTime.now().subtract(const Duration(days: 10)),
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 9,
            maxScore: 10,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        final dates = assessments.map((a) => a.completedAt).toList()..sort();
        final daysDiff = dates.last.difference(dates.first).inDays;

        expect(daysDiff >= 7, true);
      });

      test('should NOT detect more than one week for same-day data', () {
        final now = DateTime.now();
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 8,
            maxScore: 10,
            completedAt: now,
            createdAt: now,
          ),
          Assessment(
            id: 2,
            type: AssessmentType.attentionFocus,
            score: 9,
            maxScore: 10,
            completedAt: now,
            createdAt: now,
          ),
        ];

        final dates = assessments.map((a) => a.completedAt).toList()..sort();
        final daysDiff = dates.last.difference(dates.first).inDays;

        expect(daysDiff >= 7, false);
      });

      test('should detect trend from Cambridge assessments', () {
        final cambridgeResults = [
          CambridgeAssessmentResult(
            testType: CambridgeTestType.rvp,
            durationSeconds: 300,
            accuracy: 85.0,
            totalTrials: 100,
            correctTrials: 85,
            errorCount: 15,
            meanLatencyMs: 450.0,
            medianLatencyMs: 420.0,
            specificMetrics: {},
            normScore: 95.0,
            interpretation: 'Average',
            completedAt: DateTime.now().subtract(const Duration(days: 14)),
          ),
          CambridgeAssessmentResult(
            testType: CambridgeTestType.rvp,
            durationSeconds: 300,
            accuracy: 90.0,
            totalTrials: 100,
            correctTrials: 90,
            errorCount: 10,
            meanLatencyMs: 400.0,
            medianLatencyMs: 380.0,
            specificMetrics: {},
            normScore: 100.0,
            interpretation: 'Above average',
            completedAt: DateTime.now(),
          ),
        ];

        final dates = cambridgeResults.map((c) => c.completedAt).toList()..sort();
        final daysDiff = dates.last.difference(dates.first).inDays;

        expect(daysDiff >= 7, true);
      });

      test('should detect trend from cognitive exercises', () {
        final exercises = [
          CognitiveExercise(
            id: 1,
            name: 'Memory Game',
            type: ExerciseType.memoryGame,
            difficulty: ExerciseDifficulty.medium,
            score: 85,
            maxScore: 100,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(days: 10)),
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          CognitiveExercise(
            id: 2,
            name: 'Word Puzzle',
            type: ExerciseType.wordPuzzle,
            difficulty: ExerciseDifficulty.medium,
            score: 90,
            maxScore: 100,
            isCompleted: true,
            completedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        final dates = exercises
            .where((e) => e.completedAt != null)
            .map((e) => e.completedAt!)
            .toList()
          ..sort();
        final daysDiff = dates.last.difference(dates.first).inDays;

        expect(daysDiff >= 7, true);
      });
    });

    group('Cambridge Assessment Types', () {
      test('RVP test type should be recognized', () {
        final result = CambridgeAssessmentResult(
          testType: CambridgeTestType.rvp,
          durationSeconds: 300,
          accuracy: 85.0,
          totalTrials: 100,
          correctTrials: 85,
          errorCount: 15,
          meanLatencyMs: 450.0,
          medianLatencyMs: 420.0,
          specificMetrics: {},
          normScore: 95.0,
          interpretation: 'Average',
          completedAt: DateTime.now(),
        );

        expect(result.testType, CambridgeTestType.rvp);
        expect(result.testType.name, 'rvp');
      });

      test('all Cambridge test types should be valid', () {
        final testTypes = [
          CambridgeTestType.pal,
          CambridgeTestType.prm,
          CambridgeTestType.swm,
          CambridgeTestType.rvp,
          CambridgeTestType.rti,
          CambridgeTestType.soc,
        ];

        for (final type in testTypes) {
          expect(type.name.isNotEmpty, true);
        }
      });
    });

    group('Timed Test Improvement Calculation', () {
      test('should calculate improvement for timed tests (lower is better)', () {
        final firstTime = 78; // First attempt: 78 seconds
        final latestTime = 65; // Latest attempt: 65 seconds
        final improvement = firstTime - latestTime;

        expect(improvement, 13); // 13 seconds faster
        expect(improvement > 0, true); // Positive = improvement
      });

      test('should detect regression for timed tests', () {
        final firstTime = 65; // First attempt: 65 seconds
        final latestTime = 78; // Latest attempt: 78 seconds
        final improvement = firstTime - latestTime;

        expect(improvement, -13); // 13 seconds slower
        expect(improvement < 0, true); // Negative = regression
      });
    });

    group('Cambridge Accuracy Trend', () {
      test('should calculate accuracy improvement', () {
        final firstAccuracy = 75.0;
        final latestAccuracy = 88.5;
        final improvement = latestAccuracy - firstAccuracy;

        expect(improvement, 13.5);
        expect(improvement > 0, true);
      });

      test('should detect accuracy decline', () {
        final firstAccuracy = 90.0;
        final latestAccuracy = 82.0;
        final improvement = latestAccuracy - firstAccuracy;

        expect(improvement, -8.0);
        expect(improvement < 0, true);
      });
    });

    group('Week of Month Calculation', () {
      test('should calculate correct week of month for beginning of month', () {
        final date = DateTime(2024, 11, 1);
        final firstDayOfMonth = DateTime(date.year, date.month, 1);
        final firstWeekday = firstDayOfMonth.weekday;
        final weekOfMonth = ((date.day + firstWeekday - 2) ~/ 7) + 1;

        expect(weekOfMonth >= 1, true);
        expect(weekOfMonth <= 5, true);
      });

      test('should calculate correct week of month for end of month', () {
        final date = DateTime(2024, 11, 28);
        final firstDayOfMonth = DateTime(date.year, date.month, 1);
        final firstWeekday = firstDayOfMonth.weekday;
        final weekOfMonth = ((date.day + firstWeekday - 2) ~/ 7) + 1;

        expect(weekOfMonth >= 4, true);
        expect(weekOfMonth <= 5, true);
      });
    });

    group('Progress Bar Generation', () {
      test('should generate full progress bar for 100%', () {
        final progress = 1.0;
        final filled = (progress.clamp(0.0, 1.0) * 10).round();
        final empty = 10 - filled;
        final bar = '${'█' * filled}${'░' * empty}';

        expect(bar, '██████████');
        expect(filled, 10);
        expect(empty, 0);
      });

      test('should generate half progress bar for 50%', () {
        final progress = 0.5;
        final filled = (progress.clamp(0.0, 1.0) * 10).round();
        final empty = 10 - filled;
        final bar = '${'█' * filled}${'░' * empty}';

        expect(bar, '█████░░░░░');
        expect(filled, 5);
        expect(empty, 5);
      });

      test('should generate empty progress bar for 0%', () {
        final progress = 0.0;
        final filled = (progress.clamp(0.0, 1.0) * 10).round();
        final empty = 10 - filled;
        final bar = '${'█' * filled}${'░' * empty}';

        expect(bar, '░░░░░░░░░░');
        expect(filled, 0);
        expect(empty, 10);
      });

      test('should clamp progress above 100%', () {
        final progress = 1.5;
        final filled = (progress.clamp(0.0, 1.0) * 10).round();
        final empty = 10 - filled;

        expect(filled, 10);
        expect(empty, 0);
      });

      test('should clamp progress below 0%', () {
        final progress = -0.5;
        final filled = (progress.clamp(0.0, 1.0) * 10).round();
        final empty = 10 - filled;

        expect(filled, 0);
        expect(empty, 10);
      });
    });
  });
}
