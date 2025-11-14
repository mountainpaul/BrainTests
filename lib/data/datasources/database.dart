import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
// Encryption temporarily disabled due to library conflicts
// import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/services/encryption_key_manager.dart';

part 'database.g.dart';

enum AssessmentType {
  memoryRecall,
  attentionFocus,
  executiveFunction,
  languageSkills,
  visuospatialSkills,
  processingSpeed
}

enum ReminderType {
  medication,
  exercise,
  assessment,
  appointment,
  custom
}

enum ReminderFrequency {
  once,
  daily,
  weekly,
  monthly
}

enum ExerciseType {
  memoryGame,
  wordPuzzle,
  wordSearch,
  spanishAnagram,
  mathProblem,
  patternRecognition,
  sequenceRecall,
  spatialAwareness
}

enum WordLanguage {
  english,
  spanish
}

enum WordType {
  anagram,
  wordSearch,
  validationOnly  // For validating user answers without using in puzzle generation
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
  expert
}

enum MoodLevel {
  veryLow,
  low,
  neutral,
  good,
  excellent
}

enum ActivityType {
  cycling,
  resistance,
  meditation,
  dive,
  hike,
  social,
  yoga
}

enum MealType {
  lunch,
  snack,
  dinner
}

enum FastType {
  intermittent16_8,
  extended30Hour
}

enum SupplementTiming {
  morning,
  afternoon,
  evening,
  beforeBed
}

enum PlanType {
  daily,
  weekly
}

enum JournalType {
  daily,
  weekly
}

enum SleepQuality {
  poor,
  fair,
  good,
  excellent
}

enum RestlessnessLevel {
  poor,
  fair,
  good,
  excellent
}

enum CambridgeTestType {
  pal,  // Paired Associates Learning - visual episodic memory
  prm,  // Pattern Recognition Memory
  swm,  // Spatial Working Memory
  rvp,  // Rapid Visual Processing - sustained attention
  rti,  // Reaction Time
  ots,  // One Touch Stockings of Cambridge - spatial planning
}

@DataClassName('AssessmentEntry')
class AssessmentTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<AssessmentType>()();
  IntColumn get score => integer()();
  IntColumn get maxScore => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'assessments';
}

@DataClassName('ReminderEntry')
class ReminderTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => textEnum<ReminderType>()();
  TextColumn get frequency => textEnum<ReminderFrequency>()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get nextScheduled => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'reminders';
}

@DataClassName('CognitiveExerciseEntry')
class CognitiveExerciseTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<ExerciseType>()();
  TextColumn get difficulty => textEnum<ExerciseDifficulty>()();
  IntColumn get score => integer().nullable()();
  IntColumn get maxScore => integer()();
  IntColumn get timeSpentSeconds => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get exerciseData => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'cognitive_exercises';
}

// Daily tracking entry - the main "Today" card data
@DataClassName('DailyEntry')
class DailyTrackingTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get entryDate => dateTime()(); // The day this entry is for
  IntColumn get cycleDay => integer()(); // 1-10 cycle day
  RealColumn get sleepHours => real().nullable()(); // Sleep hours
  RealColumn get weight => real().nullable()(); // Weight in lbs
  IntColumn get mood => integer().nullable()(); // 1-5 scale
  BoolColumn get cycling => boolean().withDefault(const Constant(false))();
  BoolColumn get resistance => boolean().withDefault(const Constant(false))();
  BoolColumn get meditation => boolean().withDefault(const Constant(false))();
  BoolColumn get dive => boolean().withDefault(const Constant(false))();
  BoolColumn get hike => boolean().withDefault(const Constant(false))();
  BoolColumn get social => boolean().withDefault(const Constant(false))();
  BoolColumn get yoga => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'daily_tracking';
}

// 10-day meal plan
@DataClassName('MealPlan')
class MealPlanTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dayNumber => integer()(); // 1-10
  TextColumn get mealType => textEnum<MealType>()();
  TextColumn get mealName => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'meal_plans';
}

// Feeding window settings
@DataClassName('FeedingWindow')
class FeedingWindowTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startHour => integer()(); // 0-23
  IntColumn get startMinute => integer()(); // 0-59
  IntColumn get endHour => integer()(); // 0-23
  IntColumn get endMinute => integer()(); // 0-59
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'feeding_windows';
}

// Fasting logs
@DataClassName('FastingEntry')
class FastingTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fastType => textEnum<FastType>()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationHours => integer().nullable()(); // Calculated duration
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'fasting_entries';
}

// Supplements tracking
@DataClassName('Supplement')
class SupplementsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get timing => textEnum<SupplementTiming>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'supplements';
}

// Daily supplement completion tracking
@DataClassName('SupplementLog')
class SupplementLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get supplementId => integer().references(SupplementsTable, #id)();
  DateTimeColumn get logDate => dateTime()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();
  DateTimeColumn get takenAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'supplement_logs';
}

// Planning entries (daily and weekly)
@DataClassName('PlanEntry')
class PlanningTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planType => textEnum<PlanType>()();
  DateTimeColumn get planDate => dateTime()(); // For daily plans, the specific date; for weekly, the Monday of that week
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().nullable()(); // 1-5 scale
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'planning';
}

// Journal entries (daily and weekly)
@DataClassName('JournalEntry')
class JournalTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get journalType => textEnum<JournalType>()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get reflections => text().nullable()();
  TextColumn get gratitude => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get wins => text().nullable()(); // For weekly entries
  TextColumn get lessons => text().nullable()(); // For weekly entries
  TextColumn get nextWeekPlan => text().nullable()(); // For weekly entries
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'journal';
}

@DataClassName('MoodEntryData')
class MoodEntryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mood => textEnum<MoodLevel>()();
  IntColumn get energyLevel => integer()(); // 1-10 scale
  IntColumn get stressLevel => integer()(); // 1-10 scale
  IntColumn get sleepQuality => integer()(); // 1-10 scale
  TextColumn get notes => text().nullable()();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'mood_entries';
}

@DataClassName('SleepEntry')
class SleepTrackingTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get sleepDate => dateTime()(); // The date of this sleep entry
  IntColumn get score => integer().nullable()(); // 0-100 sleep score
  TextColumn get quality => textEnum<SleepQuality>().nullable()(); // Poor, Fair, Good, Excellent
  IntColumn get durationMinutes => integer().nullable()(); // Total sleep duration in minutes
  IntColumn get stress => integer().nullable()(); // 0-100 stress level
  IntColumn get deepSleepMinutes => integer().nullable()(); // Deep sleep duration in minutes
  IntColumn get lightSleepMinutes => integer().nullable()(); // Light sleep duration in minutes
  IntColumn get remSleepMinutes => integer().nullable()(); // REM sleep duration in minutes
  TextColumn get restlessness => textEnum<RestlessnessLevel>().nullable()(); // Awake/Restlessness level
  TextColumn get notes => text().nullable()(); // Additional notes
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  String get tableName => 'sleep_tracking';
}

// Garmin Cycling Tracking Table
@DataClassName('CyclingTrackingEntry')
class CyclingTrackingTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get rideDate => dateTime()(); // The date of this cycling session
  RealColumn get distanceKm => real().nullable()(); // Distance in kilometers
  IntColumn get totalTimeSeconds => integer().nullable()(); // Total time in seconds
  RealColumn get avgMovingSpeedKmh => real().nullable()(); // Average moving speed in km/h
  IntColumn get avgHeartRate => integer().nullable()(); // Average heart rate in bpm
  IntColumn get maxHeartRate => integer().nullable()(); // Maximum heart rate in bpm
  TextColumn get notes => text().nullable()(); // Additional notes
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'cycling_tracking';
}

@DataClassName('WordDictionary')
class WordDictionaryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get language => textEnum<WordLanguage>()();
  TextColumn get type => textEnum<WordType>()();
  TextColumn get difficulty => textEnum<ExerciseDifficulty>()();
  IntColumn get length => integer()(); // Word length for filtering
  IntColumn get version => integer().withDefault(const Constant(1))(); // Dictionary version for migrations
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'word_dictionary';
}

@DataClassName('UserProfile')
class UserProfileTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  IntColumn get age => integer().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get programStartDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'user_profile';
}

@DataClassName('CambridgeAssessmentEntry')
class CambridgeAssessmentTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get testType => textEnum<CambridgeTestType>()();
  IntColumn get durationSeconds => integer()();
  RealColumn get accuracy => real()(); // Percentage correct
  IntColumn get totalTrials => integer()();
  IntColumn get correctTrials => integer()();
  IntColumn get errorCount => integer()();
  RealColumn get meanLatencyMs => real()(); // Average reaction time
  RealColumn get medianLatencyMs => real()();
  RealColumn get normScore => real()(); // Age-normalized score
  TextColumn get interpretation => text()();
  TextColumn get specificMetrics => text()(); // JSON string for test-specific data
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'cambridge_assessments';
}

@DataClassName('DailyGoalEntry')
class DailyGoalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get targetGames => integer().withDefault(const Constant(5))();
  IntColumn get completedGames => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'daily_goals';
}

@DriftDatabase(tables: [
  AssessmentTable,
  ReminderTable,
  CognitiveExerciseTable,
  MoodEntryTable,
  DailyTrackingTable,
  SleepTrackingTable,
  CyclingTrackingTable,
  WordDictionaryTable,
  UserProfileTable,
  CambridgeAssessmentTable,
  DailyGoalsTable,
  MealPlanTable,
  FeedingWindowTable,
  FastingTable,
  SupplementsTable,
  SupplementLogsTable,
  PlanningTable,
  JournalTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add new tables for MCI tracking
        await m.createTable(dailyTrackingTable);
        await m.createTable(mealPlanTable);
        await m.createTable(feedingWindowTable);
        await m.createTable(fastingTable);
        await m.createTable(supplementsTable);
        await m.createTable(supplementLogsTable);
        await m.createTable(planningTable);
        await m.createTable(journalTable);
      }
      if (from < 3) {
        // Add sleep tracking table and yoga column
        await m.createTable(sleepTrackingTable);
        await m.addColumn(dailyTrackingTable, dailyTrackingTable.yoga);
      }
      if (from < 4) {
        // Add word dictionary table
        await m.createTable(wordDictionaryTable);
      }
      if (from < 5) {
        // Add Cambridge assessments table
        await m.createTable(cambridgeAssessmentTable);
      }
      if (from < 6) {
        // Add version column to word dictionary table
        await m.addColumn(wordDictionaryTable, wordDictionaryTable.version);
        // Clear old word dictionary data to force re-initialization with cleaned word lists
        await delete(wordDictionaryTable).go();
      }
      if (from < 7) {
        // Add user profile table for age-adjusted performance
        await m.createTable(userProfileTable);
      }
      if (from < 8) {
        // Add programStartDate column to user profile table for dynamic cycle calculation
        await m.addColumn(userProfileTable, userProfileTable.programStartDate);
      }
      if (from < 9) {
        // Add daily goals table for brain game tracking
        await m.createTable(dailyGoalsTable);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      // Get database file path
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'brain_plan.db'));

      // Open database with regular SQLite (encryption disabled)
      // TODO: Re-enable encryption with SQLCipher after resolving library conflicts
      return NativeDatabase.createInBackground(file);
    });
  }

  /// Get user's age from profile for age-adjusted scoring
  Future<int?> getUserAge() async {
    final profiles = await select(userProfileTable).get();
    if (profiles.isEmpty) return null;
    return profiles.first.age;
  }

  // Daily Goals methods
  Future<DailyGoalEntry?> getDailyGoalForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final goals = await (select(dailyGoalsTable)
          ..where((t) => t.date.equals(normalized)))
        .get();
    return goals.isEmpty ? null : goals.first;
  }

  Future<int> insertDailyGoal(DailyGoalEntry goal) async {
    return await into(dailyGoalsTable).insert(goal);
  }

  Future<bool> updateDailyGoal(DailyGoalEntry goal) async {
    return await update(dailyGoalsTable).replace(goal);
  }

  Future<List<DailyGoalEntry>> getAllDailyGoals() async {
    return await (select(dailyGoalsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<DailyGoalEntry>> getDailyGoalsInRange(
      DateTime start, DateTime end) async {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return await (select(dailyGoalsTable)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(normalizedStart) &
              t.date.isSmallerOrEqualValue(normalizedEnd))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<void> deleteDailyGoal(int id) async {
    await (delete(dailyGoalsTable)..where((t) => t.id.equals(id))).go();
  }
}