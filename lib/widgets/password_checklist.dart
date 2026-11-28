import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PasswordChecklist extends StatelessWidget {
  final TextEditingController controller;
  const PasswordChecklist({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final p = value.text;
        final rules = <String, bool>{
          '8 to 20 characters': p.length >= 8 && p.length <= 20,
          'One capital letter (A-Z)': RegExp(r'[A-Z]').hasMatch(p),
          'One small letter (a-z)': RegExp(r'[a-z]').hasMatch(p),
          'One digit (0-9)': RegExp(r'[0-9]').hasMatch(p),
          'One special character (!@#...)':
          RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(p),
        };
        return Column(
          children: rules.entries.map((e) {
            final color = e.value ? AppTheme.neonCyan : Colors.white54;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    e.value ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  // Wraps on narrow screens / large text instead of overflowing.
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(color: color, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}