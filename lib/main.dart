import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/database_provider.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/auto_backup_service.dart';
import 'core/services/data_migration_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/performance_monitoring_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_manager.dart';
import 'core/services/user_profile_service.dart';
import 'core/services/word_dictionary_service.dart';
import 'data/datasources/database.dart';
import 'presentation/providers/router_provider.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable SQLCipher on Android
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

  // Initialize services
  await NotificationService.initialize();

  // Enable default cognitive reminders (weekly MCI tests on Monday, daily exercises)
  await NotificationService.enableDefaultReminders();

  await AnalyticsService.initialize();
  await PerformanceMonitoringService.initialize();

  // Initialize database (will open existing restored db or create new one)
  final database = AppDatabase();

  // Initialize Supabase service (Prerequisite for Auth)
  // We can use the one we create for Auth/SyncManager to ensure single instance if needed, 
  // but currently SupabaseService is a wrapper around static Supabase.instance + database.
  // Let's reuse the same instance to be clean.
  final supabaseService = SupabaseService(database);
  await SupabaseService.initialize(); // Static init for plugin

  // Initialize Auth Service
  final authService = AuthService(supabaseService);
  await authService.initialize();

  // Initialize Sync Manager
  final syncManager = SyncManager(supabaseService);
  syncManager.initialize();

  // Initialize automatic backup service (now handles sync triggers)
  await AutoBackupService.initialize(supabaseService);

  // CRITICAL: Restore database backup BEFORE creating AppDatabase instance
  // This ensures the restored database file is in place before Drift opens it
  final wasRestored = await DataMigrationService.restoreFromBackupIfNeeded();

  // Only initialize default data if NOT restored from backup
  if (!wasRestored) {
    print('Initializing fresh database with default data...');
    await WordDictionaryService.initializeWordDictionaries(database);
  } else {
    print('Database restored from backup - skipping default data initialization');
  }

  // Load user profile (age, etc.) for age-adjusted features
  await UserProfileService.loadProfileFromDatabase(database);

  // Backup database after initialization (or after restore)
  await DataMigrationService.backupDatabase();

  // Pass initialized instances to provider scope to ensure single instance
  // This ensures UI components get the same initialized services that main() created
  // See test/unit/provider_initialization_test.dart for verification
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      supabaseServiceProvider.overrideWithValue(supabaseService),
      authServiceProvider.overrideWithValue(authService),
    ],
    child: BrainPlanApp(syncManager: syncManager),
  ));
}

class BrainPlanApp extends ConsumerStatefulWidget {
  const BrainPlanApp({super.key, required this.syncManager});

  final SyncManager syncManager;

  @override
  ConsumerState<BrainPlanApp> createState() => _BrainPlanAppState();
}

class _BrainPlanAppState extends ConsumerState<BrainPlanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AutoBackupService.dispose();
    widget.syncManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Trigger backup when app goes to background or is paused
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      print('App going to background/paused - triggering backup...');
      DataMigrationService.backupDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Brain Tests',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}