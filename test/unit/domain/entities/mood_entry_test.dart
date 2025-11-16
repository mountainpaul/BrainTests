import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/mood_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoodEntry Entity Tests', () {
    test('should calculate overall wellness correctly for excellent mood', () {
      // Arrange
      final moodEntry = MoodEntry(
        mood: MoodLevel.excellent,
        energyLevel: 8,
        stressLevel: 2,
        sleepQuality: 9,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      // Excellent mood = 10, energy = 8, adjusted stress = 9, sleep = 9
      // (10 + 8 + 9 + 9) / 4 = 9.0
      expect(moodEntry.overallWellness, 9.0);
    });

    test('should calculate overall wellness correctly for low mood', () {
      // Arrange
      final moodEntry = MoodEntry(
        mood: MoodLevel.low,
        energyLevel: 3,
        stressLevel: 8,
        sleepQuality: 4,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      // Low mood = 4, energy = 3, adjusted stress = 3, sleep = 4
      // (4 + 3 + 3 + 4) / 4 = 3.5
      expect(moodEntry.overallWellness, 3.5);
    });

    test('should calculate overall wellness correctly for neutral mood', () {
      // Arrange
      final moodEntry = MoodEntry(
        mood: MoodLevel.neutral,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 6,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      // Neutral mood = 6, energy = 5, adjusted stress = 6, sleep = 6
      // (6 + 5 + 6 + 6) / 4 = 5.75
      expect(moodEntry.overallWellness, 5.75);
    });

    test('should handle mood level mapping correctly', () {
      // Arrange & Act & Assert
      final veryLowEntry = MoodEntry(
        mood: MoodLevel.veryLow,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 5,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      final lowEntry = MoodEntry(
        mood: MoodLevel.low,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 5,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      final goodEntry = MoodEntry(
        mood: MoodLevel.good,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 5,
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // VeryLow = 2, Low = 4, Good = 8
      expect(veryLowEntry.overallWellness, lessThan(lowEntry.overallWellness));
      expect(lowEntry.overallWellness, lessThan(goodEntry.overallWellness));
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalEntry = MoodEntry(
        id: 1,
        mood: MoodLevel.neutral,
        energyLevel: 5,
        stressLevel: 5,
        sleepQuality: 5,
        notes: 'Original notes',
        entryDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act
      final updatedEntry = originalEntry.copyWith(
        mood: MoodLevel.good,
        energyLevel: 7,
        notes: 'Updated notes',
      );

      // Assert
      expect(updatedEntry.id, 1);
      expect(updatedEntry.mood, MoodLevel.good);
      expect(updatedEntry.energyLevel, 7);
      expect(updatedEntry.stressLevel, 5); // unchanged
      expect(updatedEntry.notes, 'Updated notes');
    });

    test('should maintain equality with same properties', () {
      // Arrange
      final dateTime = DateTime.now();
      final entry1 = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 7,
        stressLevel: 3,
        sleepQuality: 8,
        entryDate: dateTime,
        createdAt: dateTime,
      );
      
      final entry2 = MoodEntry(
        id: 1,
        mood: MoodLevel.good,
        energyLevel: 7,
        stressLevel: 3,
        sleepQuality: 8,
        entryDate: dateTime,
        createdAt: dateTime,
      );

      // Assert
      expect(entry1, equals(entry2));
    });
  });
}