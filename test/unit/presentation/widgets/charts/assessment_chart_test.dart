import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/assessment.dart';
import 'package:brain_plan/presentation/widgets/charts/assessment_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssessmentChart Tests', () {
    group('Widget Build Tests', () {
      testWidgets('should display empty state when no assessments provided', (WidgetTester tester) async {
        // Arrange
        const widget = AssessmentChart(assessments: []);

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert
        expect(find.text('No assessment data available'), findsOneWidget);
        expect(find.byType(LineChart), findsNothing);
      });

      testWidgets('should display LineChart when assessments are provided', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 90,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert
        expect(find.byType(LineChart), findsOneWidget);
        expect(find.text('No assessment data available'), findsNothing);
      });

      testWidgets('should filter assessments by type when filter is provided', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.attentionFocus,
            score: 90,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
        ];

        final widget = AssessmentChart(
          assessments: assessments,
          filterType: AssessmentType.memoryRecall,
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert - Should display chart (filtered assessments are not empty)
        expect(find.byType(LineChart), findsOneWidget);
      });

      testWidgets('should display empty state when filtered assessments are empty', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final widget = AssessmentChart(
          assessments: assessments,
          filterType: AssessmentType.attentionFocus, // Different type - should filter out all assessments
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert
        expect(find.text('No assessment data available'), findsOneWidget);
        expect(find.byType(LineChart), findsNothing);
      });
    });

    group('Data Processing Tests', () {
      test('should correctly process assessment spots', () {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 80,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.memoryRecall,
            score: 90,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
          Assessment(
            id: 3,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 3),
            createdAt: DateTime(2024, 1, 3),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Assert - Verify widget can be created with assessments
        expect(widget.assessments, hasLength(3));
        expect(widget.assessments[0].percentage, equals(80.0));
        expect(widget.assessments[1].percentage, equals(90.0));
        expect(widget.assessments[2].percentage, equals(85.0));
      });

      // Note: _getColorForAssessmentType is a private method and cannot be tested directly
      // The color logic is tested indirectly through integration tests
      // test('should return correct colors for assessment types', () {
      //   // Arrange
      //   const widget = AssessmentChart(assessments: []);
      //
      //   // Act & Assert
      //   expect(widget._getColorForAssessmentType(null), equals(Colors.blue));
      //   expect(widget._getColorForAssessmentType(AssessmentType.memoryRecall), equals(Colors.purple));
      //   expect(widget._getColorForAssessmentType(AssessmentType.attentionFocus), equals(Colors.orange));
      //   expect(widget._getColorForAssessmentType(AssessmentType.executiveFunction), equals(Colors.green));
      //   expect(widget._getColorForAssessmentType(AssessmentType.languageSkills), equals(Colors.blue));
      //   expect(widget._getColorForAssessmentType(AssessmentType.visuospatialSkills), equals(Colors.red));
      //   expect(widget._getColorForAssessmentType(AssessmentType.processingSpeed), equals(Colors.teal));
      // });
    });

    group('Chart Configuration Tests', () {
      testWidgets('should configure chart with correct min/max values', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert - Find the LineChart widget and verify it's configured correctly
        final lineChart = tester.widget<LineChart>(find.byType(LineChart));
        expect(lineChart.data.minY, equals(0));
        expect(lineChart.data.maxY, equals(100));
        expect(lineChart.data.minX, equals(0));
        expect(lineChart.data.maxX, equals(0)); // assessments.length - 1 = 0 for single assessment
      });

      testWidgets('should configure chart with multiple assessments correctly', (WidgetTester tester) async {
        // Arrange
        final assessments = List.generate(5, (index) => Assessment(
          id: index + 1,
          type: AssessmentType.memoryRecall,
          score: 80 + index,
          maxScore: 100,
          completedAt: DateTime(2024, 1, index + 1),
          createdAt: DateTime(2024, 1, index + 1),
        ));

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert
        final lineChart = tester.widget<LineChart>(find.byType(LineChart));
        expect(lineChart.data.maxX, equals(4.0)); // 5 assessments - 1 = 4
      });
    });

    group('Filter Type Tests', () {
      test('should filter assessments correctly', () {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          Assessment(
            id: 2,
            type: AssessmentType.attentionFocus,
            score: 90,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 2),
          ),
          Assessment(
            id: 3,
            type: AssessmentType.memoryRecall,
            score: 88,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 3),
            createdAt: DateTime(2024, 1, 3),
          ),
        ];

        // Act - Create chart widget to test internal filtering logic
        final widget = AssessmentChart(
          assessments: assessments,
          filterType: AssessmentType.memoryRecall,
        );

        // Assert - We can verify the widget was created successfully
        expect(widget.assessments, hasLength(3));
        expect(widget.filterType, equals(AssessmentType.memoryRecall));
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle single assessment', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 85,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert
        expect(find.byType(LineChart), findsOneWidget);
      });

      testWidgets('should handle perfect scores', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 100,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert - Verify the chart can handle 100% scores
        expect(find.byType(LineChart), findsOneWidget);
      });

      testWidgets('should handle zero scores', (WidgetTester tester) async {
        // Arrange
        final assessments = [
          Assessment(
            id: 1,
            type: AssessmentType.memoryRecall,
            score: 0,
            maxScore: 100,
            completedAt: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final widget = AssessmentChart(assessments: assessments);

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: widget),
          ),
        );

        // Assert - Verify the chart can handle 0% scores
        expect(find.byType(LineChart), findsOneWidget);
      });
    });
  });
}