import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/services/encryption_key_manager.dart';
import '../../domain/entities/enums.dart';
export '../../domain/entities/enums.dart';

part 'database.g.dart';

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
  CognitiveExerciseTable,
  WordDictionaryTable,
  UserProfileTable,
  CambridgeAssessmentTable,
  DailyGoalsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
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
      // Version 10: Removed unused tables (reminders, mood, fasting, meal plans, etc.)
      // Tables are automatically dropped when removed from @DriftDatabase annotation
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      // Get database file path
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'brain_plan.db'));

      // Get encryption key securely
      final encryptionKey = await EncryptionKeyManager.getOrCreateKey();

      // Open database with SQLCipher encryption enabled
      // Using NativeDatabase (main isolate) instead of createInBackground because
      // the background isolate wouldn't have the SQLCipher override applied.
      return NativeDatabase(
        file,
        setup: (database) {
          database.execute("PRAGMA key = '$encryptionKey';");
        },
      );
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