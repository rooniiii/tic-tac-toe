import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_toe/security/secure_prefs.dart';

/// Device-side login session, the mobile equivalent of a session cookie.
///
/// On every successful login a new random 256-bit token is issued together
/// with an "issued at" and "last active" time. A session is valid only while
///   * it is younger than the maximum login age (absolute lifetime), and
///   * the player opened the app within the inactivity limit.
/// Both limits are set by admins (Admin app > Session Settings, Firestore
/// `app_config/session`). The last known values are cached on the device so
/// they also apply offline; [maxSessionAge] / [idleTimeout] are the
/// defaults used until the admin values have been loaded once.
/// When it expires the player has to log in again. Logout destroys it.
///
/// The token never leaves the device and is never sent to a server: Firebase
/// Auth already protects every network call with its own short-lived ID
/// tokens over HTTPS. This class only decides how long a remembered login
/// on this phone stays valid.
class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  static const Duration maxSessionAge = Duration(days: 30);
  static const Duration idleTimeout = Duration(days: 14);

  static const String _idleDaysKey = 'session_policy_idle_days';
  static const String _maxAgeDaysKey = 'session_policy_max_age_days';

  // Same limits as the Firestore rules / Admin app.
  static const int _minIdleDays = 1, _maxIdleDays = 90;
  static const int _minAgeDays = 1, _maxAgeDays = 365;

  static const String _tokenKey = 'session_token';
  static const String _issuedAtKey = 'session_issued_at';
  static const String _lastActiveKey = 'session_last_active';

  final Random _random = Random.secure();

  String _newToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Starts a fresh session after a successful login (old token discarded,
  /// which prevents session fixation).
  Future<void> start() async {
    final prefs = await SecurePrefs.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(_tokenKey, _newToken());
    await prefs.setInt(_issuedAtKey, now);
    await prefs.setInt(_lastActiveKey, now);
  }

  /// Marks the session as used (called when the app restores it).
  Future<void> touch() async {
    final prefs = await SecurePrefs.getInstance();
    if (prefs.getString(_tokenKey) == null) return;
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Loads the admin-set timeouts and caches them. Never throws: offline or
  /// on errors the cached (or default) values stay in use.
  Future<void> refreshPolicy() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('session')
          .get()
          .timeout(const Duration(seconds: 5));
      final data = snap.data();
      if (data == null) return;

      final prefs = await SecurePrefs.getInstance();
      final idle = data['playerIdleDays'];
      final age = data['playerMaxAgeDays'];
      if (idle is num) {
        await prefs.setInt(
            _idleDaysKey, idle.toInt().clamp(_minIdleDays, _maxIdleDays));
      }
      if (age is num) {
        await prefs.setInt(
            _maxAgeDaysKey, age.toInt().clamp(_minAgeDays, _maxAgeDays));
      }
    } catch (_) {}
  }

  /// Result of checking the stored session.
  ///
  /// Sessions created before this class existed have no token; they are
  /// upgraded to a new session instead of forcing everybody to log in again.
  Future<SessionState> check() async {
    final prefs = await SecurePrefs.getInstance();

    final token = prefs.getString(_tokenKey);
    final issuedAt = prefs.getInt(_issuedAtKey);
    final lastActive = prefs.getInt(_lastActiveKey);

    if (token == null || issuedAt == null || lastActive == null) {
      return SessionState.missing;
    }

    final now = DateTime.now();
    final issued = DateTime.fromMillisecondsSinceEpoch(issuedAt);
    final active = DateTime.fromMillisecondsSinceEpoch(lastActive);

    // A clock moved backwards is treated as tampering.
    if (issued.isAfter(now.add(const Duration(minutes: 5)))) {
      return SessionState.expired;
    }

    final maxAge = Duration(
        days: (prefs.getInt(_maxAgeDaysKey) ?? maxSessionAge.inDays)
            .clamp(_minAgeDays, _maxAgeDays));
    final idle = Duration(
        days: (prefs.getInt(_idleDaysKey) ?? idleTimeout.inDays)
            .clamp(_minIdleDays, _maxIdleDays));

    if (now.difference(issued) > maxAge || now.difference(active) > idle) {
      return SessionState.expired;
    }

    return SessionState.valid;
  }

  /// Destroys the session (logout, block, account deletion).
  Future<void> clear() async {
    final prefs = await SecurePrefs.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_issuedAtKey);
    await prefs.remove(_lastActiveKey);
  }
}

enum SessionState { valid, expired, missing }
