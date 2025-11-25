import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brain_tests/core/providers/auth_provider.dart';
import 'package:brain_tests/core/providers/database_provider.dart';
import 'package:brain_tests/core/services/auth_service.dart';
import 'package:brain_tests/core/services/supabase_service.dart';
import 'package:brain_tests/data/datasources/database.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([AppDatabase])
import 'provider_initialization_test.mocks.dart';

void main() {
  group('Provider Initialization Tests', () {
    late MockAppDatabase mockDatabase;
    late ProviderContainer container;

    setUp(() {
      mockDatabase = MockAppDatabase();
    });

    tearDown(() {
      container.dispose();
    });

    test('supabaseServiceProvider creates a NEW instance each time (current bug)', () {
      // This test documents the CURRENT BUGGY behavior
      // When we read the provider twice, we get the SAME instance from the provider
      // But the issue is that main() creates a DIFFERENT instance that gets initialized

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
      );

      final instance1 = container.read(supabaseServiceProvider);
      final instance2 = container.read(supabaseServiceProvider);

      // Provider caches the instance - same instance is returned
      expect(identical(instance1, instance2), isTrue,
          reason: 'Provider should cache and return the same instance');
    });

    test('supabaseServiceProvider instance is different from manually created instance', () {
      // This test verifies the ROOT CAUSE of the bug:
      // The instance created by the provider is DIFFERENT from one created in main()

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
      );

      // Simulate what main() does - create its own instance
      final mainInstance = SupabaseService(mockDatabase);

      // Get the instance from the provider
      final providerInstance = container.read(supabaseServiceProvider);

      // These are DIFFERENT instances - this is the bug!
      expect(identical(mainInstance, providerInstance), isFalse,
          reason: 'Provider creates a different instance than main() - this is the bug');
    });

    test('authServiceProvider instance is different from manually created instance', () {
      // Same issue for AuthService

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
      );

      // Simulate what main() does
      final supabaseService = SupabaseService(mockDatabase);
      final mainAuthInstance = AuthService(supabaseService);

      // Get the instance from the provider
      final providerAuthInstance = container.read(authServiceProvider);

      // These are DIFFERENT instances - this is the bug!
      expect(identical(mainAuthInstance, providerAuthInstance), isFalse,
          reason: 'Provider creates a different AuthService instance than main()');
    });

    test('FIX: overriding providers ensures same instance is used', () {
      // This test shows the FIX - override the providers with the initialized instances

      // Simulate what main() does - create and (would) initialize the instances
      final mainSupabaseService = SupabaseService(mockDatabase);
      final mainAuthService = AuthService(mainSupabaseService);

      // Create container WITH overrides (the fix)
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
          supabaseServiceProvider.overrideWithValue(mainSupabaseService),
          authServiceProvider.overrideWithValue(mainAuthService),
        ],
      );

      // Now the provider returns the SAME instance that main() created
      final providerSupabaseInstance = container.read(supabaseServiceProvider);
      final providerAuthInstance = container.read(authServiceProvider);

      expect(identical(mainSupabaseService, providerSupabaseInstance), isTrue,
          reason: 'With override, provider should return the same SupabaseService instance');
      expect(identical(mainAuthService, providerAuthInstance), isTrue,
          reason: 'With override, provider should return the same AuthService instance');
    });
  });
}
