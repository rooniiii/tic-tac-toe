import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class AppUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class GameHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get player1UserId =>
      integer().references(AppUsers, #id)();
  IntColumn get player2UserId =>
      integer().nullable().references(AppUsers, #id)();
  TextColumn get opponentType => text()();
  TextColumn get opponentName => text()();
  TextColumn get difficulty => text().nullable()();
  TextColumn get resultForPlayer1 => text()();
  IntColumn get winnerUserId =>
      integer().nullable().references(AppUsers, #id)();
  TextColumn get movesJson => text().nullable()();
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class PlayerOpponentStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(AppUsers, #id)();
  TextColumn get opponentType => text()();
  TextColumn get difficulty => text().nullable()();
  IntColumn get gamesPlayed =>
      integer().withDefault(const Constant(0))();
  IntColumn get wins =>
      integer().withDefault(const Constant(0))();
  IntColumn get losses =>
      integer().withDefault(const Constant(0))();
  IntColumn get draws =>
      integer().withDefault(const Constant(0))();
}

class UserProfiles extends Table {
  IntColumn get userId =>
      integer().references(AppUsers, #id)();
  TextColumn get bio => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [
    AppUsers,
    GameHistory,
    PlayerOpponentStats,
    UserProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'neon_xo_database'));

  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 1;

  // Validate game results before saving.
  String _validateResult(String result) {
    final normalized = result.trim().toLowerCase();

    if (!{'win', 'loss', 'draw'}.contains(normalized)) {
      throw ArgumentError(
        'Invalid game result. Allowed values: win, loss, draw.',
      );
    }

    return normalized;
  }

  Future<int> createUser({
    required String name,
    required String phone,
    required String passwordHash,
    required String salt,
  }) {
    if (name.trim().isEmpty ||
        phone.trim().isEmpty ||
        passwordHash.isEmpty ||
        salt.isEmpty) {
      throw ArgumentError('User information is incomplete.');
    }

    return into(appUsers).insert(
      AppUsersCompanion.insert(
        name: name.trim(),
        phone: phone.trim(),
        passwordHash: passwordHash,
        salt: salt,
      ),
    );
  }

  Future<AppUser?> findUserByPhone(String phone) {
    return (select(appUsers)
      ..where((user) => user.phone.equals(phone.trim())))
        .getSingleOrNull();
  }

  // Update password hash and salt for an existing user.
  Future<void> updateUserPassword({
    required String phone,
    required String passwordHash,
    required String salt,
  }) async {
    if (phone.trim().isEmpty ||
        passwordHash.isEmpty ||
        salt.isEmpty) {
      throw ArgumentError('Password update information is incomplete.');
    }

    await (update(appUsers)
      ..where((user) => user.phone.equals(phone.trim())))
        .write(
      AppUsersCompanion(
        passwordHash: Value(passwordHash),
        salt: Value(salt),
      ),
    );
  }

  // Update or create opponent statistics.
  Future<void> _updateOpponentStats({
    required int userId,
    required String opponentType,
    required String result,
    String? difficulty,
  }) async {
    final existing = await (select(playerOpponentStats)
      ..where((row) =>
      row.userId.equals(userId) &
      row.opponentType.equals(opponentType) &
      (difficulty == null
          ? row.difficulty.isNull()
          : row.difficulty.equals(difficulty))))
        .getSingleOrNull();

    if (existing == null) {
      await into(playerOpponentStats).insert(
        PlayerOpponentStatsCompanion.insert(
          userId: userId,
          opponentType: opponentType,
          difficulty: difficulty == null
              ? const Value.absent()
              : Value(difficulty),
          gamesPlayed: const Value(1),
          wins: Value(result == 'win' ? 1 : 0),
          losses: Value(result == 'loss' ? 1 : 0),
          draws: Value(result == 'draw' ? 1 : 0),
        ),
      );
    } else {
      await (update(playerOpponentStats)
        ..where((row) => row.id.equals(existing.id)))
          .write(
        PlayerOpponentStatsCompanion(
          gamesPlayed: Value(existing.gamesPlayed + 1),
          wins: Value(existing.wins + (result == 'win' ? 1 : 0)),
          losses: Value(existing.losses + (result == 'loss' ? 1 : 0)),
          draws: Value(existing.draws + (result == 'draw' ? 1 : 0)),
        ),
      );
    }
  }

  // Save completed game and update statistics atomically.
  Future<void> saveGameResult({
    required String player1Phone,
    String? player2Phone,
    required String opponentType,
    required String opponentName,
    String? difficulty,
    required String resultForPlayer1,
  }) async {
    final result = _validateResult(resultForPlayer1);

    if (player1Phone.trim().isEmpty ||
        opponentType.trim().isEmpty ||
        opponentName.trim().isEmpty) {
      throw ArgumentError('Game information is incomplete.');
    }

    await transaction(() async {
      final player1 = await findUserByPhone(player1Phone);

      if (player1 == null) {
        throw Exception('Player 1 not found.');
      }

      final normalizedPlayer2Phone = player2Phone?.trim();

      final player2 = normalizedPlayer2Phone == null ||
          normalizedPlayer2Phone.isEmpty
          ? null
          : await findUserByPhone(normalizedPlayer2Phone);

      int? winnerId;

      if (result == 'win') {
        winnerId = player1.id;
      } else if (result == 'loss') {
        winnerId = player2?.id;
      }

      await into(gameHistory).insert(
        GameHistoryCompanion.insert(
          player1UserId: player1.id,
          player2UserId: Value(player2?.id),
          opponentType: opponentType.trim(),
          opponentName: opponentName.trim(),
          difficulty: Value(difficulty?.trim()),
          resultForPlayer1: result,
          winnerUserId: Value(winnerId),
        ),
      );

      // Update Player 1 statistics.
      await _updateOpponentStats(
        userId: player1.id,
        opponentType: opponentType.trim(),
        result: result,
        difficulty: difficulty?.trim(),
      );

      // Update Player 2 statistics if Player 2 is registered.
      if (player2 != null) {
        final player2Result = result == 'win'
            ? 'loss'
            : result == 'loss'
            ? 'win'
            : 'draw';

        await _updateOpponentStats(
          userId: player2.id,
          opponentType: 'player',
          result: player2Result,
        );
      }
    });
  }
}