import 'dart:async';

import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/mark.dart';
import '../models/user.dart';
import '../logic/level_progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/board_widget.dart';
import '../services/audio_service.dart';
import '../services/voice_assistant_service.dart';
import 'game_screen.dart';
import 'join_screen.dart';

class ModeScreen extends StatelessWidget {
  final User user;
  final Difficulty difficulty;

  const ModeScreen({
    super.key,
    required this.user,
    required this.difficulty,
  });

  static const List<Mark?> _preview = [
    Mark.o, Mark.o, Mark.o,
    null, Mark.x, null,
    Mark.x, Mark.o, Mark.x,
  ];

  void _announce(String text) {
    unawaited(VoiceAssistantService.instance.speak(text));
  }

  Future<void> _start(BuildContext context, bool vsComputer) async {
    AudioService.playButtonSound();

    final label = vsComputer ? 'VS COMPUTER' : 'VS FRIEND';
    _announce(label);

    if (!context.mounted) return;

    if (vsComputer) {
      // Continue from the saved level of this difficulty (1 for new players).
      final level =
          await LevelProgressService().currentLevel(user.phone, difficulty);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            user: user,
            difficulty: difficulty,
            level: level,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JoinScreen(
            player1: user,
            difficulty: difficulty,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0B2B),
              Color(0xFF2A0F5C),
              Color(0xFF7A1F8F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: 'Back to main menu',
                    child: InkWell(
                      onTap: () {
                        AudioService.playButtonSound();
                        _announce('Back to main menu');
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.neonPink,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonPink.withAlpha(120),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.neonPink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 240,
                            child: BoardWidget(
                              board: _preview,
                              winLine: const [0, 1, 2],
                              hintCell: null,
                              onTap: (_) {},
                            ),
                          ),
                          const SizedBox(height: 44),
                          _ModeButton(
                            label: 'VS COMPUTER',
                            tooltip: 'Play against the computer '
                                '(${difficulty.label})',
                            onTap: () => _start(context, true),
                            icon2: Icons.computer,
                          ),
                          const SizedBox(height: 20),
                          _ModeButton(
                            label: 'VS FRIEND',
                            tooltip: 'Play with a friend (Player 2 joins)',
                            onTap: () => _start(context, false),
                            icon2: Icons.person,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final IconData icon2;

  const _ModeButton({
    required this.label,
    required this.tooltip,
    required this.onTap,
    required this.icon2,
  });

  @override
  Widget build(BuildContext context) {
    const light = Color(0xFFE0B3FF);

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4A1FBF),
                  Color(0xFF2B1A8C),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD08CFF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonPink.withAlpha(110),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  color: light,
                  size: 34,
                ),
                const SizedBox(width: 18),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: light,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: light,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Icon(
                  icon2,
                  color: light,
                  size: 34,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}