import 'package:brain_plan/data/datasources/database.dart';
import 'package:drift/drift.dart';

/// Helper to create test database instances safely
/// Suppresses Drift warnings about multiple database instances in tests
AppDatabase createTestDatabase() {
  // Suppress the multiple database warning for tests
  // This is expected behavior in test environment
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  return AppDatabase.memory();
}

/// Helper to properly close test database
Future<void> closeTestDatabase(AppDatabase database) async {
  await database.close();
}
