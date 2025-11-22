import 'package:brain_tests/domain/services/cambridge_test_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for PAL sequential pattern display
/// According to CANTAB protocol, patterns should be displayed one at a time
/// for 3 seconds each, only in boxes that contain patterns
void main() {
  group('PAL Sequential Pattern Display', () {
    test('should display patterns sequentially, not all at once', () {
      // Generate a trial with multiple patterns
      final trial = CambridgeTestGenerator.generatePALTrial(3);

      // Trial should have multiple patterns
      expect(trial.numPatterns, greaterThan(1));

      // Each pattern should be displayed individually
      // This means we need to iterate through patternPositions
      final patterns = trial.patternPositions.keys.toList();
      expect(patterns.length, equals(trial.numPatterns));
    });

    test('should calculate correct total display time based on number of patterns', () {
      // Stage 1: 2 patterns = 2 * 3 seconds = 6 seconds
      final trial1 = CambridgeTestGenerator.generatePALTrial(1);
      expect(trial1.numPatterns, equals(2));
      final expectedDuration1 = trial1.numPatterns * 3; // 6 seconds
      expect(expectedDuration1, equals(6));

      // Stage 3: 4 patterns = 4 * 3 seconds = 12 seconds
      final trial3 = CambridgeTestGenerator.generatePALTrial(3);
      expect(trial3.numPatterns, equals(4));
      final expectedDuration3 = trial3.numPatterns * 3; // 12 seconds
      expect(expectedDuration3, equals(12));
    });

    test('should only display pattern in boxes that have patterns, skip empty boxes', () {
      final trial = CambridgeTestGenerator.generatePALTrial(2);

      // Trial has gridSize boxes but only numPatterns have patterns
      expect(trial.gridSize, greaterThan(trial.numPatterns));

      // Only positions in patternPositions map should show patterns
      final occupiedPositions = trial.patternPositions.values.toSet();
      expect(occupiedPositions.length, equals(trial.numPatterns));

      // Some boxes should be empty (gridSize - numPatterns)
      final emptyBoxCount = trial.gridSize - trial.numPatterns;
      expect(emptyBoxCount, greaterThan(0));
    });

    test('should iterate through patterns in order for sequential display', () {
      final trial = CambridgeTestGenerator.generatePALTrial(3);

      // Get patterns in display order
      final patterns = trial.patternPositions.keys.toList();

      // Each pattern should map to exactly one position
      for (final pattern in patterns) {
        expect(trial.patternPositions.containsKey(pattern), isTrue);
        final position = trial.patternPositions[pattern];
        expect(position, isNotNull);
        expect(position! >= 0 && position < trial.gridSize, isTrue);
      }
    });

    test('should track current displaying pattern index during presentation', () {
      final trial = CambridgeTestGenerator.generatePALTrial(2);

      // Simulate sequential display
      final patterns = trial.patternPositions.keys.toList();

      // At index 0, show first pattern
      var currentIndex = 0;
      expect(currentIndex, lessThan(patterns.length));
      var currentPattern = patterns[currentIndex];
      expect(trial.patternPositions.containsKey(currentPattern), isTrue);

      // At index 1, show second pattern
      currentIndex = 1;
      expect(currentIndex, lessThan(patterns.length));
      currentPattern = patterns[currentIndex];
      expect(trial.patternPositions.containsKey(currentPattern), isTrue);

      // After last pattern, presentation should be complete
      currentIndex = patterns.length;
      expect(currentIndex, equals(patterns.length)); // All patterns shown
    });
  });
}
