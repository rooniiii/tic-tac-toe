import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantService {
  VoiceAssistantService._();

  static final VoiceAssistantService instance =
  VoiceAssistantService._();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isEnabled = false;
  bool _isInitialized = false;

  Future<void>? _initialization;
  Future<void> _commandQueue = Future<void>.value();

  int _speechGeneration = 0;
  int _settingsGeneration = 0;

  String _lastMessage = '';
  DateTime? _lastMessageTime;

  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_initialization != null) {
      await _initialization;
      return;
    }

    _initialization = _setupTts();

    try {
      await _initialization;
    } finally {
      _initialization = null;
    }
  }

  Future<void> _setupTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Speech complete hone ka wait nahi karega.
    await _flutterTts.awaitSpeakCompletion(false);

    _isInitialized = true;
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final operation = _commandQueue.then((_) async {
      await action();
    });

    _commandQueue = operation.catchError((_) {});

    return _commandQueue;
  }

  Future<void> setEnabled(bool enabled) async {
    final int request = ++_settingsGeneration;

    if (!enabled) {
      _isEnabled = false;

      _speechGeneration++;
      _lastMessage = '';
      _lastMessageTime = null;

      await _enqueue(() async {
        await _flutterTts.stop();
      });

      return;
    }

    try {
      await initialize();

      // Agar is darmiyan setting dobara change hui ho,
      // to purani request apply nahi hogi.
      if (request != _settingsGeneration) return;

      _isEnabled = true;
    } catch (_) {
      _isEnabled = false;
    }
  }

  /// Speaks [message] when the voice assistant is enabled.
  ///
  /// [force] speaks even while the assistant is off. Use it only for an
  /// explicit player action, e.g. tapping "read aloud" on a chat message.
  Future<void> speak(String message, {bool force = false}) async {
    final String text = message.trim();

    if ((!_isEnabled && !force) || text.isEmpty) return;

    final DateTime now = DateTime.now();

    // Same text ko rapid repeated taps par dobara nahi bolega.
    if (_lastMessage == text &&
        _lastMessageTime != null &&
        now.difference(_lastMessageTime!).inMilliseconds < 900) {
      return;
    }

    _lastMessage = text;
    _lastMessageTime = now;

    final int generation = ++_speechGeneration;

    // Commands sequence mein execute honge.
    // Purani request latest request aane par skip ho jayegi.
    unawaited(
      _enqueue(() async {
        await initialize();

        if ((!_isEnabled && !force) || generation != _speechGeneration) {
          return;
        }

        await _flutterTts.stop();

        if ((!_isEnabled && !force) || generation != _speechGeneration) {
          return;
        }

        await _flutterTts.speak(text);
      }),
    );
  }

  Future<void> stop() async {
    _speechGeneration++;

    _lastMessage = '';
    _lastMessageTime = null;

    await _enqueue(() async {
      await _flutterTts.stop();
    });
  }
}