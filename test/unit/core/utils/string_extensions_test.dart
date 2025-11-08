import 'package:flutter_test/flutter_test.dart';

// String extension utilities for testing
extension StringExtensions on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  bool containsOnlyNumbers() {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  List<String> toWords() {
    return toLowerCase().split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty).toList();
  }
}

// Number utilities
extension NumExtensions on num {
  bool isBetween(num min, num max) {
    return this >= min && this <= max;
  }

  String toPercentage([int decimals = 1]) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}

// Duration utilities for assessments
extension DurationExtensions on Duration {
  String toReadableString() {
    if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  bool isWithinRange(Duration min, Duration max) {
    return this >= min && this <= max;
  }
}

// List utilities for assessments
extension ListExtensions<T> on List<T> {
  List<T> uniqueItems() {
    return toSet().toList();
  }

  T? safeElementAt(int index) {
    return index >= 0 && index < length ? this[index] : null;
  }

  List<List<T>> chunked(int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, (i + chunkSize).clamp(0, length)));
    }
    return chunks;
  }
}

void main() {
  group('String Extensions Tests', () {
    test('should capitalize strings correctly', () {
      expect('hello'.capitalize(), 'Hello');
      expect('WORLD'.capitalize(), 'World');
      expect('mixed Case'.capitalize(), 'Mixed case');
      expect(''.capitalize(), '');
    });

    test('should validate email addresses', () {
      expect('test@example.com'.isValidEmail(), true);
      expect('user.name@domain.co.uk'.isValidEmail(), true);
      expect('invalid-email'.isValidEmail(), false);
      expect('user@'.isValidEmail(), false);
      expect('@domain.com'.isValidEmail(), false);
    });

    test('should remove whitespace correctly', () {
      expect('hello world'.removeWhitespace(), 'helloworld');
      expect('  spaced  out  '.removeWhitespace(), 'spacedout');
      expect('no-spaces'.removeWhitespace(), 'no-spaces');
    });

    test('should check if string contains only numbers', () {
      expect('12345'.containsOnlyNumbers(), true);
      expect('123a45'.containsOnlyNumbers(), false);
      expect(''.containsOnlyNumbers(), false);
      expect('0'.containsOnlyNumbers(), true);
    });

    test('should convert string to word list', () {
      expect('hello world test'.toWords(), ['hello', 'world', 'test']);
      expect('Single'.toWords(), ['single']);
      expect('  extra   spaces  '.toWords(), ['extra', 'spaces']);
    });
  });

  group('Number Extensions Tests', () {
    test('should check if number is between range', () {
      expect(5.isBetween(1, 10), true);
      expect(0.isBetween(1, 10), false);
      expect(10.isBetween(1, 10), true);
      expect(1.isBetween(1, 10), true);
    });

    test('should format numbers as percentages', () {
      expect(0.75.toPercentage(), '75.0%');
      expect(0.8542.toPercentage(2), '85.42%');
      expect(1.0.toPercentage(0), '100%');
    });
  });

  group('Duration Extensions Tests', () {
    test('should format duration as readable string', () {
      expect(const Duration(seconds: 30).toReadableString(), '30s');
      expect(const Duration(minutes: 2, seconds: 15).toReadableString(), '2m 15s');
      expect(const Duration(hours: 1, minutes: 30).toReadableString(), '1h 30m');
    });

    test('should check if duration is within range', () {
      const duration = Duration(minutes: 5);
      const min = Duration(minutes: 1);
      const max = Duration(minutes: 10);

      expect(duration.isWithinRange(min, max), true);
      expect(const Duration(seconds: 30).isWithinRange(min, max), false);
      expect(const Duration(minutes: 15).isWithinRange(min, max), false);
    });
  });

  group('List Extensions Tests', () {
    test('should return unique items', () {
      expect([1, 2, 2, 3, 3, 3].uniqueItems(), [1, 2, 3]);
      expect(['a', 'b', 'a', 'c'].uniqueItems(), ['a', 'b', 'c']);
      expect([].uniqueItems(), []);
    });

    test('should safely access elements', () {
      final list = [1, 2, 3];
      expect(list.safeElementAt(1), 2);
      expect(list.safeElementAt(5), null);
      expect(list.safeElementAt(-1), null);
    });

    test('should chunk list correctly', () {
      final list = [1, 2, 3, 4, 5, 6, 7];
      expect(list.chunked(3), [[1, 2, 3], [4, 5, 6], [7]]);
      expect([1, 2].chunked(5), [[1, 2]]);
      expect([].chunked(3), []);
    });
  });
}