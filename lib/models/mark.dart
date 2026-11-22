enum Mark { x, o }

extension MarkExtra on Mark {
  Mark get other => this == Mark.x ? Mark.o : Mark.x;
  String get symbol => this == Mark.x ? 'X' : 'O';
}