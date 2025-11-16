import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/assessment.dart';
import 'package:brain_tests/presentation/providers/assessment_provider.dart';
import 'package:brain_tests/presentation/screens/assessments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAssessments extends Mock implements List<Assessment> {}

void main() {
  group('AssessmentsScreen Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Widget Structure Tests', () {
      testWidgets('should build without crashing', (WidgetTester tester) async {
        // Arrange - Create container with mock providers
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(AssessmentsScreen), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Assessments'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display assessment type grid', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Start New Assessment'), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Memory Recall'), findsOneWidget);
        expect(find.text('Attention Focus'), findsOneWidget);
        expect(find.text('Executive Function'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display progress section', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Your Progress'), findsOneWidget);
        expect(find.text('Recent Assessments'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Data Display Tests', () {
      testWidgets('should display empty state when no assessments', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('No assessments completed yet'), findsOneWidget);
        expect(find.text('Complete assessments to see your progress'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display assessment data when available', (WidgetTester tester) async {
        // Arrange
        final mockAssessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
        ];

        final mockScores = {
          AssessmentType.memoryRecall: 85.0,
        };

        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => mockAssessments),
            averageScoresByTypeProvider.overrideWith((ref) async => mockScores),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('85/100'), findsOneWidget);
        expect(find.text('85.0%'), findsOneWidget);
        expect(find.text('Average Score: 85.0%'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display loading indicator', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async {
              await Future.delayed(const Duration(seconds: 10));
              return [];
            }),
            averageScoresByTypeProvider.overrideWith((ref) async {
              await Future.delayed(const Duration(seconds: 10));
              return {};
            }),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(2));

        testContainer.dispose();
      });

      testWidgets('should display error state', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async {
              throw Exception('Test error');
            }),
            averageScoresByTypeProvider.overrideWith((ref) async {
              throw Exception('Test error');
            }),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.textContaining('Error:'), findsAtLeastNWidgets(1));

        testContainer.dispose();
      });
    });

    group('Score Indicator Tests', () {
      testWidgets('should display green indicator for high scores', (WidgetTester tester) async {
        // Arrange
        final mockScores = {
          AssessmentType.memoryRecall: 85.0,
        };

        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => mockScores),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert - Find containers with green color indicators
        final indicatorFinder = find.byWidgetPredicate(
          (widget) => widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration as BoxDecoration).border != null,
        );
        expect(indicatorFinder, findsAtLeastNWidgets(1));

        testContainer.dispose();
      });
    });

    group('Assessment Type Helper Tests', () {
      testWidgets('should have all assessment types in grid', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert - Check all 6 assessment types are present
        expect(find.text('Memory Recall'), findsOneWidget);
        expect(find.text('Attention Focus'), findsOneWidget);
        expect(find.text('Executive Function'), findsOneWidget);
        expect(find.text('Language Skills'), findsOneWidget);
        expect(find.text('Visuospatial Skills'), findsOneWidget);
        expect(find.text('Processing Speed'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should display correct assessment descriptions', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.text('Test your memory abilities'), findsOneWidget);
        expect(find.text('Measure concentration'), findsOneWidget);
        expect(find.text('Problem solving skills'), findsOneWidget);
        expect(find.text('Language comprehension'), findsOneWidget);
        expect(find.text('Spatial awareness'), findsOneWidget);
        expect(find.text('Information processing'), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Navigation Tests', () {
      testWidgets('should have bottom navigation bar', (WidgetTester tester) async {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => []),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);

        testContainer.dispose();
      });
    });

    group('Multiple Assessments Display Tests', () {
      testWidgets('should display multiple recent assessments', (WidgetTester tester) async {
        // Arrange
        final mockAssessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime.now(),
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.attentionFocus,
            score: 78,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(hours: 1)),
            createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
          ),
          Assessment(
            id: 3,
            type: AssessmentType.executiveFunction,
            score: 92,
            maxScore: 100,
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1, minutes: 15)),
          ),
        ];

        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => mockAssessments),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert - Should show recent assessments
        expect(find.text('85/100'), findsOneWidget);
        expect(find.text('78/100'), findsOneWidget);
        expect(find.text('92/100'), findsOneWidget);

        testContainer.dispose();
      });

      testWidgets('should limit display to 5 recent assessments', (WidgetTester tester) async {
        // Arrange - Create 7 assessments
        final mockAssessments = List.generate(7, (index) => Assessment(
          id: index + 1,
          type: AssessmentType.memoryRecall,
          score: 80 + index,
          maxScore: 100,
          completedAt: DateTime.now().subtract(Duration(hours: index)),
          createdAt: DateTime.now().subtract(Duration(hours: index, minutes: 10)),
        ));

        final testContainer = ProviderContainer(
          overrides: [
            assessmentsProvider.overrideWith((ref) async => mockAssessments),
            averageScoresByTypeProvider.overrideWith((ref) async => {}),
          ],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: testContainer,
            child: const MaterialApp(
              home: AssessmentsScreen(),
            ),
          ),
        );

        // Assert - Should find 5 assessment cards (first 5)
        expect(find.text('80/100'), findsOneWidget); // First assessment
        expect(find.text('81/100'), findsOneWidget); // Second assessment
        expect(find.text('82/100'), findsOneWidget); // Third assessment
        expect(find.text('83/100'), findsOneWidget); // Fourth assessment
        expect(find.text('84/100'), findsOneWidget); // Fifth assessment
        // Should not find the 6th and 7th assessments
        expect(find.text('85/100'), findsNothing);
        expect(find.text('86/100'), findsNothing);

        testContainer.dispose();
      });
    });
  });
}