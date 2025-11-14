import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/domain/entities/cognitive_exercise.dart';
import 'package:brain_plan/presentation/providers/cognitive_exercise_provider.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/screens/cognition_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration test to verify exercises are saved and displayed correctly
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  group('Exercise Completion Workflow', () {
    testWidgets('Memory Game should save to database via provider', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Text('Test')),
          ),
        ),
      );

      // Get the container to access providers
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );

      // Act - Add exercise via provider (simulating completion)
      final notifier = container.read(cognitiveExerciseProvider.notifier);
      final exercise = CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await notifier.addExercise(exercise);

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert - Verify exercise was saved to database
      final exercises = await database.select(database.cognitiveExerciseTable).get();

      expect(exercises.length, equals(1), reason: 'Exercise should be saved to database');
      expect(exercises.first.name, equals('Memory Game'));
      expect(exercises.first.type, equals(ExerciseType.memoryGame));
      expect(exercises.first.difficulty, equals(ExerciseDifficulty.medium));
      expect(exercises.first.score, equals(85));
    });

    testWidgets('Completed exercise should appear in Recent Activity', (tester) async {
      // Arrange - Add exercise to database
      await database.into(database.cognitiveExerciseTable).insert(
        CognitiveExerciseTableCompanion.insert(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 100,
          score: const Value(85),
          timeSpentSeconds: const Value(120),
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );

      // Act - Build cognition screen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Overview tab
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Assert - Recent Activity should show the exercise
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.textContaining('Memory Game'), findsOneWidget);
      expect(find.textContaining('85'), findsOneWidget);
    });

    testWidgets('Completed exercise should count in daily brain games goal', (tester) async {
      // Arrange - Add exercise completed today
      final now = DateTime.now();
      await database.into(database.cognitiveExerciseTable).insert(
        CognitiveExerciseTableCompanion.insert(
          name: 'Memory Game',
          type: ExerciseType.memoryGame,
          difficulty: ExerciseDifficulty.medium,
          maxScore: 100,
          score: const Value(85),
          completedAt: Value(now),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Assert - Should show 1/5 for daily games goal
      expect(find.text('Weekly Goals'), findsOneWidget);
      expect(find.textContaining('Play 5 brain games'), findsOneWidget);
      expect(find.text('1/5'), findsOneWidget);
    });

    testWidgets('Provider invalidation should refresh UI after exercise added', (tester) async {
      // Arrange - Start with empty database
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            home: CognitionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();

      // Verify starts at 0/5
      expect(find.text('0/5'), findsAtLeastNWidgets(1));

      // Act - Add exercise via provider
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CognitionScreen)),
      );
      final notifier = container.read(cognitiveExerciseProvider.notifier);

      await notifier.addExercise(CognitiveExercise(
        name: 'Memory Game',
        type: ExerciseType.memoryGame,
        difficulty: ExerciseDifficulty.medium,
        score: 85,
        maxScore: 100,
        timeSpentSeconds: 120,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      // Wait for provider invalidation and rebuild
      await tester.pumpAndSettle();

      // Assert - Should now show 1/5
      expect(find.text('1/5'), findsOneWidget, reason: 'Daily games count should update to 1/5 after adding exercise');
    });
  });
}
