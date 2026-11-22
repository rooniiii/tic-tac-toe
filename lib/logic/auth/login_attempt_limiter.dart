import 'package:shared_preferences/shared_preferences.dart';

/// Locks email login on this device after repeated wrong passwords.
/// Each new lock lasts longer than the previous one.
class LoginAttemptLimiter {
  static const int maxAttempts = 3;

  static const List<int> _lockSeconds = [10, 60, 120, 300, 600, 1800, 3600];

  String _key(String email) => email.trim().toLowerCase();

  String _failsKey(String email) => 'login_fails_${_key(email)}';
  String _lockUntilKey(String email) => 'login_lock_until_${_key(email)}';
  String _lockLevelKey(String email) => 'login_lock_level_${_key(email)}';

  int _lockDuration(int level) {
    final index = (level - 1).clamp(0, _lockSeconds.length - 1);
    return _lockSeconds[index];
  }

  /// Returns a message if login is currently locked, otherwise null.
  Future<String?> checkLock(String email) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockedUntil = prefs.getInt(_lockUntilKey(email)) ?? 0;

    if (now < lockedUntil) {
      final seconds = ((lockedUntil - now) / 1000).ceil();
      return 'Too many incorrect attempts. Please wait $seconds seconds.';
    }

    return null;
  }

  /// Records a wrong password and returns the message to show.
  Future<String> recordFailure(
    String email,
    String invalidCredentialsMessage,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final fails = (prefs.getInt(_failsKey(email)) ?? 0) + 1;

    if (fails < maxAttempts) {
      await prefs.setInt(_failsKey(email), fails);

      final remaining = maxAttempts - fails;
      return '$invalidCredentialsMessage. $remaining attempt(s) remaining '
          'before temporary lock.';
    }

    final level = (prefs.getInt(_lockLevelKey(email)) ?? 0) + 1;
    final seconds = _lockDuration(level);
    final lockedUntil =
        DateTime.now().millisecondsSinceEpoch + (seconds * 1000);

    await prefs.setInt(_failsKey(email), 0);
    await prefs.setInt(_lockLevelKey(email), level);
    await prefs.setInt(_lockUntilKey(email), lockedUntil);

    return '$maxAttempts incorrect attempts. Login locked for $seconds seconds.';
  }

  Future<void> clear(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_failsKey(email));
    await prefs.remove(_lockUntilKey(email));
    await prefs.remove(_lockLevelKey(email));
  }
}
