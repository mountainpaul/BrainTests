import 'package:brain_tests/core/services/word_dictionary_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/presentation/providers/database_provider.dart';
import 'package:brain_tests/presentation/screens/exercise_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

/// Test to verify the UI properly handles databases with fewer than 5 words
///
/// This test ensures the fixes prevent crashes when navigating through exercises
/// when the database has insufficient words.
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
  });

  tearDown(() async {
    await closeTestDatabase(database);
  });

  testWidgets('Exercise screen should handle database with only 2 anagram words', (WidgetTester tester) async {
    // Setup: Insert only 2 words for easy difficulty
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'CAT',
        language: WordLanguage.english,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.easy,
        length: 3,
      ),
    );
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'DOG',
        language: WordLanguage.english,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.easy,
        length: 3,
      ),
    );

    // Build the widget with provider override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ExerciseTestScreen(
              exerciseType: ExerciseType.wordPuzzle,
              difficulty: ExerciseDifficulty.easy,
            ),
          ),
        ),
      ),
    );

    // Wait for loading to complete
    await tester.pumpAndSettle();

    // Verify the widget loaded without crashing
    expect(find.byType(ExerciseTestScreen), findsOneWidget);

    // Verify progress indicator shows "/ 2" instead of "/ 5"
    expect(find.textContaining('/ 2'), findsOneWidget);
    expect(find.textContaining('/ 5'), findsNothing);
  });

  testWidgets('Exercise screen should handle database with only 1 anagram word', (WidgetTester tester) async {
    // Setup: Insert only 1 word for medium difficulty
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'HOUSE',
        language: WordLanguage.english,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.medium,
        length: 5,
      ),
    );

    // Build the widget with provider override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ExerciseTestScreen(
              exerciseType: ExerciseType.wordPuzzle,
              difficulty: ExerciseDifficulty.medium,
            ),
          ),
        ),
      ),
    );

    // Wait for loading to complete
    await tester.pumpAndSettle();

    // Verify the widget loaded without crashing
    expect(find.byType(ExerciseTestScreen), findsOneWidget);

    // Verify progress indicator shows "/ 1" instead of "/ 5"
    expect(find.textContaining('/ 1'), findsOneWidget);
    expect(find.textContaining('/ 5'), findsNothing);
  });

  testWidgets('Spanish anagram should handle database with only 2 words', (WidgetTester tester) async {
    // Setup: Insert only 2 Spanish words for easy difficulty
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'CASA',
        language: WordLanguage.spanish,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.easy,
        length: 4,
      ),
    );
    await database.into(database.wordDictionaryTable).insert(
      WordDictionaryTableCompanion.insert(
        word: 'GATO',
        language: WordLanguage.spanish,
        type: WordType.anagram,
        difficulty: ExerciseDifficulty.easy,
        length: 4,
      ),
    );

    // Build the widget with provider override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ExerciseTestScreen(
              exerciseType: ExerciseType.spanishAnagram,
              difficulty: ExerciseDifficulty.easy,
            ),
          ),
        ),
      ),
    );

    // Wait for loading to complete
    await tester.pumpAndSettle();

    // Verify the widget loaded without crashing
    expect(find.byType(ExerciseTestScreen), findsOneWidget);

    // Verify progress indicator shows "/ 2" instead of "/ 5" (in Spanish)
    expect(find.textContaining('/ 2'), findsOneWidget);
    expect(find.textContaining('/ 5'), findsNothing);
  });
}
