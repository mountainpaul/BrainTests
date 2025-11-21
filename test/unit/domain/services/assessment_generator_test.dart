import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/models/assessment_models.dart';
import 'package:brain_tests/domain/services/assessment_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssessmentGenerator', () {
    group('Memory Recall Assessment', () {
      test('should generate memory recall question with default difficulty', () async {
        final question = await AssessmentGenerator.generateMemoryRecallQuestion();

        expect(question, isA<MemoryRecallQuestion>());
        expect(question.id, contains('memory_recall_'));
        expect(question.instruction, contains('words'));
        expect(question.wordsToMemorize.length, equals(5)); // Default difficulty 1
        expect(question.studyTimeSeconds, equals(10)); // 2 * 5 words
        expect(question.timeLimit, equals(120));
        expect(question.recognitionOptions.length, equals(10)); // words + distractors

        // Should contain all target words
        for (final word in question.wordsToMemorize) {
          expect(question.recognitionOptions, contains(word));
        }
      });

      test('should generate harder questions with increased difficulty', () async {
        final easyQuestion = await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: 1);
        final hardQuestion = await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: 5);

        expect(hardQuestion.wordsToMemorize.length, greaterThan(easyQuestion.wordsToMemorize.length));
        expect(hardQuestion.studyTimeSeconds, greaterThan(easyQuestion.studyTimeSeconds));
        expect(hardQuestion.recognitionOptions.length, greaterThan(easyQuestion.recognitionOptions.length));
      });

      test('should handle extreme difficulty values gracefully', () async {
        final extremeQuestion = await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: 10);

        expect(extremeQuestion, isA<MemoryRecallQuestion>());
        expect(extremeQuestion.wordsToMemorize, isNotEmpty);
        expect(extremeQuestion.recognitionOptions, isNotEmpty);
      });

      test('should create unique question IDs', () async {
        final question1 = await AssessmentGenerator.generateMemoryRecallQuestion();
        await Future.delayed(const Duration(milliseconds: 1)); // Ensure different timestamps
        final question2 = await AssessmentGenerator.generateMemoryRecallQuestion();

        expect(question1.id, isNot(equals(question2.id)));
      });
    });

    group('Attention Focus Assessment', () {
      test('should generate attention focus question with correct parameters', () {
        final question = AssessmentGenerator.generateAttentionFocusQuestion();

        expect(question, isA<AttentionFocusQuestion>());
        expect(question.id, contains('attention_focus_'));
        expect(question.instruction, contains('3')); // target number
        expect(question.stimulusSequence.length, equals(120)); // 100 + 20
        expect(question.targetNumber, equals(3));
        expect(question.stimulusDurationMs, equals(500));
        expect(question.interStimulusIntervalMs, equals(1000));

        // Should contain roughly 10% targets
        final targetCount = question.stimulusSequence.where((n) => n == 3).length;
        expect(targetCount, closeTo(12, 3)); // ~10% of 120 with tolerance

        // Should only contain numbers 1-9
        for (final number in question.stimulusSequence) {
          expect(number, greaterThanOrEqualTo(1));
          expect(number, lessThanOrEqualTo(9));
        }
      });

      test('should scale sequence length with difficulty', () {
        final easyQuestion = AssessmentGenerator.generateAttentionFocusQuestion(difficulty: 1);
        final hardQuestion = AssessmentGenerator.generateAttentionFocusQuestion(difficulty: 5);

        expect(hardQuestion.stimulusSequence.length, greaterThan(easyQuestion.stimulusSequence.length));
        expect(hardQuestion.stimulusSequence.length, equals(200)); // 100 + 5*20
      });

      test('should maintain target frequency across difficulties', () {
        final question = AssessmentGenerator.generateAttentionFocusQuestion(difficulty: 3);
        final targetCount = question.stimulusSequence.where((n) => n == 3).length;
        final totalCount = question.stimulusSequence.length;
        final actualFrequency = targetCount / totalCount;

        expect(actualFrequency, closeTo(0.1, 0.05)); // 10% ± 5%
      });
    });

    group('Executive Function Assessment', () {
      test('should generate Tower of Hanoi question with correct structure', () {
        final question = AssessmentGenerator.generateExecutiveFunctionQuestion();

        expect(question, isA<ExecutiveFunctionQuestion>());
        expect(question.id, contains('executive_function_'));
        expect(question.instruction, contains('tower'));
        expect(question.numberOfDisks, equals(3)); // 2 + difficulty 1
        expect(question.timeLimit, equals(180)); // 60 * 3 disks
        expect(question.initialState.length, equals(3)); // 3 towers
        expect(question.targetState.length, equals(3));

        // Initial state: all disks on first tower
        expect(question.initialState[0].length, equals(3));
        expect(question.initialState[1].isEmpty, isTrue);
        expect(question.initialState[2].isEmpty, isTrue);

        // Target state: all disks on third tower
        expect(question.targetState[0].isEmpty, isTrue);
        expect(question.targetState[1].isEmpty, isTrue);
        expect(question.targetState[2].length, equals(3));

        // Should be ordered largest to smallest
        for (int i = 0; i < question.initialState[0].length - 1; i++) {
          expect(question.initialState[0][i], greaterThan(question.initialState[0][i + 1]));
        }
      });

      test('should scale disk count with difficulty', () {
        final easyQuestion = AssessmentGenerator.generateExecutiveFunctionQuestion(difficulty: 1);
        final hardQuestion = AssessmentGenerator.generateExecutiveFunctionQuestion(difficulty: 5);

        expect(hardQuestion.numberOfDisks, greaterThan(easyQuestion.numberOfDisks));
        expect(hardQuestion.timeLimit, greaterThan(easyQuestion.timeLimit));
        expect(hardQuestion.maxMoves, greaterThan(easyQuestion.maxMoves));
      });

      test('should calculate reasonable move limits', () {
        final question = AssessmentGenerator.generateExecutiveFunctionQuestion(difficulty: 2);
        // For 4 disks (2+2), optimal moves = 2^4 - 1 = 15
        // Max moves should be ~22-23 (15 * 1.5)
        expect(question.maxMoves, greaterThan(question.numberOfDisks * 3));
        expect(question.maxMoves, lessThan(question.numberOfDisks * 8));
      });
    });

    group('Language Skills Assessment', () {
      test('should generate language skills question with valid category', () async {
        final question = await AssessmentGenerator.generateLanguageSkillsQuestion();

        expect(question, isA<LanguageSkillsQuestion>());
        expect(question.id, contains('language_skills_'));
        expect(question.category, equals('animals'));
        expect(question.prompt, contains('animals'));
        expect(question.responseTimeSeconds, equals(60));
        expect(question.timeLimit, equals(60));
      });

      test('should provide different categories for different difficulties', () async {
        final categories = <String>{};
        for (int difficulty = 1; difficulty <= 5; difficulty++) {
          final question = await AssessmentGenerator.generateLanguageSkillsQuestion(difficulty: difficulty);
          categories.add(question.category);
        }

        expect(categories.length, greaterThan(3)); // Should have variety
        expect(categories, contains('animals'));
        expect(categories, anyOf([contains('foods'), contains('countries'), contains('professions')]));
      });

      test('should handle letter fluency categories', () async {
        final question = await AssessmentGenerator.generateLanguageSkillsQuestion(difficulty: 4);
        if (question.category.startsWith('words_')) {
          expect(question.category, equals('words_f'));
          expect(question.prompt, contains('letter F'));
        }
      });
    });

    group('Visuospatial Skills Assessment', () {
      test('should generate visuospatial question with rotation parameters', () async {
        final question = await AssessmentGenerator.generateVisuospatialQuestion();

        expect(question, isA<VisuospatialQuestion>());
        expect(question.id, contains('visuospatial_'));
        expect(question.instruction, contains('rotated'));
        expect(question.targetShape, isNotEmpty);
        expect(question.optionShapes.length, equals(4));
        expect(question.correctOptionIndex, greaterThanOrEqualTo(0));
        expect(question.correctOptionIndex, lessThan(4));
        expect(question.rotationDegrees, greaterThanOrEqualTo(0));
        expect(question.rotationDegrees, lessThan(360));
        expect(question.timeLimit, equals(40)); // 30 + 10 for difficulty 1

        // Should contain the correct option
        final correctOption = question.optionShapes[question.correctOptionIndex];
        expect(correctOption, contains(question.targetShape));
        expect(correctOption, contains('${question.rotationDegrees}deg'));
      });

      test('should provide more rotation angles for higher difficulty', () async {
        final easyQuestion = await AssessmentGenerator.generateVisuospatialQuestion(difficulty: 1);
        final hardQuestion = await AssessmentGenerator.generateVisuospatialQuestion(difficulty: 5);

        expect(hardQuestion.timeLimit, greaterThan(easyQuestion.timeLimit));
      });

      test('should use valid shape types', () async {
        final validShapes = {'L_shape', 'F_shape', 'T_shape', 'plus_shape', 'arrow_shape'};

        for (int i = 0; i < 10; i++) {
          final question = await AssessmentGenerator.generateVisuospatialQuestion();
          final shapeType = question.targetShape;
          expect(validShapes, contains(shapeType));
        }
      });
    });

    group('Processing Speed Assessment', () {
      test('should generate processing speed question with symbol mapping', () async {
        final question = await AssessmentGenerator.generateProcessingSpeedQuestion();

        expect(question, isA<ProcessingSpeedQuestion>());
        expect(question.id, contains('processing_speed_'));
        expect(question.instruction, contains('symbol'));
        expect(question.symbolToNumberMap.length, equals(5)); // 4 + difficulty 1
        expect(question.symbolSequence.length, equals(30)); // 20 + 10
        expect(question.correctAnswers.length, equals(question.symbolSequence.length));
        expect(question.timeLimit, equals(90));

        // Verify mapping consistency
        for (int i = 0; i < question.symbolSequence.length; i++) {
          final symbol = question.symbolSequence[i];
          final expectedAnswer = question.symbolToNumberMap[symbol]!;
          expect(question.correctAnswers[i], equals(expectedAnswer));
        }

        // Should use valid symbols and numbers
        final symbols = question.symbolToNumberMap.keys.toSet();
        final numbers = question.symbolToNumberMap.values.toSet();
        expect(symbols.length, equals(question.symbolToNumberMap.length)); // No duplicate symbols
        expect(numbers.length, equals(question.symbolToNumberMap.length)); // No duplicate numbers
      });

      test('should scale complexity with difficulty', () async {
        final easyQuestion = await AssessmentGenerator.generateProcessingSpeedQuestion(difficulty: 1);
        final hardQuestion = await AssessmentGenerator.generateProcessingSpeedQuestion(difficulty: 5);

        expect(hardQuestion.symbolToNumberMap.length, greaterThan(easyQuestion.symbolToNumberMap.length));
        expect(hardQuestion.symbolSequence.length, greaterThan(easyQuestion.symbolSequence.length));
      });

      test('should use distinct symbols from predefined set', () async {
        final question = await AssessmentGenerator.generateProcessingSpeedQuestion(difficulty: 3);
        final validSymbols = {'○', '□', '△', '◇', '☆', '♦', '♠', '♣', '♥'};

        for (final symbol in question.symbolToNumberMap.keys) {
          expect(validSymbols, contains(symbol));
        }
      });
    });

    group('Assessment Battery Generation', () {
      test('should generate battery for each assessment type', () async {
        for (final type in AssessmentType.values) {
          final battery = await AssessmentGenerator.generateAssessmentBattery(type: type);
          expect(battery, isNotEmpty);
          expect(battery.length, equals(1)); // Single question per type currently

          switch (type) {
            case AssessmentType.memoryRecall:
              expect(battery.first, isA<MemoryRecallQuestion>());
              break;
            case AssessmentType.attentionFocus:
              expect(battery.first, isA<AttentionFocusQuestion>());
              break;
            case AssessmentType.executiveFunction:
              expect(battery.first, isA<ExecutiveFunctionQuestion>());
              break;
            case AssessmentType.languageSkills:
              expect(battery.first, isA<LanguageSkillsQuestion>());
              break;
            case AssessmentType.visuospatialSkills:
              expect(battery.first, isA<VisuospatialQuestion>());
              break;
            case AssessmentType.processingSpeed:
              expect(battery.first, isA<ProcessingSpeedQuestion>());
              break;
          }
        }
      });

      test('should respect difficulty parameter in battery generation', () async {
        final easyBattery = await AssessmentGenerator.generateAssessmentBattery(
          type: AssessmentType.memoryRecall,
          difficulty: 1,
        );
        final hardBattery = await AssessmentGenerator.generateAssessmentBattery(
          type: AssessmentType.memoryRecall,
          difficulty: 5,
        );

        final easyQuestion = easyBattery.first as MemoryRecallQuestion;
        final hardQuestion = hardBattery.first as MemoryRecallQuestion;

        expect(hardQuestion.wordsToMemorize.length, greaterThan(easyQuestion.wordsToMemorize.length));
      });
    });

    group('Score Calculation', () {
      late DateTime now;

      setUp(() {
        now = DateTime.now();
      });

      test('should calculate memory recall score correctly', () {
        final response = MemoryRecallResponse(
          questionId: 'test_memory',
          startTime: now,
          endTime: now.add(const Duration(minutes: 2)),
          isCorrect: true,
          recalledWords: const ['apple', 'cat', 'book'],
          recognizedWords: const ['apple', 'cat', 'book', 'dog', 'sun'],
          freeRecallScore: 60, // 3/5 words = 60%
          recognitionScore: 100, // 5/5 recognized = 100%
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.memoryRecall,
          [response],
        );

        expect(score, equals(72.0));
      });

      test('should calculate attention focus score using d-prime', () {
        final response = AttentionFocusResponse(
          questionId: 'test_attention',
          startTime: now,
          endTime: now.add(const Duration(minutes: 5)),
          isCorrect: true,
          responses: const [true, false, true, false],
          reactionTimes: const [500, 0, 600, 0],
          hits: 8,
          misses: 2,
          falseAlarms: 3,
          correctRejections: 87,
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.attentionFocus,
          [response],
        );

        expect(score, greaterThan(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('should calculate executive function score based on efficiency', () {
        final response = ExecutiveFunctionResponse(
          questionId: 'test_executive',
          startTime: now,
          endTime: now.add(const Duration(minutes: 3)),
          isCorrect: true,
          moves: const [],
          totalMoves: 10,
          solved: true,
          planningTime: 30000,
          numberOfDisks: 3,
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.executiveFunction,
          [response],
        );

        expect(score, greaterThan(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('should return zero for unsolved executive function task', () {
        final response = ExecutiveFunctionResponse(
          questionId: 'test_executive_fail',
          startTime: now,
          endTime: now.add(const Duration(minutes: 5)),
          isCorrect: false,
          moves: const [],
          totalMoves: 20,
          solved: false,
          planningTime: 60000,
          numberOfDisks: 3,
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.executiveFunction,
          [response],
        );

        expect(score, equals(0.0));
      });

      test('should calculate language skills score based on valid words', () {
        final response = LanguageSkillsResponse(
          questionId: 'test_language',
          startTime: now,
          endTime: now.add(const Duration(seconds: 60)),
          isCorrect: true,
          words: const ['cat', 'dog', 'lion', 'tiger', 'elephant'],
          validWords: 12,
          invalidWords: 2,
          repetitions: 1,
          categories: const ['mammals'],
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.languageSkills,
          [response],
        );

        expect(score, equals(80.0));
      });

      test('should calculate visuospatial score with time bonus', () {
        final response = VisuospatialResponse(
          questionId: 'test_visuospatial',
          startTime: now,
          endTime: now.add(const Duration(seconds: 10)), // Fast response
          isCorrect: true,
          selectedOption: 2,
          correctOption: 2,
          confidence: 90.0,
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.visuospatialSkills,
          [response],
        );

        expect(score, greaterThan(75.0));
        expect(score, lessThanOrEqualTo(100.0));
      });

      test('should return zero for incorrect visuospatial response', () {
        final response = VisuospatialResponse(
          questionId: 'test_visuospatial_wrong',
          startTime: now,
          endTime: now.add(const Duration(seconds: 10)),
          isCorrect: false,
          selectedOption: 1,
          correctOption: 2,
          confidence: 30.0,
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.visuospatialSkills,
          [response],
        );

        expect(score, equals(0.0));
      });

      test('should calculate processing speed score with accuracy and speed', () {
        final response = ProcessingSpeedResponse(
          questionId: 'test_processing',
          startTime: now,
          endTime: now.add(const Duration(seconds: 60)),
          isCorrect: true,
          userAnswers: const [1, 2, 3, 4, 5],
          correctAnswers: const [1, 2, 3, 4, 1],
          correctCount: 4,
          totalAttempted: 5,
          averageTimePerItem: 2000, // 2 seconds per item
        );

        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.processingSpeed,
          [response],
        );

        expect(score, greaterThan(60));
        expect(score, lessThanOrEqualTo(100));
      });

      test('should handle empty responses gracefully', () {
        final score = AssessmentGenerator.calculateAssessmentScore(
          AssessmentType.memoryRecall,
          [],
        );

        expect(score, equals(0.0));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle invalid difficulty values', () async {
        await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: -1);
        await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: 0);
        await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: 1000);
      });

      test('should generate valid questions for all difficulty levels', () async {
        for (int difficulty = 1; difficulty <= 10; difficulty++) {
          final question = await AssessmentGenerator.generateMemoryRecallQuestion(difficulty: difficulty);
          expect(question.wordsToMemorize, isNotEmpty);
          expect(question.studyTimeSeconds, greaterThan(0));
          expect(question.recognitionOptions.length, greaterThanOrEqualTo(question.wordsToMemorize.length));
        }
      });

      test('should handle extreme executive function parameters', () {
        final question = AssessmentGenerator.generateExecutiveFunctionQuestion(difficulty: 10);
        expect(question.numberOfDisks, lessThanOrEqualTo(12));
        expect(question.maxMoves, greaterThan(0));
        expect(question.timeLimit, greaterThan(0));
      });

      test('should generate unique question IDs consistently', () async {
        final ids = <String>{};
        for (int i = 0; i < 10; i++) { 
          final question = await AssessmentGenerator.generateMemoryRecallQuestion();
          expect(ids, isNot(contains(question.id)));
          ids.add(question.id);
          await Future.delayed(const Duration(milliseconds: 1)); 
        }
      });

      test('should maintain data consistency across generation calls', () async {
        for (int i = 0; i < 10; i++) {
          final question = await AssessmentGenerator.generateProcessingSpeedQuestion(difficulty: 3);

          for (final symbol in question.symbolSequence) {
            expect(question.symbolToNumberMap.containsKey(symbol), isTrue);
          }

          for (int j = 0; j < question.symbolSequence.length; j++) {
            final symbol = question.symbolSequence[j];
            final expectedAnswer = question.symbolToNumberMap[symbol]!;
            expect(question.correctAnswers[j], equals(expectedAnswer));
          }
        }
      });
    });
  });

  group('WordValidator', () {
    group('Word Validation', () {
      test('should validate animal words correctly', () async {
        expect(await WordValidator.isValidWord('animals', 'cat'), isTrue);
        expect(await WordValidator.isValidWord('animals', 'dog'), isTrue);
        expect(await WordValidator.isValidWord('animals', 'elephant'), isTrue);
        expect(await WordValidator.isValidWord('animals', 'xyzabc'), isFalse);
        expect(await WordValidator.isValidWord('animals', ''), isFalse);
      });

      test('should validate food words correctly', () async {
        expect(await WordValidator.isValidWord('foods', 'apple'), isTrue);
        expect(await WordValidator.isValidWord('foods', 'bread'), isTrue);
        expect(await WordValidator.isValidWord('foods', 'chicken'), isTrue);
        expect(await WordValidator.isValidWord('foods', 'car'), isFalse);
      });

      test('should validate country words correctly', () async {
        expect(await WordValidator.isValidWord('countries', 'usa'), isTrue);
        expect(await WordValidator.isValidWord('countries', 'canada'), isTrue);
        expect(await WordValidator.isValidWord('countries', 'france'), isTrue);
        expect(await WordValidator.isValidWord('countries', 'atlantis'), isFalse);
      });

      test('should handle letter fluency correctly', () async {
        expect(await WordValidator.isValidWord('words_f', 'fish'), isTrue);
        expect(await WordValidator.isValidWord('words_f', 'forest'), isTrue);
        expect(await WordValidator.isValidWord('words_f', 'fantastic'), isTrue);
        expect(await WordValidator.isValidWord('words_f', 'cat'), isFalse);
        expect(await WordValidator.isValidWord('words_f', 'f'), isFalse);
      });

      test('should handle case insensitivity', () async {
        expect(await WordValidator.isValidWord('animals', 'CAT'), isTrue);
        expect(await WordValidator.isValidWord('animals', 'Dog'), isTrue);
        expect(await WordValidator.isValidWord('foods', 'APPLE'), isTrue);
      });

      test('should handle whitespace', () async {
        expect(await WordValidator.isValidWord('animals', ' cat '),
 isTrue);
        expect(await WordValidator.isValidWord('animals', '  dog  '), isTrue);
        expect(await WordValidator.isValidWord('foods', '\tapple\n'), isTrue);
      });

      test('should return false for unknown categories', () async {
        expect(await WordValidator.isValidWord('unknown_category', 'word'), isFalse);
        expect(await WordValidator.isValidWord('', 'word'), isFalse);
      });
    });

    group('Word Categorization', () {
      test('should identify animal words in mixed list', () async {
        final words = ['cat', 'apple', 'dog', 'car', 'elephant'];
        final categories = await WordValidator.categorizeWords(words);
        expect(categories, contains('animals'));
      });

      test('should identify food words in mixed list', () async {
        final words = ['house', 'apple', 'banana', 'computer', 'bread'];
        final categories = await WordValidator.categorizeWords(words);
        expect(categories, contains('foods'));
      });

      test('should identify multiple categories', () async {
        final words = ['cat', 'apple', 'dog', 'bread', 'elephant'];
        final categories = await WordValidator.categorizeWords(words);
        expect(categories, contains('animals'));
        expect(categories, contains('foods'));
      });

      test('should return empty list for no recognized words', () async {
        final words = ['xyz', 'abc', 'nonsense', 'invalid'];
        final categories = await WordValidator.categorizeWords(words);
        expect(categories, isEmpty);
      });

      test('should handle empty word list', () async {
        final categories = await WordValidator.categorizeWords([]);
        expect(categories, isEmpty);
      });

      test('should handle case-insensitive categorization', () async {
        final words = ['CAT', 'APPLE', 'DOG'];
        final categories = await WordValidator.categorizeWords(words);
        expect(categories, contains('animals'));
        expect(categories, contains('foods'));
      });
    });
  });
}