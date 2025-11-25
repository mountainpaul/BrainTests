import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Value;
import '../../data/datasources/database.dart';

class SupabaseService {
  SupabaseService(this._database);

  final AppDatabase _database;
  static bool _isInitialized = false;
  static SupabaseClient? _mockClient;

  @visibleForTesting
  static set mockClient(SupabaseClient? client) => _mockClient = client;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/supabase_credentials.json');
      final Map<String, dynamic> config = json.decode(jsonString) as Map<String, dynamic>;
      
      final String url = config['supabaseUrl'] as String;
      final String anonKey = config['supabaseAnonKey'] as String;

      if (url == 'YOUR_SUPABASE_URL' || anonKey == 'YOUR_SUPABASE_ANON_KEY') {
        print('Supabase credentials not set in assets/supabase_credentials.json');
        return;
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize Supabase: $e');
    }
  }

  SupabaseClient? get client {
    if (_mockClient != null) return _mockClient;
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  bool get isReady => (_isInitialized || _mockClient != null) && client != null;

  /// Authenticate with Supabase using Google credentials
  Future<void> signInWithGoogle(String idToken, String accessToken) async {
    if (!isReady) {
      print('SupabaseService: Not ready during signInWithGoogle');
      return;
    }
    try {
      print('SupabaseService: Attempting sign in with Google...');
      await client!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      print('SupabaseService: Sign in successful. User ID: ${client!.auth.currentUser?.id}');
    } catch (e) {
      print('SupabaseService: Auth Error: $e');
    }
  }

  /// Sync pending local data to Supabase
  Future<void> syncPendingData() async {
    if (!isReady) {
      print('SupabaseService: Not ready during syncPendingData');
      return;
    }
    
    final user = client!.auth.currentUser;
    if (user == null) {
      print('SupabaseService: No user logged in. Skipping sync.');
      return;
    }

    print('SupabaseService: Starting sync for user ${user.id}');
    await _syncPendingUserProfile(user.id);
    await _syncPendingAssessments(user.id);
    await _syncPendingCognitiveExercises(user.id);
    await _syncPendingDailyGoals(user.id);
    await _syncPendingCambridgeAssessments(user.id);
  }

  Future<void> _syncPendingUserProfile(String userId) async {
    // Include NULL syncStatus for migrated rows that weren't backfilled
    final pending = await (_database.select(_database.userProfileTable)
      ..where((t) => t.syncStatus.equals(SyncStatus.synced.index).not() | t.syncStatus.isNull())).get();

    print('SupabaseService: Found ${pending.length} pending profiles');

    for (final item in pending) {
      try {
        print('SupabaseService: Syncing profile ${item.uuid}...');
        await client!.from('user_profiles').upsert({
          'id': item.uuid,
          'user_id': userId,
          'name': item.name,
          'age': item.age,
          'date_of_birth': item.dateOfBirth?.toIso8601String(),
          'gender': item.gender,
          'program_start_date': item.programStartDate?.toIso8601String(),
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('SupabaseService: Profile ${item.uuid} synced successfully.');

         await (_database.update(_database.userProfileTable)
          ..where((t) => t.id.equals(item.id)))
          .write(UserProfileTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('SupabaseService: Failed to sync profile ${item.id}: $e');
      }
    }
  }

  Future<void> _syncPendingAssessments(String userId) async {
    // Include NULL syncStatus for migrated rows that weren't backfilled
    final pending = await (_database.select(_database.assessmentTable)
      ..where((t) => t.syncStatus.equals(SyncStatus.synced.index).not() | t.syncStatus.isNull())).get();

    print('SupabaseService: Found ${pending.length} pending assessments');

    for (final item in pending) {
      try {
        print('SupabaseService: Syncing assessment ${item.uuid} for User $userId...');
        final payload = {
          'id': item.uuid,
          'user_id': userId,
          'type': item.type.name,
          'score': item.score,
          'max_score': item.maxScore,
          'notes': item.notes,
          'completed_at': item.completedAt.toIso8601String(),
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        print('SupabaseService: Payload: $payload');

        await client!.from('assessments').upsert(payload);
        print('SupabaseService: Assessment ${item.uuid} synced successfully.');

        // Mark as synced locally
        await (_database.update(_database.assessmentTable)
          ..where((t) => t.id.equals(item.id)))
          .write(AssessmentTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('SupabaseService: Failed to sync assessment ${item.id}: $e');
      }
    }
  }

  Future<void> _syncPendingCognitiveExercises(String userId) async {
    // Include NULL syncStatus for migrated rows that weren't backfilled
    final pending = await (_database.select(_database.cognitiveExerciseTable)
      ..where((t) => t.syncStatus.equals(SyncStatus.synced.index).not() | t.syncStatus.isNull())).get();

    print('SupabaseService: Found ${pending.length} pending exercises');

    for (final item in pending) {
      try {
        print('SupabaseService: Syncing exercise ${item.uuid}...');
        await client!.from('cognitive_exercises').upsert({
          'id': item.uuid,
          'user_id': userId,
          'name': item.name,
          'type': item.type.name,
          'difficulty': item.difficulty.name,
          'score': item.score,
          'max_score': item.maxScore,
          'time_spent_seconds': item.timeSpentSeconds,
          'is_completed': item.isCompleted,
          'exercise_data': item.exerciseData,
          'completed_at': item.completedAt?.toIso8601String(),
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('SupabaseService: Exercise ${item.uuid} synced successfully.');

         await (_database.update(_database.cognitiveExerciseTable)
          ..where((t) => t.id.equals(item.id)))
          .write(CognitiveExerciseTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('SupabaseService: Failed to sync exercise ${item.id}: $e');
      }
    }
  }

  Future<void> _syncPendingDailyGoals(String userId) async {
    // Include NULL syncStatus for migrated rows that weren't backfilled
    final pending = await (_database.select(_database.dailyGoalsTable)
      ..where((t) => t.syncStatus.equals(SyncStatus.synced.index).not() | t.syncStatus.isNull())).get();

    for (final item in pending) {
      try {
        await client!.from('daily_goals').upsert({
          'id': item.uuid,
          'user_id': userId,
          'date': item.date.toIso8601String(),
          'target_games': item.targetGames,
          'completed_games': item.completedGames,
          'is_completed': item.isCompleted,
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': item.updatedAt.toIso8601String(),
        });

         await (_database.update(_database.dailyGoalsTable)
          ..where((t) => t.id.equals(item.id)))
          .write(DailyGoalsTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('Failed to sync daily goal ${item.id}: $e');
      }
    }
  }

  Future<void> _syncPendingCambridgeAssessments(String userId) async {
    // Include NULL syncStatus for migrated rows that weren't backfilled
    final pending = await (_database.select(_database.cambridgeAssessmentTable)
      ..where((t) => t.syncStatus.equals(SyncStatus.synced.index).not() | t.syncStatus.isNull())).get();

    print('SupabaseService: Found ${pending.length} pending Cambridge assessments');

    for (final item in pending) {
      try {
        print('SupabaseService: Syncing Cambridge assessment ${item.uuid}...');
        await client!.from('cambridge_assessments').upsert({
          'id': item.uuid,
          'user_id': userId,
          'test_type': item.testType.name,
          'duration_seconds': item.durationSeconds,
          'accuracy': item.accuracy,
          'total_trials': item.totalTrials,
          'correct_trials': item.correctTrials,
          'error_count': item.errorCount,
          'mean_latency_ms': item.meanLatencyMs,
          'median_latency_ms': item.medianLatencyMs,
          'norm_score': item.normScore,
          'interpretation': item.interpretation,
          'specific_metrics': item.specificMetrics,
          'completed_at': item.completedAt.toIso8601String(),
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('SupabaseService: Cambridge assessment ${item.uuid} synced successfully.');

        await (_database.update(_database.cambridgeAssessmentTable)
          ..where((t) => t.id.equals(item.id)))
          .write(CambridgeAssessmentTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('SupabaseService: Failed to sync Cambridge assessment ${item.id}: $e');
      }
    }
  }

  // --- Backup Methods (Legacy/Manual) ---

  /// Fetch data from Supabase and update local DB
  Future<void> fetchRemoteData() async {
    if (!isReady) return;
    
    final user = client!.auth.currentUser;
    if (user == null) return;

    // Fetch User Profile
    final profiles = await client!.from('user_profiles').select().eq('user_id', user.id);
    for (final data in profiles) {
      await _upsertLocalUserProfile(data);
    }

    // Fetch Assessments
    final assessments = await client!.from('assessments').select().eq('user_id', user.id);
    for (final data in assessments) {
      await _upsertLocalAssessment(data);
    }

    // Fetch Cognitive Exercises
    final exercises = await client!.from('cognitive_exercises').select().eq('user_id', user.id);
    for (final data in exercises) {
      await _upsertLocalCognitiveExercise(data);
    }
    
    // Fetch Daily Goals
    final goals = await client!.from('daily_goals').select().eq('user_id', user.id);
    for (final data in goals) {
      await _upsertLocalDailyGoal(data);
    }

    // Fetch Cambridge Assessments
    final cambridgeAssessments = await client!.from('cambridge_assessments').select().eq('user_id', user.id);
    for (final data in cambridgeAssessments) {
      await _upsertLocalCambridgeAssessment(data);
    }
  }

  Future<void> _upsertLocalUserProfile(Map<String, dynamic> data) async {
    final uuid = data['id'] as String;
    final exists = await (_database.select(_database.userProfileTable)
      ..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

    if (exists == null) {
      await _database.into(_database.userProfileTable).insert(
        UserProfileTableCompanion.insert(
          uuid: Value(uuid),
          name: data['name'] != null ? Value(data['name']) : const Value.absent(),
          age: data['age'] != null ? Value(data['age']) : const Value.absent(),
          dateOfBirth: data['date_of_birth'] != null ? Value(DateTime.parse(data['date_of_birth'])) : const Value.absent(),
          gender: data['gender'] != null ? Value(data['gender']) : const Value.absent(),
          programStartDate: data['program_start_date'] != null ? Value(DateTime.parse(data['program_start_date'])) : const Value.absent(),
          createdAt: Value(DateTime.parse(data['created_at'])),
          updatedAt: Value(DateTime.parse(data['updated_at'])),
          syncStatus: Value(SyncStatus.synced),
          lastUpdatedAt: Value(DateTime.parse(data['updated_at'] ?? data['created_at'])),
        )
      );
    } else {
      // Update existing (simple overwrite for now)
      // We match by UUID, so we find the row and update it
      await (_database.update(_database.userProfileTable)
        ..where((t) => t.uuid.equals(uuid)))
        .write(
          UserProfileTableCompanion(
            name: data['name'] != null ? Value(data['name']) : const Value.absent(),
            age: data['age'] != null ? Value(data['age']) : const Value.absent(),
            dateOfBirth: data['date_of_birth'] != null ? Value(DateTime.parse(data['date_of_birth'])) : const Value.absent(),
            gender: data['gender'] != null ? Value(data['gender']) : const Value.absent(),
            programStartDate: data['program_start_date'] != null ? Value(DateTime.parse(data['program_start_date'])) : const Value.absent(),
            updatedAt: Value(DateTime.parse(data['updated_at'])),
            syncStatus: Value(SyncStatus.synced),
            lastUpdatedAt: Value(DateTime.parse(data['updated_at'] ?? data['created_at'])),
          )
        );
    }
  }

  Future<void> _upsertLocalAssessment(Map<String, dynamic> data) async {
    final uuid = data['id'] as String;
    
    // Check if exists
    final exists = await (_database.select(_database.assessmentTable)
      ..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

    if (exists == null) {
      // Insert
       await _database.into(_database.assessmentTable).insert(
        AssessmentTableCompanion.insert(
          uuid: Value(uuid),
          type: AssessmentType.values.byName(data['type']),
          score: data['score'],
          maxScore: data['max_score'],
          notes: Value(data['notes']),
          completedAt: DateTime.parse(data['completed_at']),
          createdAt: Value(DateTime.parse(data['created_at'])),
          syncStatus: Value(SyncStatus.synced),
          lastUpdatedAt: Value(DateTime.parse(data['updated_at'] ?? data['created_at'])),
        )
      );
    } else {
      // Update logic (Conflict resolution: usually server wins if we are pulling)
      // For now, simple update
    }
  }

  Future<void> _upsertLocalCognitiveExercise(Map<String, dynamic> data) async {
    final uuid = data['id'] as String;
    final exists = await (_database.select(_database.cognitiveExerciseTable)
      ..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

    if (exists == null) {
      await _database.into(_database.cognitiveExerciseTable).insert(
        CognitiveExerciseTableCompanion.insert(
          uuid: Value(uuid),
          name: data['name'],
          type: ExerciseType.values.byName(data['type']),
          difficulty: ExerciseDifficulty.values.byName(data['difficulty']),
          maxScore: data['max_score'],
          score: Value(data['score']),
          timeSpentSeconds: Value(data['time_spent_seconds']),
          isCompleted: Value(data['is_completed'] ?? false),
          exerciseData: Value(data['exercise_data']),
          completedAt: data['completed_at'] != null ? Value(DateTime.parse(data['completed_at'])) : const Value.absent(),
          createdAt: Value(DateTime.parse(data['created_at'])),
          syncStatus: Value(SyncStatus.synced),
          lastUpdatedAt: Value(DateTime.parse(data['updated_at'] ?? data['created_at'])),
        )
      );
    }
  }

  Future<void> _upsertLocalDailyGoal(Map<String, dynamic> data) async {
    final uuid = data['id'] as String;
    final exists = await (_database.select(_database.dailyGoalsTable)
      ..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

    if (exists == null) {
      await _database.into(_database.dailyGoalsTable).insert(
        DailyGoalsTableCompanion.insert(
          uuid: Value(uuid),
          date: DateTime.parse(data['date']),
          targetGames: Value(data['target_games']),
          completedGames: Value(data['completed_games']),
          isCompleted: Value(data['is_completed'] ?? false),
          createdAt: Value(DateTime.parse(data['created_at'])),
          updatedAt: Value(DateTime.parse(data['updated_at'])),
          syncStatus: Value(SyncStatus.synced),
          lastUpdatedAt: Value(DateTime.parse(data['updated_at'] ?? data['created_at'])),
        )
      );
    }
  }

  Future<void> _upsertLocalCambridgeAssessment(Map<String, dynamic> data) async {
    final uuid = data['id'] as String;
    final exists = await (_database.select(_database.cambridgeAssessmentTable)
      ..where((t) => t.uuid.equals(uuid))).getSingleOrNull();

    if (exists == null) {
      // Parse the test type from string to enum
      final testTypeStr = data['test_type'] as String;
      final testType = CambridgeTestType.values.firstWhere(
        (e) => e.name == testTypeStr,
        orElse: () => CambridgeTestType.pal, // Fallback
      );

      await _database.into(_database.cambridgeAssessmentTable).insert(
        CambridgeAssessmentTableCompanion.insert(
          uuid: Value(uuid),
          testType: testType,
          durationSeconds: (data['duration_seconds'] as int?) ?? 0,
          accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
          totalTrials: (data['total_trials'] as int?) ?? 0,
          correctTrials: (data['correct_trials'] as int?) ?? 0,
          errorCount: (data['error_count'] as int?) ?? 0,
          meanLatencyMs: (data['mean_latency_ms'] as num?)?.toDouble() ?? 0.0,
          medianLatencyMs: (data['median_latency_ms'] as num?)?.toDouble() ?? 0.0,
          normScore: (data['norm_score'] as num?)?.toDouble() ?? 0.0,
          interpretation: (data['interpretation'] as String?) ?? '',
          specificMetrics: (data['specific_metrics'] as String?) ?? '',
          completedAt: DateTime.parse(data['completed_at'] as String),
          createdAt: Value(DateTime.parse(data['created_at'] as String)),
          syncStatus: const Value(SyncStatus.synced),
          lastUpdatedAt: Value(DateTime.parse((data['updated_at'] ?? data['created_at']) as String)),
        )
      );
      print('SupabaseService: Imported Cambridge assessment $uuid ($testTypeStr)');
    }
  }

  /// Force sync ALL Cambridge assessments regardless of syncStatus.
  /// Use this for recovery when normal sync fails.
  Future<void> forceSyncAllCambridgeAssessments() async {
    if (!isReady) {
      print('SupabaseService: Not ready during forceSyncAllCambridgeAssessments');
      return;
    }

    final user = client!.auth.currentUser;
    if (user == null) {
      print('SupabaseService: No user logged in. Skipping force sync.');
      return;
    }

    print('SupabaseService: Force syncing ALL Cambridge assessments for user ${user.id}');

    // Get ALL Cambridge assessments without filtering by syncStatus
    final allAssessments = await _database.select(_database.cambridgeAssessmentTable).get();

    print('SupabaseService: Found ${allAssessments.length} total Cambridge assessments to force sync');

    for (final item in allAssessments) {
      try {
        print('SupabaseService: Force syncing Cambridge assessment ${item.uuid}...');
        await client!.from('cambridge_assessments').upsert({
          'id': item.uuid,
          'user_id': user.id,
          'test_type': item.testType.name,
          'duration_seconds': item.durationSeconds,
          'accuracy': item.accuracy,
          'total_trials': item.totalTrials,
          'correct_trials': item.correctTrials,
          'error_count': item.errorCount,
          'mean_latency_ms': item.meanLatencyMs,
          'median_latency_ms': item.medianLatencyMs,
          'norm_score': item.normScore,
          'interpretation': item.interpretation,
          'specific_metrics': item.specificMetrics,
          'completed_at': item.completedAt.toIso8601String(),
          'created_at': item.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('SupabaseService: Cambridge assessment ${item.uuid} force synced successfully.');

        // Mark as synced locally
        await (_database.update(_database.cambridgeAssessmentTable)
          ..where((t) => t.id.equals(item.id)))
          .write(CambridgeAssessmentTableCompanion(
            syncStatus: Value(SyncStatus.synced),
          ));
      } catch (e) {
        print('SupabaseService: Failed to force sync Cambridge assessment ${item.id}: $e');
      }
    }
  }

  Future<void> backupAllUserData() async {
    if (!isReady) return;

    await backupUserProfile();
    await backupAssessments();
    await backupCognitiveExercises();
    await backupCambridgeAssessments();
    await backupDailyGoals();
  }

  Future<void> backupUserProfile() async {
    final profiles = await _database.select(_database.userProfileTable).get();
    if (profiles.isEmpty) return;

    final user = client!.auth.currentUser;
    if (user == null) return;

    for (final profile in profiles) {
      await client!.from('user_profiles').upsert({
        'user_id': user.id, // Map to Supabase auth user
        'age': profile.age,
        'date_of_birth': profile.dateOfBirth?.toIso8601String(),
        'gender': profile.gender,
        'program_start_date': profile.programStartDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> backupAssessments() async {
    final assessments = await _database.select(_database.assessmentTable).get();
    final user = client!.auth.currentUser;
    if (user == null) return;

    final data = assessments.map((e) => {
      'user_id': user.id,
      'local_id': e.id,
      'type': e.type.name,
      'score': e.score,
      'max_score': e.maxScore,
      'notes': e.notes,
      'completed_at': e.completedAt.toIso8601String(),
      'created_at': e.createdAt.toIso8601String(),
    }).toList();

    if (data.isNotEmpty) {
      await client!.from('assessments').upsert(data, onConflict: 'user_id, local_id');
    }
  }

  Future<void> backupCognitiveExercises() async {
    final exercises = await _database.select(_database.cognitiveExerciseTable).get();
    final user = client!.auth.currentUser;
    if (user == null) return;

    // Batching might be needed for large datasets, but simple list for now
    final data = exercises.map((e) => {
      'user_id': user.id,
      'local_id': e.id,
      'name': e.name,
      'type': e.type.name,
      'difficulty': e.difficulty.name,
      'score': e.score,
      'max_score': e.maxScore,
      'time_spent_seconds': e.timeSpentSeconds,
      'is_completed': e.isCompleted,
      'exercise_data': e.exerciseData,
      'completed_at': e.completedAt?.toIso8601String(),
      'created_at': e.createdAt.toIso8601String(),
    }).toList();

    if (data.isNotEmpty) {
      await client!.from('cognitive_exercises').upsert(data, onConflict: 'user_id, local_id');
    }
  }

  Future<void> backupCambridgeAssessments() async {
    final assessments = await _database.select(_database.cambridgeAssessmentTable).get();
    final user = client!.auth.currentUser;
    if (user == null) return;

    final data = assessments.map((e) => {
      'user_id': user.id,
      'local_id': e.id,
      'test_type': e.testType.name,
      'duration_seconds': e.durationSeconds,
      'accuracy': e.accuracy,
      'total_trials': e.totalTrials,
      'correct_trials': e.correctTrials,
      'error_count': e.errorCount,
      'mean_latency_ms': e.meanLatencyMs,
      'median_latency_ms': e.medianLatencyMs,
      'norm_score': e.normScore,
      'interpretation': e.interpretation,
      'specific_metrics': e.specificMetrics,
      'completed_at': e.completedAt.toIso8601String(),
      'created_at': e.createdAt.toIso8601String(),
    }).toList();

    if (data.isNotEmpty) {
      await client!.from('cambridge_assessments').upsert(data, onConflict: 'user_id, local_id');
    }
  }

  Future<void> backupDailyGoals() async {
    final goals = await _database.select(_database.dailyGoalsTable).get();
    final user = client!.auth.currentUser;
    if (user == null) return;

    final data = goals.map((e) => {
      'user_id': user.id,
      'local_id': e.id,
      'date': e.date.toIso8601String(),
      'target_games': e.targetGames,
      'completed_games': e.completedGames,
      'is_completed': e.isCompleted,
      'created_at': e.createdAt.toIso8601String(),
      'updated_at': e.updatedAt.toIso8601String(),
    }).toList();

    if (data.isNotEmpty) {
      await client!.from('daily_goals').upsert(data, onConflict: 'user_id, local_id');
    }
  }
}
