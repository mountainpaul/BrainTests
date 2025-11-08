import 'package:drift/drift.dart';
import '../../data/datasources/database.dart';

class MealPlanService {
  static const List<Map<String, dynamic>> cozumelMealPlans = [
    // Core ingredients: Chicken, White fish (tilapia/cod), Black beans, Rice, Avocados, 
    // Bell peppers, Onions, Limes, Tortillas, Mixed greens, Eggs, Greek yogurt, Almonds

    // Day 1 - Chicken focus
    {'dayNumber': 1, 'mealType': MealType.lunch, 'mealName': 'Chicken & Rice Bowl', 'description': 'Seasoned chicken breast with cilantro lime rice and black beans'},
    {'dayNumber': 1, 'mealType': MealType.snack, 'mealName': 'Greek Yogurt & Almonds', 'description': 'Plain Greek yogurt with sliced almonds'},
    {'dayNumber': 1, 'mealType': MealType.dinner, 'mealName': 'Chicken Fajita Salad', 'description': 'Grilled chicken strips with peppers, onions over mixed greens'},

    // Day 2 - Fish focus  
    {'dayNumber': 2, 'mealType': MealType.lunch, 'mealName': 'Fish Tacos', 'description': 'Seasoned white fish with cabbage slaw in corn tortillas'},
    {'dayNumber': 2, 'mealType': MealType.snack, 'mealName': 'Avocado & Lime', 'description': 'Half avocado with lime juice and sea salt'},
    {'dayNumber': 2, 'mealType': MealType.dinner, 'mealName': 'Baked Fish & Vegetables', 'description': 'Baked white fish with roasted bell peppers and onions'},

    // Day 3 - Eggs/Chicken focus
    {'dayNumber': 3, 'mealType': MealType.lunch, 'mealName': 'Chicken Salad Wraps', 'description': 'Shredded chicken salad in whole wheat tortillas'},
    {'dayNumber': 3, 'mealType': MealType.snack, 'mealName': 'Hard Boiled Eggs', 'description': 'Two hard boiled eggs with lime and pepper'},
    {'dayNumber': 3, 'mealType': MealType.dinner, 'mealName': 'Veggie Scramble', 'description': 'Scrambled eggs with peppers, onions, and black beans'},

    // Day 4 - Bean/Rice focus
    {'dayNumber': 4, 'mealType': MealType.lunch, 'mealName': 'Black Bean Rice Bowl', 'description': 'Seasoned black beans over rice with diced avocado'},
    {'dayNumber': 4, 'mealType': MealType.snack, 'mealName': 'Greek Yogurt Bowl', 'description': 'Greek yogurt with diced bell peppers and lime'},
    {'dayNumber': 4, 'mealType': MealType.dinner, 'mealName': 'Chicken & Bean Stew', 'description': 'Slow-cooked chicken with black beans and vegetables'},

    // Day 5 - Fish focus
    {'dayNumber': 5, 'mealType': MealType.lunch, 'mealName': 'Fish & Rice', 'description': 'Pan-seared fish over cilantro lime rice'},
    {'dayNumber': 5, 'mealType': MealType.snack, 'mealName': 'Almond Avocado', 'description': 'Sliced avocado topped with crushed almonds'},
    {'dayNumber': 5, 'mealType': MealType.dinner, 'mealName': 'Fish Ceviche Salad', 'description': 'Cold fish ceviche over mixed greens with avocado'},

    // Day 6 - Chicken focus
    {'dayNumber': 6, 'mealType': MealType.lunch, 'mealName': 'Chicken Quesadillas', 'description': 'Grilled chicken and cheese in whole wheat tortillas'},
    {'dayNumber': 6, 'mealType': MealType.snack, 'mealName': 'Egg Salad', 'description': 'Hard boiled egg salad with Greek yogurt dressing'},
    {'dayNumber': 6, 'mealType': MealType.dinner, 'mealName': 'Chicken Vegetable Stir-fry', 'description': 'Chicken strips with peppers and onions over rice'},

    // Day 7 - Leftover combinations
    {'dayNumber': 7, 'mealType': MealType.lunch, 'mealName': 'Loaded Bean Salad', 'description': 'Black beans, rice, avocado, and peppers over greens'},
    {'dayNumber': 7, 'mealType': MealType.snack, 'mealName': 'Greek Yogurt Parfait', 'description': 'Greek yogurt layered with crushed almonds'},
    {'dayNumber': 7, 'mealType': MealType.dinner, 'mealName': 'Fish & Bean Bowl', 'description': 'Leftover fish with black beans and rice'},

    // Day 8 - Egg focus
    {'dayNumber': 8, 'mealType': MealType.lunch, 'mealName': 'Veggie Omelet', 'description': 'Eggs with peppers, onions, and cheese'},
    {'dayNumber': 8, 'mealType': MealType.snack, 'mealName': 'Avocado Yogurt', 'description': 'Greek yogurt mixed with mashed avocado and lime'},
    {'dayNumber': 8, 'mealType': MealType.dinner, 'mealName': 'Chicken Rice Skillet', 'description': 'One-pan chicken, rice, beans, and vegetables'},

    // Day 9 - Fish focus
    {'dayNumber': 9, 'mealType': MealType.lunch, 'mealName': 'Fish Salad Bowl', 'description': 'Cold fish salad over mixed greens with avocado'},
    {'dayNumber': 9, 'mealType': MealType.snack, 'mealName': 'Almond Rice Cakes', 'description': 'Rice cakes topped with almond butter'},
    {'dayNumber': 9, 'mealType': MealType.dinner, 'mealName': 'Fish & Vegetable Packets', 'description': 'Baked fish with peppers and onions in foil packets'},

    // Day 10 - Mix of remaining ingredients
    {'dayNumber': 10, 'mealType': MealType.lunch, 'mealName': 'Chicken Bean Burrito Bowl', 'description': 'Chicken, beans, rice, peppers, and avocado in a bowl'},
    {'dayNumber': 10, 'mealType': MealType.snack, 'mealName': 'Egg & Avocado', 'description': 'Hard boiled egg with sliced avocado and lime'},
    {'dayNumber': 10, 'mealType': MealType.dinner, 'mealName': 'Everything Skillet', 'description': 'Mixed skillet with remaining chicken, fish, vegetables, and rice'},
  ];

  static Future<void> initializeDefaultMealPlans(AppDatabase database) async {
    // Check if meal plans already exist
    final existingPlans = await database.select(database.mealPlanTable).get();
    
    // Clear existing meal plans and insert updated ones
    if (existingPlans.isNotEmpty) {
      await database.delete(database.mealPlanTable).go();
      print('Cleared existing meal plans, inserting updated grocery-smart meal plans...');
    }

    // Insert default Cozumel meal plans
    for (final meal in cozumelMealPlans) {
      await database.into(database.mealPlanTable).insert(MealPlanTableCompanion.insert(
        dayNumber: meal['dayNumber'] as int,
        mealType: meal['mealType'] as MealType,
        mealName: meal['mealName'] as String,
        description: Value(meal['description'] as String?),
      ));
    }
    print('Meal plans initialized with ${cozumelMealPlans.length} meals');
  }

  static Future<void> initializeDefaultFeedingWindow(AppDatabase database) async {
    // Check if feeding window already exists
    final existingWindows = await database.select(database.feedingWindowTable).get();
    if (existingWindows.isNotEmpty) return;

    // Insert default 12pm-8pm feeding window (16:8 intermittent fasting)
    await database.into(database.feedingWindowTable).insert(FeedingWindowTableCompanion.insert(
      startHour: 12,
      startMinute: 0,
      endHour: 20,
      endMinute: 0,
    ));
  }
}