import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/user_profile_service.dart';
import '../../data/datasources/database.dart';
import '../providers/cycle_day_provider.dart';
import '../providers/database_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_card.dart';
import 'profile_setup_screen.dart';
import 'sleep_logging_screen.dart';

class TodayDashboardScreen extends ConsumerStatefulWidget {
  const TodayDashboardScreen({super.key});

  @override
  ConsumerState<TodayDashboardScreen> createState() => _TodayDashboardScreenState();
}

class _TodayDashboardScreenState extends ConsumerState<TodayDashboardScreen> {
  final _sleepController = TextEditingController();
  final _weightController = TextEditingController();
  
  int currentCycleDay = 1;
  double currentMood = 3.0;
  bool cycling = false;
  bool resistance = false;
  bool meditation = false;
  bool dive = false;
  bool hike = false;
  bool social = false;
  
  // Meal data
  List<MealPlan> todayMeals = [];
  bool mealsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _loadTodayMeals();
  }

  @override
  void dispose() {
    _sleepController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _loadTodayData() async {
    // Load today's data from database
    final database = ref.read(databaseProvider);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    try {
      // Load cycle day from provider
      final cycleDay = await ref.read(cycleDayProvider.future);

      // Load sleep data from sleepTrackingTable (Garmin data)
      final sleepQuery = database.select(database.sleepTrackingTable)
        ..where((t) => t.sleepDate.equals(todayDate));
      final sleepEntries = await sleepQuery.get();

      if (sleepEntries.isNotEmpty) {
        final sleepEntry = sleepEntries.first;
        setState(() {
          // Convert duration from minutes to hours
          if (sleepEntry.durationMinutes != null) {
            final hours = (sleepEntry.durationMinutes! / 60.0).toStringAsFixed(1);
            _sleepController.text = hours;
          }
        });
      }

      // Load daily tracking data
      final query = database.select(database.dailyTrackingTable)
        ..where((t) => t.entryDate.equals(todayDate));
      final entries = await query.get();

      if (entries.isNotEmpty) {
        final entry = entries.first;
        setState(() {
          currentCycleDay = entry.cycleDay;
          if (entry.weight != null) {
            _weightController.text = entry.weight!.toString();
          }
          if (entry.mood != null) {
            currentMood = entry.mood!.toDouble();
          }
          cycling = entry.cycling;
          resistance = entry.resistance;
          meditation = entry.meditation;
          dive = entry.dive;
          hike = entry.hike;
          social = entry.social;
        });
      } else {
        // Use cycle day from provider
        setState(() {
          currentCycleDay = cycleDay;
        });
      }
    } catch (e) {
      debugPrint('Error loading today data: $e');
    }
  }

  void _loadTodayMeals() async {
    final database = ref.read(databaseProvider);
    
    try {
      setState(() {
        mealsLoading = true;
      });
      
      final query = database.select(database.mealPlanTable)
        ..where((t) => t.dayNumber.equals(currentCycleDay))
        ..orderBy([(t) => drift.OrderingTerm.asc(t.mealType)]);
        
      final meals = await query.get();
      
      setState(() {
        todayMeals = meals;
        mealsLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading today meals: $e');
      setState(() {
        mealsLoading = false;
      });
    }
  }

  Future<void> _saveTodayData() async {
    final database = ref.read(databaseProvider);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    try {
      final sleepHours = double.tryParse(_sleepController.text);
      final weight = double.tryParse(_weightController.text);

      await database.into(database.dailyTrackingTable).insertOnConflictUpdate(
        DailyTrackingTableCompanion.insert(
          entryDate: todayDate,
          cycleDay: currentCycleDay,
          sleepHours: sleepHours != null ? Value(sleepHours) : const Value.absent(),
          weight: weight != null ? Value(weight) : const Value.absent(),
          mood: Value(currentMood.round()),
          cycling: Value(cycling),
          resistance: Value(resistance),
          meditation: Value(meditation),
          dive: Value(dive),
          hike: Value(hike),
          social: Value(social),
          updatedAt: Value(DateTime.now()),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Today\'s data saved!')),
      );
    } catch (e) {
      debugPrint('Error saving today data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today - ${_formatDate(DateTime.now())}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'exports':
                  context.push('/exports');
                  break;
                case 'settings':
                  context.go('/settings');
                  break;
                case 'about':
                  context.push('/about');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'exports',
                child: Text('Exports'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePrompt(),
            _buildTodayCard(),
            const SizedBox(height: 16),
            _buildTodayMealsCard(),
            const SizedBox(height: 16),
            _buildQuickStatsCard(),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildTodayCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$currentCycleDay',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
                        'Day $currentCycleDay of 10',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Cycle Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Activities Grid
            Text(
              'Today\'s Activities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                _buildActivityTile('Sleep', Icons.bedtime, cycling, _showSleepDialog),
                _buildActivityTile('Cycling', Icons.directions_bike, cycling, _showCyclingDialog),
                _buildActivityTile('Resistance', Icons.fitness_center, resistance, _showResistanceDialog),
                _buildActivityTile('Meditation', Icons.self_improvement, meditation, _showMeditationDialog),
                _buildActivityTile('Dive', Icons.water, dive, _showDiveDialog),
                _buildActivityTile('Hike', Icons.hiking, hike, _showHikeDialog),
                _buildActivityTile('Social', Icons.people, social, _showSocialDialog),
                _buildActivityTile('Other', Icons.notes, false, _showOtherDialog),
              ],
            ),

            const SizedBox(height: 16),

            // Simple Weight and Mood row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (lbs)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mood: ${currentMood.round()}/5', style: const TextStyle(fontSize: 12)),
                      Slider(
                        value: currentMood,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _getMoodLabel(currentMood.round()),
                        onChanged: (value) {
                          setState(() => currentMood = value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String label, IconData icon, bool isLogged, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLogged ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLogged ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isLogged ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isLogged ? FontWeight.bold : FontWeight.normal,
                color: isLogged ? Theme.of(context).primaryColor : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods for each activity
  void _showSleepDialog() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SleepLoggingScreen()),
    );
    _loadTodayData();
  }

  void _showCyclingDialog() {
    final avgSpeedController = TextEditingController();
    final maxHRController = TextEditingController();
    final distanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions_bike),
            SizedBox(width: 8),
            Text('Cycling'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: avgSpeedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Avg Speed (mph)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxHRController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Heart Rate (bpm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance (miles)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => cycling = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResistanceDialog() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fitness_center),
            SizedBox(width: 8),
            Text('Resistance Training'),
          ],
        ),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Exercises, sets, reps, weight...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => resistance = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMeditationDialog() {
    final lengthController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.self_improvement),
            SizedBox(width: 8),
            Text('Meditation'),
          ],
        ),
        content: TextField(
          controller: lengthController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Length (minutes)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => meditation = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDiveDialog() {
    final maxDepthController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.water),
            SizedBox(width: 8),
            Text('Diving'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maxDepthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Depth (ft)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => dive = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHikeDialog() {
    final elevGainController = TextEditingController();
    final elevLossController = TextEditingController();
    final distanceController = TextEditingController();
    final startElevController = TextEditingController();
    final maxElevController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hiking),
            SizedBox(width: 8),
            Text('Hiking'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance (miles)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: elevGainController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Elevation Gain (ft)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: elevLossController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Elevation Loss (ft)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: startElevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starting Elevation (ft)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: maxElevController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Elevation (ft)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Time (hours)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => hike = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSocialDialog() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.people),
            SizedBox(width: 8),
            Text('Social Activity'),
          ],
        ),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Who, what, where...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => social = true);
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showOtherDialog() {
    final activityController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notes),
            SizedBox(width: 8),
            Text('Other Activity'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveTodayData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMealsCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Meals (Day $currentCycleDay)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (mealsLoading)
              const Center(child: CircularProgressIndicator())
            else if (todayMeals.isEmpty)
              const Text(
                'No meals found for today. Check meal plan initialization.',
                style: TextStyle(color: Colors.orange),
              )
            else
              ...todayMeals.map((meal) => _buildMealItem(
                _getMealTypeDisplayName(meal.mealType),
                meal.mealName,
                _getMealIcon(meal.mealType),
                meal.description,
              )),
            const SizedBox(height: 8),
            const Text(
              'Feeding Window: 12:00 PM - 8:00 PM',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(String type, String name, IconData icon, String? description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$type: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Sleep', '${_sleepController.text.isEmpty ? '-' : _sleepController.text}h', Icons.bedtime),
                _buildStatItem('Weight', '${_weightController.text.isEmpty ? '-' : _weightController.text}lbs', Icons.scale),
                _buildStatItem('Mood', '${currentMood.round()}/5', Icons.mood),
                _buildStatItem('Activities', '${_getActiveActivitiesCount()}/6', Icons.check_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveTodayData,
        icon: const Icon(Icons.save),
        label: const Text('Save Today\'s Data'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1: return 'Poor';
      case 2: return 'Low';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Unknown';
    }
  }

  int _getActiveActivitiesCount() {
    int count = 0;
    if (cycling) count++;
    if (resistance) count++;
    if (meditation) count++;
    if (dive) count++;
    if (hike) count++;
    if (social) count++;
    return count;
  }

  String _getMealTypeDisplayName(MealType mealType) {
    switch (mealType) {
      case MealType.lunch:
        return 'Lunch';
      case MealType.snack:
        return 'Snack';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  IconData _getMealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.snack:
        return Icons.local_cafe;
      case MealType.dinner:
        return Icons.dinner_dining;
    }
  }

  Widget _buildProfilePrompt() {
    return FutureBuilder<int?>(
      future: UserProfileService.getUserAge(),
      builder: (context, snapshot) {
        // Debug logging
        debugPrint('ProfilePrompt - ConnectionState: ${snapshot.connectionState}');
        debugPrint('ProfilePrompt - Age data: ${snapshot.data}');
        debugPrint('ProfilePrompt - Has error: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('ProfilePrompt - Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.data == null) {
          debugPrint('ProfilePrompt - Showing prompt because age is null');
          return Column(
            children: [
              CustomCard(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                      );
                      if (result == true && mounted) {
                        setState(() {}); // Refresh to hide the prompt
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Set up your profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get age-adjusted feedback and optimized exercises',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        debugPrint('ProfilePrompt - NOT showing prompt because age is: ${snapshot.data}');
        return const SizedBox.shrink();
      },
    );
  }
}