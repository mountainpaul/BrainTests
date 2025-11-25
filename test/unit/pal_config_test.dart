import 'package:brain_tests/presentation/screens/cambridge/pal_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PALConfig', () {
    test('totalStages should be consistent with stagePatternCounts length', () {
      expect(PALConfig.totalStages, PALConfig.stagePatternCounts.length);
    });

    test('maxFirstAttemptScore should be the sum of stagePatternCounts', () {
      final calculatedMaxScore = PALConfig.stagePatternCounts.reduce((a, b) => a + b);
      expect(PALConfig.maxFirstAttemptScore, calculatedMaxScore);
    });
  });
}
