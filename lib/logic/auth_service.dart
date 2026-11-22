import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../database/app_database.dart';

class LoginResult {
  final User? user;
  final String? error;

  const LoginResult.success(this.user) : error = null;
  const LoginResult.failure(this.error) : user = null;
}

class AuthService {
  static const int maxAttempts = 3;
  static const int lockSeconds = 30;

  static const String _invalidCredentials =
      'Incorrect email or password';

  static const String _activeSessionKey = 'active_session_email';

  final AppDatabase _db = AppDatabase.instance;

  final firebase.FirebaseAuth _firebaseAuth =
      firebase.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  firebase.User? get currentFirebaseUser =>
      _firebaseAuth.currentUser;

  Stream<firebase.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // DEBUG TIMING HELPER
  void _logAuthTiming(
      String action,
      String step,
      Stopwatch stopwatch,
      ) {
    debugPrint(
      'AUTH_TIMING [$action] $step: '
          '${stopwatch.elapsedMilliseconds} ms',
    );
  }

  // Save verified timestamp in the background.
  // Login does not wait for this network request.
  void _updateEmailVerifiedAtInBackground(String uid) {
    unawaited(
      _firestore
          .collection('users')
          .doc(uid)
          .update({
        'emailVerifiedAt': FieldValue.serverTimestamp(),
      })
          .then((_) {
        debugPrint(
          'AUTH_BACKGROUND: Email verification timestamp saved.',
        );
      })
          .catchError((Object error) {
        debugPrint(
          'AUTH_BACKGROUND: Email verification timestamp update failed: $error',
        );
      }),
    );
  }

  Future<void> _saveActiveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _activeSessionKey,
      email.trim().toLowerCase(),
    );
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeSessionKey);
    }
  }

  // Only temporary network failures permit offline session restoration.
  bool _isTemporaryFirebaseError(FirebaseException e) {
    return e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed' ||
        e.code == 'web-network-request-failed';
  }

  Future<LoginResult> restoreSession() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return _restoreLocalSession();
    }

    try {
      await firebaseUser.reload().timeout(
        const Duration(seconds: 15),
      );

      final refreshedUser =
          _firebaseAuth.currentUser ?? firebaseUser;

      final profile = await _firestore
          .collection('users')
          .doc(refreshedUser.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!profile.exists) {
        await logout();

        return const LoginResult.failure(
          'User profile not found.',
        );
      }

      final data = profile.data()!;

      final verificationRequired =
          data['emailVerificationRequired'] == true;

      if (verificationRequired &&
          !refreshedUser.emailVerified) {
        await logout();

        return const LoginResult.failure(
          'Please verify your email before logging in.',
        );
      }

      final phone = data['phone'] as String?;
      final email = refreshedUser.email;

      if (phone == null ||
          phone.isEmpty ||
          email == null ||
          email.isEmpty) {
        await logout();

        return const LoginResult.failure(
          'Player profile information is incomplete.',
        );
      }

      final localUser = await _db.findUserByPhone(phone);

      if (localUser == null) {
        await logout();

        return const LoginResult.failure(
          'Local player profile not found. Please login again.',
        );
      }

      await _saveActiveSession(email);

      return LoginResult.success(_toUser(localUser));
    } on TimeoutException {
      return _restoreLocalSession();
    } on FirebaseException catch (e) {
      if (_isTemporaryFirebaseError(e)) {
        return _restoreLocalSession();
      }

      return LoginResult.failure(
        'Unable to restore session: ${e.code}',
      );
    } catch (e) {
      return LoginResult.failure(
        'Unable to restore session: $e',
      );
    }
  }

  Future<LoginResult> _restoreLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString(_activeSessionKey);

      if (email == null || email.isEmpty) {
        return const LoginResult.failure(
          'No active session found.',
        );
      }

      final phone = prefs.getString(_offlinePhoneKey(email));

      if (phone == null || phone.isEmpty) {
        await prefs.remove(_activeSessionKey);

        return const LoginResult.failure(
          'Saved player session not found.',
        );
      }

      final localUser = await _db.findUserByPhone(phone);

      if (localUser == null) {
        await prefs.remove(_activeSessionKey);

        return const LoginResult.failure(
          'Local player profile not found.',
        );
      }

      return LoginResult.success(_toUser(localUser));
    } catch (e) {
      return LoginResult.failure(
        'Unable to restore session: $e',
      );
    }
  }

  String _generateSalt() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
          (_) => random.nextInt(256),
    );

    return base64UrlEncode(bytes);
  }

  String _hash(String password, String salt) {
    return sha256.convert(
      utf8.encode(salt + password),
    ).toString();
  }

  User _toUser(AppUser data) {
    return User(
      name: data.name,
      phone: data.phone,
      passwordHash: data.passwordHash,
      salt: data.salt,
    );
  }

  String _offlinePhoneKey(String email) {
    return 'offline_phone_${email.trim().toLowerCase()}';
  }

  String _failsKey(String email) =>
      'login_fails_${email.trim().toLowerCase()}';

  String _lockUntilKey(String email) =>
      'login_lock_until_${email.trim().toLowerCase()}';

  String _lockLevelKey(String email) =>
      'login_lock_level_${email.trim().toLowerCase()}';

  int _lockDuration(int level) {
    const durations = [
      10,
      60,
      120,
      300,
      600,
      1800,
      3600,
    ];

    final index = (level - 1).clamp(
      0,
      durations.length - 1,
    );

    return durations[index];
  }

  Future<String?> _checkEmailLock(String email) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockedUntil =
        prefs.getInt(_lockUntilKey(email)) ?? 0;

    if (now < lockedUntil) {
      final seconds = ((lockedUntil - now) / 1000).ceil();

      return 'Too many incorrect attempts. Please wait $seconds seconds.';
    }

    return null;
  }

  Future<LoginResult> _recordFailedAttempt(
      String email,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final failsKey = _failsKey(email);
    final lockKey = _lockUntilKey(email);
    final levelKey = _lockLevelKey(email);

    final fails = (prefs.getInt(failsKey) ?? 0) + 1;

    if (fails < 3) {
      await prefs.setInt(failsKey, fails);

      final remaining = 3 - fails;

      return LoginResult.failure(
        '$_invalidCredentials. $remaining attempt(s) remaining before temporary lock.',
      );
    }

    final level = (prefs.getInt(levelKey) ?? 0) + 1;
    final seconds = _lockDuration(level);

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockedUntil = now + (seconds * 1000);

    await prefs.setInt(failsKey, 0);
    await prefs.setInt(levelKey, level);
    await prefs.setInt(lockKey, lockedUntil);

    return LoginResult.failure(
      '3 incorrect attempts. Login locked for $seconds seconds.',
    );
  }

  Future<void> _clearEmailAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_failsKey(email));
    await prefs.remove(_lockUntilKey(email));
    await prefs.remove(_lockLevelKey(email));
  }

  Future<LoginResult> _trackOfflineResult(
      String email,
      LoginResult result,
      ) async {
    if (result.user != null) {
      await _clearEmailAttempts(email);
      await _saveActiveSession(email);

      return result;
    }

    if (result.error == _invalidCredentials) {
      return _recordFailedAttempt(email);
    }

    return result;
  }

  Future<void> _migrateOldUsers() async {
    final prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 10));

    if (prefs.getBool('sqlite_users_migrated') == true) {
      return;
    }

    final raw = prefs.getString('users');

    if (raw != null) {
      final users = jsonDecode(raw) as Map<String, dynamic>;

      for (final entry in users.entries) {
        final data = Map<String, dynamic>.from(entry.value);

        if (data['role'] == 'admin') continue;

        final phone = data['phone'] as String;

        final existingUser = await _db
            .findUserByPhone(phone)
            .timeout(const Duration(seconds: 10));

        if (existingUser == null) {
          await _db.createUser(
            name: data['name'],
            phone: phone,
            passwordHash: data['passwordHash'],
            salt: data['salt'],
          ).timeout(const Duration(seconds: 15));
        }
      }
    }

    await prefs.setBool('sqlite_users_migrated', true);
  }

  Future<void> ensureAdminExists() async {
    await _migrateOldUsers();
  }

  Future<void> _saveOfflineCredentials({
    required String email,
    required String phone,
    required String password,
    required String name,
  }) async {
    final salt = _generateSalt();

    final existing = await _db.findUserByPhone(phone);

    if (existing == null) {
      await _db.createUser(
        name: name,
        phone: phone,
        passwordHash: _hash(password, salt),
        salt: salt,
      );
    } else {
      await _db.updateUserPassword(
        phone: phone,
        passwordHash: _hash(password, salt),
        salt: salt,
      );
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _offlinePhoneKey(email),
      phone,
    );
  }

  Future<LoginResult> _offlineLoginByEmail({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final phone = prefs.getString(_offlinePhoneKey(email));

      if (phone == null || phone.isEmpty) {
        return const LoginResult.failure(
          'Offline login is not set up yet. Please login online once.',
        );
      }

      final localUser = await _db.findUserByPhone(phone);

      if (localUser == null ||
          localUser.passwordHash.isEmpty) {
        return const LoginResult.failure(
          'Offline login data not found. Please login online once.',
        );
      }

      final enteredHash = _hash(password, localUser.salt);

      if (enteredHash != localUser.passwordHash) {
        return const LoginResult.failure(_invalidCredentials);
      }

      return LoginResult.success(_toUser(localUser));
    } catch (e) {
      return LoginResult.failure('Offline login failed: $e');
    }
  }

  Future<String?> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      await _migrateOldUsers();

      final existingUser = await _db
          .findUserByPhone(phone)
          .timeout(const Duration(seconds: 10));

      if (existingUser != null) {
        return 'This phone number is already registered';
      }

      final salt = _generateSalt();

      await _db.createUser(
        name: name.trim(),
        phone: phone,
        passwordHash: _hash(password, salt),
        salt: salt,
      ).timeout(const Duration(seconds: 15));

      return null;
    } on TimeoutException {
      return 'Local signup timed out. Please try again.';
    } catch (e) {
      return 'Signup failed: $e';
    }
  }

  // FIREBASE SIGNUP WITH TIMING LOGS
  Future<String?> signUpWithFirebase({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    firebase.User? firebaseUser;
    bool accountCreated = false;

    final normalizedEmail = email.trim().toLowerCase();
    final timer = Stopwatch()..start();

    debugPrint('AUTH_TIMING [SIGNUP] Started');

    try {
      final existingUser = await _db
          .findUserByPhone(phone)
          .timeout(const Duration(seconds: 10));

      _logAuthTiming('SIGNUP', 'SQLite phone check completed', timer);

      if (existingUser != null) {
        return 'This phone number is already registered';
      }

      final credential = await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      ).timeout(const Duration(seconds: 20));

      _logAuthTiming('SIGNUP', 'Firebase account creation completed', timer);

      firebaseUser = credential.user;

      if (firebaseUser == null) {
        return 'Firebase account could not be created.';
      }

      accountCreated = true;

      await firebaseUser
          .updateDisplayName(name.trim())
          .timeout(const Duration(seconds: 15));

      _logAuthTiming('SIGNUP', 'Display name update completed', timer);

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        'uid': firebaseUser.uid,
        'name': name.trim(),
        'email': normalizedEmail,
        'phone': phone,
        'emailVerificationRequired': true,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 20));

      _logAuthTiming('SIGNUP', 'Firestore profile save completed', timer);

      try {
        await firebaseUser
            .sendEmailVerification()
            .timeout(const Duration(seconds: 20));

        _logAuthTiming('SIGNUP', 'Verification email request completed', timer);
      } catch (_) {
        _logAuthTiming('SIGNUP', 'Verification email request failed', timer);

        await _firebaseAuth.signOut();

        return 'Account created, but verification email could not be sent. Please check your internet and try login again to resend it.';
      }

      await _firebaseAuth.signOut();

      _logAuthTiming('SIGNUP', 'Sign out completed', timer);
      _logAuthTiming('SIGNUP', 'TOTAL COMPLETED', timer);

      return null;
    } on firebase.FirebaseAuthException catch (e) {
      _logAuthTiming('SIGNUP', 'Firebase Auth error: ${e.code}', timer);

      if (accountCreated) {
        try {
          await _firebaseAuth.signOut();
        } catch (_) {}

        return 'Account created, but verification setup failed. Please try login again.';
      }

      return _firebaseError(e.code);
    } on TimeoutException {
      _logAuthTiming('SIGNUP', 'TIMEOUT', timer);

      if (accountCreated) {
        try {
          await _firebaseAuth.signOut();
        } catch (_) {}

        return 'Account created, but setup timed out. Please try login again.';
      }

      return 'Request timed out. Check your internet and try again.';
    } catch (e) {
      _logAuthTiming('SIGNUP', 'ERROR: $e', timer);

      if (accountCreated) {
        try {
          await _firebaseAuth.signOut();
        } catch (_) {}

        return 'Account created, but profile setup failed. Please try login again.';
      }

      return 'Account creation failed: $e';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth
          .sendPasswordResetEmail(
        email: email.trim(),
      )
          .timeout(const Duration(seconds: 20));

      return null;
    } on firebase.FirebaseAuthException catch (e) {
      return _firebaseError(e.code);
    } on TimeoutException {
      return 'Request timed out. Please try again.';
    } catch (e) {
      return 'Unable to send reset email: $e';
    }
  }

  Future<User?> login({
    required String phone,
    required String password,
  }) async {
    await _migrateOldUsers();

    final data = await _db
        .findUserByPhone(phone)
        .timeout(const Duration(seconds: 10));

    if (data == null) return null;

    final user = _toUser(data);

    if (_hash(password, user.salt) == user.passwordHash) {
      return user;
    }

    return null;
  }

  Future<LoginResult> secureLogin({
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 10));

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockedUntil = prefs.getInt('lock_$phone') ?? 0;

    if (now < lockedUntil) {
      final secs = ((lockedUntil - now) / 1000).ceil();

      return LoginResult.failure(
        'Too many attempts. Try again in $secs seconds.',
      );
    }

    final user = await login(
      phone: phone,
      password: password,
    );

    if (user != null) {
      await prefs.remove('fails_$phone');
      await prefs.remove('lock_$phone');

      return LoginResult.success(user);
    }

    final fails = (prefs.getInt('fails_$phone') ?? 0) + 1;

    if (fails >= maxAttempts) {
      await prefs.setInt('fails_$phone', 0);
      await prefs.setInt(
        'lock_$phone',
        now + lockSeconds * 1000,
      );

      return const LoginResult.failure(
        '3 wrong attempts. Locked for 30 seconds.',
      );
    }

    await prefs.setInt('fails_$phone', fails);

    return const LoginResult.failure(
      'Wrong phone number or password',
    );
  }

  // FIREBASE LOGIN WITH TIMING LOGS
  Future<LoginResult> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final timer = Stopwatch()..start();

    debugPrint('AUTH_TIMING [LOGIN] Started');

    try {
      final lockMessage =
      await _checkEmailLock(normalizedEmail);

      _logAuthTiming('LOGIN', 'Email lock check completed', timer);

      if (lockMessage != null) {
        return LoginResult.failure(lockMessage);
      }

      try {
        final credential = await _firebaseAuth
            .signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        ).timeout(const Duration(seconds: 20));

        _logAuthTiming('LOGIN', 'Firebase sign-in completed', timer);

        firebase.User? firebaseUser = credential.user;

        if (firebaseUser == null) {
          return const LoginResult.failure(
            'Unable to login. Please try again.',
          );
        }

        await firebaseUser.reload();

        _logAuthTiming('LOGIN', 'Firebase user reload completed', timer);

        firebaseUser =
            _firebaseAuth.currentUser ?? firebaseUser;

        DocumentSnapshot<Map<String, dynamic>> profile;

        try {
          profile = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 15));

          _logAuthTiming('LOGIN', 'Firestore profile fetch completed', timer);
        } on TimeoutException {
          _logAuthTiming('LOGIN', 'Firestore profile fetch timed out', timer);

          await _firebaseAuth.signOut();

          final offlineResult = await _offlineLoginByEmail(
            email: normalizedEmail,
            password: password,
          );

          return _trackOfflineResult(
            normalizedEmail,
            offlineResult,
          );
        } on FirebaseException catch (e) {
          _logAuthTiming('LOGIN', 'Firestore error: ${e.code}', timer);

          await _firebaseAuth.signOut();

          if (_isTemporaryFirebaseError(e)) {
            final offlineResult = await _offlineLoginByEmail(
              email: normalizedEmail,
              password: password,
            );

            return _trackOfflineResult(
              normalizedEmail,
              offlineResult,
            );
          }

          return LoginResult.failure(
            'Unable to load player profile: ${e.code}',
          );
        }

        if (!profile.exists) {
          await _firebaseAuth.signOut();

          return const LoginResult.failure(
            'User profile not found in Firestore.',
          );
        }

        final data = profile.data()!;

        final verificationRequired =
            data['emailVerificationRequired'] == true;

        if (verificationRequired &&
            !firebaseUser.emailVerified) {
          try {
            await firebaseUser.sendEmailVerification();
            _logAuthTiming('LOGIN', 'Verification email resend completed', timer);
          } catch (_) {
            _logAuthTiming('LOGIN', 'Verification email resend failed', timer);
          }

          await _firebaseAuth.signOut();

          return const LoginResult.failure(
            'Please verify your email first. We have sent a verification link to your inbox. Check your spam folder too.',
          );
        }

        // Only write the timestamp if it does not already exist.
        // Do not make successful Login wait for this Firestore write.
        if (verificationRequired &&
            firebaseUser.emailVerified &&
            data['emailVerifiedAt'] == null) {
          _logAuthTiming(
            'LOGIN',
            'Starting background verification update',
            timer,
          );

          _updateEmailVerifiedAtInBackground(firebaseUser.uid);
        }

        final phone = data['phone'] as String?;
        final name = data['name'] as String? ?? 'Player';

        if (phone == null || phone.isEmpty) {
          await _firebaseAuth.signOut();

          return const LoginResult.failure(
            'Phone number not found in profile.',
          );
        }

        await _saveOfflineCredentials(
          email: normalizedEmail,
          phone: phone,
          password: password,
          name: name,
        );

        _logAuthTiming('LOGIN', 'Offline credentials save completed', timer);

        final localUser = await _db.findUserByPhone(phone);

        _logAuthTiming('LOGIN', 'SQLite user fetch completed', timer);

        if (localUser == null) {
          await _firebaseAuth.signOut();

          return const LoginResult.failure(
            'Local player profile could not be created.',
          );
        }

        await _clearEmailAttempts(normalizedEmail);
        await _saveActiveSession(normalizedEmail);

        _logAuthTiming('LOGIN', 'Session save completed', timer);
        _logAuthTiming('LOGIN', 'TOTAL COMPLETED', timer);

        return LoginResult.success(_toUser(localUser));
      } on firebase.FirebaseAuthException catch (e) {
        _logAuthTiming('LOGIN', 'Firebase Auth error: ${e.code}', timer);

        if (e.code == 'network-request-failed' ||
            e.code == 'web-network-request-failed') {
          final offlineResult = await _offlineLoginByEmail(
            email: normalizedEmail,
            password: password,
          );

          return _trackOfflineResult(
            normalizedEmail,
            offlineResult,
          );
        }

        if (e.code == 'wrong-password' ||
            e.code == 'user-not-found' ||
            e.code == 'invalid-credential') {
          return _recordFailedAttempt(normalizedEmail);
        }

        return LoginResult.failure(_firebaseError(e.code));
      } on TimeoutException {
        _logAuthTiming('LOGIN', 'TIMEOUT', timer);

        try {
          await _firebaseAuth.signOut();
        } catch (_) {}

        final offlineResult = await _offlineLoginByEmail(
          email: normalizedEmail,
          password: password,
        );

        return _trackOfflineResult(
          normalizedEmail,
          offlineResult,
        );
      }
    } catch (e) {
      _logAuthTiming('LOGIN', 'ERROR: $e', timer);

      return LoginResult.failure('Login failed: $e');
    }
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';

      case 'invalid-email':
        return 'Please enter a valid email address';

      case 'weak-password':
        return 'Password is too weak';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return _invalidCredentials;

      case 'network-request-failed':
      case 'web-network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'user-disabled':
        return 'This account has been disabled. Contact the administrator.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'permission-denied':
        return 'Firestore permission denied. Check your security rules.';

      default:
        return 'Authentication failed: $code';
    }
  }

  Future<List<User>> getPlayers() async {
    await _migrateOldUsers();

    final records = await _db
        .select(_db.appUsers)
        .get()
        .timeout(const Duration(seconds: 15));

    return records.map(_toUser).toList();
  }

  Future<bool> deleteUser(String phone) async {
    await _migrateOldUsers();

    final existingUser = await _db
        .findUserByPhone(phone)
        .timeout(const Duration(seconds: 10));

    if (existingUser == null) return false;

    await (_db.delete(_db.appUsers)
      ..where((user) => user.phone.equals(phone)))
        .go()
        .timeout(const Duration(seconds: 15));

    return true;
  }
}