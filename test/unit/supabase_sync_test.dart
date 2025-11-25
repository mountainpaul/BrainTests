import 'package:brain_tests/core/services/supabase_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:brain_tests/domain/entities/enums.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Value;

import 'supabase_sync_test.mocks.dart';

@GenerateMocks([
  SupabaseClient, 
  GoTrueClient, 
  SupabaseQueryBuilder, 
  PostgrestFilterBuilder,
  User // Mock Supabase User
])
void main() {
  group('SupabaseSync', () {
    late SupabaseService service;
    late AppDatabase database; // Real in-memory DB
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockUser mockUser;

    setUp(() {
      database = AppDatabase.memory();
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockUser = MockUser();

      // Setup Auth
      when(mockSupabaseClient.auth).thenReturn(mockAuth);
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.id).thenReturn('test-user-id');

      // Setup Chain: client.from() -> builder.upsert() -> future
      // Moved to test body to allow customization
      
      // Inject mock client
      SupabaseService.mockClient = mockSupabaseClient;
      service = SupabaseService(database);
    });

    tearDown(() {
      database.close();
      SupabaseService.mockClient = null;
    });

    test('syncPendingData should upload pending daily goals', () async {
      // 1. Insert a pending item
      final uuid = 'test-uuid-123';
      await database.into(database.dailyGoalsTable).insert(
        DailyGoalsTableCompanion.insert(
          date: DateTime.now(),
          uuid: Value(uuid),
          targetGames: const Value(5),
          syncStatus: Value(SyncStatus.pendingInsert),
        )
      );

      // Verify it is pending
      final before = await database.select(database.dailyGoalsTable).getSingle();
      expect(before.syncStatus, equals(SyncStatus.pendingInsert));

      // 2. Run Sync
      // Mockups
      when(mockSupabaseClient.from(any)).thenAnswer((_) => mockQueryBuilder);
      
      // We need mockFilterBuilder to be awaitable.
      // Since it's a Mock, 'await mockFilterBuilder' calls its 'then' method.
      // We need to stub 'then'.
      when(mockQueryBuilder.upsert(any)).thenAnswer((_) => mockFilterBuilder);

      // Stubing 'then' to simulate completion
      // Note: This is specific to how Dart awaits Futures (calling .then)
      // We assume the service awaits it.
      // We return an empty list/map as the result of the query
      when(mockFilterBuilder.then(any, onError: any)).thenAnswer((invocation) {
        final onValue = invocation.positionalArguments[0];
        return onValue([]); // Return empty list
      });
      
      await service.syncPendingData();

      // 3. Verify Supabase Call
      verify(mockSupabaseClient.from('daily_goals')).called(1);
      
      // Verify upsert was called with correct data
      final captured = verify(mockQueryBuilder.upsert(captureAny)).captured;
      final data = captured.first as Map<String, dynamic>;
      expect(data['id'], equals(uuid));
      expect(data['user_id'], equals('test-user-id'));
      expect(data['target_games'], equals(5));

      // 4. Verify Local Update (to Synced)
      final after = await database.select(database.dailyGoalsTable).getSingle();
      expect(after.syncStatus, equals(SyncStatus.synced));
    });
  });
}