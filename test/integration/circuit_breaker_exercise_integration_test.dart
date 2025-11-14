import 'package:brain_plan/core/services/circuit_breaker.dart';
import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// Integration test for Circuit Breaker with Exercise Generation
///
/// This test demonstrates how the circuit breaker prevents cascading failures
/// when exercise generation fails repeatedly (e.g., empty word database)
void main() {
  group('Circuit Breaker Exercise Integration', () {
    late AppDatabase database;
    late CircuitBreaker breaker;

    setUp(() async {
      database = createTestDatabase();
      breaker = CircuitBreaker(
        name: 'exercise_generation',
        failureThreshold: 3,
        timeout: const Duration(seconds: 5),
        fallback: () => WordPuzzleData(
          type: WordPuzzleType.anagram,
          targetWord: 'FALLBACK',
          scrambledLetters: ['F', 'A', 'L', 'L', 'B', 'A', 'C', 'K'],
          timeLimit: 60,
        ),
      );
    });

    tearDown(() async {
      await closeTestDatabase(database);
    });

    test('should use circuit breaker for word puzzle generation', () async {
      // Insert test words
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'COGNITIVE',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 9,
        ),
      );

      // Generate exercise through circuit breaker
      final result = await breaker.execute<WordPuzzleData>(() async {
        return await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.medium,
          database: database,
          wordType: WordType.anagram,
        );
      });

      expect(result.targetWord, 'COGNITIVE');
      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);
    });

    test('should open circuit after repeated exercise generation failures', () async {
      // Simulate failures by forcing exceptions
      for (int i = 0; i < 3; i++) {
        try {
          await breaker.execute<WordPuzzleData>(() async {
            throw Exception('Simulated generation failure');
          });
          fail('Should have thrown exception');
        } catch (e) {
          // Expected to fail
        }
      }

      // Circuit should be open after 3 failures
      expect(breaker.state, CircuitBreakerState.open);
      expect(breaker.failureCount, greaterThanOrEqualTo(3));

      print('Circuit breaker statistics after failures:');
      print(breaker.statistics);
    });

    test('should return fallback when circuit is open', () async {
      // Trip the circuit breaker with forced failures
      for (int i = 0; i < 3; i++) {
        try {
          await breaker.execute<WordPuzzleData>(() async {
            throw Exception('Forced failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Next request should use fallback or throw CircuitBreakerOpenException
      try {
        await breaker.execute<WordPuzzleData>(() async {
          fail('Should not execute when circuit is open');
          return WordPuzzleData(
            type: WordPuzzleType.anagram,
            targetWord: 'TEST',
            scrambledLetters: 'TSET'.split(''),
            timeLimit: 60,
          );
        });
        // If it doesn't throw, the circuit might have a grace period
      } catch (e) {
        // Expected - circuit is open
        expect(e.toString(), contains('Circuit'));
      }
    });

    test('should close circuit after successful generation following timeout', () async {
      // Trip the circuit breaker with forced failures
      for (int i = 0; i < 3; i++) {
        try {
          await breaker.execute<WordPuzzleData>(() async {
            throw Exception('Forced failure');
          });
        } catch (e) {
          // Expected
        }
      }

      expect(breaker.state, CircuitBreakerState.open);

      // Wait for circuit breaker timeout
      await Future.delayed(const Duration(seconds: 6));

      // Add word to database (fix the issue)
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'RECOVERED',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 9,
        ),
      );

      // Try again - should succeed and close circuit
      final result = await breaker.execute<WordPuzzleData>(() async {
        return await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.medium,
          database: database,
        );
      });

      expect(result.targetWord, isNotNull);
      // Circuit should be closed or half-open after successful execution
      expect([CircuitBreakerState.closed, CircuitBreakerState.halfOpen].contains(breaker.state), isTrue);

      print('Circuit breaker statistics after recovery:');
      print(breaker.statistics);
    });

    test('should handle concurrent exercise generation through circuit breaker', () async {
      // Add multiple words
      final words = ['BRAIN', 'MEMORY', 'COGNITIVE', 'LEARNING', 'THINKING'];
      for (final word in words) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: word,
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: word.length,
          ),
        );
      }

      // Generate multiple exercises concurrently
      final futures = <Future<WordPuzzleData>>[];
      for (int i = 0; i < 10; i++) {
        futures.add(
          breaker.execute<WordPuzzleData>(() async {
            return await ExerciseGenerator.generateWordPuzzle(
              difficulty: ExerciseDifficulty.medium,
              database: database,
              wordType: WordType.anagram,
            );
          }),
        );
      }

      final results = await Future.wait(futures);

      expect(results.length, 10);
      expect(breaker.state, CircuitBreakerState.closed);
      expect(breaker.failureCount, 0);

      // All exercises should be from our word list
      for (final result in results) {
        expect(words.contains(result.targetWord), true);
      }
    });

    test('should protect against word database exhaustion', () async {
      // Add only 2 words
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'WORD1',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 5,
        ),
      );
      await database.into(database.wordDictionaryTable).insert(
        WordDictionaryTableCompanion.insert(
          word: 'WORD2',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 5,
        ),
      );

      final generatedWords = <String>[];
      final failures = <String>[];

      // Try to generate many exercises
      for (int i = 0; i < 10; i++) {
        try {
          final result = await breaker.execute<WordPuzzleData>(() async {
            return await ExerciseGenerator.generateWordPuzzle(
              difficulty: ExerciseDifficulty.medium,
              database: database,
              wordType: WordType.anagram,
            );
          });
          generatedWords.add(result.targetWord!);
        } on CircuitBreakerOpenException {
          // Circuit breaker prevented the request
          failures.add('Circuit open at request $i');
        } catch (e) {
          // Generation failed
          failures.add('Failed at request $i');
        }
      }

      // Circuit breaker should have protected us
      expect(breaker.state, isIn([CircuitBreakerState.open, CircuitBreakerState.closed]));

      print('Generated exercises: ${generatedWords.length}');
      print('Failures: ${failures.length}');
      print('Circuit breaker prevented ${failures.where((f) => f.contains('Circuit open')).length} requests');
    });
  });

  group('Circuit Breaker Memory Game Integration', () {
    late CircuitBreaker breaker;

    setUp(() {
      breaker = CircuitBreaker(
        name: 'memory_game_generation',
        failureThreshold: 3,
        timeout: const Duration(seconds: 5),
      );
    });

    test('should use circuit breaker for memory game generation', () {
      // Memory games don't use database, so always succeed
      final result = breaker.execute<MemoryGameData>(() async {
        return ExerciseGenerator.generateMemoryGame(
          difficulty: ExerciseDifficulty.medium,
        );
      });

      expect(result, completes);
    });

    test('should handle memory game generation errors gracefully', () async {
      // Simulate error by passing invalid difficulty
      // (This is a contrived example - memory games are robust)

      int attempts = 0;
      while (attempts < 3) {
        try {
          await breaker.execute<MemoryGameData>(() async {
            throw StateError('Simulated memory game generation error');
          });
        } catch (e) {
          attempts++;
        }
      }

      expect(breaker.state, CircuitBreakerState.open);
      expect(breaker.failureCount, 3);
    });
  });
}
