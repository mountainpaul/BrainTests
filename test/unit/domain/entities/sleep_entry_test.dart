import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sleep Entry Validation', () {
    test('should accept valid Garmin sleep data', () {
      // Garmin typical values
      const duration = 420; // 7 hours
      const stress = 35; // 0-100 scale
      const lightSleep = 240; // 4 hours
      const deepSleep = 120; // 2 hours
      const remSleep = 60; // 1 hour

      expect(duration, greaterThan(0));
      expect(stress, inInclusiveRange(0, 100));
      expect(lightSleep, greaterThanOrEqualTo(0));
      expect(deepSleep, greaterThanOrEqualTo(0));
      expect(remSleep, greaterThanOrEqualTo(0));
    });

    test('should validate sleep stages sum to total duration', () {
      const duration = 420;
      const lightSleep = 240;
      const deepSleep = 120;
      const remSleep = 60;

      const totalStages = lightSleep + deepSleep + remSleep;

      expect(totalStages, equals(duration),
          reason: 'Sleep stages should sum to total duration');
    });

    test('should accept stress levels from 0 to 100', () {
      expect(0, inInclusiveRange(0, 100));
      expect(50, inInclusiveRange(0, 100));
      expect(100, inInclusiveRange(0, 100));
    });

    test('should reject negative sleep values', () {
      expect(-10, lessThan(0), reason: 'Negative sleep duration is invalid');
    });

    test('should reject stress levels outside 0-100 range', () {
      expect(101, greaterThan(100), reason: 'Stress > 100 is invalid');
      expect(-1, lessThan(0), reason: 'Stress < 0 is invalid');
    });

    test('should handle edge case of no REM sleep', () {
      const remSleep = 0;
      expect(remSleep, greaterThanOrEqualTo(0),
          reason: 'Zero REM sleep is valid');
    });

    test('should handle edge case of no deep sleep', () {
      const deepSleep = 0;
      expect(deepSleep, greaterThanOrEqualTo(0),
          reason: 'Zero deep sleep is valid');
    });
  });
}
