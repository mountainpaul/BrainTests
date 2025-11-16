import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_entry_repository.dart';
import '../datasources/database.dart';

/// Mood tracking feature removed - this implementation returns empty data
class MoodEntryRepositoryImpl implements MoodEntryRepository {

  MoodEntryRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async => [];

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) async => [];

  @override
  Future<MoodEntry?> getMoodEntryById(int id) async => null;

  @override
  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async => null;

  @override
  Future<int> insertMoodEntry(MoodEntry moodEntry) async => 0;

  @override
  Future<bool> updateMoodEntry(MoodEntry moodEntry) async => false;

  @override
  Future<bool> deleteMoodEntry(int id) async => false;

  @override
  Future<Map<MoodLevel, int>> getMoodDistribution() async => {};

  @override
  Future<List<MoodEntry>> getRecentMoodEntries({int limit = 7}) async => [];

  @override
  Future<double> getAverageWellnessScore() async => 0.0;
}
