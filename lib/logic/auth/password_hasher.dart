import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hashes passwords that are stored on the device (offline login and local
/// two-player accounts).
///
/// New hashes use PBKDF2-HMAC-SHA256 with [iterations] rounds, which makes
/// guessing a password from a stolen hash much slower than a single SHA-256.
/// Hashes created by older versions of the app (plain SHA-256) still verify,
/// and [needsUpgrade] tells the caller to re-save them in the new format.
class PasswordHasher {
  PasswordHasher._();

  static const int iterations = 10000;
  static const String _prefix = 'pbkdf2-sha256';

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Returns a self-describing hash: `pbkdf2-sha256$<iterations>$<base64>`.
  static String hash(String password, String salt) {
    final derived = _pbkdf2(
      utf8.encode(password),
      utf8.encode(salt),
      iterations,
    );
    return '$_prefix\$$iterations\$${base64UrlEncode(derived)}';
  }

  static bool verify(String password, String salt, String storedHash) {
    if (storedHash.isEmpty) return false;

    if (!storedHash.startsWith('$_prefix\$')) {
      return _constantTimeEquals(_legacyHash(password, salt), storedHash);
    }

    final parts = storedHash.split('\$');
    if (parts.length != 3) return false;

    final rounds = int.tryParse(parts[1]);
    if (rounds == null || rounds <= 0) return false;

    final derived = _pbkdf2(
      utf8.encode(password),
      utf8.encode(salt),
      rounds,
    );

    return _constantTimeEquals(base64UrlEncode(derived), parts[2]);
  }

  /// True for hashes made by older app versions.
  static bool needsUpgrade(String storedHash) =>
      !storedHash.startsWith('$_prefix\$$iterations\$');

  // Original format: sha256(salt + password) as hex.
  static String _legacyHash(String password, String salt) {
    return sha256.convert(utf8.encode(salt + password)).toString();
  }

  // PBKDF2 with HMAC-SHA256, one 32-byte output block.
  static List<int> _pbkdf2(List<int> password, List<int> salt, int rounds) {
    final hmac = Hmac(sha256, password);

    final firstInput = Uint8List(salt.length + 4)
      ..setAll(0, salt)
      ..setAll(salt.length, const [0, 0, 0, 1]);

    var block = hmac.convert(firstInput).bytes;
    final result = Uint8List.fromList(block);

    for (var i = 1; i < rounds; i++) {
      block = hmac.convert(block).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }

    return result;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
