import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/database.dart';
import '../providers/cycle_day_provider.dart';
import '../providers/database_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Meals', icon: Icon(Icons.restaurant)),
            Tab(text: 'Daily', icon: Icon(Icons.today)),
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_view_week)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MealPlanTab(),
          DailyPlanTab(),
          WeeklyPlanTab(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}

class MealPlanTab extends ConsumerStatefulWidget {
  const MealPlanTab({super.key});

  @override
  ConsumerState<MealPlanTab> createState() => _MealPlanTabState();
}

class _MealPlanTabState extends ConsumerState<MealPlanTab> {
  List<MealPlan> mealPlans = [];
  int currentCycleDay = 1;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
    _loadCurrentCycleDay();
  }

  void _loadMealPlans() async {
    final database = ref.read(databaseProvider);
    try {
      final plans = await (database.select(database.mealPlanTable)
            ..orderBy([
              (t) => OrderingTerm.asc(t.dayNumber),
              (t) => OrderingTerm.asc(t.mealType)
            ]))
          .get();
      setState(() {
        mealPlans = plans;
      });
    } catch (e) {
      debugPrint('Error loading meal plans: $e');
    }
  }

  void _loadCurrentCycleDay() async {
    try {
      // Use centralized cycle day provider
      final cycleDay = await ref.read(cycleDayProvider.future);
      setState(() {
        currentCycleDay = cycleDay;
      });
    } catch (e) {
      debugPrint('Error loading cycle day: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedMeals = <int, List<MealPlan>>{};
    for (final meal in mealPlans) {
      groupedMeals.putIfAbsent(meal.dayNumber, () => []).add(meal);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Day Highlight
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$currentCycleDay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today is Day $currentCycleDay',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Your current meal plan for today',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 10-Day Meal Plan
          Text(
            '10-Day Cozumel Meal Rotation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          if (groupedMeals.isEmpty)
            const CustomCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Loading meal plans...'),
                ),
              ),
            )
          else
            ...List.generate(10, (index) {
              final dayNumber = index + 1;
              final dayMeals = groupedMeals[dayNumber] ?? [];
              final isToday = dayNumber == currentCycleDay;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  child: Container(
                    decoration: isToday ? BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Day $dayNumber',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isToday ? Theme.of(context).primaryColor : null,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'TODAY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editDayMeals(dayNumber, dayMeals),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...dayMeals.map(_buildMealItem),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMealItem(MealPlan meal) {
    IconData icon;
    switch (meal.mealType) {
      case MealType.lunch:
        icon = Icons.lunch_dining;
        break;
      case MealType.snack:
        icon = Icons.local_cafe;
        break;
      case MealType.dinner:
        icon = Icons.dinner_dining;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${meal.mealType.name.toUpperCase()}: ${meal.mealName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (meal.description != null)
                  Text(
                    meal.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editDayMeals(int dayNumber, List<MealPlan> meals) async {
    await showDialog(
      context: context,
      builder: (context) => MealEditDialog(
        dayNumber: dayNumber,
        meals: meals,
        onSave: (updatedMeals) async {
          final database = ref.read(databaseProvider);

          // Update each meal in the database
          for (final meal in updatedMeals) {
            await (database.update(database.mealPlanTable)
                  ..where((t) => t.id.equals(meal.id)))
                .write(MealPlanTableCompanion(
                  mealName: Value(meal.mealName),
                  description: Value(meal.description),
                  updatedAt: Value(DateTime.now()),
                ));
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Meals for Day $dayNumber updated!')),
            );
          }
        },
      ),
    );
  }
}

class MealEditDialog extends StatefulWidget {
  const MealEditDialog({
    super.key,
    required this.dayNumber,
    required this.meals,
    required this.onSave,
  });

  final int dayNumber;
  final List<MealPlan> meals;
  final Function(List<MealPlan>) onSave;

  @override
  State<MealEditDialog> createState() => _MealEditDialogState();
}

class _MealEditDialogState extends State<MealEditDialog> {
  late List<Map<String, TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.meals.map((meal) => {
      'name': TextEditingController(text: meal.mealName),
      'description': TextEditingController(text: meal.description ?? ''),
    }).toList();
  }

  @override
  void dispose() {
    for (final controllerMap in controllers) {
      controllerMap['name']!.dispose();
      controllerMap['description']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Day ${widget.dayNumber} Meals'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.meals.length,
          itemBuilder: (context, index) {
            final meal = widget.meals[index];
            final controller = controllers[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.mealType.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller['name'],
                      decoration: const InputDecoration(
                        labelText: 'Meal Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller['description'],
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedMeals = <MealPlan>[];
            for (int i = 0; i < widget.meals.length; i++) {
              final meal = widget.meals[i];
              final controller = controllers[i];

              updatedMeals.add(MealPlan(
                id: meal.id,
                dayNumber: meal.dayNumber,
                mealType: meal.mealType,
                mealName: controller['name']!.text,
                description: controller['description']!.text.isEmpty
                    ? null
                    : controller['description']!.text,
                isActive: meal.isActive,
                createdAt: meal.createdAt,
                updatedAt: DateTime.now(),
              ));
            }

            widget.onSave(updatedMeals);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class DailyPlanTab extends ConsumerStatefulWidget {
  const DailyPlanTab({super.key});

  @override
  ConsumerState<DailyPlanTab> createState() => _DailyPlanTabState();
}

class _DailyPlanTabState extends ConsumerState<DailyPlanTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<PlanEntry> todayPlans = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDailyPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadDailyPlans() async {
    final database = ref.read(databaseProvider);
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    try {
      final plans = await (database.select(database.planningTable)
            ..where((t) => t.planType.equals(PlanType.daily.name) & t.planDate.equals(date))
            ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      
      setState(() {
        todayPlans = plans;
      });
    } catch (e) {
      debugPrint('Error loading daily plans: $e');
    }
  }

  Future<void> _addPlan() async {
    if (_titleController.text.trim().isEmpty) return;
    
    final database = ref.read(databaseProvider);
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    try {
      await database.into(database.planningTable).insert(
        PlanningTableCompanion.insert(
          planType: PlanType.daily,
          planDate: date,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty 
              ? Value(_descriptionController.text.trim()) 
              : const Value.absent(),
          priority: const Value(3), // Default medium priority
        ),
      );
      
      _titleController.clear();
      _descriptionController.clear();
      _loadDailyPlans();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan added!')),
      );
    } catch (e) {
      debugPrint('Error adding plan: $e');
    }
  }

  Future<void> _togglePlanComplete(PlanEntry plan) async {
    final database = ref.read(databaseProvider);
    
    try {
      await (database.update(database.planningTable)
            ..where((t) => t.id.equals(plan.id)))
          .write(PlanningTableCompanion(
            isCompleted: Value(!plan.isCompleted),
            updatedAt: Value(DateTime.now()),
          ));
      
      _loadDailyPlans();
    } catch (e) {
      debugPrint('Error updating plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatDate(selectedDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                        _loadDailyPlans();
                      }
                    },
                    child: const Text('Change Date'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Add New Plan
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Daily Goal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal/Task',
                      border: OutlineInputBorder(),
                      hintText: 'What do you want to accomplish?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Details (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Additional notes or steps',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addPlan,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Goal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Today's Plans
          Text(
            'Today\'s Goals (${todayPlans.where((p) => p.isCompleted).length}/${todayPlans.length} completed)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          if (todayPlans.isEmpty)
            const CustomCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No goals set for this day'),
                ),
              ),
            )
          else
            ...todayPlans.map((plan) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: CustomCard(
                child: ListTile(
                  leading: Checkbox(
                    value: plan.isCompleted,
                    onChanged: (_) => _togglePlanComplete(plan),
                  ),
                  title: Text(
                    plan.title,
                    style: TextStyle(
                      decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                      color: plan.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: plan.description != null 
                      ? Text(plan.description!) 
                      : null,
                  trailing: plan.priority != null
                      ? _buildPriorityIndicator(plan.priority!)
                      : null,
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    Color color;
    String label;
    switch (priority) {
      case 1:
        color = Colors.red;
        label = 'Low';
        break;
      case 2:
        color = Colors.orange;
        label = 'Med-';
        break;
      case 3:
        color = Colors.blue;
        label = 'Med';
        break;
      case 4:
        color = Colors.green;
        label = 'Med+';
        break;
      case 5:
        color = Colors.purple;
        label = 'High';
        break;
      default:
        color = Colors.grey;
        label = '';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day;
    final isToday = DateTime.now().difference(date).inDays == 0;
    final isTomorrow = DateTime.now().difference(date).inDays == -1;
    final isYesterday = DateTime.now().difference(date).inDays == 1;
    
    if (isToday) return 'Today, ${months[date.month - 1]} $day';
    if (isTomorrow) return 'Tomorrow, ${months[date.month - 1]} $day';
    if (isYesterday) return 'Yesterday, ${months[date.month - 1]} $day';
    
    return '${months[date.month - 1]} $day, ${date.year}';
  }
}

class WeeklyPlanTab extends ConsumerStatefulWidget {
  const WeeklyPlanTab({super.key});

  @override
  ConsumerState<WeeklyPlanTab> createState() => _WeeklyPlanTabState();
}

class _WeeklyPlanTabState extends ConsumerState<WeeklyPlanTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<PlanEntry> weeklyPlans = [];
  DateTime selectedWeek = DateTime.now();
  int selectedPriority = 3;

  @override
  void initState() {
    super.initState();
    _loadWeeklyPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _loadWeeklyPlans() async {
    final database = ref.read(databaseProvider);
    final weekStart = _getWeekStart(selectedWeek);
    final mondayDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    try {
      final plans = await (database.select(database.planningTable)
            ..where((t) => t.planType.equals(PlanType.weekly.name) & t.planDate.equals(mondayDate))
            ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      
      setState(() {
        weeklyPlans = plans;
      });
    } catch (e) {
      debugPrint('Error loading weekly plans: $e');
    }
  }

  Future<void> _addWeeklyPlan() async {
    if (_titleController.text.trim().isEmpty) return;
    
    final database = ref.read(databaseProvider);
    final weekStart = _getWeekStart(selectedWeek);
    final mondayDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    try {
      await database.into(database.planningTable).insert(
        PlanningTableCompanion.insert(
          planType: PlanType.weekly,
          planDate: mondayDate,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty 
              ? Value(_descriptionController.text.trim()) 
              : const Value.absent(),
          priority: Value(selectedPriority),
        ),
      );
      
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        selectedPriority = 3;
      });
      _loadWeeklyPlans();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly goal added!')),
      );
    } catch (e) {
      debugPrint('Error adding weekly plan: $e');
    }
  }

  Future<void> _toggleWeeklyPlanComplete(PlanEntry plan) async {
    final database = ref.read(databaseProvider);
    
    try {
      await (database.update(database.planningTable)
            ..where((t) => t.id.equals(plan.id)))
          .write(PlanningTableCompanion(
            isCompleted: Value(!plan.isCompleted),
            updatedAt: Value(DateTime.now()),
          ));
      
      _loadWeeklyPlans();
    } catch (e) {
      debugPrint('Error updating weekly plan: $e');
    }
  }

  Future<void> _deleteWeeklyPlan(PlanEntry plan) async {
    final database = ref.read(databaseProvider);
    
    try {
      await (database.delete(database.planningTable)
            ..where((t) => t.id.equals(plan.id)))
          .go();
      
      _loadWeeklyPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal deleted')),
      );
    } catch (e) {
      debugPrint('Error deleting weekly plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStart(selectedWeek);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Selector
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_view_week, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week of ${_formatDate(weekStart)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedWeek = selectedWeek.subtract(const Duration(days: 7));
                          });
                          _loadWeeklyPlans();
                        },
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Previous Week'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedWeek = selectedWeek.add(const Duration(days: 7));
                          });
                          _loadWeeklyPlans();
                        },
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Next Week'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Add New Weekly Goal
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Weekly Goal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Goal',
                      border: OutlineInputBorder(),
                      hintText: 'What do you want to accomplish this week?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Action Steps (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'How will you achieve this goal?',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Priority: '),
                      const SizedBox(width: 8),
                      ...List.generate(5, (index) {
                        final priority = index + 1;
                        final isSelected = selectedPriority == priority;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPriority = priority;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? _getPriorityColor(priority) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getPriorityColor(priority)),
                            ),
                            child: Text(
                              _getPriorityLabel(priority),
                              style: TextStyle(
                                color: isSelected ? Colors.white : _getPriorityColor(priority),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addWeeklyPlan,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Weekly Goal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Weekly Goals Summary
          Row(
            children: [
              Text(
                'This Week\'s Goals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${weeklyPlans.where((p) => p.isCompleted).length}/${weeklyPlans.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (weeklyPlans.isEmpty)
            const CustomCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No weekly goals set yet. Add some goals above!'),
                ),
              ),
            )
          else
            ...weeklyPlans.map((plan) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: plan.isCompleted,
                        onChanged: (_) => _toggleWeeklyPlanComplete(plan),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                                      color: plan.isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                ),
                                if (plan.priority != null)
                                  _buildPriorityBadge(plan.priority!),
                              ],
                            ),
                            if (plan.description != null && plan.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                plan.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: plan.isCompleted ? Colors.grey : Colors.grey[700],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  'Added ${_formatDateTime(plan.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteWeeklyPlan(plan);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getPriorityColor(priority).withOpacity(0.3)),
      ),
      child: Text(
        _getPriorityLabel(priority),
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue[300]!;
      case 2:
        return Colors.green[400]!;
      case 3:
        return Colors.orange[400]!;
      case 4:
        return Colors.red[400]!;
      case 5:
        return Colors.purple[400]!;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium-';
      case 3:
        return 'Medium';
      case 4:
        return 'Medium+';
      case 5:
        return 'High';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}