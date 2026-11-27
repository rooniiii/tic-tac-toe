import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../logic/auth_service.dart';

/// Thrown when the signed-in player has been blocked by an administrator.
class AccountBlockedException implements Exception {
  final String message;

  const AccountBlockedException([this.message = AuthService.blockedMessage]);

  @override
  String toString() => message;
}

/// Detects a block that happens while the player is already signed in.
///
/// [startWatching] listens for a block in real time while the player is
/// signed in. As a second safety net, call [ensureActive] before sending data
/// to Firebase and [checkAfterFailure] when a Firebase write fails. If the account is
/// blocked, the player is signed out and [onBlocked] fires; main.dart
/// listens to it, shows the error and returns to the login screen.
class AccountStatusService {
  AccountStatusService._();

  static final AccountStatusService instance = AccountStatusService._();

  final StreamController<String> _blockedController =
      StreamController<String>.broadcast();

  bool _handling = false;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _watchSub;
  String? _watchUid;

  Stream<String> get onBlocked => _blockedController.stream;

  static bool isBlockedData(Map<String, dynamic>? data) {
    return data?['isBlocked'] == true || data?['status'] == 'blocked';
  }

  /// Reads the player's profile and throws [AccountBlockedException] if an
  /// admin has blocked them. If the device is offline the check is skipped;
  /// the security rules will still reject the data when it reaches Firebase.
  Future<void> ensureActive() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic>? data;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 8));
      data = doc.data();
    } catch (e) {
      if (kDebugMode) debugPrint('Account status check skipped: $e');
      return;
    }

    if (isBlockedData(data)) {
      await _reportBlocked(user.email ?? '');
      throw const AccountBlockedException();
    }
  }

  /// Call when a Firebase write fails. A permission-denied error may mean the
  /// player was blocked; if so they are signed out. Returns true when the
  /// failure was caused by a block.
  Future<bool> checkAfterFailure(Object error) async {
    if (error is AccountBlockedException) return true;

    if (error is! FirebaseException || error.code != 'permission-denied') {
      return false;
    }

    try {
      await ensureActive();
    } on AccountBlockedException {
      return true;
    }

    return false;
  }

  /// Listens to the signed-in player's profile while they use the app, so a
  /// block by an admin signs them out immediately (or as soon as an offline
  /// device reconnects). Started after login / session restore.
  void startWatching() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_watchSub != null && _watchUid == user.uid) return;

    stopWatching();

    _watchUid = user.uid;
    final email = user.email ?? '';

    _watchSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (isBlockedData(snapshot.data())) {
          unawaited(_reportBlocked(email));
        } else if (!snapshot.exists && !snapshot.metadata.isFromCache) {
          // The profile was deleted by an admin while the player was in
          // the app (confirmed by the server, not just a cache miss).
          unawaited(_reportBlocked(email, removedMessage));
        }
      },
      onError: (Object error) {
        if (kDebugMode) debugPrint('Account status listener error: $error');
      },
    );
  }

  /// Stops the listener (called on logout).
  void stopWatching() {
    _watchSub?.cancel();
    _watchSub = null;
    _watchUid = null;
  }

  static const String removedMessage =
      'This account has been removed by an administrator.';

  Future<void> _reportBlocked(
    String email, [
    String message = AuthService.blockedMessage,
  ]) async {
    if (_handling) return;
    _handling = true;

    try {
      await AuthService().handleBlockedAccount(email);
    } catch (e) {
      if (kDebugMode) debugPrint('Blocked-account sign out failed: $e');
    } finally {
      _handling = false;
    }

    _blockedController.add(message);
  }
}
