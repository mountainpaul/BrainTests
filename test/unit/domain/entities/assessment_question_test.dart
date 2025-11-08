import 'package:flutter_test/flutter_test.dart';

// Mock assessment question classes for testing
class MemoryRecallQuestion {

  MemoryRecallQuestion({
    required this.wordsToRemember,
    required this.timeToStudy,
  });
  final List<String> wordsToRemember;
  final int timeToStudy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryRecallQuestion &&
          runtimeType == other.runtimeType &&
          wordsToRemember.toString() == other.wordsToRemember.toString() &&
          timeToStudy == other.timeToStudy;

  @override
  int get hashCode => wordsToRemember.hashCode ^ timeToStudy.hashCode;
}

class AttentionFocusQuestion {

  AttentionFocusQuestion({
    required this.stimulusSequence,
    required this.targetNumber,
    required this.stimulusDuration,
    required this.isi,
  });
  final List<int> stimulusSequence;
  final int targetNumber;
  final int stimulusDuration;
  final int isi;
}

enum TrailType { numbersOnly, alternating }

class TrailPoint {

  TrailPoint(this.label, this.x, this.y);
  final dynamic label;
  final double x;
  final double y;
}

class ExecutiveFunctionQuestion {

  ExecutiveFunctionQuestion({
    required this.trailType,
    required this.points,
  });
  final TrailType trailType;
  final List<TrailPoint> points;
}

enum LanguageTaskType { naming, comprehension, fluency }

class LanguageTask {

  LanguageTask({
    required this.type,
    required this.stimulus,
    required this.expectedAnswer,
  });
  final LanguageTaskType type;
  final String stimulus;
  final String expectedAnswer;
}

class LanguageSkillsQuestion {

  LanguageSkillsQuestion({required this.tasks});
  final List<LanguageTask> tasks;
}

class VisuoSpatialSkillsQuestion {

  VisuoSpatialSkillsQuestion({
    required this.targetShape,
    required this.optionShapes,
    required this.rotationDegrees,
  });
  final String targetShape;
  final List<String> optionShapes;
  final double rotationDegrees;
}

class ProcessingSpeedItem {

  ProcessingSpeedItem({
    required this.symbol,
    required this.correctDigit,
  });
  final String symbol;
  final int correctDigit;
}

class ProcessingSpeedQuestion {

  ProcessingSpeedQuestion({
    required this.symbolDigitMappings,
    required this.testItems,
  });
  final Map<String, int> symbolDigitMappings;
  final List<ProcessingSpeedItem> testItems;
}

class TowersOfHanoiQuestion {

  TowersOfHanoiQuestion({
    required this.initialState,
    required this.targetMoves,
  });
  final List<List<int>> initialState;
  final int targetMoves;
}

// Mock response classes
class MemoryRecallResponse {

  MemoryRecallResponse({
    required this.recalledWords,
    required this.totalWords,
    required this.completionTime,
  });
  final List<String> recalledWords;
  final int totalWords;
  final Duration completionTime;

  int get score => recalledWords.length;
  double get percentage => (score / totalWords) * 100;
}

class AttentionFocusResponse {

  AttentionFocusResponse({
    required this.hits,
    required this.falseAlarms,
    required this.totalTargets,
    required this.totalNonTargets,
    required this.completionTime,
  });
  final int hits;
  final int falseAlarms;
  final int totalTargets;
  final int totalNonTargets;
  final Duration completionTime;

  double get accuracy => hits / totalTargets;
}

class ExecutiveFunctionResponse {

  ExecutiveFunctionResponse({
    required this.completionTime,
    required this.errors,
    required this.trailCompleted,
  });
  final Duration completionTime;
  final int errors;
  final bool trailCompleted;
}

class VisuoSpatialSkillsResponse {

  VisuoSpatialSkillsResponse({
    required this.selectedOption,
    required this.confidence,
    required this.isCorrect,
    required this.completionTime,
  });
  final int selectedOption;
  final double confidence;
  final bool isCorrect;
  final Duration completionTime;
}

class ProcessingSpeedResponse {

  ProcessingSpeedResponse({
    required this.userAnswers,
    required this.correctAnswers,
    required this.responseTimes,
    required this.completionTime,
  });
  final List<int> userAnswers;
  final List<int> correctAnswers;
  final List<Duration> responseTimes;
  final Duration completionTime;

  int get correctCount {
    int count = 0;
    for (int i = 0; i < userAnswers.length && i < correctAnswers.length; i++) {
      if (userAnswers[i] == correctAnswers[i]) count++;
    }
    return count;
  }

  Duration get averageResponseTime {
    if (responseTimes.isEmpty) return Duration.zero;
    final totalMs = responseTimes.fold<int>(0, (sum, time) => sum + time.inMilliseconds);
    return Duration(milliseconds: (totalMs / responseTimes.length).round());
  }
}

class HanoiMove {

  HanoiMove({required this.from, required this.to});
  final int from;
  final int to;
}

class TowersOfHanoiResponse {

  TowersOfHanoiResponse({
    required this.moves,
    required this.completed,
    required this.completionTime,
  });
  final List<HanoiMove> moves;
  final bool completed;
  final Duration completionTime;

  int get moveCount => moves.length;
}

void main() {
  group('Assessment Question Entity Tests', () {
    group('MemoryRecallQuestion Tests', () {
      test('should create with valid parameters', () {
        // Arrange & Act
        final question = MemoryRecallQuestion(
          wordsToRemember: ['apple', 'house', 'car'],
          timeToStudy: 10,
        );

        // Assert
        expect(question.wordsToRemember, ['apple', 'house', 'car']);
        expect(question.timeToStudy, 10);
      });

      test('should be equal with same properties', () {
        // Arrange
        final question1 = MemoryRecallQuestion(
          wordsToRemember: ['apple', 'house'],
          timeToStudy: 10,
        );
        final question2 = MemoryRecallQuestion(
          wordsToRemember: ['apple', 'house'],
          timeToStudy: 10,
        );

        // Assert
        expect(question1, equals(question2));
      });

      test('should not be equal with different words', () {
        // Arrange
        final question1 = MemoryRecallQuestion(
          wordsToRemember: ['apple', 'house'],
          timeToStudy: 10,
        );
        final question2 = MemoryRecallQuestion(
          wordsToRemember: ['apple', 'car'],
          timeToStudy: 10,
        );

        // Assert
        expect(question1, isNot(equals(question2)));
      });
    });

    group('AttentionFocusQuestion Tests', () {
      test('should create with valid parameters', () {
        // Arrange & Act
        final question = AttentionFocusQuestion(
          stimulusSequence: [1, 2, 3, 2, 4],
          targetNumber: 2,
          stimulusDuration: 1000,
          isi: 500,
        );

        // Assert
        expect(question.stimulusSequence, [1, 2, 3, 2, 4]);
        expect(question.targetNumber, 2);
        expect(question.stimulusDuration, 1000);
        expect(question.isi, 500);
      });

      test('should calculate correct target count', () {
        // Arrange
        final question = AttentionFocusQuestion(
          stimulusSequence: [1, 2, 3, 2, 4, 2],
          targetNumber: 2,
          stimulusDuration: 1000,
          isi: 500,
        );

        // Act
        final targetCount = question.stimulusSequence.where((x) => x == question.targetNumber).length;

        // Assert
        expect(targetCount, 3);
      });
    });

    group('ExecutiveFunctionQuestion Tests', () {
      test('should create numbers only trail', () {
        // Arrange & Act
        final question = ExecutiveFunctionQuestion(
          trailType: TrailType.numbersOnly,
          points: [
            TrailPoint(1, 100, 100),
            TrailPoint(2, 200, 150),
            TrailPoint(3, 150, 200),
          ],
        );

        // Assert
        expect(question.trailType, TrailType.numbersOnly);
        expect(question.points.length, 3);
        expect(question.points[0].label, 1);
        expect(question.points[0].x, 100);
        expect(question.points[0].y, 100);
      });

      test('should create alternating trail', () {
        // Arrange & Act
        final question = ExecutiveFunctionQuestion(
          trailType: TrailType.alternating,
          points: [
            TrailPoint(1, 100, 100),
            TrailPoint('A', 200, 150),
            TrailPoint(2, 150, 200),
            TrailPoint('B', 250, 250),
          ],
        );

        // Assert
        expect(question.trailType, TrailType.alternating);
        expect(question.points.length, 4);
        expect(question.points[0].label, 1);
        expect(question.points[1].label, 'A');
        expect(question.points[2].label, 2);
        expect(question.points[3].label, 'B');
      });
    });

    group('TrailPoint Tests', () {
      test('should create with dynamic label type', () {
        // Arrange & Act
        final numberPoint = TrailPoint(1, 100, 150);
        final letterPoint = TrailPoint('A', 200, 250);

        // Assert
        expect(numberPoint.label, 1);
        expect(numberPoint.x, 100);
        expect(numberPoint.y, 150);
        expect(letterPoint.label, 'A');
        expect(letterPoint.x, 200);
        expect(letterPoint.y, 250);
      });
    });

    group('LanguageSkillsQuestion Tests', () {
      test('should create with multiple tasks', () {
        // Arrange & Act
        final question = LanguageSkillsQuestion(
          tasks: [
            LanguageTask(
              type: LanguageTaskType.naming,
              stimulus: 'apple.png',
              expectedAnswer: 'apple',
            ),
            LanguageTask(
              type: LanguageTaskType.comprehension,
              stimulus: 'Point to the red circle',
              expectedAnswer: 'red_circle',
            ),
          ],
        );

        // Assert
        expect(question.tasks.length, 2);
        expect(question.tasks[0].type, LanguageTaskType.naming);
        expect(question.tasks[0].stimulus, 'apple.png');
        expect(question.tasks[0].expectedAnswer, 'apple');
        expect(question.tasks[1].type, LanguageTaskType.comprehension);
      });
    });

    group('LanguageTask Tests', () {
      test('should create naming task', () {
        // Arrange & Act
        final task = LanguageTask(
          type: LanguageTaskType.naming,
          stimulus: 'apple.png',
          expectedAnswer: 'apple',
        );

        // Assert
        expect(task.type, LanguageTaskType.naming);
        expect(task.stimulus, 'apple.png');
        expect(task.expectedAnswer, 'apple');
      });

      test('should create comprehension task', () {
        // Arrange & Act
        final task = LanguageTask(
          type: LanguageTaskType.comprehension,
          stimulus: 'What color is the sky?',
          expectedAnswer: 'blue',
        );

        // Assert
        expect(task.type, LanguageTaskType.comprehension);
        expect(task.stimulus, 'What color is the sky?');
        expect(task.expectedAnswer, 'blue');
      });

      test('should create fluency task', () {
        // Arrange & Act
        final task = LanguageTask(
          type: LanguageTaskType.fluency,
          stimulus: 'Name as many animals as you can',
          expectedAnswer: '', // Fluency tasks don't have expected answers
        );

        // Assert
        expect(task.type, LanguageTaskType.fluency);
        expect(task.stimulus, 'Name as many animals as you can');
        expect(task.expectedAnswer, '');
      });
    });

    group('VisuoSpatialSkillsQuestion Tests', () {
      test('should create with target and options', () {
        // Arrange & Act
        final question = VisuoSpatialSkillsQuestion(
          targetShape: 'L_shape',
          optionShapes: ['L_shape_90deg', 'F_shape', 'T_shape', 'plus_shape'],
          rotationDegrees: 90,
        );

        // Assert
        expect(question.targetShape, 'L_shape');
        expect(question.optionShapes, ['L_shape_90deg', 'F_shape', 'T_shape', 'plus_shape']);
        expect(question.rotationDegrees, 90);
      });

      test('should handle different rotation degrees', () {
        // Arrange & Act
        final question = VisuoSpatialSkillsQuestion(
          targetShape: 'T_shape',
          optionShapes: ['T_shape_180deg', 'L_shape'],
          rotationDegrees: 180,
        );

        // Assert
        expect(question.rotationDegrees, 180);
      });
    });

    group('ProcessingSpeedQuestion Tests', () {
      test('should create with symbol mappings and test items', () {
        // Arrange & Act
        final question = ProcessingSpeedQuestion(
          symbolDigitMappings: {
            '★': 1,
            '●': 2,
            '▲': 3,
            '■': 4,
          },
          testItems: [
            ProcessingSpeedItem(symbol: '★', correctDigit: 1),
            ProcessingSpeedItem(symbol: '●', correctDigit: 2),
            ProcessingSpeedItem(symbol: '▲', correctDigit: 3),
          ],
        );

        // Assert
        expect(question.symbolDigitMappings.length, 4);
        expect(question.symbolDigitMappings['★'], 1);
        expect(question.symbolDigitMappings['●'], 2);
        expect(question.testItems.length, 3);
        expect(question.testItems[0].symbol, '★');
        expect(question.testItems[0].correctDigit, 1);
      });
    });

    group('ProcessingSpeedItem Tests', () {
      test('should create with symbol and correct digit', () {
        // Arrange & Act
        final item = ProcessingSpeedItem(
          symbol: '★',
          correctDigit: 1,
        );

        // Assert
        expect(item.symbol, '★');
        expect(item.correctDigit, 1);
      });
    });

    group('TowersOfHanoiQuestion Tests', () {
      test('should create with initial state and target moves', () {
        // Arrange & Act
        final question = TowersOfHanoiQuestion(
          initialState: [
            [3, 2, 1], // Tower A with 3 disks
            [], // Tower B empty
            [], // Tower C empty
          ],
          targetMoves: 7,
        );

        // Assert
        expect(question.initialState.length, 3);
        expect(question.initialState[0], [3, 2, 1]);
        expect(question.initialState[1], isEmpty);
        expect(question.initialState[2], isEmpty);
        expect(question.targetMoves, 7);
      });

      test('should handle different disk configurations', () {
        // Arrange & Act
        final question = TowersOfHanoiQuestion(
          initialState: [
            [2, 1],
            [],
            [],
          ],
          targetMoves: 3,
        );

        // Assert
        expect(question.initialState[0], [2, 1]);
        expect(question.targetMoves, 3);
      });
    });
  });

  group('Assessment Response Entity Tests', () {
    group('MemoryRecallResponse Tests', () {
      test('should create with recalled words and calculate score', () {
        // Arrange & Act
        final response = MemoryRecallResponse(
          recalledWords: ['apple', 'house'],
          totalWords: 3,
          completionTime: const Duration(seconds: 30),
        );

        // Assert
        expect(response.recalledWords, ['apple', 'house']);
        expect(response.totalWords, 3);
        expect(response.completionTime, const Duration(seconds: 30));
        expect(response.score, 2); // 2 out of 3 words recalled
      });

      test('should calculate percentage correctly', () {
        // Arrange & Act
        final response = MemoryRecallResponse(
          recalledWords: ['apple', 'house'],
          totalWords: 4,
          completionTime: const Duration(seconds: 45),
        );

        // Assert
        expect(response.percentage, 50.0); // 2/4 = 50%
      });
    });

    group('AttentionFocusResponse Tests', () {
      test('should create with hits and false alarms', () {
        // Arrange & Act
        final response = AttentionFocusResponse(
          hits: 3,
          falseAlarms: 1,
          totalTargets: 4,
          totalNonTargets: 6,
          completionTime: const Duration(seconds: 15),
        );

        // Assert
        expect(response.hits, 3);
        expect(response.falseAlarms, 1);
        expect(response.totalTargets, 4);
        expect(response.totalNonTargets, 6);
        expect(response.completionTime, const Duration(seconds: 15));
      });

      test('should calculate accuracy correctly', () {
        // Arrange & Act
        final response = AttentionFocusResponse(
          hits: 3,
          falseAlarms: 1,
          totalTargets: 4,
          totalNonTargets: 6,
          completionTime: const Duration(seconds: 15),
        );

        // Assert
        expect(response.accuracy, 0.75); // 3/4 hits = 75%
      });
    });

    group('ExecutiveFunctionResponse Tests', () {
      test('should create with completion time and errors', () {
        // Arrange & Act
        final response = ExecutiveFunctionResponse(
          completionTime: const Duration(seconds: 45),
          errors: 2,
          trailCompleted: true,
        );

        // Assert
        expect(response.completionTime, const Duration(seconds: 45));
        expect(response.errors, 2);
        expect(response.trailCompleted, true);
      });

      test('should handle incomplete trails', () {
        // Arrange & Act
        final response = ExecutiveFunctionResponse(
          completionTime: const Duration(seconds: 120),
          errors: 5,
          trailCompleted: false,
        );

        // Assert
        expect(response.trailCompleted, false);
        expect(response.errors, 5);
      });
    });

    group('VisuoSpatialSkillsResponse Tests', () {
      test('should create with selected option and confidence', () {
        // Arrange & Act
        final response = VisuoSpatialSkillsResponse(
          selectedOption: 2,
          confidence: 85.0,
          isCorrect: true,
          completionTime: const Duration(seconds: 20),
        );

        // Assert
        expect(response.selectedOption, 2);
        expect(response.confidence, 85.0);
        expect(response.isCorrect, true);
        expect(response.completionTime, const Duration(seconds: 20));
      });

      test('should handle incorrect responses', () {
        // Arrange & Act
        final response = VisuoSpatialSkillsResponse(
          selectedOption: 1,
          confidence: 60.0,
          isCorrect: false,
          completionTime: const Duration(seconds: 35),
        );

        // Assert
        expect(response.isCorrect, false);
        expect(response.confidence, 60.0);
      });
    });

    group('ProcessingSpeedResponse Tests', () {
      test('should create with user answers and calculate score', () {
        // Arrange & Act
        final response = ProcessingSpeedResponse(
          userAnswers: [1, 2, 3, 2],
          correctAnswers: [1, 2, 3, 4],
          responseTimes: [
            const Duration(milliseconds: 1500),
            const Duration(milliseconds: 1200),
            const Duration(milliseconds: 1800),
            const Duration(milliseconds: 1400),
          ],
          completionTime: const Duration(seconds: 90),
        );

        // Assert
        expect(response.userAnswers, [1, 2, 3, 2]);
        expect(response.correctAnswers, [1, 2, 3, 4]);
        expect(response.responseTimes.length, 4);
        expect(response.completionTime, const Duration(seconds: 90));
        expect(response.correctCount, 3); // 3 correct out of 4
      });

      test('should calculate average response time', () {
        // Arrange & Act
        final response = ProcessingSpeedResponse(
          userAnswers: [1, 2],
          correctAnswers: [1, 2],
          responseTimes: [
            const Duration(milliseconds: 1000),
            const Duration(milliseconds: 2000),
          ],
          completionTime: const Duration(seconds: 30),
        );

        // Assert
        expect(response.averageResponseTime, const Duration(milliseconds: 1500));
      });
    });

    group('TowersOfHanoiResponse Tests', () {
      test('should create with moves and completion status', () {
        // Arrange & Act
        final response = TowersOfHanoiResponse(
          moves: [
            HanoiMove(from: 0, to: 2), // Move from tower A to C
            HanoiMove(from: 0, to: 1), // Move from tower A to B
            HanoiMove(from: 2, to: 1), // Move from tower C to B
          ],
          completed: true,
          completionTime: const Duration(minutes: 2),
        );

        // Assert
        expect(response.moves.length, 3);
        expect(response.moves[0].from, 0);
        expect(response.moves[0].to, 2);
        expect(response.completed, true);
        expect(response.completionTime, const Duration(minutes: 2));
        expect(response.moveCount, 3);
      });

      test('should handle incomplete puzzles', () {
        // Arrange & Act
        final response = TowersOfHanoiResponse(
          moves: [
            HanoiMove(from: 0, to: 2),
            HanoiMove(from: 0, to: 1),
          ],
          completed: false,
          completionTime: const Duration(minutes: 5),
        );

        // Assert
        expect(response.completed, false);
        expect(response.moveCount, 2);
      });
    });

    group('HanoiMove Tests', () {
      test('should create with from and to towers', () {
        // Arrange & Act
        final move = HanoiMove(from: 0, to: 2);

        // Assert
        expect(move.from, 0);
        expect(move.to, 2);
      });
    });
  });
}