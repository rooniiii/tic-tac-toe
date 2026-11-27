import 'package:audioplayers/audioplayers.dart';
import '../logic/settings_service.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static bool get _soundEnabled => SettingsService.instance.sound;

  static Future<void> playButtonSound() async {
    if (!_soundEnabled) return;

    await _player.stop();
    await _player.play(
      AssetSource('audio/button.mp3.mpeg'),
    );
  }

  static Future<void> playMoveSound() async {
    if (!_soundEnabled) return;

    await _player.stop();
    await _player.play(
      AssetSource('audio/move.mp3.mpeg'),
    );
  }

  static Future<void> playWinningSound() async {
    if (!_soundEnabled) return;

    await _player.stop();
    await _player.play(
      AssetSource('audio/winning.mp3.mp4'),
    );
  }

  static Future<void> playCongratsSound() async {
    if (!_soundEnabled) return;

    await _player.stop();
    await _player.play(
      AssetSource('audio/congrats.mp3.mp4'),
    );
  }
}