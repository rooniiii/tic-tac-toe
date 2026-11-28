import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens the app's SQLite database encrypted with SQLCipher (AES-256).
///
/// The 256-bit database key is random per install and is kept in
/// [FlutterSecureStorage] (Android Keystore), never in code or plain files.
/// A database created by an older, unencrypted app version is converted to
/// an encrypted one the first time this runs.
QueryExecutor openEncryptedDatabase(String name) {
  return DatabaseConnection.delayed(Future(() async {
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    _useSqlCipher();

    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, '$name.sqlite'));

    final tempDirectory = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = tempDirectory;

    final key = await _databaseKey();

    if (_isPlaintextDatabase(file)) {
      _encryptExistingDatabase(file, key);
    }

    return DatabaseConnection(
      NativeDatabase.createInBackground(
        file,
        isolateSetup: () {
          _useSqlCipher();
          sqlite3.tempDirectory = tempDirectory;
        },
        setup: (db) => _unlock(db, key),
      ),
    );
  }));
}

const String _keyName = 'neon_xo_db_key_v1';

void _useSqlCipher() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

Future<String> _databaseKey() async {
  const storage = FlutterSecureStorage();

  final existing = await storage.read(key: _keyName);
  if (existing != null && existing.isNotEmpty) return existing;

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final key = base64UrlEncode(bytes);

  await storage.write(key: _keyName, value: key);
  return key;
}

void _unlock(Database db, String key) {
  // Without SQLCipher, PRAGMA key is silently ignored and the data would be
  // stored in plain text, so stop instead.
  if (db.select('PRAGMA cipher_version;').isEmpty) {
    throw StateError('SQLCipher is not available; refusing to open the '
        'database without encryption.');
  }

  db.execute("PRAGMA key = '${_quote(key)}';");

  // Fails here if the key is wrong, instead of on the first real query.
  db.select('SELECT count(*) FROM sqlite_master;');
}

String _quote(String value) => value.replaceAll("'", "''");

/// True if [file] is an existing SQLite file that is not encrypted.
/// Unencrypted files start with the text "SQLite format 3".
bool _isPlaintextDatabase(File file) {
  if (!file.existsSync() || file.lengthSync() < 16) return false;

  final raf = file.openSync();
  try {
    final header = raf.readSync(16);
    return ascii.decode(header.sublist(0, 15), allowInvalid: true) ==
        'SQLite format 3';
  } finally {
    raf.closeSync();
  }
}

/// Copies an old plain database into a new encrypted file, then replaces it.
void _encryptExistingDatabase(File file, String key) {
  final encryptedPath = '${file.path}.encrypting';
  final encryptedFile = File(encryptedPath);
  if (encryptedFile.existsSync()) encryptedFile.deleteSync();

  final db = sqlite3.open(file.path);
  try {
    if (db.select('PRAGMA cipher_version;').isEmpty) {
      throw StateError('SQLCipher is not available.');
    }

    db.execute("ATTACH DATABASE '${_quote(encryptedPath)}' AS encrypted "
        "KEY '${_quote(key)}';");
    db.execute("SELECT sqlcipher_export('encrypted');");

    final version = db.select('PRAGMA user_version;').first.values.first;
    db.execute('PRAGMA encrypted.user_version = $version;');
    db.execute('DETACH DATABASE encrypted;');
  } finally {
    db.dispose();
  }

  for (final suffix in ['-wal', '-shm', '-journal']) {
    final leftover = File('${file.path}$suffix');
    if (leftover.existsSync()) leftover.deleteSync();
  }

  encryptedFile.renameSync(file.path);
}
