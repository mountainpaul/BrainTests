import 'package:brain_tests/data/word_lists/word_list_generator.dart';
import 'package:brain_tests/data/word_lists/word_list_persistence.dart';
import 'package:brain_tests/data/word_lists/word_list_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration tests for 5-Word Recall Test with Toronto Word Pool
/// Added on 2024-11-24
///
/// Tests the complete flow:
/// 1. Integration with FiveWordRecallTestScreen
/// 2. Persistence of usage tracking
/// 3. Automatic regeneration when exhausted
void main() {
  group('Word List Persistence', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save used list indices to SharedPreferences', () async {
      final persistence = WordListPersistence();
      final usedIndices = {5, 10, 15, 20};

      await persistence.saveUsedIndices(usedIndices);

      final loaded = await persistence.loadUsedIndices();
      expect(loaded, usedIndices);
    });

    test('should save generation number', () async {
      final persistence = WordListPersistence();

      await persistence.saveGenerationNumber(3);

      final loaded = await persistence.loadGenerationNumber();
      expect(loaded, 3);
    });

    test('should start with generation 0 and no used indices', () async {
      final persistence = WordListPersistence();

      final generation = await persistence.loadGenerationNumber();
      final used = await persistence.loadUsedIndices();

      expect(generation, 0);
      expect(used.isEmpty, true);
    });

    test('should persist across multiple saves and loads', () async {
      final persistence = WordListPersistence();

      await persistence.saveUsedIndices({1, 2, 3});
      await persistence.saveGenerationNumber(1);

      final indices1 = await persistence.loadUsedIndices();
      expect(indices1, {1, 2, 3});

      await persistence.saveUsedIndices({1, 2, 3, 4, 5});
      final indices2 = await persistence.loadUsedIndices();
      expect(indices2, {1, 2, 3, 4, 5});
    });

    test('should clear used indices on regeneration', () async {
      final persistence = WordListPersistence();

      await persistence.saveUsedIndices({1, 2, 3, 4, 5});
      await persistence.saveGenerationNumber(1);

      await persistence.clearUsedIndices();

      final indices = await persistence.loadUsedIndices();
      expect(indices.isEmpty, true);
    });
  });

  group('Word List Manager Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should get unique list on each call', () async {
      final manager = WordListManager();
      await manager.initialize();

      final list1 = await manager.getNextWordList();
      final list2 = await manager.getNextWordList();
      final list3 = await manager.getNextWordList();

      expect(list1.length, 5);
      expect(list2.length, 5);
      expect(list3.length, 5);

      // Lists should be different
      expect(list1.toString(), isNot(list2.toString()));
      expect(list2.toString(), isNot(list3.toString()));
      expect(list1.toString(), isNot(list3.toString()));
    });

    test('should not reuse lists', () async {
      final manager = WordListManager();
      await manager.initialize();

      final usedLists = <String>{};

      // Get 50 lists
      for (int i = 0; i < 50; i++) {
        final list = await manager.getNextWordList();
        final listStr = list.toString();

        expect(usedLists.contains(listStr), false,
          reason: 'List $i should not be a duplicate');

        usedLists.add(listStr);
      }

      expect(usedLists.length, 50);
    });

    test('should persist used indices between sessions', () async {
      // First session - use some lists
      final manager1 = WordListManager();
      await manager1.initialize();

      await manager1.getNextWordList();
      await manager1.getNextWordList();
      await manager1.getNextWordList();

      final usedAfterSession1 = manager1.getUsedListCount();
      expect(usedAfterSession1, 3);

      // Second session - should remember used lists
      final manager2 = WordListManager();
      await manager2.initialize();

      final usedAfterSession2 = manager2.getUsedListCount();
      expect(usedAfterSession2, 3);

      // Get more lists
      await manager2.getNextWordList();
      await manager2.getNextWordList();

      expect(manager2.getUsedListCount(), 5);
    });

    test('should automatically regenerate when exhausted', () async {
      final manager = WordListManager();
      await manager.initialize();

      // Use all 200 lists
      for (int i = 0; i < 200; i++) {
        await manager.getNextWordList();
      }

      final generationBefore = manager.getCurrentGeneration();
      expect(generationBefore, 0);
      expect(manager.getUsedListCount(), 200);

      // Next call should trigger regeneration
      final listAfterRegen = await manager.getNextWordList();

      expect(listAfterRegen.length, 5);
      expect(manager.getCurrentGeneration(), 1);
      expect(manager.getUsedListCount(), 1);
    });

    test('should persist generation number across sessions', () async {
      // First session - exhaust all lists
      final manager1 = WordListManager();
      await manager1.initialize();

      for (int i = 0; i < 200; i++) {
        await manager1.getNextWordList();
      }
      await manager1.getNextWordList(); // Trigger regeneration

      expect(manager1.getCurrentGeneration(), 1);

      // Second session - should remember generation
      final manager2 = WordListManager();
      await manager2.initialize();

      expect(manager2.getCurrentGeneration(), 1);
    });

    test('should handle multiple regenerations', () async {
      final manager = WordListManager();
      await manager.initialize();

      // Generation 0 -> 1
      for (int i = 0; i < 200; i++) {
        await manager.getNextWordList();
      }
      await manager.getNextWordList();
      expect(manager.getCurrentGeneration(), 1);

      // Generation 1 -> 2
      for (int i = 0; i < 199; i++) {
        await manager.getNextWordList();
      }
      await manager.getNextWordList();
      expect(manager.getCurrentGeneration(), 2);

      expect(manager.getUsedListCount(), 1);
    });

    test('should provide progress information', () async {
      final manager = WordListManager();
      await manager.initialize();

      expect(manager.getTotalLists(), 200);
      expect(manager.getUsedListCount(), 0);
      expect(manager.getRemainingListCount(), 200);

      await manager.getNextWordList();
      await manager.getNextWordList();
      await manager.getNextWordList();

      expect(manager.getUsedListCount(), 3);
      expect(manager.getRemainingListCount(), 197);
    });
  });

  group('Word List Manager - Error Handling', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should handle initialization errors gracefully', () async {
      final manager = WordListManager();
      // Don't call initialize - should still work with defaults
      final list = await manager.getNextWordList();
      expect(list.length, 5);
    });

    test('should validate list contents', () async {
      final manager = WordListManager();
      await manager.initialize();

      final list = await manager.getNextWordList();

      // All words should be uppercase
      for (final word in list) {
        expect(word, equals(word.toUpperCase()));
      }

      // All words should be non-empty
      for (final word in list) {
        expect(word.isNotEmpty, true);
      }
    });
  });

  group('Word List Manager - Performance', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('should get next list quickly', () async {
      final manager = WordListManager();
      await manager.initialize();

      final stopwatch = Stopwatch()..start();
      await manager.getNextWordList();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Getting next list should take less than 100ms');
    });

    test('should regenerate quickly', () async {
      final manager = WordListManager();
      await manager.initialize();

      // Use all 200 lists
      for (int i = 0; i < 200; i++) {
        await manager.getNextWordList();
      }

      final stopwatch = Stopwatch()..start();
      await manager.getNextWordList(); // Trigger regeneration
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: 'Regeneration should take less than 2 seconds');
    });
  });
}
