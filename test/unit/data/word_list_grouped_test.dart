import 'package:brain_tests/data/word_lists/word_list_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for pre-grouped word lists with semantic categories
/// Added on 2024-11-24
///
/// Each list contains exactly one word from each semantic category:
/// - Food
/// - Profession
/// - Abstract concept
/// - Object
/// - Animal
void main() {
  group('Pre-grouped Word Lists', () {
    test('should have exactly 200 pre-grouped lists', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      expect(lists.length, 200);
    });

    test('each list should have exactly 5 words', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      for (final list in lists) {
        expect(list.length, 5);
      }
    });

    test('first list should match expected categories', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // List 1: lemon, captain, mercy, ladder, rabbit
      final firstList = lists[0];
      expect(firstList, containsAll(['LEMON', 'CAPTAIN', 'MERCY', 'LADDER', 'RABBIT']));
    });

    test('second list should match expected categories', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // List 2: kettle, banker, freedom, tulip, camel
      final secondList = lists[1];
      expect(secondList, containsAll(['KETTLE', 'BANKER', 'FREEDOM', 'TULIP', 'CAMEL']));
    });

    test('last list (200) should match expected categories', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // List 200: provolone, editor, virtue, clip, gerbil
      final lastList = lists[199];
      expect(lastList, containsAll(['PROVOLONE', 'EDITOR', 'VIRTUE', 'CLIP', 'GERBIL']));
    });

    test('should not have duplicate words within a single list', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      for (int i = 0; i < lists.length; i++) {
        final list = lists[i];
        final uniqueWords = list.toSet();
        expect(uniqueWords.length, list.length,
            reason: 'List ${i + 1} should not contain duplicate words: $list');
      }
    });

    test('all words should be uppercase', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      for (final list in lists) {
        for (final word in list) {
          expect(word, equals(word.toUpperCase()));
        }
      }
    });

    test('all words should be non-empty', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      for (final list in lists) {
        for (final word in list) {
          expect(word.isNotEmpty, true);
        }
      }
    });

    test('lists should maintain semantic diversity', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // Spot check a few lists to ensure they have diverse word types
      // List 10: plum, guard, kindness, wallet, ferret
      final list10 = lists[9];
      expect(list10, containsAll(['PLUM', 'GUARD', 'KINDNESS', 'WALLET', 'FERRET']));

      // List 50: cherry, painter, wit, thermometer, lion
      final list50 = lists[49];
      expect(list50, containsAll(['CHERRY', 'PAINTER', 'WIT', 'THERMOMETER', 'LION']));

      // List 101: bagel, policeman, desire, marker, chimpanzee
      final list101 = lists[100];
      expect(list101, containsAll(['BAGEL', 'POLICEMAN', 'DESIRE', 'MARKER', 'CHIMPANZEE']));
    });

    test('should shuffle words within each list', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // List 1 originally: LEMON (Food), CAPTAIN (Profession), MERCY (Abstract), LADDER (Object), RABBIT (Animal)
      // After shuffling, should contain same words but in different order
      final list1 = lists[0];
      expect(list1.toSet(), containsAll(['LEMON', 'CAPTAIN', 'MERCY', 'LADDER', 'RABBIT']));

      // The order should be different from the original
      // (This test might rarely fail due to random chance of same order, but very unlikely with seed)
      final originalOrder = ['LEMON', 'CAPTAIN', 'MERCY', 'LADDER', 'RABBIT'];
      expect(list1.toString(), isNot(originalOrder.toString()),
          reason: 'Words should be shuffled within the list');
    });

    test('should preserve list order when using same seed', () {
      final generator1 = WordListGenerator(seed: 12345);
      final generator2 = WordListGenerator(seed: 12345);

      final lists1 = generator1.generateInitialLists();
      final lists2 = generator2.generateInitialLists();

      for (int i = 0; i < lists1.length; i++) {
        expect(lists1[i], lists2[i],
            reason: 'Same seed should produce identical lists at index $i');
      }
    });

    test('usage tracking should work with pre-grouped lists', () {
      final generator = WordListGenerator(seed: 12345);
      generator.generateInitialLists();

      expect(generator.usedListIndices.length, 0);
      expect(generator.hasUnusedLists(), true);

      generator.markListAsUsed(0);
      generator.markListAsUsed(1);

      expect(generator.usedListIndices.length, 2);
      expect(generator.hasUnusedLists(), true);
    });

    test('regeneration should produce different order with different seed', () {
      final generator = WordListGenerator(seed: 12345);
      final originalLists = generator.generateInitialLists();

      // Mark all as used
      for (int i = 0; i < 200; i++) {
        generator.markListAsUsed(i);
      }

      // Regenerate
      final newLists = generator.regenerateLists();

      // At least some lists should be in different positions
      int differentPositions = 0;
      for (int i = 0; i < 200; i++) {
        if (originalLists[i].toString() != newLists[i].toString()) {
          differentPositions++;
        }
      }

      expect(differentPositions, greaterThan(150),
          reason: 'Regeneration should shuffle list order');
    });
  });

  group('Semantic Category Distribution', () {
    test('should have good variety of word lengths across all lists', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // Collect all word lengths
      final allLengths = <int>[];
      for (final list in lists) {
        for (final word in list) {
          allLengths.add(word.length);
        }
      }

      // Should have variety of lengths (3-12+ characters)
      final uniqueLengths = allLengths.toSet();
      expect(uniqueLengths.length, greaterThan(5),
          reason: 'Should have diverse word lengths across all lists');
    });

    test('each list should have varied word lengths', () {
      final generator = WordListGenerator(seed: 12345);
      final lists = generator.generateInitialLists();

      // At least 75% of lists should have 3+ different word lengths
      int listsWithVariety = 0;
      for (final list in lists) {
        final lengths = list.map((w) => w.length).toSet();
        if (lengths.length >= 3) {
          listsWithVariety++;
        }
      }

      expect(listsWithVariety / lists.length, greaterThan(0.75),
          reason: 'Most lists should have varied word lengths');
    });
  });
}
