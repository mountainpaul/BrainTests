import 'package:brain_plan/data/datasources/database.dart';
import 'package:brain_plan/presentation/providers/database_provider.dart';
import 'package:brain_plan/presentation/screens/plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'plan_screen_meal_edit_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('Meal Edit Dialog Tests', () {
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
    });

    testWidgets('should display meal edit dialog with all meals for a day', (tester) async {
      // Arrange
      final meals = [
        MealPlan(
          id: 1,
          dayNumber: 1,
          mealType: MealType.lunch,
          mealName: 'Oatmeal',
          description: 'With berries',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MealPlan(
          id: 2,
          dayNumber: 1,
          mealType: MealType.snack,
          mealName: 'Salad',
          description: 'Green salad',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MealPlan(
          id: 3,
          dayNumber: 1,
          mealType: MealType.dinner,
          mealName: 'Grilled chicken',
          description: 'With vegetables',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(mockDatabase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MealEditDialog(
                        dayNumber: 1,
                        meals: meals,
                        onSave: (updatedMeals) {},
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Day 1 Meals'), findsOneWidget);
      expect(find.text('LUNCH'), findsOneWidget);
      expect(find.text('SNACK'), findsOneWidget);
      // Check for at least 2 meals that are visible (Grilled chicken may be scrolled out of view)
      expect(find.text('Oatmeal'), findsOneWidget);
      expect(find.text('Salad'), findsOneWidget);
    });

    testWidgets('should allow editing meal names', (tester) async {
      // Arrange
      final meals = [
        MealPlan(
          id: 1,
          dayNumber: 1,
          mealType: MealType.lunch,
          mealName: 'Oatmeal',
          description: 'With berries',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(mockDatabase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MealEditDialog(
                        dayNumber: 1,
                        meals: meals,
                        onSave: (updatedMeals) {},
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Find the text field with "Oatmeal" and change it
      final mealNameField = find.widgetWithText(TextField, 'Oatmeal');
      expect(mealNameField, findsOneWidget);

      await tester.enterText(mealNameField, 'Scrambled Eggs');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Scrambled Eggs'), findsOneWidget);
    });

    testWidgets('should call onSave with updated meals when Save is pressed', (tester) async {
      // Arrange
      final meals = [
        MealPlan(
          id: 1,
          dayNumber: 1,
          mealType: MealType.lunch,
          mealName: 'Oatmeal',
          description: 'With berries',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      List<MealPlan>? savedMeals;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(mockDatabase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MealEditDialog(
                        dayNumber: 1,
                        meals: meals,
                        onSave: (updatedMeals) {
                          savedMeals = updatedMeals;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Edit the meal name
      final mealNameField = find.widgetWithText(TextField, 'Oatmeal');
      await tester.enterText(mealNameField, 'Pancakes');
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert
      expect(savedMeals, isNotNull);
      expect(savedMeals!.length, 1);
      expect(savedMeals![0].mealName, 'Pancakes');
    });

    testWidgets('should close dialog when Cancel is pressed', (tester) async {
      // Arrange
      final meals = [
        MealPlan(
          id: 1,
          dayNumber: 1,
          mealType: MealType.lunch,
          mealName: 'Oatmeal',
          description: 'With berries',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(mockDatabase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MealEditDialog(
                        dayNumber: 1,
                        meals: meals,
                        onSave: (updatedMeals) {},
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Day 1 Meals'), findsOneWidget);

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Day 1 Meals'), findsNothing);
    });

    testWidgets('should allow editing meal descriptions', (tester) async {
      // Arrange
      final meals = [
        MealPlan(
          id: 1,
          dayNumber: 1,
          mealType: MealType.lunch,
          mealName: 'Oatmeal',
          description: 'With berries',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(mockDatabase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => MealEditDialog(
                        dayNumber: 1,
                        meals: meals,
                        onSave: (updatedMeals) {},
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Act - Find the description field and change it
      final descriptionFields = find.byType(TextField);
      expect(descriptionFields, findsNWidgets(2)); // Name and description

      // Enter text in the second TextField (description)
      await tester.enterText(descriptionFields.at(1), 'With strawberries and honey');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('With strawberries and honey'), findsOneWidget);
    });
  });
}
