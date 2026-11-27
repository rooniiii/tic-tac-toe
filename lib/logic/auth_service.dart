import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../database/app_database.dart';
import '../services/account_status_service.dart';
import '../services/leaderboard_service.dart';
import 'auth/login_attempt_limiter.dart';
import 'auth/offline_credentials_store.dart';
import 'auth/password_hasher.dart';

class LoginResult {
  final User? user;
  final String? error;

  const LoginResult.success(this.user) : error = null;
  const LoginResult.failure(this.error) : user = null;
}

class AuthService {
  static const int maxAttempts = 3;
  static const int lockSeconds = 30;

  static const String _invalidCredentials = 'Incorrect email or password';

  static const String blockedMessage =
      'This account has been blocked by an administrator. '
      'Contact support if you think this is a mistake.';

  static const String _activeSessionKey = 'active_session_email';

  final AppDatabase _db = AppDatabase.instance;
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoginAttemptLimiter _limiter = LoginAttemptLimiter();

  late final OfflineCredentialsStore _offline = OfflineCredentialsStore(_db);

  firebase.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<firebase.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Small helpers
  // ---------------------------------------------------------------------------

  void _logAuthTiming(String action, String step, Stopwatch stopwatch) {
    if (!kDebugMode) return;
    debugPrint(
      'AUTH_TIMING [$action] $step: ${stopwatch.elapsedMilliseconds} ms',
    );
  }

  void _updateEmailVerifiedAtInBackground(String uid) {
    unawaited(
      _firestore
          .collection('users')
          .doc(uid)
          .update({'emailVerifiedAt': FieldValue.serverTimestamp()})
          .catchError((Object error) {
        if (kDebugMode) {
          debugPrint('Email verification timestamp update failed: $error');
        }
      }),
    );
  }

  Future<void> _saveActiveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSessionKey, email.trim().toLowerCase());
  }

  User _toUser(AppUser data) {
    return User(
      name: data.name,
      phone: data.phone,
      passwordHash: data.passwordHash,
      salt: data.salt,
    );
  }

  bool _isTemporaryFirebaseError(FirebaseException e) {
    return e.code == 'unavailable' ||
        e.code == 'deadline-exceeded' ||
        e.code == 'network-request-failed' ||
        e.code == 'web-network-request-failed';
  }

  bool _isBlockedProfile(Map<String, dynamic> data) =>
      AccountStatusService.isBlockedData(data);

  void _onOnlineSessionStarted() {
    AccountStatusService.instance.startWatching();
    unawaited(LeaderboardService().syncMyEntry());
  }

  // ---------------------------------------------------------------------------
  // Blocking and logout
  // ---------------------------------------------------------------------------

  Future<void> handleBlockedAccount(String email) async {
    await _offline.markBlocked(email);
    await logout();
  }

  Future<void> logout() async {
    AccountStatusService.instance.stopWatching();

    try {
      await _firebaseAuth.signOut();
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeSessionKey);
    }
  }

  // ---------------------------------------------------------------------------
  // Session restore
  // ---------------------------------------------------------------------------

  Future<LoginResult> restoreSession() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return _restoreLocalSession();
    }

    try {
      await firebaseUser.reload().timeout(const Duration(seconds: 15));

      final refreshedUser = _firebaseAuth.currentUser ?? firebaseUser;

      final profile = await _firestore
          .collection('users')
          .doc(refreshedUser.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (!profile.exists) {
        await logout();
        return const LoginResult.failure('User profile not found.');
      }

      final data = profile.data()!;

      if (_isBlockedProfile(data)) {
        await handleBlockedAccount(refreshedUser.email ?? '');
        return const LoginResult.failure(blockedMessage);
      }

      await _offline.clearBlocked(refreshedUser.email ?? '');

      final verificationRequired = data['emailVerificationRequired'] == true;

      if (verificationRequired && !refreshedUser.emailVerified) {
        await logout();
        return const LoginResult.failure(
          'Please verify your email before logging in.',
        );
      }

      final phone = data['phone'] as String?;
      final email = refreshedUser.email;

      if (phone == null || phone.isEmpty || email == null || email.isEmpty) {
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
      _onOnlineSessionStarted();

      return LoginResult.success(_toUser(localUser));
    } on TimeoutException {
      return _restoreLocalSession();
    } on FirebaseException catch (e) {
      if (_isTemporaryFirebaseError(e)) {
        return _restoreLocalSession();
      }
      return LoginResult.failure('Unable to restore session: ${e.code}');
    } catch (e) {
      return LoginResult.failure('Unable to restore session: $e');
    }
  }

  Future<LoginResult> _restoreLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString(_activeSessionKey);

      if (email == null || email.isEmpty) {
        return const LoginResult.failure('No active session found.');
      }

      if (await _offline.isBlocked(email)) {
        await prefs.remove(_activeSessionKey);
        return const LoginResult.failure(blockedMessage);
      }

      final phone = await _offline.phoneForEmail(email);

      if (phone == null || phone.isEmpty) {
        await prefs.remove(_activeSessionKey);
        return const LoginResult.failure('Saved player session not found.');
      }

      final localUser = await _db.findUserByPhone(phone);

      if (localUser == null) {
        await prefs.remove(_activeSessionKey);
        return const LoginResult.failure('Local player profile not found.');
      }

      if (_firebaseAuth.currentUser != null) {
        AccountStatusService.instance.startWatching();
      }

      return LoginResult.success(_toUser(localUser));
    } catch (e) {
      return LoginResult.failure('Unable to restore session: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Offline login helpers
  // ---------------------------------------------------------------------------

  Future<LoginResult> _offlineLogin(String email, String password) async {
    final result = await _offline.login(
      email: email,
      password: password,
      invalidCredentialsMessage: _invalidCredentials,
      blockedMessage: blockedMessage,
    );

    if (result.user != null) {
      await _limiter.clear(email);
      await _saveActiveSession(email);
      return LoginResult.success(_toUser(result.user!));
    }

    if (result.wrongPassword) {
      return _recordFailedAttempt(email);
    }

    return LoginResult.failure(result.error);
  }

  Future<LoginResult> _recordFailedAttempt(String email) async {
    final message = await _limiter.recordFailure(email, _invalidCredentials);
    return LoginResult.failure(message);
  }

  // ---------------------------------------------------------------------------
  // Migration
  // ---------------------------------------------------------------------------

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
          await _db
              .createUser(
            name: data['name'],
            phone: phone,
            passwordHash: data['passwordHash'],
            salt: data['salt'],
          )
              .timeout(const Duration(seconds: 15));
        }
      }
    }

    await prefs.setBool('sqlite_users_migrated', true);
  }

  Future<void> ensureAdminExists() async {
    await _migrateOldUsers();
  }

  // ---------------------------------------------------------------------------
  // Sign-up
  // ---------------------------------------------------------------------------

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

      final salt = PasswordHasher.generateSalt();

      await _db
          .createUser(
        name: name.trim(),
        phone: phone,
        passwordHash: PasswordHasher.hash(password, salt),
        salt: salt,
      )
          .timeout(const Duration(seconds: 15));

      return null;
    } on TimeoutException {
      return 'Local signup timed out. Please try again.';
    } catch (e) {
      return 'Signup failed: $e';
    }
  }

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

    _logAuthTiming('SIGNUP', 'Started', timer);

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
      )
          .timeout(const Duration(seconds: 20));

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

      await _firestore.collection('users').doc(firebaseUser.uid).set({
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

        return 'Account created, but verification email could not be sent. '
            'Please check your internet and try login again to resend it.';
      }

      await _firebaseAuth.signOut();

      _logAuthTiming('SIGNUP', 'TOTAL COMPLETED', timer);

      return null;
    } on firebase.FirebaseAuthException catch (e) {
      _logAuthTiming('SIGNUP', 'Firebase Auth error: ${e.code}', timer);

      if (accountCreated) {
        try {
          await _firebaseAuth.signOut();
        } catch (_) {}

        return 'Account created, but verification setup failed. '
            'Please try login again.';
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

        return 'Account created, but profile setup failed. '
            'Please try login again.';
      }

      return 'Account creation failed: $e';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth
          .sendPasswordResetEmail(email: email.trim())
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

  // ---------------------------------------------------------------------------
  // Local login
  // ---------------------------------------------------------------------------

  Future<User?> login({
    required String phone,
    required String password,
  }) async {
    await _migrateOldUsers();

    final data = await _db
        .findUserByPhone(phone)
        .timeout(const Duration(seconds: 10));

    if (data == null) return null;

    if (!PasswordHasher.verify(password, data.salt, data.passwordHash)) {
      return null;
    }

    if (PasswordHasher.needsUpgrade(data.passwordHash)) {
      final salt = PasswordHasher.generateSalt();
      await _db.updateUserPassword(
        phone: phone,
        passwordHash: PasswordHasher.hash(password, salt),
        salt: salt,
      );

      final upgraded = await _db.findUserByPhone(phone);
      if (upgraded != null) return _toUser(upgraded);
    }

    return _toUser(data);
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

    final user = await login(phone: phone, password: password);

    if (user != null) {
      await prefs.remove('fails_$phone');
      await prefs.remove('lock_$phone');
      return LoginResult.success(user);
    }

    final fails = (prefs.getInt('fails_$phone') ?? 0) + 1;

    if (fails >= maxAttempts) {
      await prefs.setInt('fails_$phone', 0);
      await prefs.setInt('lock_$phone', now + lockSeconds * 1000);

      return const LoginResult.failure(
        '3 wrong attempts. Locked for 30 seconds.',
      );
    }

    await prefs.setInt('fails_$phone', fails);

    return const LoginResult.failure('Wrong phone number or password');
  }

  // ---------------------------------------------------------------------------
  // Firebase login
  // ---------------------------------------------------------------------------

  Future<LoginResult> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final timer = Stopwatch()..start();
    final stepTimer = Stopwatch()..start();

    void logStep(String step) {
      _logAuthTiming('LOGIN_STEP', step, stepTimer);
      stepTimer
        ..reset()
        ..start();
    }

    _logAuthTiming('LOGIN', 'Started', timer);

    try {
      final lockMessage = await _limiter.checkLock(normalizedEmail);
      logStep('Login limiter check');

      if (lockMessage != null) {
        return LoginResult.failure(lockMessage);
      }

      try {
        final credential = await _firebaseAuth
            .signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        )
            .timeout(const Duration(seconds: 20));

        logStep('Firebase sign-in');

        final firebaseUser = credential.user;

        if (firebaseUser == null) {
          return const LoginResult.failure(
            'Unable to login. Please try again.',
          );
        }

        // Firebase sign-in response already provides the authenticated user.
        // Avoid an additional reload network request during login.
        logStep('Firebase user ready');

        DocumentSnapshot<Map<String, dynamic>> profile;

        try {
          profile = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 15));

          logStep('Firestore profile fetch');
        } on TimeoutException {
          logStep('Firestore profile timeout');

          await _firebaseAuth.signOut();
          return _offlineLogin(normalizedEmail, password);
        } on FirebaseException catch (e) {
          logStep('Firestore error: ${e.code}');

          await _firebaseAuth.signOut();

          if (_isTemporaryFirebaseError(e)) {
            return _offlineLogin(normalizedEmail, password);
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

        if (_isBlockedProfile(data)) {
          await handleBlockedAccount(normalizedEmail);
          return const LoginResult.failure(blockedMessage);
        }

        await _offline.clearBlocked(normalizedEmail);
        logStep('Clear offline blocked status');

        final verificationRequired =
            data['emailVerificationRequired'] == true;

        if (verificationRequired && !firebaseUser.emailVerified) {
          try {
            await firebaseUser.sendEmailVerification();
            _logAuthTiming('LOGIN', 'Verification email resent', timer);
          } catch (_) {
            _logAuthTiming(
              'LOGIN',
              'Verification email resend failed',
              timer,
            );
          }

          await _firebaseAuth.signOut();

          return const LoginResult.failure(
            'Please verify your email first. We have sent a verification '
                'link to your inbox. Check your spam folder too.',
          );
        }

        if (verificationRequired &&
            firebaseUser.emailVerified &&
            data['emailVerifiedAt'] == null) {
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

        await _offline.save(
          email: normalizedEmail,
          phone: phone,
          password: password,
          name: name,
        );
        logStep('Offline credentials save');

        final localUser = await _db.findUserByPhone(phone);
        logStep('SQLite user lookup');

        if (localUser == null) {
          await _firebaseAuth.signOut();
          return const LoginResult.failure(
            'Local player profile could not be created.',
          );
        }

        await _limiter.clear(normalizedEmail);
        logStep('Clear login limiter');

        await _saveActiveSession(normalizedEmail);
        logStep('Save active session');

        _onOnlineSessionStarted();

        _logAuthTiming('LOGIN', 'TOTAL COMPLETED', timer);

        return LoginResult.success(_toUser(localUser));
      } on firebase.FirebaseAuthException catch (e) {
        _logAuthTiming('LOGIN', 'Firebase Auth error: ${e.code}', timer);

        if (e.code == 'network-request-failed' ||
            e.code == 'web-network-request-failed') {
          return _offlineLogin(normalizedEmail, password);
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

        return _offlineLogin(normalizedEmail, password);
      }
    } catch (e) {
      _logAuthTiming('LOGIN', 'ERROR: $e', timer);
      return LoginResult.failure('Login failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Delete own account
  // ---------------------------------------------------------------------------

  Future<String?> deleteOwnAccount({
    required String password,
    required String phone,
  }) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      return 'You need to be logged in online to delete your account.';
    }

    try {
      await user
          .reauthenticateWithCredential(
        firebase.EmailAuthProvider.credential(
          email: email,
          password: password,
        ),
      )
          .timeout(const Duration(seconds: 20));

      AccountStatusService.instance.stopWatching();

      await _deleteFirestoreData(user.uid);

      await user.delete().timeout(const Duration(seconds: 20));
    } on firebase.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect password.';
      }
      return _firebaseError(e.code);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Your account could not be deleted. '
            'If it has been blocked, contact the administrator.';
      }
      return 'Could not delete your data: ${e.code}';
    } on TimeoutException {
      return 'Request timed out. Check your internet and try again.';
    } catch (e) {
      return 'Account deletion failed: $e';
    }

    try {
      await deleteUser(phone);
      await _offline.forget(email);
      await _limiter.clear(email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeSessionKey);
    } catch (e) {
      if (kDebugMode) debugPrint('Local cleanup after delete failed: $e');
    }

    return null;
  }

  Future<void> _deleteFirestoreData(String uid) async {
    const pageSize = 400;

    while (true) {
      final page = await _firestore
          .collection('game_history')
          .where('player1Uid', isEqualTo: uid)
          .limit(pageSize)
          .get();

      if (page.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (page.docs.length < pageSize) break;
    }

    final batch = _firestore.batch();
    batch.delete(_firestore.collection('leaderboard').doc(uid));
    batch.delete(_firestore.collection('user_profiles').doc(uid));
    batch.delete(_firestore.collection('player_stats').doc(uid));
    batch.delete(_firestore.collection('users').doc(uid));
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Errors and local player list
  // ---------------------------------------------------------------------------

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
      case 'requires-recent-login':
        return 'Please log out and log in again, then try once more.';
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

    await (_db.delete(_db.appUsers)..where((user) => user.phone.equals(phone)))
        .go()
        .timeout(const Duration(seconds: 15));

    return true;
  }
}