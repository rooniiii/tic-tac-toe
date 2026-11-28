import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final bool loading;

  /// Shown on long-press / mouse hover and read by screen readers.
  final String? tooltip;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppTheme.neonPink,
    this.loading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 48,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(150),
            blurRadius: 18,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color, width: 2),
          ),
        ),
        child: loading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final message = tooltip;
    if (message == null) return button;
    return Tooltip(message: message, child: button);
  }
}