import 'package:tic_tac_toe/security/secure_prefs.dart';

/// Remembers whether a player has already seen the first-time walkthrough
/// on this device.
class OnboardingService {
  String _key(String phone) => 'onboarding_done_$phone';

  Future<bool> shouldShow(String phone) async {
    try {
      final prefs = await SecurePrefs.getInstance();
      return !(prefs.getBool(_key(phone)) ?? false);
    } catch (_) {
      return false;
    }
  }

  Future<void> markDone(String phone) async {
    try {
      final prefs = await SecurePrefs.getInstance();
      await prefs.setBool(_key(phone), true);
    } catch (_) {}
  }
}
