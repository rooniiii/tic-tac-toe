import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account_status_service.dart';
import 'leaderboard_service.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  late final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> syncGameResult({
    required String opponentType,
    required String opponentName,
    String? difficulty,
    required String result,
  }) async {
    // 1. Check authenticated user.
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    // 2. Validate game result.
    final normalizedResult = result.trim().toLowerCase();

    if (!{'win', 'loss', 'draw'}.contains(normalizedResult)) {
      throw ArgumentError('Invalid game result.');
    }

    // 3. Validate input fields.
    final normalizedOpponentType = opponentType.trim();
    final normalizedOpponentName = opponentName.trim();
    final normalizedDifficulty = difficulty?.trim();

    if (normalizedOpponentType.isEmpty ||
        normalizedOpponentName.isEmpty) {
      throw ArgumentError('Opponent information is incomplete.');
    }

    if (normalizedOpponentType.length > 30 ||
        normalizedOpponentName.length > 100 ||
        (normalizedDifficulty?.length ?? 0) > 30) {
      throw ArgumentError('Game information exceeds allowed length.');
    }

    // Stop here (and sign the player out) if an admin has blocked them.
    await AccountStatusService.instance.ensureActive();

    final uid = currentUser.uid;

    // 4. Prepare Firestore references.
    final batch = _firestore.batch();

    final gameRef =
    _firestore.collection('game_history').doc();

    final statsRef =
    _firestore.collection('player_stats').doc(uid);

    // 5. Save game history.
    batch.set(gameRef, {
      'player1Uid': uid,
      'player1Email': currentUser.email,
      'opponentType': normalizedOpponentType,
      'opponentName': normalizedOpponentName,
      'difficulty': normalizedDifficulty,
      'resultForPlayer1': normalizedResult,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // 6. Update player statistics.
    batch.set(
      statsRef,
      {
        'uid': uid,
        'email': currentUser.email,
        'gamesPlayed': FieldValue.increment(1),
        'wins': FieldValue.increment(
          normalizedResult == 'win' ? 1 : 0,
        ),
        'losses': FieldValue.increment(
          normalizedResult == 'loss' ? 1 : 0,
        ),
        'draws': FieldValue.increment(
          normalizedResult == 'draw' ? 1 : 0,
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // 7. Commit both writes together.
    try {
      await batch.commit();
    } catch (e) {
      await AccountStatusService.instance.checkAfterFailure(e);
      rethrow;
    }

    // Update this player's public leaderboard entry from the saved stats.
    await LeaderboardService().syncMyEntry();
  }
}