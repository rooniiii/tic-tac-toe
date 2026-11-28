import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/auth_service.dart';
import '../main.dart' show showSessionExpiredMessage;
import '../models/user.dart';
import 'login_screen.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;

  final AuthService _auth = AuthService();

  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _navigationTimer = Timer(
      const Duration(seconds: 3),
          () {
        _goNext();
      },
    );
  }

  Future<void> _goNext() async {
    if (!mounted || _navigationStarted) return;

    _navigationStarted = true;

    User? user;
    bool expired = false;

    try {
      // Restore the existing user session.
      final LoginResult result = await _auth
          .restoreSession()
          .timeout(const Duration(seconds: 20));

      user = result.user;

      if (result.error != null) {
        debugPrint('Session restore: ${result.error}');
        expired = result.error == AuthService.sessionExpiredMessage;
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
      user = null;
    }

    if (!mounted) return;

    final Widget nextScreen = user != null
        ? MenuScreen(user: user)
        : const LoginScreen();

    if (expired) showSessionExpiredMessage();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _logo(double t) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _LogoPainter(t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0B3A),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final opacity = (t / 0.15).clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(t),

                  // Reflection below the logo
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.4,
                      child: Opacity(
                        opacity: 0.35,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Colors.transparent,
                              ],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Transform.scale(
                            scaleY: -1,
                            child: _logo(t),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double t;

  _LogoPainter(this.t);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color pink = Color(0xFFFF2BD6);

  static const List<int> _order = [0, 1, 4, 6, 7, 8];
  static const Set<int> _oCells = {0, 4, 8};

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final frame = RRect.fromRectAndRadius(
      rect.deflate(4),
      const Radius.circular(10),
    );

    // Background of the board
    canvas.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0F5C),
            Color(0xFF0E0B3A),
          ],
        ).createShader(rect),
    );

    // Neon frame
    const frameGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [cyan, pink],
    );

    canvas.drawRRect(
      frame,
      Paint()
        ..shader = frameGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        ),
    );

    canvas.drawRRect(
      frame,
      Paint()
        ..shader = frameGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Grid lines
    final inner = rect.deflate(14);
    final cell = inner.width / 3;

    final gridPaint = Paint()
      ..color = const Color(0x6600E5FF)
      ..strokeWidth = 1.5;

    for (var k = 1; k < 3; k++) {
      final x = inner.left + cell * k;
      final y = inner.top + cell * k;

      canvas.drawLine(
        Offset(x, inner.top),
        Offset(x, inner.bottom),
        gridPaint,
      );

      canvas.drawLine(
        Offset(inner.left, y),
        Offset(inner.right, y),
        gridPaint,
      );
    }

    Offset center(int i) => Offset(
      inner.left + (i % 3) * cell + cell / 2,
      inner.top + (i ~/ 3) * cell + cell / 2,
    );

    final core = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    Paint glow(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        6,
      );

    // Marks appear one by one
    for (var k = 0; k < _order.length; k++) {
      final start = 0.15 + k * 0.09;
      final local = ((t - start) / 0.12).clamp(0.0, 1.0);

      if (local <= 0) continue;

      final scale = Curves.easeOutBack.transform(local);
      final cellIndex = _order[k];
      final c = center(cellIndex);
      final r = cell * 0.30 * scale;

      if (_oCells.contains(cellIndex)) {
        canvas.drawCircle(c, r, glow(pink));
        canvas.drawCircle(c, r, core);
      } else {
        final g = glow(cyan);

        canvas.drawLine(
          c.translate(-r, -r),
          c.translate(r, r),
          g,
        );

        canvas.drawLine(
          c.translate(-r, r),
          c.translate(r, -r),
          g,
        );

        canvas.drawLine(
          c.translate(-r, -r),
          c.translate(r, r),
          core,
        );

        canvas.drawLine(
          c.translate(-r, r),
          c.translate(r, -r),
          core,
        );
      }
    }

    // Winning diagonal line
    final p = ((t - 0.72) / 0.28).clamp(0.0, 1.0);

    if (p > 0) {
      final from = center(0);
      final to = Offset.lerp(from, center(8), p)!;

      canvas.drawLine(
        from,
        to,
        glow(pink)..strokeWidth = 12,
      );

      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t;
}