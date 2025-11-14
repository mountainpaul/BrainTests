import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/services/google_drive_backup_service.dart';

part 'google_drive_provider.g.dart';

/// Provider for Google Drive sign-in state
/// Watches for authentication changes and rebuilds UI automatically
@riverpod
class GoogleDriveAuth extends _$GoogleDriveAuth {
  @override
  bool build() {
    // Initialize service
    GoogleDriveBackupService.initialize();

    // Return current sign-in state
    return GoogleDriveBackupService.isSignedIn;
  }

  /// Sign in to Google Drive
  Future<void> signIn() async {
    await GoogleDriveBackupService.signIn();
    // Invalidate to refresh state
    ref.invalidateSelf();
  }

  /// Sign out from Google Drive
  Future<void> signOut() async {
    await GoogleDriveBackupService.signOut();
    // Invalidate to refresh state
    ref.invalidateSelf();
  }
}

/// Convenience provider for sign-in status (bool)
@riverpod
bool isGoogleDriveSignedIn(ref) {
  return ref.watch(googleDriveAuthProvider);
}

/// Convenience provider for user email
@riverpod
String? googleDriveUserEmail(ref) {
  final isSignedIn = ref.watch(googleDriveAuthProvider);
  return isSignedIn ? GoogleDriveBackupService.userEmail : null;
}
