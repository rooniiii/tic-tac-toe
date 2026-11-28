import 'package:tic_tac_toe/security/secure_prefs.dart';

import '../models/difficulty.dart';

/// Saves how far a player got in each difficulty (VS COMPUTER).
///
/// Every difficulty has its own track of [maxLevel] levels. A new player
/// starts at level 1; winning a level unlocks the next one. Winning the last
/// level completes the track: progress goes back to level 1 and the number
/// of completed runs is increased.
class LevelProgressService {
  static const int maxLevel = 1000;

  String _levelKey(String phone, Difficulty d) => 'level_${phone}_${d.name}';
  String _completedKey(String phone, Difficulty d) =>
      'level_done_${phone}_${d.name}';

  /// Level to play next (1..[maxLevel]).
  Future<int> currentLevel(String phone, Difficulty difficulty) async {
    try {
      final prefs = await SecurePrefs.getInstance();
      final level = prefs.getInt(_levelKey(phone, difficulty)) ?? 1;
      return clamp(level);
    } catch (_) {
      return 1;
    }
  }

  /// How many times the player finished all [maxLevel] levels.
  Future<int> completedRuns(String phone, Difficulty difficulty) async {
    try {
      final prefs = await SecurePrefs.getInstance();
      return prefs.getInt(_completedKey(phone, difficulty)) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Call after the player won [level]. Returns true when this was the last
  /// level ([maxLevel]) and the whole track is now complete.
  Future<bool> recordWin(
    String phone,
    Difficulty difficulty,
    int level,
  ) async {
    final finished = level >= maxLevel;

    try {
      final prefs = await SecurePrefs.getInstance();
      final saved = prefs.getInt(_levelKey(phone, difficulty)) ?? 1;

      if (finished) {
        await prefs.setInt(_levelKey(phone, difficulty), 1);
        await prefs.setInt(
          _completedKey(phone, difficulty),
          (prefs.getInt(_completedKey(phone, difficulty)) ?? 0) + 1,
        );
      } else if (level + 1 > saved) {
        // Never move progress backwards (e.g. replaying an older level).
        await prefs.setInt(_levelKey(phone, difficulty), clamp(level + 1));
      }
    } catch (_) {}

    return finished;
  }

  static int clamp(int level) => level.clamp(1, maxLevel);
}
