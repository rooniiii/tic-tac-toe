import '../models/mark.dart';

class GameLogic {
  final List<Mark?> _board = List<Mark?>.filled(9, null);
  final List<int> _history = [];
  Mark _current = Mark.x;
  Mark? _winner;
  List<int>? _winLine;

  static const List<List<int>> lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  List<Mark?> get board => List<Mark?>.from(_board);
  Mark get current => _current;
  Mark? get winner => _winner;
  List<int>? get winLine => _winLine;
  bool get isDraw => _winner == null && !_board.contains(null);
  bool get isOver => _winner != null || isDraw;
  int get movesPlayed => _history.length;

  /// Returns true if the move was accepted.
  bool play(int index) {
    if (isOver || index < 0 || index > 8 || _board[index] != null) {
      return false;
    }
    _board[index] = _current;
    _history.add(index);
    _winLine = winLineOf(_board);
    if (_winLine != null) {
      _winner = _board[_winLine![0]];
    } else {
      _current = _current.other;
    }
    return true;
  }

  /// Takes back the last move.
  bool undo() {
    if (_history.isEmpty) return false;
    final index = _history.removeLast();
    _current = _board[index]!;
    _board[index] = null;
    _winner = null;
    _winLine = null;
    return true;
  }

  void reset() {
    for (var i = 0; i < 9; i++) {
      _board[i] = null;
    }
    _history.clear();
    _current = Mark.x;
    _winner = null;
    _winLine = null;
  }

  // These two work on any board list, so the computer players can use them too.
  static List<int>? winLineOf(List<Mark?> b) {
    for (final line in lines) {
      final m = b[line[0]];
      if (m != null && m == b[line[1]] && m == b[line[2]]) return line;
    }
    return null;
  }

  static Mark? winnerOf(List<Mark?> b) {
    final line = winLineOf(b);
    return line == null ? null : b[line[0]];
  }
}