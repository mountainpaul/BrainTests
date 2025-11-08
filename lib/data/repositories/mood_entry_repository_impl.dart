import 'package:drift/drift.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_entry_repository.dart';
import '../datasources/database.dart';

class MoodEntryRepositoryImpl implements MoodEntryRepository {

  MoodEntryRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final entries = await (_database.select(_database.moodEntryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)]))
        .get();
    return entries.map(_mapToEntity).toList();
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) async {
    final entries = await (_database.select(_database.moodEntryTable)
          ..where((t) => t.entryDate.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)]))
        .get();
    return entries.map(_mapToEntity).toList();
  }

  @override
  Future<MoodEntry?> getMoodEntryById(int id) async {
    final entry = await (_database.select(_database.moodEntryTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return entry != null ? _mapToEntity(entry) : null;
  }

  @override
  Future<MoodEntry?> getMoodEntryByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final entry = await (_database.select(_database.moodEntryTable)
          ..where((t) => t.entryDate.isBetweenValues(startOfDay, endOfDay)))
        .getSingleOrNull();
    return entry != null ? _mapToEntity(entry) : null;
  }

  @override
  Future<int> insertMoodEntry(MoodEntry moodEntry) async {
    return await _database.into(_database.moodEntryTable).insert(
      MoodEntryTableCompanion.insert(
        mood: moodEntry.mood,
        energyLevel: moodEntry.energyLevel,
        stressLevel: moodEntry.stressLevel,
        sleepQuality: moodEntry.sleepQuality,
        notes: Value(moodEntry.notes),
        entryDate: moodEntry.entryDate,
        createdAt: Value(moodEntry.createdAt),
      ),
    );
  }

  @override
  Future<bool> updateMoodEntry(MoodEntry moodEntry) async {
    if (moodEntry.id == null) return false;
    final rowsUpdated = await (_database.update(_database.moodEntryTable)
          ..where((t) => t.id.equals(moodEntry.id!)))
        .write(
      MoodEntryTableCompanion(
        mood: Value(moodEntry.mood),
        energyLevel: Value(moodEntry.energyLevel),
        stressLevel: Value(moodEntry.stressLevel),
        sleepQuality: Value(moodEntry.sleepQuality),
        notes: Value(moodEntry.notes),
        entryDate: Value(moodEntry.entryDate),
      ),
    );
    return rowsUpdated > 0;
  }

  @override
  Future<bool> deleteMoodEntry(int id) async {
    final rowsDeleted = await (_database.delete(_database.moodEntryTable)
          ..where((t) => t.id.equals(id)))
        .go();
    return rowsDeleted > 0;
  }

  @override
  Future<Map<MoodLevel, int>> getMoodDistribution() async {
    final entries = await getAllMoodEntries();
    final Map<MoodLevel, int> distribution = {};
    
    for (final mood in MoodLevel.values) {
      distribution[mood] = entries.where((e) => e.mood == mood).length;
    }
    
    return distribution;
  }

  @override
  Future<List<MoodEntry>> getRecentMoodEntries({int limit = 7}) async {
    final entries = await (_database.select(_database.moodEntryTable)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)])
          ..limit(limit))
        .get();
    return entries.map(_mapToEntity).toList();
  }

  @override
  Future<double> getAverageWellnessScore() async {
    final entries = await getAllMoodEntries();
    if (entries.isEmpty) return 0.0;
    
    final totalWellness = entries
        .map((e) => e.overallWellness)
        .reduce((a, b) => a + b);
    
    return totalWellness / entries.length;
  }

  MoodEntry _mapToEntity(MoodEntryData entry) {
    return MoodEntry(
      id: entry.id,
      mood: entry.mood,
      energyLevel: entry.energyLevel,
      stressLevel: entry.stressLevel,
      sleepQuality: entry.sleepQuality,
      notes: entry.notes,
      entryDate: entry.entryDate,
      createdAt: entry.createdAt,
    );
  }
}