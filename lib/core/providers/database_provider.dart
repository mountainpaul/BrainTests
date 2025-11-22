import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database.dart';

// Singleton database provider - only creates one instance
final databaseProvider = Provider<AppDatabase>((ref) {
  // Create the database once and keep it alive
  ref.keepAlive();
  return AppDatabase();
});

final repositoryModule = Provider((ref) {
  return ref.read(databaseProvider);
});