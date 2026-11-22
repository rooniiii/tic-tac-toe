import 'package:flutter/material.dart';
import '../models/mark.dart';
import '../theme/app_theme.dart';

class BoardWidget extends StatelessWidget {
  final List<Mark?> board;
  final List<int>? winLine;
  final int? hintCell;
  final void Function(int index) onTap;

  const BoardWidget({
    super.key,
    required this.board,
    required this.winLine,
    required this.hintCell,
    required this.onTap,
  });

  static Color colorOf(Mark m) =>
      m == Mark.x ? AppTheme.neonCyan : AppTheme.neonPink;

  Widget _cell(int i) {
    final m = board[i];
    final isHint = hintCell == i;
    return GestureDetector(
      onTap: () => onTap(i),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHint
                ? AppTheme.neonYellow
                : AppTheme.purple.withAlpha(120),
            width: isHint ? 3 : 1,
          ),
          boxShadow: isHint
              ? [BoxShadow(color: AppTheme.neonYellow.withAlpha(160), blurRadius: 14)]
              : [],
        ),
        child: Center(
          child: m == null
              ? null
              : TweenAnimationBuilder<double>(
            key: ValueKey('$i-${m.name}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (_, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                child: Text(
                  m.symbol,
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: colorOf(m),
                    shadows: [
                      Shadow(color: colorOf(m), blurRadius: 12),
                      Shadow(color: colorOf(m), blurRadius: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x44200A5C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.purple, width: 3),
          boxShadow: [
            BoxShadow(color: AppTheme.purple.withAlpha(160), blurRadius: 20),
          ],
        ),
        child: Stack(
          children: [
            GridView.count(
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(6),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: List.generate(9, _cell),
            ),
            if (winLine != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (_, v, __) => CustomPaint(
                      painter: _WinLinePainter(
                        winLine!,
                        v,
                        colorOf(board[winLine![0]]!),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WinLinePainter extends CustomPainter {
  final List<int> line;
  final double progress;
  final Color color;

  _WinLinePainter(this.line, this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
    const gap = 6.0;
    final cell = (size.width - 2 * pad - 2 * gap) / 3;
    Offset center(int i) => Offset(
      pad + (i % 3) * (cell + gap) + cell / 2,
      pad + (i ~/ 3) * (cell + gap) + cell / 2,
    );

    final start = center(line.first);
    final end = Offset.lerp(start, center(line.last), progress)!;

    final glow = Paint()
      ..color = color
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final core = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, glow);
    canvas.drawLine(start, end, core);
  }

  @override
  bool shouldRepaint(_WinLinePainter old) => old.progress != progress;
}