import 'package:tic_tac_toe/security/secure_prefs.dart';

import '../../database/app_database.dart';
import 'password_hasher.dart';

/// Result of an offline login attempt.
class OfflineLoginResult {
  final AppUser? user;
  final String? error;

  /// True when the error is a wrong password (counts as a failed attempt).
  final bool wrongPassword;

  const OfflineLoginResult.success(AppUser this.user)
      : error = null,
        wrongPassword = false;

  const OfflineLoginResult.failure(String this.error,
      {this.wrongPassword = false})
      : user = null;
}

/// Keeps what the game needs to let a player log in without internet:
/// a hashed copy of their password in SQLite, the email -> phone link,
/// and a "blocked" flag when an admin has blocked the account.
class OfflineCredentialsStore {
  final AppDatabase _db;

  OfflineCredentialsStore(this._db);

  String _key(String email) => email.trim().toLowerCase();

  String _phoneKey(String email) => 'offline_phone_${_key(email)}';
  String _blockedKey(String email) => 'account_blocked_${_key(email)}';

  Future<String?> phoneForEmail(String email) async {
    final prefs = await SecurePrefs.getInstance();
    return prefs.getString(_phoneKey(email));
  }

  /// Saves (or refreshes) the offline login after a successful online login.
  Future<void> save({
    required String email,
    required String phone,
    required String password,
    required String name,
  }) async {
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);

    final existing = await _db.findUserByPhone(phone);

    if (existing == null) {
      await _db.createUser(
        name: name,
        phone: phone,
        passwordHash: hash,
        salt: salt,
      );
    } else {
      await _db.updateUserPassword(
        phone: phone,
        passwordHash: hash,
        salt: salt,
      );
    }

    final prefs = await SecurePrefs.getInstance();
    await prefs.setString(_phoneKey(email), phone);
  }

  Future<OfflineLoginResult> login({
    required String email,
    required String password,
    required String invalidCredentialsMessage,
    required String blockedMessage,
  }) async {
    try {
      if (await isBlocked(email)) {
        return OfflineLoginResult.failure(blockedMessage);
      }

      final phone = await phoneForEmail(email);

      if (phone == null || phone.isEmpty) {
        return const OfflineLoginResult.failure(
          'Offline login is not set up yet. Please login online once.',
        );
      }

      final localUser = await _db.findUserByPhone(phone);

      if (localUser == null || localUser.passwordHash.isEmpty) {
        return const OfflineLoginResult.failure(
          'Offline login data not found. Please login online once.',
        );
      }

      final ok = PasswordHasher.verify(
        password,
        localUser.salt,
        localUser.passwordHash,
      );

      if (!ok) {
        return OfflineLoginResult.failure(
          invalidCredentialsMessage,
          wrongPassword: true,
        );
      }

      // Re-save hashes from older app versions in the stronger format.
      if (PasswordHasher.needsUpgrade(localUser.passwordHash)) {
        final salt = PasswordHasher.generateSalt();
        await _db.updateUserPassword(
          phone: phone,
          passwordHash: PasswordHasher.hash(password, salt),
          salt: salt,
        );
      }

      return OfflineLoginResult.success(localUser);
    } catch (e) {
      return OfflineLoginResult.failure('Offline login failed: $e');
    }
  }

  /// Called when an admin block is detected: remember it and remove the
  /// saved offline login so the player cannot keep playing offline.
  Future<void> markBlocked(String email) async {
    if (_key(email).isEmpty) return;

    final prefs = await SecurePrefs.getInstance();
    await prefs.setBool(_blockedKey(email), true);
    await prefs.remove(_phoneKey(email));
  }

  Future<void> clearBlocked(String email) async {
    final prefs = await SecurePrefs.getInstance();
    await prefs.remove(_blockedKey(email));
  }

  Future<bool> isBlocked(String email) async {
    final prefs = await SecurePrefs.getInstance();
    return prefs.getBool(_blockedKey(email)) ?? false;
  }

  /// Removes everything stored for this email (used when the account is
  /// deleted).
  Future<void> forget(String email) async {
    final prefs = await SecurePrefs.getInstance();
    await prefs.remove(_phoneKey(email));
    await prefs.remove(_blockedKey(email));
  }
}
