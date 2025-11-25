import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService(this._supabaseService);

  final SupabaseService _supabaseService;
  
  // Scopes: We only need email/profile, which are default.
  // We DO NOT ask for Drive permissions anymore.
  final _googleSignIn = GoogleSignIn(
    serverClientId: '817677274854-kememf9orcave4p5hr53m8vpintk8e8f.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

  /// Current signed-in user email
  String? get userEmail => _googleSignIn.currentUser?.email;

  /// Initialize and try to sign in silently (if user previously signed in)
  Future<void> initialize() async {
    try {
      // Listen to auth state changes from Google
      _googleSignIn.onCurrentUserChanged.listen((account) {
        if (account != null) {
          _authenticateWithSupabase(account);
        }
      });

      // Try silent sign-in
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        debugPrint('Restored Google Sign-In session for: ${account.email}');
      }
    } catch (e) {
      debugPrint('AuthService Init Error: $e');
    }
  }

  /// Trigger interactive Sign In
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (e) {
      debugPrint('Sign In Error: $e');
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabaseService.client?.auth.signOut();
  }

  /// Exchange Google Credentials for Supabase Session
  Future<void> _authenticateWithSupabase(GoogleSignInAccount account) async {
    try {
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      debugPrint('Google Auth Tokens received - ID Token: ${idToken != null ? "YES" : "NO"}, Access Token: ${accessToken != null ? "YES" : "NO"}');

      if (idToken == null || accessToken == null) {
        debugPrint('Missing Google Auth Tokens');
        return;
      }

      await _supabaseService.signInWithGoogle(idToken, accessToken);
      
      // Verification
      if (_supabaseService.client?.auth.currentUser == null) {
         debugPrint('Supabase Auth Failed: User is null after sign-in call');
      } else {
         debugPrint('Successfully authenticated with Supabase via Google');
         // Trigger a sync now that we are logged in
         await _supabaseService.fetchRemoteData();
         await _supabaseService.syncPendingData();
      }
      
    } catch (e) {
      debugPrint('Supabase Auth Failed: $e');
    }
  }
}
