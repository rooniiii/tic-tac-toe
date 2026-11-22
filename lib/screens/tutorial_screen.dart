import 'dart:async';

import 'package:flutter/material.dart';
import '../services/voice_assistant_service.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;
  bool _isClosing = false;

  static const Color background = Color(0xFF080B20);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color pink = Color(0xFFFF2BD6);
  static const Color purple = Color(0xFF7B2FF7);
  static const Color yellow = Color(0xFFFFD740);

  final List<Map<String, dynamic>> tutorialPages = [
    {
      'title': 'WELCOME TO NEON XO',
      'description':
      'Experience the classic Tic Tac Toe game with a glowing neon gaming style.',
      'type': 'welcome',
      'color': cyan,
    },
    {
      'title': 'CHOOSE YOUR MOVE',
      'description':
      'Take turns placing X and O in empty boxes. Plan your moves carefully!',
      'type': 'moves',
      'color': pink,
    },
    {
      'title': 'MAKE THREE IN A ROW',
      'description':
      'Match three symbols horizontally, vertically, or diagonally to win!',
      'type': 'win',
      'color': yellow,
    },
    {
      'title': 'READY TO PLAY?',
      'description':
      'Challenge the computer or play with another player. Let the battle begin!',
      'type': 'play',
      'color': cyan,
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isClosing) return;
      _speakPage(0);
    });
  }

  void _speak(String text) {
    unawaited(VoiceAssistantService.instance.speak(text));
  }

  void _speakPage(int index) {
    if (index < 0 || index >= tutorialPages.length) return;

    final item = tutorialPages[index];
    _speak('${item['title']}. ${item['description']}');
  }

  void nextPage() {
    if (_isClosing) return;

    if (currentPage < tutorialPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _closeTutorial('Get Started');
    }
  }

  void _skipTutorial() {
    _closeTutorial('Skip');
  }

  void _closeTutorial(String buttonText) {
    if (_isClosing) return;

    _isClosing = true;
    _speak(buttonText);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _neonCell(String symbol, Color color, {bool highlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.12) : const Color(0xFF111832),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(highlight ? 0.9 : 0.35),
          width: highlight ? 2 : 1,
        ),
        boxShadow: highlight
            ? [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: color,
            shadows: [
              Shadow(color: color.withOpacity(0.8), blurRadius: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameBoard(String type) {
    List<String> symbols;
    List<int> winningCells = [];
    Color winningColor = cyan;

    switch (type) {
      case 'moves':
        symbols = ['', 'X', '', 'O', '', '', '', '', ''];
        break;
      case 'win':
        symbols = ['X', 'O', '', '', 'X', 'O', '', '', 'X'];
        winningCells = [0, 4, 8];
        winningColor = yellow;
        break;
      case 'play':
        symbols = ['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', 'O'];
        break;
      default:
        symbols = ['X', '', 'O', '', 'X', '', 'O', '', 'X'];
        break;
    }

    return Container(
      width: 270,
      height: 270,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10162D),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: purple.withOpacity(0.65), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.22),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
        ),
        itemBuilder: (context, index) {
          final symbol = symbols[index];
          final color = symbol == 'O' ? pink : cyan;
          final isWinning = winningCells.contains(index);

          return _neonCell(
            symbol,
            isWinning ? winningColor : color,
            highlight: isWinning,
          );
        },
      ),
    );
  }

  Widget _visual(String type) {
    if (type == 'play') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _playerIcon('X', cyan),
              const SizedBox(width: 24),
              const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 24),
              _playerIcon('O', pink),
            ],
          ),
          const SizedBox(height: 28),
          _gameBoard(type),
        ],
      );
    }

    return _gameBoard(type);
  }

  Widget _playerIcon(String symbol, Color color) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: color, blurRadius: 18)],
          ),
        ),
      ),
    );
  }

  Widget _pageContent(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final color = item['color'] as Color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: purple.withOpacity(0.13),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: purple.withOpacity(0.55)),
          ),
          child: const Text(
            'NEON XO  •  HOW TO PLAY',
            style: TextStyle(
              color: cyan,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 25),
        _visual(type),
        const SizedBox(height: 30),
        Text(
          item['title'] as String,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 15)],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            item['description'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cyan.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NEON XO',
                        style: TextStyle(
                          color: cyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          letterSpacing: 3,
                          shadows: [Shadow(color: cyan, blurRadius: 12)],
                        ),
                      ),
                      TextButton(
                        onPressed: _skipTutorial,
                        child: const Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: tutorialPages.length,
                      onPageChanged: (index) {
                        if (_isClosing) return;
                        setState(() => currentPage = index);
                        _speakPage(index);
                      },
                      itemBuilder: (context, index) {
                        return _pageContent(tutorialPages[index]);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      tutorialPages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 7,
                        width: currentPage == index ? 27 : 7,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? cyan
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: currentPage == index
                              ? [
                            BoxShadow(
                              color: cyan.withOpacity(0.7),
                              blurRadius: 10,
                            ),
                          ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyan,
                        foregroundColor: background,
                        elevation: 8,
                        shadowColor: cyan.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentPage == tutorialPages.length - 1
                            ? 'GET STARTED  →'
                            : 'NEXT  →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}