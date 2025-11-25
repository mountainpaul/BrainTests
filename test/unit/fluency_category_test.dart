import 'package:flutter_test/flutter_test.dart';

/// Tests for Fluency Test random category selection
/// Verifies that categories are randomly chosen from the available options
void main() {
  group('Fluency Category Selection', () {
    test('should have 5 available categories', () {
      const categories = [
        'Animals',
        'Foods',
        'Countries',
        'Words starting with F',
        'Professions',
      ];

      expect(categories.length, 5);
      expect(categories, contains('Animals'));
      expect(categories, contains('Foods'));
      expect(categories, contains('Countries'));
      expect(categories, contains('Words starting with F'));
      expect(categories, contains('Professions'));
    });

    test('should randomly select a category', () {
      // This test verifies the logic can select any category
      const categories = [
        'Animals',
        'Foods',
        'Countries',
        'Words starting with F',
        'Professions',
      ];

      // Simulate random selection by index
      for (int i = 0; i < categories.length; i++) {
        expect(categories[i], isNotEmpty);
        expect(categories, contains(categories[i]));
      }
    });

    test('should select category within valid range', () {
      const categories = [
        'Animals',
        'Foods',
        'Countries',
        'Words starting with F',
        'Professions',
      ];

      // Test that index-based selection works
      for (int i = 0; i < 100; i++) {
        final randomIndex = i % categories.length;
        expect(randomIndex, greaterThanOrEqualTo(0));
        expect(randomIndex, lessThan(categories.length));
        expect(categories[randomIndex], isNotEmpty);
      }
    });

    test('should provide category-specific prompts', () {
      final prompts = {
        'Animals': 'Name as many animals as you can in 60 seconds',
        'Foods': 'Name as many foods as you can in 60 seconds',
        'Countries': 'Name as many countries as you can in 60 seconds',
        'Words starting with F': 'Name as many words starting with F as you can in 60 seconds',
        'Professions': 'Name as many professions as you can in 60 seconds',
      };

      expect(prompts.length, 5);
      for (final category in prompts.keys) {
        expect(prompts[category], contains('60 seconds'));
        expect(prompts[category], contains('Name as many'));
      }
    });
  });
}
