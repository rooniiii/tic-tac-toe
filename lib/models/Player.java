import 'dart:math';
import '../logic/game_logic.dart';
import 'difficulty.dart';
import 'mark.dart';

/// Parent class. Child classes must write their own chooseMove().
abstract class Player {
  final String _name; // private = encapsulation
  final Mark mark;

  Player(String name, this.mark) : _name = name;

  String get name => _name;
  bool get isComputer;

  /// Returns the cell (0-8) to play, or null if the player taps by hand.
  int? chooseMove(List<Mark?> board);
}

class HumanPlayer extends Player {
  HumanPlayer(super.name, super.mark);

  @override
  bool get isComputer => false;

  @override
  int? chooseMove(List<Mark?> board) => null; // waits for the user's tap
}

abstract class ComputerPlayer extends Player {
  final Random _rng = Random();

  ComputerPlayer(super.name, super.mark);

  /// Creates the right child class. The game never needs to know which one.
  factory ComputerPlayer.forDifficulty(Difficulty d, Mark mark) {
    switch (d) {
      case Difficulty.easy:
        return EasyComputer(mark);
      case Difficulty.medium:
        return MediumComputer(mark);
      case Difficulty.hard:
        return HardComputer(mark);
    }
  }

  @override
  bool get isComputer => true;

  List<int> emptyCells(List<Mark?> b) =>
      [for (var i = 0; i < 9; i++) if (b[i] == null) i];

  int randomMove(List<Mark?> b) {
    final empty = emptyCells(b);
    return empty[_rng.nextInt(empty.length)];
  }

  /// A cell where `who` would win on the next move, or null.
  int? findWinningCell(List<Mark?> b, Mark who) {
    for (final i in emptyCells(b)) {
      final copy = List<Mark?>.from(b);
      copy[i] = who;
      if (GameLogic.winnerOf(copy) == who) return i;
    }
    return null;
  }
}

class EasyComputer extends ComputerPlayer {
  EasyComputer(Mark mark) : super('Computer (Easy)', mark);

  @override
  int? chooseMove(List<Mark?> board) => randomMove(board);
}

class MediumComputer extends ComputerPlayer {
  MediumComputer(Mark mark) : super('Computer (Medium)', mark);

  @override
  int? chooseMove(List<Mark?> board) {
    if (_rng.nextInt(100) < 25) return randomMove(board); // sometimes errs
    final win = findWinningCell(board, mark);
    if (win != null) return win;
    final block = findWinningCell(board, mark.other);
    if (block != null) return block;
    if (board[4] == null) return 4;
    return randomMove(board);
  }
}

class HardComputer extends ComputerPlayer {
  HardComputer(Mark mark) : super('Computer (Hard)', mark);

  @override
  int? chooseMove(List<Mark?> board) {
    var bestScore = -1000;
    final bestMoves = <int>[];
    for (final i in emptyCells(board)) {
      final copy = List<Mark?>.from(board);
      copy[i] = mark;
      final score = _minimax(copy, mark.other, 1);
      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(i);
      } else if (score == bestScore) {
        bestMoves.add(i);
      }
    }
    return bestMoves[_rng.nextInt(bestMoves.length)];
  }

  int _minimax(List<Mark?> b, Mark turn, int depth) {
    final w = GameLogic.winnerOf(b);
    if (w == mark) return 10 - depth;
    if (w != null) return depth - 10;
    if (!b.contains(null)) return 0;

    final scores = <int>[];
    for (final i in emptyCells(b)) {
      b[i] = turn;
      scores.add(_minimax(b, turn.other, depth + 1));
      b[i] = null;
    }
    return turn == mark ? scores.reduce(max) : scores.reduce(min);
  }
}