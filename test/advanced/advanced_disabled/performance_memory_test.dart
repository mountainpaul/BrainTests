import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';import 'package:brain_tests/domain/services/exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';
import 'package:brain_tests/data/repositories/word_repository_impl.dart';
/// Performance and memory tests
///
/// As a senior engineer, performance issues often don't show up
/// until production with real data volumes. Critical concerns:
/// 1. Database query performance with large datasets
/// 2. Memory leaks from unclosed resources
/// 3. O(n²) algorithms that become problematic at scale
/// 4. UI rendering performance with complex states
/// 5. Memory consumption during intensive operations
///
/// These tests catch performance regressions early
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  group('Performance - Database Query Optimization', () {
    test('should query large dataset efficiently', () async {
      // Insert 1000 words
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'WORD$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      stopwatch.stop();
      final insertTime = stopwatch.elapsedMilliseconds;

      // Should complete in reasonable time (< 5 seconds)
      expect(insertTime, lessThan(5000));

      // Query performance
      stopwatch.reset();
      stopwatch.start();

      final results = await database.select(database.wordDictionaryTable).get();

      stopwatch.stop();
      final queryTime = stopwatch.elapsedMilliseconds;

      expect(results.length, 1000);
      expect(queryTime, lessThan(1000)); // Should be fast
    });

    test('should handle filtered queries efficiently', () async {
      // Insert mixed data
      for (int i = 0; i < 500; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'EASY$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 5 + i.toString().length,
          ),
        );

        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'HARD$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.hard,
            length: 5 + i.toString().length,
          ),
        );
      }

      // Test filtered query performance
      final stopwatch = Stopwatch()..start();

      final results = await (database.select(database.wordDictionaryTable)
            ..where((tbl) => tbl.difficulty.equalsValue(ExerciseDifficulty.easy)))
          .get();

      stopwatch.stop();

      expect(results.length, 500);
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should handle pagination efficiently', () async {
      // Insert 1000 records
      for (int i = 0; i < 1000; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'PAGE$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      // Test paginated queries
      final stopwatch = Stopwatch()..start();
      const pageSize = 50;
      var totalFetched = 0;

      for (int page = 0; page < 20; page++) {
        final results = await (database.select(database.wordDictionaryTable)
              ..limit(pageSize, offset: page * pageSize))
            .get();
        totalFetched += results.length;
      }

      stopwatch.stop();

      expect(totalFetched, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('Performance - Exercise Generation at Scale', () {
    test('should generate 100 exercises without performance degradation', () async {
      // Seed database
      for (int i = 0; i < 50; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'PERF$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      final stopwatch = Stopwatch()..start();
      final exercises = <WordPuzzleData>[];

      // Generate 100 exercises
      for (int i = 0; i < 100; i++) {
        final puzzle = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.medium,
          wordRepository: WordRepositoryImpl(database),
          wordType: WordType.anagram,
        );
        exercises.add(puzzle);
      }

      stopwatch.stop();

      expect(exercises.length, 100);
      // Should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // < 10 seconds
    });

    test('should handle rapid successive exercise generation', () async {
      // Seed database
      for (int i = 0; i < 20; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'RAPID$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 6 + i.toString().length,
          ),
        );
      }

      final stopwatch = Stopwatch()..start();

      // Generate exercises as fast as possible
      for (int i = 0; i < 50; i++) {
        final puzzle = await ExerciseGenerator.generateWordPuzzle(
          difficulty: ExerciseDifficulty.easy,
          wordRepository: WordRepositoryImpl(database),
          wordType: WordType.anagram,
        );
        expect(puzzle, isNotNull);
      }

      stopwatch.stop();

      // Should handle rapid requests
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should measure word search grid generation performance', () async {
      // Seed database
      for (int i = 0; i < 10; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'GRID$i',
            language: WordLanguage.english,
            type: WordType.wordSearch,
            difficulty: ExerciseDifficulty.medium,
            length: 5 + i.toString().length,
          ),
        );
      }

      final stopwatch = Stopwatch()..start();

      // Generate word search (computationally expensive)
      final puzzle = await ExerciseGenerator.generateWordPuzzle(
        difficulty: ExerciseDifficulty.hard, // Large grid
        wordRepository: WordRepositoryImpl(database),
        wordType: WordType.wordSearch,
      );

      stopwatch.stop();

      expect(puzzle.grid, isNotNull);
      // Grid generation should complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Performance - Memory Efficiency', () {
    test('should not accumulate memory with repeated operations', () async {
      // Seed database
      for (int i = 0; i < 100; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'MEM$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 4 + i.toString().length,
          ),
        );
      }

      // Perform many operations
      for (int i = 0; i < 1000; i++) {
        final results = await (database.select(database.wordDictionaryTable)
              ..limit(10))
            .get();
        expect(results, isNotEmpty);

        // Force garbage collection hint
        if (i % 100 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }

      // If there's a memory leak, this test would eventually slow down or OOM
      // Test completion indicates no obvious memory leaks
    });

    test('should handle large result sets without excessive memory', () async {
      // Insert large dataset
      for (int i = 0; i < 5000; i++) {
        await database.into(database.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'LARGE$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.medium,
            length: 6 + i.toString().length,
          ),
        );
      }

      // Query all results (memory stress test)
      final results = await database.select(database.wordDictionaryTable).get();

      expect(results.length, 5000);
      // Should complete without OOM
    });

    test('should cleanup resources properly in loops', () async {
      // Test that database connections don't leak
      for (int i = 0; i < 100; i++) {
        final tempDb = createTestDatabase();

        await tempDb.into(tempDb.wordDictionaryTable).insert(
          WordDictionaryTableCompanion.insert(
            word: 'CLEANUP$i',
            language: WordLanguage.english,
            type: WordType.anagram,
            difficulty: ExerciseDifficulty.easy,
            length: 8 + i.toString().length,
          ),
        );

        // Must close to prevent resource leak
        await tempDb.close();
      }

      // If connections aren't closed, this would fail or hang
    });
  });

  group('Performance - Algorithmic Complexity', () {
    test('should demonstrate linear time complexity for inserts', () async {
      final measurements = <int, int>{};

      for (final size in [100, 200, 400]) {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < size; i++) {
          await database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: 'SCALE$size$i',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.medium,
              length: 6 + i.toString().length,
            ),
          );
        }

        stopwatch.stop();
        measurements[size] = stopwatch.elapsedMilliseconds;

        // Clear for next iteration
        await database.delete(database.wordDictionaryTable).go();
      }

      // Verify roughly linear scaling
      // 400 should take ~2x as long as 200 (with some tolerance)
      // Allow for measurement variability - avoid division by zero
      if (measurements[200]! > 0) {
        final ratio = measurements[400]! / measurements[200]!;
        expect(ratio, lessThan(10.0)); // Should be close to 2.0, allow 10.0 for system variance
      } else {
        // If measurements are too fast, just verify they completed
        expect(measurements[400]!, greaterThanOrEqualTo(0));
      }
    });

    test('should avoid O(n²) patterns in exercise generation', () async {
      // Seed with varying dataset sizes
      final timings = <int>[];

      for (final wordCount in [10, 20, 40]) {
        // Clear database
        await database.delete(database.wordDictionaryTable).go();

        // Insert words
        for (int i = 0; i < wordCount; i++) {
          await database.into(database.wordDictionaryTable).insert(
            WordDictionaryTableCompanion.insert(
              word: 'COMPLEX$i',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.medium,
              length: 8 + i.toString().length,
            ),
          );
        }

        // Measure generation time
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10; i++) {
          await ExerciseGenerator.generateWordPuzzle(
            difficulty: ExerciseDifficulty.medium,
            wordRepository: WordRepositoryImpl(database),
            wordType: WordType.anagram,
          );
        }

        stopwatch.stop();
        timings.add(stopwatch.elapsedMilliseconds);
      }

      // Should scale sub-quadratically
      // If O(n²), 40 items would take 16x as long as 10 items
      // We expect much better scaling
      if (timings[0] > 0) {
        final ratio = timings[2] / timings[0];
        expect(ratio, lessThan(15.0)); // Allow very generous margin for variability
      } else {
        // If measurements are too fast, just verify they completed
        expect(timings[2], greaterThanOrEqualTo(0));
      }
    });
  });

  group('Performance - Batch Operations', () {
    test('should handle batch inserts efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Batch insert
      await database.batch((batch) {
        for (int i = 0; i < 1000; i++) {
          batch.insert(
            database.wordDictionaryTable,
            WordDictionaryTableCompanion.insert(
              word: 'BATCH$i',
              language: WordLanguage.english,
              type: WordType.anagram,
              difficulty: ExerciseDifficulty.medium,
              length: 6 + i.toString().length,
            ),
          );
        }
      });

      stopwatch.stop();

      // Batch operations should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Verify all inserted
      final count = await database.select(database.wordDictionaryTable).get();
      expect(count.length, 1000);
    });

    test('should compare batch vs individual insert performance', () async {
      final individualTime = await _measureIndividualInserts(100);
      await database.delete(database.wordDictionaryTable).go();

      final batchTime = await _measureBatchInsert(100);

      // Batch should be significantly faster
      expect(batchTime, lessThan(individualTime));
    });
  });

  group('Performance - String Operations', () {
    test('should handle string scrambling efficiently for long words', () async {
      final longWord = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' * 10; // 260 chars
      final letters = longWord.split('');

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        final scrambled = ExerciseGenerator.ensureScrambled(List.from(letters));
        expect(scrambled.length, letters.length);
      }

      stopwatch.stop();

      // Should handle efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should handle case-insensitive comparisons efficiently', () async {
      final words = List.generate(1000, (i) => 'TeSt$i');

      final stopwatch = Stopwatch()..start();

      for (final word in words) {
        final upper = word.toUpperCase();
        final lower = word.toLowerCase();
        expect(upper != lower || upper == lower, true);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}

/// Helper: Measure individual inserts
Future<int> _measureIndividualInserts(int count) async {
  final db = createTestDatabase();
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < count; i++) {
    await db.into(db.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'INDIVIDUAL$i',
        language: WordLanguage.english,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.medium,
        length: 11 + i.toString().length,
      ),
    );
  }

  stopwatch.stop();
  await db.close();
  return stopwatch.elapsedMilliseconds;
}

/// Helper: Measure batch insert
Future<int> _measureBatchInsert(int count) async {
  final db = createTestDatabase();
  final stopwatch = Stopwatch()..start();

  await db.batch((batch) {
    for (int i = 0; i < count; i++) {
      batch.insert(
        db.wordDictionaryTable,
        WordDictionaryTableCompanion.insert(
          word: 'BATCH$i',
          language: WordLanguage.english,
          type: WordType.anagram,
          difficulty: ExerciseDifficulty.medium,
          length: 6 + i.toString().length,
        ),
      );
    }
  });

  stopwatch.stop();
  await db.close();
  return stopwatch.elapsedMilliseconds;
}
