import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'database_provider.dart';

/// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final database = ref.watch(databaseProvider);
  return SupabaseService(database);
});

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthService(supabaseService);
});

/// Provider for current user email (if signed in)
final currentUserEmailProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  // We might need to expose userEmail as a stream or notifier for reactivity
  // For now, we just get the current value.
  // Note: AuthService.initialize should have been called in main.
  return authService.userEmail;
});
