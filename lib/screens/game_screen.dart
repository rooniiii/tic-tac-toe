import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/game_logic.dart';
import '../logic/profile_service.dart';
import '../models/difficulty.dart';
import '../models/mark.dart';
import '../models/player.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/board_widget.dart';
import '../database/app_database.dart';
import '../services/audio_service.dart';
import '../services/firestore_sync_service.dart';
import '../services/voice_assistant_service.dart';
import '../services/rewarded_ad_service.dart';
import '../services/house_ad_service.dart';
import '../logic/level_progress_service.dart';
import 'ad_countdown_screen.dart';
import 'menu_screen.dart';
import 'win_screen.dart';

class GameScreen extends StatefulWidget {
  final User user;
  final Difficulty difficulty;
  final int level;
  final int score;
  final bool vsComputer;
  final User? opponentUser;

  const GameScreen({
    super.key,
    required this.user,
    required this.difficulty,
    required this.level,
    this.score = 0,
    this.vsComputer = true,
    this.opponentUser,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLogic _game = GameLogic();
  final ProfileService _profile = ProfileService();
  final AppDatabase _db = AppDatabase.instance;
  final RewardedAdService _rewardedAdService = RewardedAdService();

  late final Player _human;
  late final Player _opponent;
  late int _score;

  bool _busy = false;
  bool _gameFinished = false;
  bool _leaving = false;
  bool _adIsReady = false;

  // Admin-managed countdown ad, used when no AdMob ad is available.
  bool _houseAdReady = false;
  bool _showingHouseAd = false;

  final LevelProgressService _progress = LevelProgressService();

  int _undosLeft = 2;
  int _hintsLeft = 3;
  int? _hint;

  // One rewarded Undo per player in each game.
  bool _rewardedUndoX = false;
  bool _rewardedUndoO = false;

  String get _opponentName => _opponent.name;

  bool get _currentPlayerHasReward {
    if (_game.current == Mark.x) {
      return _rewardedUndoX;
    }
    return _rewardedUndoO;
  }

  int get _availableUndoCount =>
      _undosLeft + (_currentPlayerHasReward ? 1 : 0);

  bool get _canWatchAd {
    if (widget.vsComputer) {
      return !_rewardedUndoX;
    }

    return _game.current == Mark.x
        ? !_rewardedUndoX
        : !_rewardedUndoO;
  }

  String get _adButtonLabel {
    if (!_adIsReady && !_houseAdReady) return 'AD LOADING...';

    if (widget.vsComputer) {
      return 'WATCH AD  +1 UNDO';
    }

    final playerName =
    _game.current == Mark.x ? _human.name : _opponent.name;

    return 'WATCH AD  +1 UNDO ($playerName)';
  }

  String get _status {
    if (_game.isOver) return '';

    if (widget.vsComputer) {
      return _busy ? 'Computer is thinking...' : 'Your turn';
    }

    final currentPlayer =
    _game.current == Mark.x ? _human.name : _opponent.name;

    return "$currentPlayer's turn";
  }

  @override
  void initState() {
    super.initState();

    _human = HumanPlayer(widget.user.name.trim(), Mark.x);

    final opponentName =
    widget.opponentUser?.name.trim().isNotEmpty == true
        ? widget.opponentUser!.name.trim()
        : 'Guest';

    _opponent = widget.vsComputer
        ? ComputerPlayer.forDifficulty(widget.difficulty, Mark.o)
        : HumanPlayer(opponentName, Mark.o);

    _score = widget.score;

    // Check whether the ad was already loaded from Menu Screen.
    _adIsReady = _rewardedAdService.isAdReady;

    // Listen for ad loading and closing updates.
    _rewardedAdService.onAdStateChanged = () {
      if (!mounted) return;

      setState(() {
        _adIsReady = _rewardedAdService.isAdReady;
      });
    };

    // If Menu Screen has not loaded it yet, continue loading here.
    _rewardedAdService.loadAd();

    unawaited(HouseAdService.instance.pickAd().then((ad) {
      if (!mounted) return;
      setState(() => _houseAdReady = ad != null);
    }));

    unawaited(
      VoiceAssistantService.instance.initialize().catchError((error) {
        debugPrint('Voice Assistant initialization failed: $error');
      }),
    );
  }

  @override
  void dispose() {
    // Do not destroy the shared preloaded ad.
    _rewardedAdService.onAdStateChanged = null;
    _rewardedAdService.onAdClosed = null;

    super.dispose();
  }

  void _watchAdForUndo() {
    if (_busy || _gameFinished || _leaving || !_canWatchAd) {
      return;
    }

    // Remember which player requested the ad.
    final rewardedPlayer = _game.current;

    if (!_adIsReady) {
      unawaited(_watchHouseAdForUndo(rewardedPlayer));
      return;
    }

    _rewardedAdService.showAd(
      onRewardEarned: () => _grantRewardedUndo(rewardedPlayer),
      onAdUnavailable: () {
        if (!mounted || _leaving) return;
        unawaited(_watchHouseAdForUndo(rewardedPlayer));
      },
    );
  }

  void _grantRewardedUndo(Mark rewardedPlayer) {
    if (!mounted || _leaving) return;

    setState(() {
      if (rewardedPlayer == Mark.x) {
        _rewardedUndoX = true;
      } else {
        _rewardedUndoO = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${rewardedPlayer == Mark.x ? _human.name : _opponent.name} '
              'received 1 extra Undo!',
        ),
      ),
    );
  }

  /// Fallback reward: the admin-managed ad with its countdown (15 s by
  /// default). The extra Undo is given only when it was watched fully.
  Future<void> _watchHouseAdForUndo(Mark rewardedPlayer) async {
    if (_showingHouseAd) return;
    _showingHouseAd = true;

    try {
      final ad = await HouseAdService.instance.pickAd();
      if (!mounted || _leaving) return;

      if (ad == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad is not ready. Please try again shortly.'),
          ),
        );
        return;
      }

      final watched = await AdCountdownScreen.show(context, ad);
      if (watched) _grantRewardedUndo(rewardedPlayer);
    } finally {
      _showingHouseAd = false;
    }
  }

  void _announce(String message) {
    unawaited(
      VoiceAssistantService.instance.speak(message),
    );
  }

  Future<void> _onTap(int index) async {
    if (_busy || _game.isOver || _gameFinished || _leaving) return;

    if (_game.board[index] != null) return;

    final movingMark = _game.current;

    if (!_game.play(index)) return;

    setState(() {
      _hint = null;

      if (widget.vsComputer && movingMark == Mark.x) {
        _busy = true;
      }
    });

    AudioService.playMoveSound().catchError((_) {});

    if (!widget.vsComputer) {
      _announce(_status);
    }

    if (!mounted) return;

    if (await _finishIfOver()) return;

    if (!widget.vsComputer) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || _gameFinished || _leaving) return;

    final computerMove = _opponent.chooseMove(_game.board);

    if (computerMove != null && _game.play(computerMove)) {
      setState(() {
        _busy = false;
      });

      AudioService.playMoveSound().catchError((_) {});

      if (!_game.isOver) {
        _announce(_status);
      }
    } else {
      setState(() {
        _busy = false;
      });
    }

    if (!mounted) return;

    await _finishIfOver();
  }

  Future<bool> _finishIfOver() async {
    if (!_game.isOver || _gameFinished) return false;

    _gameFinished = true;

    setState(() {
      _busy = true;
    });

    final winner = _game.winner;

    if (winner != null) {
      AudioService.playWinningSound().catchError((_) {});
    }

    final result = winner == null
        ? 'draw'
        : (winner == Mark.x ? 'win' : 'loss');

    await _db.saveGameResult(
      player1Phone: widget.user.phone,
      player2Phone: widget.opponentUser?.phone,
      opponentType: widget.vsComputer
          ? 'computer'
          : (widget.opponentUser == null ? 'guest' : 'player'),
      opponentName: widget.vsComputer ? 'Computer' : _opponentName,
      difficulty: widget.vsComputer ? widget.difficulty.label : null,
      resultForPlayer1: result,
    );

    unawaited(
      FirestoreSyncService()
          .syncGameResult(
        opponentType: widget.vsComputer
            ? 'computer'
            : (widget.opponentUser == null ? 'guest' : 'player'),
        opponentName: widget.vsComputer ? 'Computer' : _opponentName,
        difficulty: widget.vsComputer ? widget.difficulty.label : null,
        result: result,
      )
          .catchError((Object error) {
        debugPrint('Firebase game sync failed: $error');
      }),
    );

    if (widget.vsComputer) {
      if (winner == Mark.x) {
        _score += 10 * widget.level;

        // Unlock the next level (or complete the 1000-level track).
        await _progress.recordWin(
          widget.user.phone,
          widget.difficulty,
          widget.level,
        );

        await _profile.recordResult(
          widget.user.phone,
          'win',
          _score,
        );
      } else if (winner == Mark.o) {
        await _profile.recordResult(
          widget.user.phone,
          'loss',
          _score,
        );
      } else {
        await _profile.recordResult(
          widget.user.phone,
          'draw',
          _score,
        );
      }
    } else {
      final playerOneResult = winner == null
          ? 'draw'
          : (winner == Mark.x ? 'win' : 'loss');

      final playerTwoResult = winner == null
          ? 'draw'
          : (winner == Mark.o ? 'win' : 'loss');

      await _profile.recordResult(
        widget.user.phone,
        playerOneResult,
        0,
        twoPlayer: true,
      );

      final other = widget.opponentUser;

      if (other != null) {
        await _profile.recordResult(
          other.phone,
          playerTwoResult,
          0,
          twoPlayer: true,
        );
      }

      if (winner != null) {
        _score += 10 * widget.level;
      }
    }

    await Future.delayed(const Duration(milliseconds: 1300));

    if (!mounted) return true;

    if (winner == null) {
      _showEnd('Draw!', 'Nobody won this round.');
    } else if (!widget.vsComputer) {
      final winnerName =
      winner == Mark.x ? _human.name : _opponent.name;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WinScreen(
            user: widget.user,
            difficulty: widget.difficulty,
            level: widget.level,
            score: _score,
            vsComputer: false,
            opponentUser: widget.opponentUser,
            winnerName: winnerName,
          ),
        ),
      );
    } else if (winner == Mark.x) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WinScreen(
            user: widget.user,
            difficulty: widget.difficulty,
            level: widget.level,
            score: _score,
          ),
        ),
      );
    } else {
      _showEnd('Computer wins!', 'Better luck next time.');
    }

    return true;
  }

  void _showEnd(String title, String message) {
    _announce('$title $message');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppTheme.neonPink,
            width: 2,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.neonPink),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _goMenu();
            },
            child: const Text('Main menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _reset();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _goMenu() {
    if (_leaving) return;

    _leaving = true;

    _announce('Main menu');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MenuScreen(user: widget.user),
      ),
          (route) => false,
    );
  }

  void _reset() {
    _game.reset();
    _gameFinished = false;
    _leaving = false;

    // Reset rewarded ad limits for the new game.
    _rewardedUndoX = false;
    _rewardedUndoO = false;

    setState(() {
      _busy = false;
      _hint = null;
      _undosLeft = 2;
      _hintsLeft = 3;
    });

    _announce(_status);
  }

  void _undo() {
    final currentPlayer = _game.current;
    final requiredMoves = widget.vsComputer ? 2 : 1;

    if (_busy ||
        _gameFinished ||
        _leaving ||
        _game.movesPlayed < requiredMoves) {
      return;
    }

    // Use normal Undo first. Rewarded Undo stays separate.
    if (_undosLeft > 0) {
      for (var i = 0; i < requiredMoves; i++) {
        _game.undo();
      }

      setState(() {
        _undosLeft--;
        _hint = null;
      });

      _announce('Undo');
      return;
    }

    // Use only the current player's rewarded Undo.
    if (currentPlayer == Mark.x && _rewardedUndoX) {
      _rewardedUndoX = false;
    } else if (currentPlayer == Mark.o && _rewardedUndoO) {
      _rewardedUndoO = false;
    } else {
      return;
    }

    for (var i = 0; i < requiredMoves; i++) {
      _game.undo();
    }

    setState(() {
      _hint = null;
    });

    _announce('Rewarded Undo');
  }

  void _showHint() {
    if (_busy ||
        _game.isOver ||
        _gameFinished ||
        _leaving ||
        _hintsLeft == 0) {
      return;
    }

    final hint = HardComputer(_game.current).chooseMove(_game.board);

    if (hint == null) return;

    setState(() {
      _hint = hint;
      _hintsLeft--;
    });

    _announce('Hint');
  }

  /// Double-tap on the top bar: say (and show) where the game stands.
  void _repeatStatus() {
    final level = widget.vsComputer
        ? 'Level ${widget.level} of ${LevelProgressService.maxLevel}, '
            '${widget.difficulty.label}. Score $_score. '
        : 'Player versus player. ';
    final status = _game.isOver ? 'Game over.' : '$_status.';
    final message = '$level$status '
        'Undo left: $_availableUndoCount'
        '${widget.vsComputer ? ', hints left: $_hintsLeft' : ''}.';

    _announce(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ));
  }

  /// Swipe left on the board = Undo, swipe right = Hint.
  void _onBoardSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 250) return;

    if (velocity < 0) {
      if (_availableUndoCount > 0) {
        _undo();
      } else {
        _announce('No undo left');
      }
    } else if (widget.vsComputer) {
      if (_hintsLeft > 0) {
        _showHint();
      } else {
        _announce('No hints left');
      }
    }
  }

  Widget _tool(
      IconData icon,
      String label,
      int remaining,
      VoidCallback onTap,
      Color color,
      ) {
    final enabled =
        remaining > 0 && !_busy && !_gameFinished && !_leaving;

    return Tooltip(
      message: '$label ($remaining left)',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: '$label, $remaining left',
        excludeSemantics: true,
        onTap: enabled ? onTap : null,
        child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.purple,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(120),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text('$label ($remaining)'),
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canUndoNow = _game.movesPlayed >=
        (widget.vsComputer ? 2 : 1);

    final header = Semantics(
      hint: 'Double tap the top bar to hear the game status',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _repeatStatus,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Main menu',
                    icon: const Icon(
                      Icons.home,
                      color: AppTheme.neonCyan,
                    ),
                    onPressed: _busy || _gameFinished || _leaving
                        ? null
                        : () {
                      AudioService.playButtonSound();
                      _goMenu();
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.vsComputer
                              ? 'Level ${widget.level} | ${widget.difficulty.label}'
                              : 'Player vs Player',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonYellow,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.vsComputer)
                          Text(
                            'Score: $_score  •  '
                            '${widget.level}/${LevelProgressService.maxLevel}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Retry',
                    icon: const Icon(
                      Icons.refresh,
                      color: AppTheme.neonPink,
                    ),
                    onPressed: _busy || _gameFinished || _leaving
                        ? null
                        : () {
                      AudioService.playButtonSound();
                      _reset();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '${_human.name} (X)',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.neonCyan,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${_opponent.name} (O)',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.neonPink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Semantics(liveRegion: true, child: Text(_status)),
          ],
        ),
      ),
    );

    final tools = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tool(
                Icons.undo,
                'Undo',
                _availableUndoCount,
                _undo,
                AppTheme.neonPink,
              ),
              if (widget.vsComputer) ...[
                const SizedBox(width: 36),
                _tool(
                  Icons.lightbulb,
                  'Hint',
                  _hintsLeft,
                  _showHint,
                  AppTheme.neonYellow,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: ElevatedButton.icon(
            onPressed: (_adIsReady || _houseAdReady) &&
                _canWatchAd &&
                canUndoNow &&
                !_busy &&
                !_gameFinished &&
                !_leaving
                ? _watchAdForUndo
                : null,
            icon: const Icon(Icons.play_circle_fill),
            label: Text(
              _adButtonLabel,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.purple,
              foregroundColor: AppTheme.neonYellow,
              disabledBackgroundColor:
              AppTheme.purple.withAlpha(100),
              disabledForegroundColor: Colors.white54,
              side: const BorderSide(
                color: AppTheme.neonYellow,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        // The board size is computed from the free space, and the page can
        // scroll on very small or landscape screens, so nothing can overflow
        // at the bottom.
        child: LayoutBuilder(
          builder: (context, constraints) {
            const reservedHeight = 300.0; // header + tools + spacing
            final byHeight = constraints.maxHeight - reservedHeight;
            final byWidth = constraints.maxWidth - 40;
            final boardSize =
                (byHeight < byWidth ? byHeight : byWidth).clamp(200.0, 420.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    header,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: GestureDetector(
                        onHorizontalDragEnd: _onBoardSwipe,
                        child: SizedBox(
                          width: boardSize,
                          child: BoardWidget(
                            board: _game.board,
                            winLine: _game.winLine,
                            hintCell: _hint,
                            onTap: _onTap,
                          ),
                        ),
                      ),
                    ),
                    tools,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
