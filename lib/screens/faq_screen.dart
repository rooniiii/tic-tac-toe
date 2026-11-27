import 'dart:async';

import 'package:flutter/material.dart';
import '../services/voice_assistant_service.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  static const Color background = Color(0xFF080B20);
  static const Color cardColor = Color(0xFF111832);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color pink = Color(0xFFFF2BD6);
  static const Color purple = Color(0xFF7B2FF7);
  static const Color yellow = Color(0xFFFFD740);

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is NEON XO?',
      'answer':
      'NEON XO is a Tic Tac Toe game where players place X and O marks on a 3x3 board. The first player to make a line of three wins.',
    },
    {
      'question': 'How do I play the game?',
      'answer':
      'Select an empty box on the board to place your mark. Make a horizontal, vertical, or diagonal line of three marks to win. Open HOW TO PLAY for the full tutorial.',
    },
    {
      'question': 'What is Single Player mode?',
      'answer':
      'In Single Player mode, you play against the computer. You can select Easy, Medium, or Hard difficulty.',
    },
    {
      'question': 'What is Two Player mode?',
      'answer':
      'Two Player mode allows two people to play on the same device. Players take turns placing X and O.',
    },
    {
      'question': 'What are the difficulty levels?',
      'answer':
      'Easy, Medium, and Hard are the available difficulty levels for playing against the computer.',
    },
    {
      'question': 'How does the leaderboard work?',
      'answer':
      'The leaderboard displays player rankings based on the game scores and performance recorded by the app.',
    },
    {
      'question': 'What if I forget my password?',
      'answer':
      'Use the Forgot Password option on the Login screen, if available, and follow the instructions to reset your password.',
    },
    {
      'question': 'How can I logout?',
      'answer':
      'Tap the Logout option on the Menu screen and confirm your choice.',
    },
    {
      'question': 'How can I turn sound on or off?',
      'answer':
      'Open Settings from the Menu screen and use the Sound effects switch.',
    },
    {
      'question': 'What is the Voice Assistant?',
      'answer':
      'The Voice Assistant speaks game options and button names. You can enable or disable it from Settings.',
    },
  ];

  IconData _questionIcon(int index) {
    const icons = [
      Icons.grid_3x3,
      Icons.touch_app_outlined,
      Icons.smart_toy_outlined,
      Icons.people_alt_outlined,
      Icons.speed,
      Icons.emoji_events_outlined,
      Icons.lock_reset,
      Icons.logout,
      Icons.volume_up_outlined,
      Icons.record_voice_over,
    ];

    return icons[index % icons.length];
  }

  Color _questionColor(int index) {
    const colors = [cyan, pink, purple, yellow];
    return colors[index % colors.length];
  }

  Widget _neonSymbol(String symbol, Color color) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: color, blurRadius: 12)],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: purple.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: purple.withOpacity(0.6)),
          ),
          child: const Text(
            'NEON XO  •  GAME GUIDE',
            style: TextStyle(
              color: cyan,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _neonSymbol('X', cyan),
            const SizedBox(width: 13),
            const Icon(Icons.bolt, color: yellow, size: 28),
            const SizedBox(width: 13),
            _neonSymbol('O', pink),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'PLAYER HELP CENTER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Got questions? Find everything you need to know about NEON XO.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _faqCard(
      BuildContext context,
      Map<String, String> faq,
      int index,
      ) {
    final color = _questionColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withOpacity(0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: color.withOpacity(0.08),
          highlightColor: color.withOpacity(0.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(17, 0, 17, 17),
          iconColor: color,
          collapsedIconColor: color,

          onExpansionChanged: (expanded) {
            if (expanded) {
              unawaited(
                VoiceAssistantService.instance.speak(
                  '${faq['question']}. ${faq['answer']}',
                ),
              );
            }
          },

          leading: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(
              _questionIcon(index),
              color: color,
              size: 21,
            ),
          ),
          title: Text(
            faq['question']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: color, width: 3),
                ),
              ),
              child: Text(
                faq['answer']!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: cyan,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NEON FAQ',
          style: TextStyle(
            color: cyan,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            right: -90,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -90,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(17, 12, 17, 25),
              children: [
                _header(),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: cyan,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'GAME QUESTIONS',
                      style: TextStyle(
                        color: cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${faqs.length} TOPICS',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ...List.generate(
                  faqs.length,
                      (index) => _faqCard(context, faqs[index], index),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_esports,
                        color: pink,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'GOOD LUCK, PLAYER!',
                        style: TextStyle(
                          color: pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Keep playing. Keep winning.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}