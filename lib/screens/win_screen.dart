import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/difficulty.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../services/audio_service.dart';
import '../services/voice_assistant_service.dart';
import '../services/house_ad_service.dart';
import '../logic/level_progress_service.dart';
import 'ad_countdown_screen.dart';
import 'game_screen.dart';
import 'menu_screen.dart';

class WinScreen extends StatefulWidget {
  final User user;
  final Difficulty difficulty;
  final int level;
  final int score;
  final bool vsComputer;
  final User? opponentUser;
  final String? winnerName;

  const WinScreen({
    super.key,
    required this.user,
    required this.difficulty,
    required this.level,
    required this.score,
    this.vsComputer = true,
    this.opponentUser,
    this.winnerName,
  });

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  late final List<_ConfettiPiece> _pieces;

  bool _navigating = false;

  /// The player just won the very last level (1000).
  bool get _finishedAllLevels => widget.level >= LevelProgressService.maxLevel;

  String get _resultText {
    if (_finishedAllLevels) {
      return 'CONGRATULATIONS! You completed all '
          '${LevelProgressService.maxLevel} levels'
          '${widget.vsComputer ? ' on ${widget.difficulty.label}' : ''}! '
          'Final score: ${widget.score}';
    }

    final winner = widget.winnerName;

    final winnerText =
    winner != null && winner.isNotEmpty
        ? '$winner won the game! '
        : '';

    final levelText =
        'You completed Level ${widget.level}'
        '${widget.vsComputer ? ' (${widget.difficulty.label})' : ''}';

    return 'CONGRATULATIONS! $winnerText$levelText '
        'Score: ${widget.score}';
  }

  @override
  void initState() {
    super.initState();

    final random = Random(42);

    const colors = [
      Colors.pink,
      Colors.cyan,
      Colors.yellow,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.red,
    ];

    _pieces = List.generate(100, (index) {
      return _ConfettiPiece(
        x: random.nextDouble(),
        delay: random.nextDouble(),
        size: 5 + random.nextDouble() * 7,
        rotation: random.nextDouble() * pi * 2,
        drift: (random.nextDouble() - 0.5) * 0.25,
        color: colors[random.nextInt(colors.length)],
      );
    });

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      AudioService.playCongratsSound();
      _confettiController.forward();

      // Read only the result text displayed on this screen.
      unawaited(
        VoiceAssistantService.instance.speak(_resultText),
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _nextLevel() async {
    if (_navigating || _finishedAllLevels) return;
    _navigating = true;

    AudioService.playButtonSound();

    // Speak only the button's visible label.
    unawaited(
      VoiceAssistantService.instance.speak('NEXT LEVEL'),
    );

    final nextLevel = LevelProgressService.clamp(widget.level + 1);

    // Every few levels an admin-managed ad plays with its countdown.
    final ads = HouseAdService.instance;
    if (ads.shouldShowBeforeLevel(nextLevel)) {
      final ad = await ads.pickAd();
      if (!mounted) return;
      if (ad != null) {
        await AdCountdownScreen.show(context, ad);
        if (!mounted) return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          user: widget.user,
          difficulty: widget.difficulty,
          level: nextLevel,
          score: widget.score,
          vsComputer: widget.vsComputer,
          opponentUser: widget.opponentUser,
        ),
      ),
    );
  }

  void _goToMenu() {
    if (_navigating) return;
    _navigating = true;

    AudioService.playButtonSound();

    // Speak only the button's visible label.
    unawaited(
      VoiceAssistantService.instance.speak(
        _finishedAllLevels ? 'RETURN TO HOME' : 'MAIN MENU',
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MenuScreen(user: widget.user),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 120,
                        color: AppTheme.neonYellow,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _finishedAllLevels ? 'CHAMPION!' : 'CONGRATULATIONS!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neonYellow,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (widget.winnerName != null)
                      Text('${widget.winnerName} won the game!'),

                    if (_finishedAllLevels) ...[
                      Text(
                        'You completed all ${LevelProgressService.maxLevel} '
                        'levels${widget.vsComputer ? ' on ${widget.difficulty.label}' : ''}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.neonPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your next game starts again from Level 1.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ] else
                      Text(
                        'You completed Level ${widget.level} of '
                            '${LevelProgressService.maxLevel}'
                            '${widget.vsComputer ? ' (${widget.difficulty.label})' : ''}',
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 6),
                    Text(
                      'Score: ${widget.score}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppTheme.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 36),

                    if (!_finishedAllLevels) ...[
                      NeonButton(
                        text: 'NEXT LEVEL',
                        onPressed: _nextLevel,
                      ),
                      const SizedBox(height: 14),
                    ],

                    NeonButton(
                      text: _finishedAllLevels ? 'RETURN TO HOME' : 'MAIN MENU',
                      color: AppTheme.neonCyan,
                      onPressed: _goToMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Falling confetti animation
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                      pieces: _pieces,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final double size;
  final double rotation;
  final double drift;
  final Color color;

  const _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.size,
    required this.rotation,
    required this.drift,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({
    required this.progress,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final fall = (progress * 1.3 + piece.delay) % 1.3;

      final dx = (piece.x + piece.drift * progress) * size.width;
      final dy = fall * size.height - size.height * 0.12;

      if (dy < -20 || dy > size.height + 20) continue;

      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.rotation + progress * pi * 5);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 1.8,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}