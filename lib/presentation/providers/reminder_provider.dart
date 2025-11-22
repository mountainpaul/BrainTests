import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/reminder.dart';
import 'repository_providers.dart';

part 'reminder_provider.g.dart';

final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.read(reminderRepositoryProvider);
  return await repository.getAllReminders();
});

final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.read(reminderRepositoryProvider);
  return await repository.getActiveReminders();
});

final upcomingRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.read(reminderRepositoryProvider);
  return await repository.getUpcomingReminders();
});

final overdueRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.read(reminderRepositoryProvider);
  return await repository.getOverdueReminders();
});

final remindersByTypeProvider = FutureProvider.family<List<Reminder>, ReminderType>((ref, type) async {
  final repository = ref.read(reminderRepositoryProvider);
  return await repository.getRemindersByType(type);
});

@riverpod
class ReminderNotifier extends _$ReminderNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reminderRepositoryProvider);
      await repository.insertReminder(reminder);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reminderRepositoryProvider);
      await repository.updateReminder(reminder);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteReminder(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reminderRepositoryProvider);
      await repository.deleteReminder(id);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markCompleted(int id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reminderRepositoryProvider);
      await repository.markReminderCompleted(id);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> snoozeReminder(int id, Duration duration) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reminderRepositoryProvider);
      await repository.snoozeReminder(id, duration);
      state = const AsyncValue.data(null);

      _invalidateProviders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _invalidateProviders() {
    ref.invalidate(remindersProvider);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(upcomingRemindersProvider);
    ref.invalidate(overdueRemindersProvider);
  }
}