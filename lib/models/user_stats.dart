class UserStats {
  final int _played;
  final int _wins;
  final int _losses;
  final int _draws;
  final int _bestScore;

  const UserStats({
    int played = 0,
    int wins = 0,
    int losses = 0,
    int draws = 0,
    int bestScore = 0,
  })  : _played = played,
        _wins = wins,
        _losses = losses,
        _draws = draws,
        _bestScore = bestScore;

  int get played => _played;
  int get wins => _wins;
  int get losses => _losses;
  int get draws => _draws;
  int get bestScore => _bestScore;

  Map<String, dynamic> toMap() => {
    'played': _played,
    'wins': _wins,
    'losses': _losses,
    'draws': _draws,
    'bestScore': _bestScore,
  };

  factory UserStats.fromMap(Map<String, dynamic> m) => UserStats(
    played: m['played'] ?? 0,
    wins: m['wins'] ?? 0,
    losses: m['losses'] ?? 0,
    draws: m['draws'] ?? 0,
    bestScore: m['bestScore'] ?? 0,
  );
}