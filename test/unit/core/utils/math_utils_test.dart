import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

// Math utilities for assessment scoring
class AssessmentMath {
  static double calculatePercentage(int score, int total) {
    if (total == 0) return 0.0;
    return (score / total) * 100;
  }

  static double calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return correct / total;
  }

  static double calculateZScore(double value, double mean, double standardDeviation) {
    if (standardDeviation == 0) return 0.0;
    return (value - mean) / standardDeviation;
  }

  static List<double> calculateMovingAverage(List<double> values, int windowSize) {
    if (values.length < windowSize) return values;

    final result = <double>[];
    for (int i = windowSize - 1; i < values.length; i++) {
      final window = values.sublist(i - windowSize + 1, i + 1);
      final average = window.reduce((a, b) => a + b) / windowSize;
      result.add(average);
    }
    return result;
  }

  static double calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumOfSquaredDifferences = values
        .map((value) => math.pow(value - mean, 2))
        .reduce((a, b) => a + b);

    return math.sqrt(sumOfSquaredDifferences / values.length);
  }

  static Map<String, double> calculateBasicStats(List<double> values) {
    if (values.isEmpty) {
      return {
        'mean': 0.0,
        'median': 0.0,
        'min': 0.0,
        'max': 0.0,
        'stdDev': 0.0,
      };
    }

    final sorted = List<double>.from(values)..sort();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final median = sorted.length.isOdd
        ? sorted[sorted.length ~/ 2]
        : (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;

    return {
      'mean': mean,
      'median': median,
      'min': sorted.first,
      'max': sorted.last,
      'stdDev': calculateStandardDeviation(values),
    };
  }

  static double normalizeScore(double score, double min, double max) {
    if (max == min) return 0.0;
    return (score - min) / (max - min);
  }

  static int roundToNearestInt(double value) {
    return (value + 0.5).floor();
  }

  static bool isOutlier(double value, List<double> dataset) {
    if (dataset.length < 4) return false;

    final sorted = List<double>.from(dataset)..sort();
    final q1Index = (sorted.length * 0.25).floor();
    final q3Index = (sorted.length * 0.75).floor();
    final q1 = sorted[q1Index];
    final q3 = sorted[q3Index];
    final iqr = q3 - q1;

    final lowerBound = q1 - (1.5 * iqr);
    final upperBound = q3 + (1.5 * iqr);

    return value < lowerBound || value > upperBound;
  }

  static double calculateCoefficient(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    final meanX = x.reduce((a, b) => a + b) / x.length;
    final meanY = y.reduce((a, b) => a + b) / y.length;

    double numerator = 0;
    double denominatorX = 0;
    double denominatorY = 0;

    for (int i = 0; i < x.length; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      denominatorX += diffX * diffX;
      denominatorY += diffY * diffY;
    }

    final denominator = math.sqrt(denominatorX * denominatorY);
    return denominator == 0 ? 0.0 : numerator / denominator;
  }
}

void main() {
  group('Assessment Math Tests', () {
    group('Basic Calculations', () {
      test('should calculate percentage correctly', () {
        expect(AssessmentMath.calculatePercentage(8, 10), 80.0);
        expect(AssessmentMath.calculatePercentage(0, 10), 0.0);
        expect(AssessmentMath.calculatePercentage(10, 10), 100.0);
        expect(AssessmentMath.calculatePercentage(5, 0), 0.0); // Edge case
      });

      test('should calculate accuracy correctly', () {
        expect(AssessmentMath.calculateAccuracy(8, 10), 0.8);
        expect(AssessmentMath.calculateAccuracy(0, 10), 0.0);
        expect(AssessmentMath.calculateAccuracy(10, 10), 1.0);
        expect(AssessmentMath.calculateAccuracy(5, 0), 0.0); // Edge case
      });

      test('should calculate Z-score correctly', () {
        expect(AssessmentMath.calculateZScore(85, 100, 15), closeTo(-1.0, 0.01));
        expect(AssessmentMath.calculateZScore(100, 100, 15), 0.0);
        expect(AssessmentMath.calculateZScore(115, 100, 15), closeTo(1.0, 0.01));
        expect(AssessmentMath.calculateZScore(85, 100, 0), 0.0); // Edge case
      });
    });

    group('Statistical Calculations', () {
      test('should calculate moving average correctly', () {
        final values = [1.0, 2.0, 3.0, 4.0, 5.0];
        final result = AssessmentMath.calculateMovingAverage(values, 3);
        expect(result, [2.0, 3.0, 4.0]);

        // Test with insufficient data
        final shortValues = [1.0, 2.0];
        final shortResult = AssessmentMath.calculateMovingAverage(shortValues, 3);
        expect(shortResult, [1.0, 2.0]);
      });

      test('should calculate standard deviation correctly', () {
        final values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
        final result = AssessmentMath.calculateStandardDeviation(values);
        expect(result, closeTo(2.0, 0.1));

        // Test with empty list
        expect(AssessmentMath.calculateStandardDeviation([]), 0.0);
      });

      test('should calculate basic statistics correctly', () {
        final values = [1.0, 2.0, 3.0, 4.0, 5.0];
        final stats = AssessmentMath.calculateBasicStats(values);

        expect(stats['mean'], 3.0);
        expect(stats['median'], 3.0);
        expect(stats['min'], 1.0);
        expect(stats['max'], 5.0);
        expect(stats['stdDev'], closeTo(1.58, 0.2));

        // Test with empty list
        final emptyStats = AssessmentMath.calculateBasicStats([]);
        expect(emptyStats['mean'], 0.0);
        expect(emptyStats['median'], 0.0);
      });
    });

    group('Score Normalization', () {
      test('should normalize scores correctly', () {
        expect(AssessmentMath.normalizeScore(75, 0, 100), 0.75);
        expect(AssessmentMath.normalizeScore(0, 0, 100), 0.0);
        expect(AssessmentMath.normalizeScore(100, 0, 100), 1.0);
        expect(AssessmentMath.normalizeScore(50, 50, 50), 0.0); // Edge case
      });

      test('should round to nearest integer correctly', () {
        expect(AssessmentMath.roundToNearestInt(2.3), 2);
        expect(AssessmentMath.roundToNearestInt(2.7), 3);
        expect(AssessmentMath.roundToNearestInt(2.5), 3);
        expect(AssessmentMath.roundToNearestInt(-1.5), -1);
      });
    });

    group('Outlier Detection', () {
      test('should detect outliers correctly', () {
        final dataset = [1.0, 2.0, 3.0, 4.0, 5.0, 100.0]; // 100 is an outlier
        expect(AssessmentMath.isOutlier(100.0, dataset), true);
        expect(AssessmentMath.isOutlier(3.0, dataset), false);

        // Test with insufficient data
        final smallDataset = [1.0, 2.0];
        expect(AssessmentMath.isOutlier(100.0, smallDataset), false);
      });
    });

    group('Correlation Analysis', () {
      test('should calculate correlation coefficient correctly', () {
        final x = [1.0, 2.0, 3.0, 4.0, 5.0];
        final y = [2.0, 4.0, 6.0, 8.0, 10.0]; // Perfect positive correlation

        final correlation = AssessmentMath.calculateCoefficient(x, y);
        expect(correlation, closeTo(1.0, 0.01));

        // Test with no correlation
        final uncorrelatedY = [5.0, 3.0, 8.0, 1.0, 7.0];
        final noCorrelation = AssessmentMath.calculateCoefficient(x, uncorrelatedY);
        expect(noCorrelation, lessThan(0.5)); // Should be low correlation

        // Test with mismatched lengths
        final shortY = [1.0, 2.0];
        expect(AssessmentMath.calculateCoefficient(x, shortY), 0.0);

        // Test with empty lists
        expect(AssessmentMath.calculateCoefficient([], []), 0.0);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle division by zero gracefully', () {
        expect(AssessmentMath.calculatePercentage(5, 0), 0.0);
        expect(AssessmentMath.calculateAccuracy(5, 0), 0.0);
        expect(AssessmentMath.calculateZScore(85, 100, 0), 0.0);
        expect(AssessmentMath.normalizeScore(50, 100, 100), 0.0);
      });

      test('should handle empty datasets gracefully', () {
        expect(AssessmentMath.calculateStandardDeviation([]), 0.0);
        expect(AssessmentMath.calculateMovingAverage([], 3), []);

        final emptyStats = AssessmentMath.calculateBasicStats([]);
        expect(emptyStats['mean'], 0.0);
        expect(emptyStats['median'], 0.0);
        expect(emptyStats['min'], 0.0);
        expect(emptyStats['max'], 0.0);
        expect(emptyStats['stdDev'], 0.0);
      });

      test('should handle single value datasets', () {
        final singleValue = [42.0];
        expect(AssessmentMath.calculateStandardDeviation(singleValue), 0.0);

        final singleStats = AssessmentMath.calculateBasicStats(singleValue);
        expect(singleStats['mean'], 42.0);
        expect(singleStats['median'], 42.0);
        expect(singleStats['min'], 42.0);
        expect(singleStats['max'], 42.0);
        expect(singleStats['stdDev'], 0.0);
      });
    });
  });
}