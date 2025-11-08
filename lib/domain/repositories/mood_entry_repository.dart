import '../../data/datasources/database.dart';
import '../entities/mood_entry.dart';

abstract class MoodEntryRepository {
  Future<List<MoodEntry>> getAllMoodEntries();
  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end);
  Future<MoodEntry?> getMoodEntryById(int id);
  Future<MoodEntry?> getMoodEntryByDate(DateTime date);
  Future<int> insertMoodEntry(MoodEntry moodEntry);
  Future<bool> updateMoodEntry(MoodEntry moodEntry);
  Future<bool> deleteMoodEntry(int id);
  Future<Map<MoodLevel, int>> getMoodDistribution();
  Future<List<MoodEntry>> getRecentMoodEntries({int limit = 7});
  Future<double> getAverageWellnessScore();
}