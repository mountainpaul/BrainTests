import 'package:brain_tests/core/services/encryption_key_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'encryption_key_manager_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionKeyManager', () {
    late MockFlutterSecureStorage mockStorage;
    String? storedKey;

    setUp(() {
      storedKey = null;
      mockStorage = MockFlutterSecureStorage();

      // Setup mock behavior
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => storedKey);

      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((invocation) async {
        storedKey = invocation.namedArguments[const Symbol('value')] as String;
      });

      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {
        storedKey = null;
      });

      // Inject mock storage
      EncryptionKeyManager.setTestStorage(mockStorage);
    });

    tearDown(() {
      // Reset to real storage
      EncryptionKeyManager.setTestStorage(null);
    });

    test('should generate and store a new encryption key', () async {
      // Act
      final key = await EncryptionKeyManager.getOrCreateKey();

      // Assert
      expect(key, isNotNull);
      expect(key, isNotEmpty);
      expect(key.length, equals(64)); // 32 bytes = 64 hex characters

      // Verify key is hexadecimal
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(key), isTrue);
    });

    test('should return the same key on subsequent calls', () async {
      // Act
      final key1 = await EncryptionKeyManager.getOrCreateKey();
      final key2 = await EncryptionKeyManager.getOrCreateKey();

      // Assert
      expect(key1, equals(key2));
    });

    test('should indicate when key exists', () async {
      // Arrange - No key initially
      expect(await EncryptionKeyManager.hasKey(), isFalse);

      // Act - Create key
      await EncryptionKeyManager.getOrCreateKey();

      // Assert
      expect(await EncryptionKeyManager.hasKey(), isTrue);
    });

    test('should delete encryption key', () async {
      // Arrange - Create key
      await EncryptionKeyManager.getOrCreateKey();
      expect(await EncryptionKeyManager.hasKey(), isTrue);

      // Act - Delete key
      await EncryptionKeyManager.deleteKey();

      // Assert
      expect(await EncryptionKeyManager.hasKey(), isFalse);
    });

    test('should generate different keys when deleted and recreated', () async {
      // Arrange - Create first key
      final key1 = await EncryptionKeyManager.getOrCreateKey();

      // Act - Delete and create new key
      await EncryptionKeyManager.deleteKey();
      final key2 = await EncryptionKeyManager.getOrCreateKey();

      // Assert - Keys should be different (cryptographically)
      expect(key1, isNot(equals(key2)));
    });
  });
}
