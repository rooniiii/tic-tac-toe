enum Difficulty { easy, medium, hard }

extension DifficultyLabel on Difficulty {
  String get label => name[0].toUpperCase() + name.substring(1);
}