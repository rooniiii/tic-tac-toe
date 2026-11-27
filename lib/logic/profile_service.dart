import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/app_database.dart';
import '../models/user_stats.dart';
import '../services/account_status_service.dart';

class ProfileService {
  final AppDatabase _db = AppDatabase.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  late final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int maxBioLength = 40;

  String _bestScoreKey(String phone, bool twoPlayer) =>
      twoPlayer ? 'best2p_$phone' : 'best_$phone';

  String _pendingBioKey(String phone) =>
      'pending_bio_$phone';

  // Sync pending bio with Firebase.
  Future<void> _syncBio(
      String phone,
      String bio,
      ) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) return;

    try {
      // Stop here (and sign the player out) if an admin has blocked them.
      await AccountStatusService.instance.ensureActive();

      await _firestore
          .collection('user_profiles')
          .doc(firebaseUser.uid)
          .set({
        'uid': firebaseUser.uid,
        'phone': phone,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(
        const Duration(seconds: 5),
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_pendingBioKey(phone));
    } catch (e) {
      if (await AccountStatusService.instance.checkAfterFailure(e)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_pendingBioKey(phone));
        return;
      }
      // Keep pending bio for the next sync attempt.
    }
  }

  Future<String> getBio(String phone) async {
    try {
      final user = await _db.findUserByPhone(phone);

      if (user == null) return '';

      final prefs = await SharedPreferences.getInstance();

      // Pending local bio has priority.
      final pendingBio = prefs.getString(
        _pendingBioKey(phone),
      );

      if (pendingBio != null) {
        _syncBio(phone, pendingBio);
        return pendingBio;
      }

      final firebaseUser = _auth.currentUser;

      if (firebaseUser != null) {
        try {
          final doc = await _firestore
              .collection('user_profiles')
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 5));

          if (doc.exists) {
            final bio = doc.data()?['bio'] as String? ?? '';

            await _db.into(_db.userProfiles).insertOnConflictUpdate(
              UserProfilesCompanion.insert(
                userId: Value(user.id),
                bio: Value(bio),
                updatedAt: Value(DateTime.now()),
              ),
            );

            return bio;
          }
        } catch (_) {
          // Use local SQLite if Firebase is unavailable.
        }
      }

      final profile = await (_db.select(_db.userProfiles)
        ..where((row) => row.userId.equals(user.id)))
          .getSingleOrNull();

      return profile?.bio ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> setBio(String phone, String bio) async {
    final cleanBio = bio.trim();

    if (cleanBio.length > maxBioLength) {
      throw ArgumentError(
        'Bio cannot exceed $maxBioLength characters.',
      );
    }

    final user = await _db.findUserByPhone(phone);

    if (user == null) {
      throw Exception('User not found.');
    }

    // STEP 1: Save bio in local SQLite first.
    await _db.into(_db.userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion.insert(
        userId: Value(user.id),
        bio: Value(cleanBio),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // STEP 2: Keep a pending copy until Firebase sync succeeds.
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _pendingBioKey(phone),
      cleanBio,
    );

    // STEP 3: Start Firebase sync without waiting.
    _syncBio(phone, cleanBio);
  }

  Future<UserStats> getStats(
      String phone, {
        bool? twoPlayer,
        String? opponentType,
      }) async {
    try {
      final user = await _db.findUserByPhone(phone);

      if (user == null) return const UserStats();

      final rows = await (_db.select(_db.playerOpponentStats)
        ..where((row) => row.userId.equals(user.id)))
          .get();

      final selectedRows = rows.where((row) {
        if (opponentType != null) {
          return row.opponentType == opponentType;
        }

        if (twoPlayer == true) {
          return row.opponentType == 'guest' ||
              row.opponentType == 'player';
        }

        if (twoPlayer == false) {
          return row.opponentType == 'computer';
        }

        return true;
      });

      int played = 0;
      int wins = 0;
      int losses = 0;
      int draws = 0;

      for (final row in selectedRows) {
        played += row.gamesPlayed;
        wins += row.wins;
        losses += row.losses;
        draws += row.draws;
      }

      final prefs = await SharedPreferences.getInstance();

      final bestScore =
          prefs.getInt(_bestScoreKey(phone, false)) ?? 0;

      return UserStats(
        played: played,
        wins: wins,
        losses: losses,
        draws: draws,
        bestScore: bestScore,
      );
    } catch (_) {
      return const UserStats();
    }
  }

  Future<void> recordResult(
      String phone,
      String result,
      int score, {
        bool twoPlayer = false,
      }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = _bestScoreKey(phone, twoPlayer);
      final oldScore = prefs.getInt(key) ?? 0;

      if (score > oldScore) {
        await prefs.setInt(key, score);
      }
    } catch (_) {}
  }
}