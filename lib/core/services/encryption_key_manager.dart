import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages encryption keys for the SQLCipher encrypted database
///
/// This service handles secure generation, storage, and retrieval of the
/// database encryption key using flutter_secure_storage which provides:
/// - Android: Encrypted storage backed by KeyStore
/// - iOS: Encrypted storage backed by Keychain
class EncryptionKeyManager {
  static const String _keyName = 'brain_plan_db_encryption_key';

  // Allow injection for testing
  static FlutterSecureStorage? _testStorage;

  static FlutterSecureStorage get _storage {
    return _testStorage ?? const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }

  /// Set custom storage for testing (package-private)
  @visibleForTesting
  static void setTestStorage(FlutterSecureStorage? storage) {
    _testStorage = storage;
  }

  /// Gets the encryption key, generating a new one if it doesn't exist
  ///
  /// The key is stored securely in the device's secure storage:
  /// - Android: KeyStore-backed encrypted SharedPreferences
  /// - iOS: Keychain
  ///
  /// Returns a 256-bit (32-byte) key in hexadecimal format
  static Future<String> getOrCreateKey() async {
    try {
      // Try to retrieve existing key
      final existingKey = await _storage.read(key: _keyName);

      if (existingKey != null && existingKey.isNotEmpty) {
        return existingKey;
      }

      // Generate new 256-bit encryption key
      final key = _generateSecureKey();

      // Store it securely
      await _storage.write(key: _keyName, value: key);

      return key;
    } catch (e) {
      throw Exception('Failed to get or create encryption key: $e');
    }
  }

  /// Generates a cryptographically secure 256-bit (32-byte) encryption key
  ///
  /// Uses dart:math Random.secure() to generate cryptographically strong
  /// random bytes, then converts to hexadecimal string
  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Deletes the encryption key from secure storage
  ///
  /// WARNING: This will make the existing encrypted database unreadable.
  /// Only use this during:
  /// - App uninstall/data reset
  /// - Testing/development
  /// - User-initiated data deletion
  static Future<void> deleteKey() async {
    try {
      await _storage.delete(key: _keyName);
    } catch (e) {
      throw Exception('Failed to delete encryption key: $e');
    }
  }

  /// Checks if an encryption key exists in secure storage
  static Future<bool> hasKey() async {
    try {
      final key = await _storage.read(key: _keyName);
      return key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
