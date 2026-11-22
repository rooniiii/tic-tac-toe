import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'account_status_service.dart';

class LeaderboardEntry {
  final String uid;
  final String name;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  factory LeaderboardEntry.fromMap(String uid, Map<String, dynamic> data) {
    int toInt(dynamic v) => v is num ? v.toInt() : 0;

    return LeaderboardEntry(
      uid: uid,
      name: data['name']?.toString() ?? 'Player',
      gamesPlayed: toInt(data['gamesPlayed']),
      wins: toInt(data['wins']),
      losses: toInt(data['losses']),
      draws: toInt(data['draws']),
    );
  }

  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed * 100;
}

/// Global online leaderboard.
///
/// `player_stats` is private (it contains the player's email), so each
/// player also has a public `leaderboard/{uid}` entry with only their name
/// and totals. The security rules check that these totals match the
/// player's real `player_stats`, so they cannot be faked.
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _leaderboard =>
      _firestore.collection('leaderboard');

  /// Copies the signed-in player's current totals into their leaderboard
  /// entry. Called after each saved game and after login. Errors are
  /// ignored: the entry is simply refreshed next time.
  Future<void> syncMyEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    try {
      await _firestore.runTransaction((transaction) async {
        final stats = await transaction
            .get(_firestore.collection('player_stats').doc(uid));
        final profile =
            await transaction.get(_firestore.collection('users').doc(uid));

        final statsData = stats.data();
        final profileData = profile.data();

        if (statsData == null || profileData == null) return;
        if (AccountStatusService.isBlockedData(profileData)) return;

        final name = profileData['name'];
        if (name is! String || name.trim().isEmpty) return;

        transaction.set(_leaderboard.doc(uid), {
          'uid': uid,
          'name': name,
          'gamesPlayed': statsData['gamesPlayed'] ?? 0,
          'wins': statsData['wins'] ?? 0,
          'losses': statsData['losses'] ?? 0,
          'draws': statsData['draws'] ?? 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }).timeout(const Duration(seconds: 15));
    } catch (e) {
      if (kDebugMode) debugPrint('Leaderboard sync skipped: $e');
    }
  }

  /// Top players by wins.
  Future<List<LeaderboardEntry>> getTop({int limit = 20}) async {
    final snapshot = await _leaderboard
        .orderBy('wins', descending: true)
        .limit(limit)
        .get()
        .timeout(const Duration(seconds: 15));

    return snapshot.docs
        .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
        .toList();
  }
}
