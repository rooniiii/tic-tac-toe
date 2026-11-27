import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/logic/game_logic.dart';
import 'package:tic_tac_toe/models/difficulty.dart';
import 'package:tic_tac_toe/models/mark.dart';
import 'package:tic_tac_toe/models/player.dart';

GameLogic playAll(List<int> moves) {
  final game = GameLogic();
  for (final m in moves) {
    expect(game.play(m), isTrue, reason: 'move $m should be legal');
  }
  return game;
}

void main() {
  group('GameLogic', () {
    test('starts empty with X to move', () {
      final game = GameLogic();
      expect(game.board.every((c) => c == null), isTrue);
      expect(game.current, Mark.x);
      expect(game.isOver, isFalse);
      expect(game.movesPlayed, 0);
    });

    test('players alternate', () {
      final game = playAll([0]);
      expect(game.current, Mark.o);
      game.play(4);
      expect(game.current, Mark.x);
    });

    test('rejects occupied, out-of-range and post-game moves', () {
      final game = playAll([0]);
      expect(game.play(0), isFalse);
      expect(game.play(-1), isFalse);
      expect(game.play(9), isFalse);

      final won = playAll([0, 3, 1, 4, 2]); // X wins top row
      expect(won.play(8), isFalse);
    });

    test('detects a row, a column and both diagonals', () {
      expect(playAll([0, 3, 1, 4, 2]).winLine, [0, 1, 2]);
      expect(playAll([1, 0, 4, 2, 7]).winLine, [1, 4, 7]);
      expect(playAll([0, 1, 4, 2, 8]).winLine, [0, 4, 8]);
      expect(playAll([2, 0, 4, 1, 6]).winLine, [2, 4, 6]);
    });

    test('O can win too', () {
      final game = playAll([0, 3, 1, 4, 8, 5]);
      expect(game.winner, Mark.o);
      expect(game.winLine, [3, 4, 5]);
    });

    test('full board without a line is a draw', () {
      // X O X / X O O / O X X
      final game = playAll([0, 1, 2, 4, 3, 5, 7, 6, 8]);
      expect(game.winner, isNull);
      expect(game.isDraw, isTrue);
      expect(game.isOver, isTrue);
    });

    test('undo takes back the move, the turn and the win', () {
      final game = playAll([0, 3, 1, 4, 2]);
      expect(game.winner, Mark.x);

      expect(game.undo(), isTrue);
      expect(game.winner, isNull);
      expect(game.winLine, isNull);
      expect(game.board[2], isNull);
      expect(game.current, Mark.x);
      expect(game.movesPlayed, 4);
    });

    test('undo on an empty board does nothing', () {
      expect(GameLogic().undo(), isFalse);
    });

    test('reset clears everything', () {
      final game = playAll([0, 3, 1, 4, 2])..reset();
      expect(game.board.every((c) => c == null), isTrue);
      expect(game.current, Mark.x);
      expect(game.winner, isNull);
      expect(game.canUndo, isFalse);
    });

    test('board getter returns a copy', () {
      final game = GameLogic();
      game.board[0] = Mark.o;
      expect(game.board[0], isNull);
    });
  });

  group('Computer players', () {
    test('factory returns the right class per difficulty', () {
      expect(ComputerPlayer.forDifficulty(Difficulty.easy, Mark.o),
          isA<EasyComputer>());
      expect(ComputerPlayer.forDifficulty(Difficulty.medium, Mark.o),
          isA<MediumComputer>());
      expect(ComputerPlayer.forDifficulty(Difficulty.hard, Mark.o),
          isA<HardComputer>());
      expect(HumanPlayer('Ann', Mark.x).chooseMove(List.filled(9, null)),
          isNull);
    });

    test('every computer only picks empty cells', () {
      final board = <Mark?>[Mark.x, Mark.o, Mark.x, null, Mark.o, null,
          null, Mark.x, null];
      for (final d in Difficulty.values) {
        final ai = ComputerPlayer.forDifficulty(d, Mark.o);
        for (var i = 0; i < 30; i++) {
          final move = ai.chooseMove(board);
          expect(move, isNotNull);
          expect(board[move!], isNull, reason: '${d.name} picked a full cell');
        }
      }
    });

    test('hard computer takes a winning move', () {
      // O to play and win at 5 (row 3-4-5).
      final board = <Mark?>[Mark.x, Mark.x, null, Mark.o, Mark.o, null,
          Mark.x, null, null];
      expect(HardComputer(Mark.o).chooseMove(board), 5);
    });

    test('hard computer blocks the opponent', () {
      // X threatens 0-1-2; O must play 2.
      final board = <Mark?>[Mark.x, Mark.x, null, null, Mark.o, null,
          null, null, null];
      expect(HardComputer(Mark.o).chooseMove(board), 2);
    });

    test('hard computer never loses (all human move sequences)', () {
      final ai = HardComputer(Mark.o);
      var games = 0;

      void explore(GameLogic game) {
        if (game.isOver) {
          games++;
          expect(game.winner, isNot(Mark.x),
              reason: 'human won with board ${game.board}');
          return;
        }
        // Human (X): try every possible move.
        for (var i = 0; i < 9; i++) {
          if (game.board[i] != null) continue;
          game.play(i);
          if (!game.isOver) {
            game.play(ai.chooseMove(game.board)!);
            explore(game);
            game.undo();
          } else {
            explore(game);
          }
          game.undo();
        }
      }

      explore(GameLogic());
      expect(games, greaterThan(100));
    });
  });
}
