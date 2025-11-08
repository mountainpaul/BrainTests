import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/database.dart';
import '../../domain/entities/mood_entry.dart';
import 'repository_providers.dart';

part 'mood_entry_provider.g.dart';

final moodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  return await repository.getAllMoodEntries();
});

final recentMoodEntriesProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  return await repository.getRecentMoodEntries(limit: 7);
});

final moodDistributionProvider = FutureProvider<Map<MoodLevel, int>>((ref) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  return await repository.getMoodDistribution();
});

final averageWellnessScoreProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  return await repository.getAverageWellnessScore();
});

final moodEntriesByDateRangeProvider = FutureProvider.family<List<MoodEntry>, DateRange>((ref, dateRange) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  return await repository.getMoodEntriesByDateRange(dateRange.start, dateRange.end);
});

final todayMoodEntryProvider = FutureProvider<MoodEntry?>((ref) async {
  final repository = ref.read(moodEntryRepositoryProvider);
  final today = DateTime.now();
  return await repository.getMoodEntryByDate(today);
});

class DateRange {

  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

@riverpod
class MoodEntryNotifier extends _$MoodEntryNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addMoodEntry(MoodEntry moodEntry) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(moodEntryRepositoryProvider);
      await repository.insertMoodEntry(moodEntry);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMoodEntry(MoodEntry moodEntry) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(moodEntryRepositoryProvider);
      await repository.updateMoodEntry(moodEntry);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMoodEntry(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(moodEntryRepositoryProvider);
      await repository.deleteMoodEntry(id);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addOrUpdateTodayMoodEntry(MoodEntry moodEntry) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(moodEntryRepositoryProvider);
      final existingEntry = await repository.getMoodEntryByDate(moodEntry.entryDate);

      if (existingEntry != null) {
        final updatedEntry = moodEntry.copyWith(id: existingEntry.id);
        await repository.updateMoodEntry(updatedEntry);
      } else {
        await repository.insertMoodEntry(moodEntry);
      }

      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _invalidateProviders() {
    ref.invalidate(moodEntriesProvider);
    ref.invalidate(recentMoodEntriesProvider);
    ref.invalidate(moodDistributionProvider);
    ref.invalidate(averageWellnessScoreProvider);
    ref.invalidate(todayMoodEntryProvider);
  }
}