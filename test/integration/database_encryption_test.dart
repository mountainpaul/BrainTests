import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import 'package:brain_tests/core/services/encryption_key_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Database Encryption Test', () {
    test('database should be encrypted', () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'test_encrypted.db'));

      if (await file.exists()) {
        await file.delete();
      }

      // This is the key part: we're using the real encryption key manager
      final key = await EncryptionKeyManager.getOrCreateKey();

      // Set up the dynamic library for sqlcipher
      if (Platform.isAndroid) {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      } else if (Platform.isIOS) {
        open.overrideFor(OperatingSystem.iOS, openCipherOnIOS);
      }

      final db = NativeDatabase(file, setup: (db) {
        db.execute('PRAGMA key = "$key";');
        db.execute('PRAGMA cipher_page_size = 4096;');
      });

      // Write something to the database
      await db.customStatement('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);');
      await db.customStatement('INSERT INTO test (name) VALUES ("test");');
      await db.close();

      // Now, try to open it without the key
      final unencryptedDb = NativeDatabase(file);
      try {
        await unencryptedDb.customStatement('SELECT * FROM test;');
        fail('Should not be able to read from encrypted database without a key');
      } catch (e) {
        expect(e, isA<Exception>());
      }
      await unencryptedDb.close();

      // Now, try to open it WITH the key
      final encryptedDb = NativeDatabase(file, setup: (db) {
        db.execute('PRAGMA key = "$key";');
      });
      final result = await encryptedDb.customStatement('SELECT * FROM test;');
      expect(result.first.data['name'], 'test');
      await encryptedDb.close();
    });
  });
}
