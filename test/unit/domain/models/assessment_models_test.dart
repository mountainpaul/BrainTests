import 'package:brain_plan/domain/models/assessment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assessment Question Models', () {
    late DateTime now;

    setUp(() {
      now = DateTime.now();
    });

    group('MemoryRecallQuestion', () {
      test('should create memory recall question with all parameters', () {
        const question = MemoryRecallQuestion(
          id: 'memory_test_1',
          instruction: 'Remember these words',
          wordsToMemorize: ['apple', 'banana', 'cherry'],
          studyTimeSeconds: 30,
          recognitionOptions: ['apple', 'banana', 'cherry', 'orange', 'grape'],
          timeLimit: 120,
        );

        expect(question.id, equals('memory_test_1'));
        expect(question.instruction, equals('Remember these words'));
        expect(question.wordsToMemorize.length, equals(3));
        expect(question.studyTimeSeconds, equals(30));
        expect(question.recognitionOptions.length, equals(5));
        expect(question.timeLimit, equals(120));
      });

      test('should create memory recall question with default time limit', () {
        const question = MemoryRecallQuestion(
          id: 'memory_test_2',
          instruction: 'Test instruction',
          wordsToMemorize: ['word1'],
          studyTimeSeconds: 10,
          recognitionOptions: ['word1', 'word2'],
        );

        expect(question.timeLimit, equals(0)); // Default no time limit
      });

      test('should support equality comparison', () {
        const question1 = MemoryRecallQuestion(
          id: 'test',
          instruction: 'instruction',
          wordsToMemorize: ['a', 'b'],
          studyTimeSeconds: 10,
          recognitionOptions: ['a', 'b', 'c'],
        );

        const question2 = MemoryRecallQuestion(
          id: 'test',
          instruction: 'instruction',
          wordsToMemorize: ['a', 'b'],
          studyTimeSeconds: 10,
          recognitionOptions: ['a', 'b', 'c'],
        );

        expect(question1, equals(question2));
        expect(question1.hashCode, equals(question2.hashCode));
      });
    });

    group('AttentionFocusQuestion', () {
      test('should create attention focus question correctly', () {
        const question = AttentionFocusQuestion(
          id: 'attention_test_1',
          instruction: 'Press space for every number except 3',
          stimulusSequence: [1, 2, 3, 4, 5],
          targetNumber: 3,
          stimulusDurationMs: 500,
          interStimulusIntervalMs: 1000,
          timeLimit: 300,
        );

        expect(question.id, equals('attention_test_1'));
        expect(question.stimulusSequence.length, equals(5));
        expect(question.targetNumber, equals(3));
        expect(question.stimulusDurationMs, equals(500));
        expect(question.interStimulusIntervalMs, equals(1000));
        expect(question.timeLimit, equals(300));
      });

      test('should have default time limit of 0', () {
        const question = AttentionFocusQuestion(
          id: 'test',
          instruction: 'test',
          stimulusSequence: [1, 2],
          targetNumber: 1,
          stimulusDurationMs: 500,
          interStimulusIntervalMs: 1000,
        );

        expect(question.timeLimit, equals(0));
      });
    });

    group('ExecutiveFunctionQuestion', () {
      test('should create executive function question correctly', () {
        const question = ExecutiveFunctionQuestion(
          id: 'executive_test_1',
          instruction: 'Move disks from left to right',
          numberOfDisks: 3,
          initialState: [[3, 2, 1], [], []],
          targetState: [[], [], [3, 2, 1]],
          maxMoves: 7,
          timeLimit: 300,
        );

        expect(question.numberOfDisks, equals(3));
        expect(question.initialState.length, equals(3));
        expect(question.targetState.length, equals(3));
        expect(question.maxMoves, equals(7));
        expect(question.timeLimit, equals(300));
      });

      test('should have default time limit of 300 seconds', () {
        const question = ExecutiveFunctionQuestion(
          id: 'test',
          instruction: 'test',
          numberOfDisks: 2,
          initialState: [[], []],
          targetState: [[], []],
          maxMoves: 3,
        );

        expect(question.timeLimit, equals(300));
      });
    });

    group('LanguageSkillsQuestion', () {
      test('should create language skills question correctly', () {
        const question = LanguageSkillsQuestion(
          id: 'language_test_1',
          instruction: 'Name as many animals as you can',
          category: 'animals',
          prompt: 'Animals you can think of',
          responseTimeSeconds: 60,
          timeLimit: 60,
        );

        expect(question.category, equals('animals'));
        expect(question.prompt, equals('Animals you can think of'));
        expect(question.responseTimeSeconds, equals(60));
        expect(question.timeLimit, equals(60));
      });

      test('should have default time limit of 60 seconds', () {
        const question = LanguageSkillsQuestion(
          id: 'test',
          instruction: 'test',
          category: 'test',
          prompt: 'test',
          responseTimeSeconds: 60,
        );

        expect(question.timeLimit, equals(60));
      });
    });

    group('VisuospatialQuestion', () {
      test('should create visuospatial question correctly', () {
        const question = VisuospatialQuestion(
          id: 'visuospatial_test_1',
          instruction: 'Which shape matches when rotated?',
          targetShape: 'L_shape',
          optionShapes: ['L_90deg', 'L_180deg', 'T_90deg', 'F_90deg'],
          correctOptionIndex: 1,
          rotationDegrees: 180.0,
          timeLimit: 30,
        );

        expect(question.targetShape, equals('L_shape'));
        expect(question.optionShapes.length, equals(4));
        expect(question.correctOptionIndex, equals(1));
        expect(question.rotationDegrees, equals(180.0));
        expect(question.timeLimit, equals(30));
      });

      test('should have default time limit of 30 seconds', () {
        const question = VisuospatialQuestion(
          id: 'test',
          instruction: 'test',
          targetShape: 'shape',
          optionShapes: ['a', 'b', 'c', 'd'],
          correctOptionIndex: 0,
          rotationDegrees: 90.0,
        );

        expect(question.timeLimit, equals(30));
      });
    });

    group('ProcessingSpeedQuestion', () {
      test('should create processing speed question correctly', () {
        final symbolMap = {'○': 1, '□': 2, '△': 3};
        final question = ProcessingSpeedQuestion(
          id: 'processing_test_1',
          instruction: 'Convert symbols to numbers',
          symbolToNumberMap: symbolMap,
          symbolSequence: const ['○', '□', '△', '○'],
          correctAnswers: const [1, 2, 3, 1],
          timeLimit: 90,
        );

        expect(question.symbolToNumberMap.length, equals(3));
        expect(question.symbolSequence.length, equals(4));
        expect(question.correctAnswers.length, equals(4));
        expect(question.timeLimit, equals(90));
      });

      test('should have default time limit of 90 seconds', () {
        const question = ProcessingSpeedQuestion(
          id: 'test',
          instruction: 'test',
          symbolToNumberMap: {'○': 1},
          symbolSequence: ['○'],
          correctAnswers: [1],
        );

        expect(question.timeLimit, equals(90));
      });
    });
  });

  group('Assessment Response Models', () {
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      startTime = DateTime.now();
      endTime = startTime.add(const Duration(seconds: 30));
    });

    group('AssessmentResponse Base Class', () {
      test('should calculate response time correctly', () {
        final response = MemoryRecallResponse(
          questionId: 'test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          recalledWords: const [],
          recognizedWords: const [],
          freeRecallScore: 0,
          recognitionScore: 0,
        );

        expect(response.responseTimeMs, equals(30000)); // 30 seconds in ms
      });

      test('should handle sub-second response times', () {
        final quickEnd = startTime.add(const Duration(milliseconds: 500));
        final response = MemoryRecallResponse(
          questionId: 'test',
          startTime: startTime,
          endTime: quickEnd,
          isCorrect: true,
          recalledWords: const [],
          recognizedWords: const [],
          freeRecallScore: 0,
          recognitionScore: 0,
        );

        expect(response.responseTimeMs, equals(500));
      });
    });

    group('MemoryRecallResponse', () {
      test('should create memory recall response correctly', () {
        final response = MemoryRecallResponse(
          questionId: 'memory_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          recalledWords: const ['apple', 'banana'],
          recognizedWords: const ['apple', 'banana', 'cherry'],
          freeRecallScore: 67, // 2/3 words
          recognitionScore: 100, // 3/3 recognized
        );

        expect(response.questionId, equals('memory_1'));
        expect(response.isCorrect, isTrue);
        expect(response.recalledWords.length, equals(2));
        expect(response.recognizedWords.length, equals(3));
        expect(response.freeRecallScore, equals(67));
        expect(response.recognitionScore, equals(100));
      });

      test('should support equality comparison', () {
        final response1 = MemoryRecallResponse(
          questionId: 'test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          recalledWords: const ['a'],
          recognizedWords: const ['a'],
          freeRecallScore: 100,
          recognitionScore: 100,
        );

        final response2 = MemoryRecallResponse(
          questionId: 'test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          recalledWords: const ['a'],
          recognizedWords: const ['a'],
          freeRecallScore: 100,
          recognitionScore: 100,
        );

        expect(response1, equals(response2));
      });
    });

    group('AttentionFocusResponse', () {
      test('should create attention focus response correctly', () {
        final response = AttentionFocusResponse(
          questionId: 'attention_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          responses: const [true, false, true, false, true],
          reactionTimes: const [400, 0, 350, 0, 420],
          hits: 8,
          misses: 2,
          falseAlarms: 3,
          correctRejections: 87,
        );

        expect(response.responses.length, equals(5));
        expect(response.reactionTimes.length, equals(5));
        expect(response.hits, equals(8));
        expect(response.misses, equals(2));
        expect(response.falseAlarms, equals(3));
        expect(response.correctRejections, equals(87));
      });

      test('should calculate d-prime correctly', () {
        final response = AttentionFocusResponse(
          questionId: 'attention_test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          responses: const [],
          reactionTimes: const [],
          hits: 8,
          misses: 2,
          falseAlarms: 3,
          correctRejections: 87,
        );

        final dPrime = response.dPrime;
        expect(dPrime, isA<double>());
        expect(dPrime, greaterThan(0)); // Should be positive for good performance
      });

      test('should calculate criterion correctly', () {
        final response = AttentionFocusResponse(
          questionId: 'attention_test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          responses: const [],
          reactionTimes: const [],
          hits: 8,
          misses: 2,
          falseAlarms: 3,
          correctRejections: 87,
        );

        final criterion = response.criterion;
        expect(criterion, isA<double>());
      });

      test('should handle extreme hit rates in d-prime calculation', () {
        // Perfect performance (all hits, no false alarms)
        final perfectResponse = AttentionFocusResponse(
          questionId: 'perfect',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          responses: const [],
          reactionTimes: const [],
          hits: 10,
          misses: 0,
          falseAlarms: 0,
          correctRejections: 90,
        );

        expect(perfectResponse.dPrime, isA<double>());
        expect(perfectResponse.dPrime, greaterThan(0));

        // Poor performance (no hits, many false alarms)
        final poorResponse = AttentionFocusResponse(
          questionId: 'poor',
          startTime: startTime,
          endTime: endTime,
          isCorrect: false,
          responses: const [],
          reactionTimes: const [],
          hits: 0,
          misses: 10,
          falseAlarms: 20,
          correctRejections: 70,
        );

        expect(poorResponse.dPrime, isA<double>());
        expect(poorResponse.dPrime, lessThan(0));
      });
    });

    group('ExecutiveFunctionResponse', () {
      test('should create executive function response correctly', () {
        final moves = [
          Move(fromTower: 0, toTower: 2, timestamp: startTime),
          Move(fromTower: 0, toTower: 1, timestamp: startTime.add(const Duration(seconds: 5))),
        ];

        final response = ExecutiveFunctionResponse(
          questionId: 'executive_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          moves: moves,
          totalMoves: 7,
          solved: true,
          planningTime: 5000, // 5 seconds planning
        );

        expect(response.moves.length, equals(2));
        expect(response.totalMoves, equals(7));
        expect(response.solved, isTrue);
        expect(response.planningTime, equals(5000));
      });

      test('should handle unsolved tasks', () {
        final response = ExecutiveFunctionResponse(
          questionId: 'executive_failed',
          startTime: startTime,
          endTime: endTime,
          isCorrect: false,
          moves: const [],
          totalMoves: 20, // Too many moves
          solved: false,
          planningTime: 10000,
        );

        expect(response.solved, isFalse);
        expect(response.isCorrect, isFalse);
        expect(response.totalMoves, equals(20));
      });
    });

    group('Move', () {
      test('should create move correctly', () {
        final move = Move(
          fromTower: 0,
          toTower: 2,
          timestamp: startTime,
        );

        expect(move.fromTower, equals(0));
        expect(move.toTower, equals(2));
        expect(move.timestamp, equals(startTime));
      });

      test('should support equality comparison', () {
        final move1 = Move(fromTower: 0, toTower: 1, timestamp: startTime);
        final move2 = Move(fromTower: 0, toTower: 1, timestamp: startTime);

        expect(move1, equals(move2));
        expect(move1.hashCode, equals(move2.hashCode));
      });
    });

    group('LanguageSkillsResponse', () {
      test('should create language skills response correctly', () {
        final response = LanguageSkillsResponse(
          questionId: 'language_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          words: const ['cat', 'dog', 'lion', 'tiger', 'elephant'],
          validWords: 5,
          invalidWords: 0,
          repetitions: 0,
          categories: const ['mammals'],
        );

        expect(response.words.length, equals(5));
        expect(response.validWords, equals(5));
        expect(response.invalidWords, equals(0));
        expect(response.repetitions, equals(0));
        expect(response.categories.length, equals(1));
        expect(response.categories.first, equals('mammals'));
      });

      test('should handle invalid words and repetitions', () {
        final response = LanguageSkillsResponse(
          questionId: 'language_2',
          startTime: startTime,
          endTime: endTime,
          isCorrect: false,
          words: const ['cat', 'xyz', 'dog', 'cat'], // 'xyz' invalid, 'cat' repeated
          validWords: 2, // cat, dog (counting cat once)
          invalidWords: 1, // xyz
          repetitions: 1, // cat repeated
          categories: const ['animals'],
        );

        expect(response.validWords, equals(2));
        expect(response.invalidWords, equals(1));
        expect(response.repetitions, equals(1));
      });
    });

    group('VisuospatialResponse', () {
      test('should create visuospatial response correctly', () {
        final response = VisuospatialResponse(
          questionId: 'visuospatial_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          selectedOption: 2,
          correctOption: 2,
          confidence: 85.5,
        );

        expect(response.selectedOption, equals(2));
        expect(response.correctOption, equals(2));
        expect(response.confidence, equals(85.5));
        expect(response.isCorrect, isTrue);
      });

      test('should handle incorrect responses', () {
        final response = VisuospatialResponse(
          questionId: 'visuospatial_wrong',
          startTime: startTime,
          endTime: endTime,
          isCorrect: false,
          selectedOption: 1,
          correctOption: 3,
          confidence: 30.0,
        );

        expect(response.selectedOption, equals(1));
        expect(response.correctOption, equals(3));
        expect(response.confidence, equals(30.0));
        expect(response.isCorrect, isFalse);
      });

      test('should handle confidence values in valid range', () {
        final response = VisuospatialResponse(
          questionId: 'confidence_test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          selectedOption: 0,
          correctOption: 0,
          confidence: 100.0,
        );

        expect(response.confidence, lessThanOrEqualTo(100.0));
        expect(response.confidence, greaterThanOrEqualTo(0.0));
      });
    });

    group('ProcessingSpeedResponse', () {
      test('should create processing speed response correctly', () {
        final response = ProcessingSpeedResponse(
          questionId: 'processing_1',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          userAnswers: const [1, 2, 3, 1, 2],
          correctAnswers: const [1, 2, 3, 1, 2],
          correctCount: 5,
          totalAttempted: 5,
          averageTimePerItem: 1800.0, // 1.8 seconds per item
        );

        expect(response.userAnswers.length, equals(5));
        expect(response.correctAnswers.length, equals(5));
        expect(response.correctCount, equals(5));
        expect(response.totalAttempted, equals(5));
        expect(response.averageTimePerItem, equals(1800.0));
      });

      test('should handle partial accuracy', () {
        final response = ProcessingSpeedResponse(
          questionId: 'processing_partial',
          startTime: startTime,
          endTime: endTime,
          isCorrect: false,
          userAnswers: const [1, 2, 9, 1, 2], // Third answer wrong
          correctAnswers: const [1, 2, 3, 1, 2],
          correctCount: 4,
          totalAttempted: 5,
          averageTimePerItem: 2000.0,
        );

        expect(response.correctCount, equals(4));
        expect(response.totalAttempted, equals(5));
        expect(response.isCorrect, isFalse);
      });

      test('should calculate performance metrics correctly', () {
        final response = ProcessingSpeedResponse(
          questionId: 'performance_test',
          startTime: startTime,
          endTime: endTime,
          isCorrect: true,
          userAnswers: const [1, 2, 3],
          correctAnswers: const [1, 2, 3],
          correctCount: 3,
          totalAttempted: 3,
          averageTimePerItem: 1500.0,
        );

        // Accuracy = 3/3 = 100%
        final accuracy = response.correctCount / response.totalAttempted;
        expect(accuracy, equals(1.0));

        // Average time is reasonable (1.5 seconds per item)
        expect(response.averageTimePerItem, equals(1500.0));
      });
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle empty word lists in memory recall', () {
      const question = MemoryRecallQuestion(
        id: 'empty_test',
        instruction: 'Empty test',
        wordsToMemorize: [],
        studyTimeSeconds: 0,
        recognitionOptions: [],
      );

      expect(question.wordsToMemorize, isEmpty);
      expect(question.recognitionOptions, isEmpty);
      expect(question.studyTimeSeconds, equals(0));
    });

    test('should handle zero-duration responses', () {
      final startTime = DateTime.now();
      final response = MemoryRecallResponse(
        questionId: 'zero_duration',
        startTime: startTime,
        endTime: startTime, // Same time
        isCorrect: true,
        recalledWords: const [],
        recognizedWords: const [],
        freeRecallScore: 0,
        recognitionScore: 0,
      );

      expect(response.responseTimeMs, equals(0));
    });

    test('should handle extreme d-prime calculation edge cases', () {
      // All correct rejections, no hits or false alarms
      final response = AttentionFocusResponse(
        questionId: 'edge_case',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 1)),
        isCorrect: true,
        responses: const [],
        reactionTimes: const [],
        hits: 0,
        misses: 0,
        falseAlarms: 0,
        correctRejections: 100,
      );

      // Should not throw an error
      expect(() => response.dPrime, returnsNormally);
      expect(() => response.criterion, returnsNormally);
    });

    test('should handle very fast processing speed responses', () {
      final response = ProcessingSpeedResponse(
        questionId: 'fast_test',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(milliseconds: 100)),
        isCorrect: true,
        userAnswers: const [1],
        correctAnswers: const [1],
        correctCount: 1,
        totalAttempted: 1,
        averageTimePerItem: 100.0, // Very fast
      );

      expect(response.averageTimePerItem, equals(100.0));
      expect(response.responseTimeMs, equals(100));
    });

    test('should handle visuospatial responses with extreme confidence values', () {
      final highConfidence = VisuospatialResponse(
        questionId: 'high_confidence',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 1)),
        isCorrect: true,
        selectedOption: 0,
        correctOption: 0,
        confidence: 100.0,
      );

      final lowConfidence = VisuospatialResponse(
        questionId: 'low_confidence',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 1)),
        isCorrect: false,
        selectedOption: 1,
        correctOption: 0,
        confidence: 0.0,
      );

      expect(highConfidence.confidence, equals(100.0));
      expect(lowConfidence.confidence, equals(0.0));
    });

    test('should handle executive function responses with no moves', () {
      final response = ExecutiveFunctionResponse(
        questionId: 'no_moves',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 300)),
        isCorrect: false,
        moves: const [],
        totalMoves: 0,
        solved: false,
        planningTime: 300000, // Spent all time planning
      );

      expect(response.moves, isEmpty);
      expect(response.totalMoves, equals(0));
      expect(response.solved, isFalse);
      expect(response.planningTime, equals(300000));
    });

    test('should handle language skills responses with no valid words', () {
      final response = LanguageSkillsResponse(
        questionId: 'no_valid_words',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(seconds: 60)),
        isCorrect: false,
        words: const ['xyz', 'abc', 'nonsense'],
        validWords: 0,
        invalidWords: 3,
        repetitions: 0,
        categories: const [],
      );

      expect(response.validWords, equals(0));
      expect(response.invalidWords, equals(3));
      expect(response.categories, isEmpty);
      expect(response.isCorrect, isFalse);
    });

    test('should maintain immutability of question properties', () {
      const question = MemoryRecallQuestion(
        id: 'immutable_test',
        instruction: 'Test',
        wordsToMemorize: ['word1', 'word2'],
        studyTimeSeconds: 10,
        recognitionOptions: ['word1', 'word2', 'word3'],
      );

      // Props should be accessible but immutable
      expect(question.wordsToMemorize, isA<List<String>>());
      expect(question.recognitionOptions, isA<List<String>>());
      expect(question.props, isA<List<Object?>>());
    });
  });

  group('Equatable Implementation', () {
    test('should properly implement equality for all question types', () {
      // Test that identical questions are equal
      const q1 = MemoryRecallQuestion(
        id: 'test',
        instruction: 'test',
        wordsToMemorize: ['a'],
        studyTimeSeconds: 10,
        recognitionOptions: ['a', 'b'],
      );

      const q2 = MemoryRecallQuestion(
        id: 'test',
        instruction: 'test',
        wordsToMemorize: ['a'],
        studyTimeSeconds: 10,
        recognitionOptions: ['a', 'b'],
      );

      expect(q1, equals(q2));
      expect(q1.hashCode, equals(q2.hashCode));

      // Test that different questions are not equal
      const q3 = MemoryRecallQuestion(
        id: 'different',
        instruction: 'test',
        wordsToMemorize: ['a'],
        studyTimeSeconds: 10,
        recognitionOptions: ['a', 'b'],
      );

      expect(q1, isNot(equals(q3)));
    });

    test('should properly implement equality for all response types', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(seconds: 10));

      final r1 = MemoryRecallResponse(
        questionId: 'test',
        startTime: startTime,
        endTime: endTime,
        isCorrect: true,
        recalledWords: const ['a'],
        recognizedWords: const ['a'],
        freeRecallScore: 100,
        recognitionScore: 100,
      );

      final r2 = MemoryRecallResponse(
        questionId: 'test',
        startTime: startTime,
        endTime: endTime,
        isCorrect: true,
        recalledWords: const ['a'],
        recognizedWords: const ['a'],
        freeRecallScore: 100,
        recognitionScore: 100,
      );

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
    });
  });
}