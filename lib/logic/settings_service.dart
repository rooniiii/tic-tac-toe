import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe/security/secure_prefs.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  bool _music = true;
  bool _sound = true;
  bool _voiceAssistant = false;

  bool get music => _music;
  bool get sound => _sound;
  bool get voiceAssistant => _voiceAssistant;

  Future<void> load() async {
    try {
      final prefs = await SecurePrefs.getInstance();

      _music = prefs.getBool('music') ?? true;
      _sound = prefs.getBool('sound') ?? true;
      _voiceAssistant = prefs.getBool('voiceAssistant') ?? false;

      notifyListeners();
    } catch (_) {}
  }

  Future<void> setMusic(bool value) async {
    _music = value;
    notifyListeners();

    try {
      final prefs = await SecurePrefs.getInstance();
      await prefs.setBool('music', value);
    } catch (_) {}
  }

  Future<void> setSound(bool value) async {
    _sound = value;
    notifyListeners();

    try {
      final prefs = await SecurePrefs.getInstance();
      await prefs.setBool('sound', value);
    } catch (_) {}
  }

  Future<void> setVoiceAssistant(bool value) async {
    _voiceAssistant = value;
    notifyListeners();

    try {
      final prefs = await SecurePrefs.getInstance();
      await prefs.setBool('voiceAssistant', value);
    } catch (_) {}
  }
}