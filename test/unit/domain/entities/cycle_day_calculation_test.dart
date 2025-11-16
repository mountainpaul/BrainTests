import 'package:brain_tests/core/utils/cycle_day_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cycle Day Calculation', () {
    test('should calculate cycle day 1 on program start date', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 1);

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 1);
    });

    test('should calculate cycle day 2 on day after start', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 2);

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 2);
    });

    test('should calculate cycle day 10 on 9 days after start', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 10);

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 10);
    });

    test('should wrap to cycle day 1 after day 10', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 11); // 10 days later

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 1);
    });

    test('should wrap to cycle day 3 after 12 days', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 1, 13); // 12 days later

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 3);
    });

    test('should handle multiple complete cycles', () {
      // Arrange
      final programStartDate = DateTime(2024, 1, 1);
      final currentDate = DateTime(2024, 2, 10); // 40 days later (4 complete cycles)

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 1); // 40 % 10 = 0, so day 10 of 4th cycle wraps to day 1
    });

    test('should handle leap year correctly', () {
      // Arrange
      final programStartDate = DateTime(2024, 2, 28);
      final currentDate = DateTime(2024, 3, 2); // 3 days later (through leap day)

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 4); // Feb 28 -> Feb 29 (1) -> Mar 1 (2) -> Mar 2 (3)
    });

    test('should default to current date if program start date is null', () {
      // Arrange
      final DateTime? programStartDate = null;
      final currentDate = DateTime.now();

      // Act
      final cycleDay = CycleDayCalculator.calculateCycleDay(programStartDate, currentDate);

      // Assert
      expect(cycleDay, 1); // Should default to day 1
    });
  });
}
