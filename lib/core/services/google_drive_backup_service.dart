import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle Google Drive backup and restore for database
/// This ensures data persistence across app reinstalls and devices
/// Updated to use google_sign_in 7.x API
class GoogleDriveBackupService {
  static const String _backupFileName = 'brain_plan_backup.db';
  static const String _savedAccountKey = 'google_drive_account_email';
  static bool _initialized = false;

  /// HTTP client that adds authentication headers
  static http.Client? _authenticatedClient;

  /// Current signed-in user
  static GoogleSignInAccount? _currentUser;

  /// Drive API scopes
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  /// OAuth Web Client ID from Google Cloud Console (not Android client ID)
  static const String _serverClientId = '817677274854-kememf9orcave4p5hr53m8vpintk8e8f.apps.googleusercontent.com';

  /// Initialize Google Sign-In
  static Future<void> initialize() async {
    try {
      if (_initialized) return;

      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );

      // Listen to authentication events
      GoogleSignIn.instance.authenticationEvents.listen(_handleAuthenticationEvent);

      _initialized = true;
      debugPrint('Google Drive backup service initialized');
    } catch (e) {
      debugPrint('Error initializing Google Drive backup: $e');
    }
  }

  static void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    _currentUser = user;

    if (user != null) {
      await _setupAuthenticatedClient(user);
      // Save the account email for future silent sign-ins
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedAccountKey, user.email);
      debugPrint('Saved Google account: ${user.email}');
    } else {
      _authenticatedClient = null;
      // Clear saved account on sign-out
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedAccountKey);
    }
  }


  static Future<void> _setupAuthenticatedClient(GoogleSignInAccount user) async {
    try {
      debugPrint('Requesting authorization for scopes: $_scopes');
      // Use authorizeScopes() to trigger consent dialog (not authorizationForScopes!)
      final authorization = await user.authorizationClient.authorizeScopes(_scopes);
      _authenticatedClient = _GoogleAuthClient(authorization.accessToken);
      debugPrint('✓ Authenticated client set up for ${user.email} with access token');
    } catch (e) {
      debugPrint('✗ Error setting up authenticated client: $e');
    }
  }

  /// Sign in to Google account
  static Future<String?> signIn() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Use authenticate() to request Drive access
      debugPrint('Requesting authentication with Drive scopes: $_scopes');
      await GoogleSignIn.instance.authenticate();

      // Wait for user to be available via authentication event callback
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_currentUser != null) {
          break;
        }
      }

      if (_currentUser == null) {
        debugPrint('Sign-in cancelled by user');
        return null;
      }

      debugPrint('User signed in: ${_currentUser!.email}');

      if (_authenticatedClient != null) {
        debugPrint('✓ Signed in as ${_currentUser!.email} with authenticated client ready');
        return _currentUser!.email;
      } else {
        debugPrint('✗ Failed to set up authenticated client');
        return null;
      }
    } catch (e) {
      debugPrint('Error signing in to Google Drive: $e');
      return null;
    }
  }

  /// Check if user is signed in
  static bool get isSignedIn => _currentUser != null;

  /// Get current user email
  static String? get userEmail => _currentUser?.email;

  /// Sign out
  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.disconnect();
      _currentUser = null;
      _authenticatedClient = null;
      debugPrint('Signed out from Google Drive');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Upload database backup to Google Drive
  static Future<bool> uploadBackup() async {
    try {
      if (_authenticatedClient == null) {
        debugPrint('Not signed in to Google Drive');
        return false;
      }

      // Get database file path
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocDir.path, 'brain_plan.db');
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        debugPrint('Database file not found at $dbPath');
        return false;
      }

      // Create Drive API instance
      final driveApi = drive.DriveApi(_authenticatedClient!);

      // Search for existing backup file
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      final media = drive.Media(dbFile.openRead(), await dbFile.length());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file - don't include parents field for updates
        final fileId = fileList.files!.first.id!;
        final updateFile = drive.File()..name = _backupFileName;
        await driveApi.files.update(
          updateFile,
          fileId,
          uploadMedia: media,
        );
        debugPrint('Updated existing backup in Google Drive');
      } else {
        // Create new file - parents field only for creation
        final createFile = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];
        await driveApi.files.create(
          createFile,
          uploadMedia: media,
        );
        debugPrint('Created new backup in Google Drive');
      }

      return true;
    } catch (e) {
      debugPrint('Error uploading backup to Google Drive: $e');
      return false;
    }
  }

  /// Download database backup from Google Drive
  static Future<bool> downloadBackup() async {
    try {
      if (_authenticatedClient == null) {
        debugPrint('Not signed in to Google Drive');
        return false;
      }

      final driveApi = drive.DriveApi(_authenticatedClient!);

      // Search for backup file
      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        debugPrint('No backup found in Google Drive');
        return false;
      }

      final fileId = fileList.files!.first.id!;

      // Download file
      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to local storage
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocDir.path, 'brain_plan.db');
      final dbFile = File(dbPath);

      final sink = dbFile.openWrite();
      await media.stream.pipe(sink);
      await sink.close();

      debugPrint('Downloaded backup from Google Drive to $dbPath');
      return true;
    } catch (e) {
      debugPrint('Error downloading backup from Google Drive: $e');
      return false;
    }
  }

  /// Check if backup exists in Google Drive
  static Future<bool> hasBackup() async {
    try {
      if (_authenticatedClient == null) {
        return false;
      }

      final driveApi = drive.DriveApi(_authenticatedClient!);

      final fileList = await driveApi.files.list(
        q: "name='$_backupFileName' and trashed=false",
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      return fileList.files != null && fileList.files!.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking for backup in Google Drive: $e');
      return false;
    }
  }

  /// Helper function for debug prints
  static void debugPrint(String message) {
    // ignore: avoid_print
    print(message);
  }
}

/// HTTP client that adds authentication headers for Google APIs
class _GoogleAuthClient extends http.BaseClient {

  _GoogleAuthClient(this._accessToken);
  final String _accessToken;
  final http.Client _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}
