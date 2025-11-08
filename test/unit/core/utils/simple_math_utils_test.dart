import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

// Simple math utilities that can be easily tested
class SimpleMathUtils {
  static double percentage(int score, int total) {
    if (total == 0) return 0.0;
    return (score / total) * 100;
  }

  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static int roundToNearest(double value) {
    return value.round();
  }

  static bool isWithinRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  static List<double> normalize(List<double> values) {
    if (values.isEmpty) return [];

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    if (min == max) return values.map((v) => 0.5).toList();

    return values.map((v) => (v - min) / (max - min)).toList();
  }

  static double average(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double median(List<double> values) {
    if (values.isEmpty) return 0.0;

    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length % 2 == 0) {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    } else {
      return sorted[middle];
    }
  }

  static int sum(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b);
  }

  static double standardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = average(values);
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return variance.isNaN || variance < 0 ? 0.0 : math.sqrt(variance);
  }

  static bool isPrime(int n) {
    if (n <= 1) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;

    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  static int factorial(int n) {
    if (n < 0) return 0;
    if (n <= 1) return 1;

    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static int fibonacci(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;

    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      final int temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  static List<int> range(int start, int end, [int step = 1]) {
    if (step == 0) return [];

    final result = <int>[];
    if (step > 0) {
      for (int i = start; i < end; i += step) {
        result.add(i);
      }
    } else {
      for (int i = start; i > end; i += step) {
        result.add(i);
      }
    }
    return result;
  }

  static Map<String, double> calculateStats(List<double> values) {
    return {
      'count': values.length.toDouble(),
      'sum': values.isEmpty ? 0.0 : values.reduce((a, b) => a + b),
      'average': average(values),
      'median': median(values),
      'standardDeviation': standardDeviation(values),
      'min': values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b),
      'max': values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b),
    };
  }
}

void main() {
  group('SimpleMathUtils Tests', () {
    group('Percentage Tests', () {
      test('should calculate percentage correctly', () {
        expect(SimpleMathUtils.percentage(85, 100), 85.0);
        expect(SimpleMathUtils.percentage(50, 100), 50.0);
        expect(SimpleMathUtils.percentage(0, 100), 0.0);
        expect(SimpleMathUtils.percentage(100, 100), 100.0);
      });

      test('should handle division by zero', () {
        expect(SimpleMathUtils.percentage(50, 0), 0.0);
        expect(SimpleMathUtils.percentage(0, 0), 0.0);
      });

      test('should handle edge cases', () {
        expect(SimpleMathUtils.percentage(150, 100), 150.0);
        expect(SimpleMathUtils.percentage(-10, 100), -10.0);
      });
    });

    group('Clamp Tests', () {
      test('should clamp values correctly', () {
        expect(SimpleMathUtils.clamp(5.0, 0.0, 10.0), 5.0);
        expect(SimpleMathUtils.clamp(-5.0, 0.0, 10.0), 0.0);
        expect(SimpleMathUtils.clamp(15.0, 0.0, 10.0), 10.0);
      });

      test('should handle equal min and max', () {
        expect(SimpleMathUtils.clamp(5.0, 3.0, 3.0), 3.0);
        expect(SimpleMathUtils.clamp(1.0, 3.0, 3.0), 3.0);
      });
    });

    group('Rounding Tests', () {
      test('should round to nearest integer', () {
        expect(SimpleMathUtils.roundToNearest(4.4), 4);
        expect(SimpleMathUtils.roundToNearest(4.5), 5);
        expect(SimpleMathUtils.roundToNearest(4.6), 5);
        expect(SimpleMathUtils.roundToNearest(-4.4), -4);
        expect(SimpleMathUtils.roundToNearest(-4.5), -5); // Dart uses "round away from zero" for .5
        expect(SimpleMathUtils.roundToNearest(-4.6), -5);
      });
    });

    group('Range Tests', () {
      test('should check if value is within range', () {
        expect(SimpleMathUtils.isWithinRange(5.0, 0.0, 10.0), isTrue);
        expect(SimpleMathUtils.isWithinRange(0.0, 0.0, 10.0), isTrue);
        expect(SimpleMathUtils.isWithinRange(10.0, 0.0, 10.0), isTrue);
        expect(SimpleMathUtils.isWithinRange(-1.0, 0.0, 10.0), isFalse);
        expect(SimpleMathUtils.isWithinRange(11.0, 0.0, 10.0), isFalse);
      });
    });

    group('Normalization Tests', () {
      test('should normalize values correctly', () {
        final values = [1.0, 2.0, 3.0, 4.0, 5.0];
        final normalized = SimpleMathUtils.normalize(values);

        expect(normalized.first, 0.0);
        expect(normalized.last, 1.0);
        expect(normalized.length, values.length);
      });

      test('should handle empty list', () {
        expect(SimpleMathUtils.normalize([]), isEmpty);
      });

      test('should handle single value', () {
        final normalized = SimpleMathUtils.normalize([5.0]);
        expect(normalized.first, 0.5);
      });

      test('should handle identical values', () {
        final normalized = SimpleMathUtils.normalize([3.0, 3.0, 3.0]);
        expect(normalized.every((v) => v == 0.5), isTrue);
      });
    });

    group('Statistical Tests', () {
      test('should calculate average correctly', () {
        expect(SimpleMathUtils.average([1.0, 2.0, 3.0, 4.0, 5.0]), 3.0);
        expect(SimpleMathUtils.average([10.0, 20.0]), 15.0);
        expect(SimpleMathUtils.average([]), 0.0);
        expect(SimpleMathUtils.average([42.0]), 42.0);
      });

      test('should calculate median correctly', () {
        expect(SimpleMathUtils.median([1.0, 2.0, 3.0]), 2.0);
        expect(SimpleMathUtils.median([1.0, 2.0, 3.0, 4.0]), 2.5);
        expect(SimpleMathUtils.median([5.0]), 5.0);
        expect(SimpleMathUtils.median([]), 0.0);
      });

      test('should calculate standard deviation correctly', () {
        final values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
        final result = SimpleMathUtils.standardDeviation(values);
        expect(result, closeTo(2.0, 0.1));

        expect(SimpleMathUtils.standardDeviation([]), 0.0);
        expect(SimpleMathUtils.standardDeviation([5.0]), 0.0);
      });

      test('should calculate stats correctly', () {
        final values = [1.0, 2.0, 3.0, 4.0, 5.0];
        final stats = SimpleMathUtils.calculateStats(values);

        expect(stats['count'], 5.0);
        expect(stats['sum'], 15.0);
        expect(stats['average'], 3.0);
        expect(stats['median'], 3.0);
        expect(stats['min'], 1.0);
        expect(stats['max'], 5.0);
      });
    });

    group('Integer Sum Tests', () {
      test('should sum integers correctly', () {
        expect(SimpleMathUtils.sum([1, 2, 3, 4, 5]), 15);
        expect(SimpleMathUtils.sum([10, 20]), 30);
        expect(SimpleMathUtils.sum([]), 0);
        expect(SimpleMathUtils.sum([42]), 42);
        expect(SimpleMathUtils.sum([-5, 5]), 0);
      });
    });

    group('Prime Number Tests', () {
      test('should identify prime numbers correctly', () {
        expect(SimpleMathUtils.isPrime(2), isTrue);
        expect(SimpleMathUtils.isPrime(3), isTrue);
        expect(SimpleMathUtils.isPrime(5), isTrue);
        expect(SimpleMathUtils.isPrime(7), isTrue);
        expect(SimpleMathUtils.isPrime(11), isTrue);
        expect(SimpleMathUtils.isPrime(13), isTrue);
      });

      test('should identify non-prime numbers correctly', () {
        expect(SimpleMathUtils.isPrime(1), isFalse);
        expect(SimpleMathUtils.isPrime(4), isFalse);
        expect(SimpleMathUtils.isPrime(6), isFalse);
        expect(SimpleMathUtils.isPrime(8), isFalse);
        expect(SimpleMathUtils.isPrime(9), isFalse);
        expect(SimpleMathUtils.isPrime(10), isFalse);
        expect(SimpleMathUtils.isPrime(12), isFalse);
      });

      test('should handle edge cases', () {
        expect(SimpleMathUtils.isPrime(0), isFalse);
        expect(SimpleMathUtils.isPrime(-5), isFalse);
      });
    });

    group('Factorial Tests', () {
      test('should calculate factorial correctly', () {
        expect(SimpleMathUtils.factorial(0), 1);
        expect(SimpleMathUtils.factorial(1), 1);
        expect(SimpleMathUtils.factorial(2), 2);
        expect(SimpleMathUtils.factorial(3), 6);
        expect(SimpleMathUtils.factorial(4), 24);
        expect(SimpleMathUtils.factorial(5), 120);
      });

      test('should handle negative numbers', () {
        expect(SimpleMathUtils.factorial(-1), 0);
        expect(SimpleMathUtils.factorial(-5), 0);
      });
    });

    group('Fibonacci Tests', () {
      test('should calculate fibonacci correctly', () {
        expect(SimpleMathUtils.fibonacci(0), 0);
        expect(SimpleMathUtils.fibonacci(1), 1);
        expect(SimpleMathUtils.fibonacci(2), 1);
        expect(SimpleMathUtils.fibonacci(3), 2);
        expect(SimpleMathUtils.fibonacci(4), 3);
        expect(SimpleMathUtils.fibonacci(5), 5);
        expect(SimpleMathUtils.fibonacci(6), 8);
        expect(SimpleMathUtils.fibonacci(7), 13);
      });

      test('should handle negative numbers', () {
        expect(SimpleMathUtils.fibonacci(-1), 0);
        expect(SimpleMathUtils.fibonacci(-5), 0);
      });
    });

    group('Range Generation Tests', () {
      test('should generate ranges correctly', () {
        expect(SimpleMathUtils.range(0, 5), [0, 1, 2, 3, 4]);
        expect(SimpleMathUtils.range(1, 4), [1, 2, 3]);
        expect(SimpleMathUtils.range(0, 10, 2), [0, 2, 4, 6, 8]);
        expect(SimpleMathUtils.range(10, 0, -2), [10, 8, 6, 4, 2]);
      });

      test('should handle edge cases', () {
        expect(SimpleMathUtils.range(5, 5), isEmpty);
        expect(SimpleMathUtils.range(0, 5, 0), isEmpty);
        expect(SimpleMathUtils.range(5, 0), isEmpty);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle NaN values gracefully', () {
        final values = [1.0, double.nan, 3.0];
        final stats = SimpleMathUtils.calculateStats(values);
        expect(stats['count'], 3.0);
        // NaN propagates in calculations
        expect(stats['sum']!.isNaN, isTrue);
      });

      test('should handle infinity values', () {
        expect(SimpleMathUtils.clamp(double.infinity, 0.0, 100.0), 100.0);
        expect(SimpleMathUtils.clamp(double.negativeInfinity, 0.0, 100.0), 0.0);
      });

      test('should handle very large numbers', () {
        const largeNum = 1e10;
        expect(SimpleMathUtils.percentage(largeNum.toInt(), largeNum.toInt()), 100.0);
        expect(SimpleMathUtils.clamp(largeNum, 0.0, 1e5), 1e5);
      });

      test('should handle very small numbers', () {
        const smallNum = 1e-10;
        // Very small numbers converted to int become 0, so division by zero returns 0.0
        expect(SimpleMathUtils.percentage(1, smallNum.toInt()), 0.0);
        expect(SimpleMathUtils.isWithinRange(smallNum, 0.0, 1.0), isTrue);
      });
    });
  });
}