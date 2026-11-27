import 'dart:async';

import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../services/audio_service.dart';
import '../services/voice_assistant_service.dart';
import 'game_screen.dart';

class JoinScreen extends StatelessWidget {
  final User player1;
  final Difficulty difficulty;

  const JoinScreen({
    super.key,
    required this.player1,
    required this.difficulty,
  });

  void _announce(String text) {
    unawaited(VoiceAssistantService.instance.speak(text));
  }

  void _startGame(BuildContext context) {
    AudioService.playButtonSound();

    // Speak the exact button label.
    _announce('PLAY AS GUEST');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          user: player1,
          difficulty: difficulty,
          level: 1,
          vsComputer: false,
          opponentUser: null,
        ),
      ),
    );
  }

  Widget _player1Card() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x3300E5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neonCyan,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            color: AppTheme.neonCyan,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player1.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Player 1 (X)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppTheme.neonCyan,
          ),
          const SizedBox(width: 4),
          const Text('Ready'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioService.playButtonSound();
            _announce('Back');
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Player 2 Join',
          style: TextStyle(
            color: AppTheme.neonYellow,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                _player1Card(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonPink,
                    ),
                  ),
                ),
                const Text(
                  'Player 2 (O)',
                  style: TextStyle(
                    color: AppTheme.neonPink,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.person_outline,
                  size: 65,
                  color: AppTheme.neonCyan,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Player 2 can play as Guest',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                NeonButton(
                  text: 'PLAY AS GUEST',
                  color: AppTheme.neonCyan,
                  onPressed: () => _startGame(context),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No login or password required.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}