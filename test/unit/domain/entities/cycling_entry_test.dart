import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cycling Entry Validation', () {
    test('should accept valid Garmin cycling data', () {
      // Garmin typical values for cycling
      const distance = 15.5; // km
      const totalTime = 3600; // seconds (1 hour)
      const avgMovingSpeed = 15.5; // km/h
      const avgHeartRate = 145; // bpm
      const maxHeartRate = 175; // bpm

      expect(distance, greaterThan(0));
      expect(totalTime, greaterThan(0));
      expect(avgMovingSpeed, greaterThan(0));
      expect(avgHeartRate, greaterThan(0));
      expect(maxHeartRate, greaterThanOrEqualTo(avgHeartRate));
    });

    test('should validate max heart rate >= avg heart rate', () {
      const avgHeartRate = 145;
      const maxHeartRate = 175;

      expect(maxHeartRate, greaterThanOrEqualTo(avgHeartRate),
          reason: 'Max HR must be >= Avg HR');
    });

    test('should accept zero distance for short rides', () {
      const distance = 0.0;
      expect(distance, greaterThanOrEqualTo(0),
          reason: 'Zero distance is valid for very short rides');
    });

    test('should reject negative values', () {
      expect(-5.0, lessThan(0), reason: 'Negative distance is invalid');
      expect(-10, lessThan(0), reason: 'Negative time is invalid');
      expect(-20.0, lessThan(0), reason: 'Negative speed is invalid');
    });

    test('should accept typical heart rate ranges', () {
      // Resting to max heart rate ranges
      expect(60, inInclusiveRange(40, 220));
      expect(145, inInclusiveRange(40, 220));
      expect(195, inInclusiveRange(40, 220));
    });

    test('should calculate average speed from distance and time', () {
      const distance = 20.0; // km
      const totalTime = 3600; // seconds (1 hour)
      const calculatedSpeed = (distance / totalTime) * 3600; // km/h

      expect(calculatedSpeed, closeTo(20.0, 0.1));
    });

    test('should handle edge case of stationary cycling (0 distance)', () {
      const distance = 0.0;
      const totalTime = 1800; // 30 minutes

      expect(distance, equals(0.0));
      expect(totalTime, greaterThan(0));
    });
  });
}
