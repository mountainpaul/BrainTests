import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/domain/services/gds15_scoring.dart';

void main() {
  group('GDS-15 Scoring', () {
    test('should calculate score correctly for optimal responses (no depression)', () {
      // All positive answers to reverse-scored questions, all no to negative questions
      final responses = [
        true,  // Q1: satisfied with life (REVERSE - Yes = 0 points)
        false, // Q2: dropped activities (No = 0 points)
        false, // Q3: life is empty (No = 0 points)
        false, // Q4: often bored (No = 0 points)
        true,  // Q5: good spirits (REVERSE - Yes = 0 points)
        false, // Q6: afraid (No = 0 points)
        true,  // Q7: happy (REVERSE - Yes = 0 points)
        false, // Q8: helpless (No = 0 points)
        true,  // Q9: enjoy going out (REVERSE - Yes = 0 points)
        false, // Q10: memory problems (No = 0 points)
        true,  // Q11: wonderful (REVERSE - Yes = 0 points)
        false, // Q12: worthless (No = 0 points)
        true,  // Q13: full of energy (REVERSE - Yes = 0 points)
        false, // Q14: hopeless (No = 0 points)
        false, // Q15: others better off (No = 0 points)
      ];
      final score = GDS15Scoring.calculateScore(responses);

      expect(score, 0);
      expect(GDS15Scoring.getSeverityLevel(score), GDS15SeverityLevel.normal);
    });

    test('should calculate score correctly for mild depression range', () {
      // Reverse scored items: Q1, Q5, Q7, Q9, Q11, Q13 (indices 0, 4, 6, 8, 10, 12)
      // For mild depression (5-9 points), provide mixed answers
      final responses = [
        true,  // Q1: satisfied with life (REVERSE - Yes = 0 points)
        true,  // Q2: dropped activities (Yes = 1 point)
        false, // Q3: life is empty (No = 0 points)
        true,  // Q4: often bored (Yes = 1 point)
        false, // Q5: NOT good spirits (REVERSE - No = 1 point)
        true,  // Q6: afraid something bad (Yes = 1 point)
        false, // Q7: NOT happy (REVERSE - No = 1 point)
        false, // Q8: feel helpless (No = 0 points)
        true,  // Q9: like going out (REVERSE - Yes = 0 points)
        true,  // Q10: memory problems (Yes = 1 point)
        false, // Q11: NOT wonderful (REVERSE - No = 1 point)
        false, // Q12: feel worthless (No = 0 points)
        true,  // Q13: full of energy (REVERSE - Yes = 0 points)
        false, // Q14: situation hopeless (No = 0 points)
        true,  // Q15: others better off (Yes = 1 point)
      ];

      final score = GDS15Scoring.calculateScore(responses);
      // Score: 0 + 1 + 0 + 1 + 1 + 1 + 1 + 0 + 0 + 1 + 1 + 0 + 0 + 0 + 1 = 8

      expect(score, 8); // Within mild depression range (5-9)
      expect(GDS15Scoring.getSeverityLevel(score), GDS15SeverityLevel.mild);
    });

    test('should calculate score correctly for moderate to severe depression', () {
      // Worst possible answers - all indicating depression
      final responses = [
        false, // Q1: NOT satisfied (REVERSE - No = 1 point)
        true,  // Q2: dropped activities (Yes = 1 point)
        true,  // Q3: life is empty (Yes = 1 point)
        true,  // Q4: often bored (Yes = 1 point)
        false, // Q5: NOT good spirits (REVERSE - No = 1 point)
        true,  // Q6: afraid (Yes = 1 point)
        false, // Q7: NOT happy (REVERSE - No = 1 point)
        true,  // Q8: helpless (Yes = 1 point)
        false, // Q9: prefer stay home (REVERSE - No = 1 point)
        true,  // Q10: memory problems (Yes = 1 point)
        false, // Q11: NOT wonderful (REVERSE - No = 1 point)
        true,  // Q12: worthless (Yes = 1 point)
        false, // Q13: NOT full of energy (REVERSE - No = 1 point)
        true,  // Q14: hopeless (Yes = 1 point)
        true,  // Q15: others better off (Yes = 1 point)
      ];

      final score = GDS15Scoring.calculateScore(responses);

      expect(score, 15); // Maximum score
      expect(GDS15Scoring.getSeverityLevel(score), GDS15SeverityLevel.severe);
    });

    test('should handle edge cases for severity levels', () {
      expect(GDS15Scoring.getSeverityLevel(0), GDS15SeverityLevel.normal);
      expect(GDS15Scoring.getSeverityLevel(4), GDS15SeverityLevel.normal);
      expect(GDS15Scoring.getSeverityLevel(5), GDS15SeverityLevel.mild);
      expect(GDS15Scoring.getSeverityLevel(9), GDS15SeverityLevel.mild);
      expect(GDS15Scoring.getSeverityLevel(10), GDS15SeverityLevel.severe);
      expect(GDS15Scoring.getSeverityLevel(15), GDS15SeverityLevel.severe);
    });

    test('should provide correct interpretation for each severity level', () {
      expect(GDS15Scoring.getInterpretation(GDS15SeverityLevel.normal),
          contains('No depression'));
      expect(GDS15Scoring.getInterpretation(GDS15SeverityLevel.mild),
          contains('Mild depression'));
      expect(GDS15Scoring.getInterpretation(GDS15SeverityLevel.severe),
          contains('Moderate to severe depression'));
    });

    test('should return all 15 GDS-15 questions', () {
      final questions = GDS15Scoring.getQuestions();

      expect(questions.length, 15);
      expect(questions[0], contains('satisfied with your life'));
      expect(questions[1], contains('dropped many of your activities'));
      expect(questions[14], contains('better off'));
    });

    test('should correctly identify reverse scored items', () {
      final reverseScoredItems = GDS15Scoring.reverseScoredItems;

      expect(reverseScoredItems, contains(0));  // Q1 (index 0)
      expect(reverseScoredItems, contains(4));  // Q5 (index 4)
      expect(reverseScoredItems, contains(6));  // Q7 (index 6)
      expect(reverseScoredItems, contains(8));  // Q9 (index 8)
      expect(reverseScoredItems, contains(10)); // Q11 (index 10)
      expect(reverseScoredItems, contains(12)); // Q13 (index 12)
      expect(reverseScoredItems.length, 6);
    });
  });
}
