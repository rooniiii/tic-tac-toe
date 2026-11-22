// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    passwordHash,
    salt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final int id;
  final String name;
  final String phone;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      createdAt: Value(createdAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppUser copyWith({
    int? id,
    String? name,
    String? phone,
    String? passwordHash,
    String? salt,
    DateTime? createdAt,
  }) => AppUser(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    createdAt: createdAt ?? this.createdAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, passwordHash, salt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.createdAt == this.createdAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<DateTime> createdAt;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    required String passwordHash,
    required String salt,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone),
       passwordHash = Value(passwordHash),
       salt = Value(salt);
  static Insertable<AppUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? passwordHash,
    Value<String>? salt,
    Value<DateTime>? createdAt,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GameHistoryTable extends GameHistory
    with TableInfo<$GameHistoryTable, GameHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _player1UserIdMeta = const VerificationMeta(
    'player1UserId',
  );
  @override
  late final GeneratedColumn<int> player1UserId = GeneratedColumn<int>(
    'player1_user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _player2UserIdMeta = const VerificationMeta(
    'player2UserId',
  );
  @override
  late final GeneratedColumn<int> player2UserId = GeneratedColumn<int>(
    'player2_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _opponentTypeMeta = const VerificationMeta(
    'opponentType',
  );
  @override
  late final GeneratedColumn<String> opponentType = GeneratedColumn<String>(
    'opponent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opponentNameMeta = const VerificationMeta(
    'opponentName',
  );
  @override
  late final GeneratedColumn<String> opponentName = GeneratedColumn<String>(
    'opponent_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultForPlayer1Meta = const VerificationMeta(
    'resultForPlayer1',
  );
  @override
  late final GeneratedColumn<String> resultForPlayer1 = GeneratedColumn<String>(
    'result_for_player1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winnerUserIdMeta = const VerificationMeta(
    'winnerUserId',
  );
  @override
  late final GeneratedColumn<int> winnerUserId = GeneratedColumn<int>(
    'winner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _movesJsonMeta = const VerificationMeta(
    'movesJson',
  );
  @override
  late final GeneratedColumn<String> movesJson = GeneratedColumn<String>(
    'moves_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    player1UserId,
    player2UserId,
    opponentType,
    opponentName,
    difficulty,
    resultForPlayer1,
    winnerUserId,
    movesJson,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player1_user_id')) {
      context.handle(
        _player1UserIdMeta,
        player1UserId.isAcceptableOrUnknown(
          data['player1_user_id']!,
          _player1UserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_player1UserIdMeta);
    }
    if (data.containsKey('player2_user_id')) {
      context.handle(
        _player2UserIdMeta,
        player2UserId.isAcceptableOrUnknown(
          data['player2_user_id']!,
          _player2UserIdMeta,
        ),
      );
    }
    if (data.containsKey('opponent_type')) {
      context.handle(
        _opponentTypeMeta,
        opponentType.isAcceptableOrUnknown(
          data['opponent_type']!,
          _opponentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opponentTypeMeta);
    }
    if (data.containsKey('opponent_name')) {
      context.handle(
        _opponentNameMeta,
        opponentName.isAcceptableOrUnknown(
          data['opponent_name']!,
          _opponentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opponentNameMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('result_for_player1')) {
      context.handle(
        _resultForPlayer1Meta,
        resultForPlayer1.isAcceptableOrUnknown(
          data['result_for_player1']!,
          _resultForPlayer1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resultForPlayer1Meta);
    }
    if (data.containsKey('winner_user_id')) {
      context.handle(
        _winnerUserIdMeta,
        winnerUserId.isAcceptableOrUnknown(
          data['winner_user_id']!,
          _winnerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('moves_json')) {
      context.handle(
        _movesJsonMeta,
        movesJson.isAcceptableOrUnknown(data['moves_json']!, _movesJsonMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      player1UserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player1_user_id'],
      )!,
      player2UserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player2_user_id'],
      ),
      opponentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_type'],
      )!,
      opponentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_name'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      resultForPlayer1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_for_player1'],
      )!,
      winnerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}winner_user_id'],
      ),
      movesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moves_json'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $GameHistoryTable createAlias(String alias) {
    return $GameHistoryTable(attachedDatabase, alias);
  }
}

class GameHistoryData extends DataClass implements Insertable<GameHistoryData> {
  final int id;
  final int player1UserId;
  final int? player2UserId;
  final String opponentType;
  final String opponentName;
  final String? difficulty;
  final String resultForPlayer1;
  final int? winnerUserId;
  final String? movesJson;
  final DateTime completedAt;
  const GameHistoryData({
    required this.id,
    required this.player1UserId,
    this.player2UserId,
    required this.opponentType,
    required this.opponentName,
    this.difficulty,
    required this.resultForPlayer1,
    this.winnerUserId,
    this.movesJson,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player1_user_id'] = Variable<int>(player1UserId);
    if (!nullToAbsent || player2UserId != null) {
      map['player2_user_id'] = Variable<int>(player2UserId);
    }
    map['opponent_type'] = Variable<String>(opponentType);
    map['opponent_name'] = Variable<String>(opponentName);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['result_for_player1'] = Variable<String>(resultForPlayer1);
    if (!nullToAbsent || winnerUserId != null) {
      map['winner_user_id'] = Variable<int>(winnerUserId);
    }
    if (!nullToAbsent || movesJson != null) {
      map['moves_json'] = Variable<String>(movesJson);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  GameHistoryCompanion toCompanion(bool nullToAbsent) {
    return GameHistoryCompanion(
      id: Value(id),
      player1UserId: Value(player1UserId),
      player2UserId: player2UserId == null && nullToAbsent
          ? const Value.absent()
          : Value(player2UserId),
      opponentType: Value(opponentType),
      opponentName: Value(opponentName),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      resultForPlayer1: Value(resultForPlayer1),
      winnerUserId: winnerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerUserId),
      movesJson: movesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(movesJson),
      completedAt: Value(completedAt),
    );
  }

  factory GameHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameHistoryData(
      id: serializer.fromJson<int>(json['id']),
      player1UserId: serializer.fromJson<int>(json['player1UserId']),
      player2UserId: serializer.fromJson<int?>(json['player2UserId']),
      opponentType: serializer.fromJson<String>(json['opponentType']),
      opponentName: serializer.fromJson<String>(json['opponentName']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      resultForPlayer1: serializer.fromJson<String>(json['resultForPlayer1']),
      winnerUserId: serializer.fromJson<int?>(json['winnerUserId']),
      movesJson: serializer.fromJson<String?>(json['movesJson']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'player1UserId': serializer.toJson<int>(player1UserId),
      'player2UserId': serializer.toJson<int?>(player2UserId),
      'opponentType': serializer.toJson<String>(opponentType),
      'opponentName': serializer.toJson<String>(opponentName),
      'difficulty': serializer.toJson<String?>(difficulty),
      'resultForPlayer1': serializer.toJson<String>(resultForPlayer1),
      'winnerUserId': serializer.toJson<int?>(winnerUserId),
      'movesJson': serializer.toJson<String?>(movesJson),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  GameHistoryData copyWith({
    int? id,
    int? player1UserId,
    Value<int?> player2UserId = const Value.absent(),
    String? opponentType,
    String? opponentName,
    Value<String?> difficulty = const Value.absent(),
    String? resultForPlayer1,
    Value<int?> winnerUserId = const Value.absent(),
    Value<String?> movesJson = const Value.absent(),
    DateTime? completedAt,
  }) => GameHistoryData(
    id: id ?? this.id,
    player1UserId: player1UserId ?? this.player1UserId,
    player2UserId: player2UserId.present
        ? player2UserId.value
        : this.player2UserId,
    opponentType: opponentType ?? this.opponentType,
    opponentName: opponentName ?? this.opponentName,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    resultForPlayer1: resultForPlayer1 ?? this.resultForPlayer1,
    winnerUserId: winnerUserId.present ? winnerUserId.value : this.winnerUserId,
    movesJson: movesJson.present ? movesJson.value : this.movesJson,
    completedAt: completedAt ?? this.completedAt,
  );
  GameHistoryData copyWithCompanion(GameHistoryCompanion data) {
    return GameHistoryData(
      id: data.id.present ? data.id.value : this.id,
      player1UserId: data.player1UserId.present
          ? data.player1UserId.value
          : this.player1UserId,
      player2UserId: data.player2UserId.present
          ? data.player2UserId.value
          : this.player2UserId,
      opponentType: data.opponentType.present
          ? data.opponentType.value
          : this.opponentType,
      opponentName: data.opponentName.present
          ? data.opponentName.value
          : this.opponentName,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      resultForPlayer1: data.resultForPlayer1.present
          ? data.resultForPlayer1.value
          : this.resultForPlayer1,
      winnerUserId: data.winnerUserId.present
          ? data.winnerUserId.value
          : this.winnerUserId,
      movesJson: data.movesJson.present ? data.movesJson.value : this.movesJson,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameHistoryData(')
          ..write('id: $id, ')
          ..write('player1UserId: $player1UserId, ')
          ..write('player2UserId: $player2UserId, ')
          ..write('opponentType: $opponentType, ')
          ..write('opponentName: $opponentName, ')
          ..write('difficulty: $difficulty, ')
          ..write('resultForPlayer1: $resultForPlayer1, ')
          ..write('winnerUserId: $winnerUserId, ')
          ..write('movesJson: $movesJson, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    player1UserId,
    player2UserId,
    opponentType,
    opponentName,
    difficulty,
    resultForPlayer1,
    winnerUserId,
    movesJson,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameHistoryData &&
          other.id == this.id &&
          other.player1UserId == this.player1UserId &&
          other.player2UserId == this.player2UserId &&
          other.opponentType == this.opponentType &&
          other.opponentName == this.opponentName &&
          other.difficulty == this.difficulty &&
          other.resultForPlayer1 == this.resultForPlayer1 &&
          other.winnerUserId == this.winnerUserId &&
          other.movesJson == this.movesJson &&
          other.completedAt == this.completedAt);
}

class GameHistoryCompanion extends UpdateCompanion<GameHistoryData> {
  final Value<int> id;
  final Value<int> player1UserId;
  final Value<int?> player2UserId;
  final Value<String> opponentType;
  final Value<String> opponentName;
  final Value<String?> difficulty;
  final Value<String> resultForPlayer1;
  final Value<int?> winnerUserId;
  final Value<String?> movesJson;
  final Value<DateTime> completedAt;
  const GameHistoryCompanion({
    this.id = const Value.absent(),
    this.player1UserId = const Value.absent(),
    this.player2UserId = const Value.absent(),
    this.opponentType = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.resultForPlayer1 = const Value.absent(),
    this.winnerUserId = const Value.absent(),
    this.movesJson = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  GameHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int player1UserId,
    this.player2UserId = const Value.absent(),
    required String opponentType,
    required String opponentName,
    this.difficulty = const Value.absent(),
    required String resultForPlayer1,
    this.winnerUserId = const Value.absent(),
    this.movesJson = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : player1UserId = Value(player1UserId),
       opponentType = Value(opponentType),
       opponentName = Value(opponentName),
       resultForPlayer1 = Value(resultForPlayer1);
  static Insertable<GameHistoryData> custom({
    Expression<int>? id,
    Expression<int>? player1UserId,
    Expression<int>? player2UserId,
    Expression<String>? opponentType,
    Expression<String>? opponentName,
    Expression<String>? difficulty,
    Expression<String>? resultForPlayer1,
    Expression<int>? winnerUserId,
    Expression<String>? movesJson,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (player1UserId != null) 'player1_user_id': player1UserId,
      if (player2UserId != null) 'player2_user_id': player2UserId,
      if (opponentType != null) 'opponent_type': opponentType,
      if (opponentName != null) 'opponent_name': opponentName,
      if (difficulty != null) 'difficulty': difficulty,
      if (resultForPlayer1 != null) 'result_for_player1': resultForPlayer1,
      if (winnerUserId != null) 'winner_user_id': winnerUserId,
      if (movesJson != null) 'moves_json': movesJson,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  GameHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? player1UserId,
    Value<int?>? player2UserId,
    Value<String>? opponentType,
    Value<String>? opponentName,
    Value<String?>? difficulty,
    Value<String>? resultForPlayer1,
    Value<int?>? winnerUserId,
    Value<String?>? movesJson,
    Value<DateTime>? completedAt,
  }) {
    return GameHistoryCompanion(
      id: id ?? this.id,
      player1UserId: player1UserId ?? this.player1UserId,
      player2UserId: player2UserId ?? this.player2UserId,
      opponentType: opponentType ?? this.opponentType,
      opponentName: opponentName ?? this.opponentName,
      difficulty: difficulty ?? this.difficulty,
      resultForPlayer1: resultForPlayer1 ?? this.resultForPlayer1,
      winnerUserId: winnerUserId ?? this.winnerUserId,
      movesJson: movesJson ?? this.movesJson,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (player1UserId.present) {
      map['player1_user_id'] = Variable<int>(player1UserId.value);
    }
    if (player2UserId.present) {
      map['player2_user_id'] = Variable<int>(player2UserId.value);
    }
    if (opponentType.present) {
      map['opponent_type'] = Variable<String>(opponentType.value);
    }
    if (opponentName.present) {
      map['opponent_name'] = Variable<String>(opponentName.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (resultForPlayer1.present) {
      map['result_for_player1'] = Variable<String>(resultForPlayer1.value);
    }
    if (winnerUserId.present) {
      map['winner_user_id'] = Variable<int>(winnerUserId.value);
    }
    if (movesJson.present) {
      map['moves_json'] = Variable<String>(movesJson.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameHistoryCompanion(')
          ..write('id: $id, ')
          ..write('player1UserId: $player1UserId, ')
          ..write('player2UserId: $player2UserId, ')
          ..write('opponentType: $opponentType, ')
          ..write('opponentName: $opponentName, ')
          ..write('difficulty: $difficulty, ')
          ..write('resultForPlayer1: $resultForPlayer1, ')
          ..write('winnerUserId: $winnerUserId, ')
          ..write('movesJson: $movesJson, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayerOpponentStatsTable extends PlayerOpponentStats
    with TableInfo<$PlayerOpponentStatsTable, PlayerOpponentStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerOpponentStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _opponentTypeMeta = const VerificationMeta(
    'opponentType',
  );
  @override
  late final GeneratedColumn<String> opponentType = GeneratedColumn<String>(
    'opponent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gamesPlayedMeta = const VerificationMeta(
    'gamesPlayed',
  );
  @override
  late final GeneratedColumn<int> gamesPlayed = GeneratedColumn<int>(
    'games_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _winsMeta = const VerificationMeta('wins');
  @override
  late final GeneratedColumn<int> wins = GeneratedColumn<int>(
    'wins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lossesMeta = const VerificationMeta('losses');
  @override
  late final GeneratedColumn<int> losses = GeneratedColumn<int>(
    'losses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _drawsMeta = const VerificationMeta('draws');
  @override
  late final GeneratedColumn<int> draws = GeneratedColumn<int>(
    'draws',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    opponentType,
    difficulty,
    gamesPlayed,
    wins,
    losses,
    draws,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_opponent_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerOpponentStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('opponent_type')) {
      context.handle(
        _opponentTypeMeta,
        opponentType.isAcceptableOrUnknown(
          data['opponent_type']!,
          _opponentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_opponentTypeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('games_played')) {
      context.handle(
        _gamesPlayedMeta,
        gamesPlayed.isAcceptableOrUnknown(
          data['games_played']!,
          _gamesPlayedMeta,
        ),
      );
    }
    if (data.containsKey('wins')) {
      context.handle(
        _winsMeta,
        wins.isAcceptableOrUnknown(data['wins']!, _winsMeta),
      );
    }
    if (data.containsKey('losses')) {
      context.handle(
        _lossesMeta,
        losses.isAcceptableOrUnknown(data['losses']!, _lossesMeta),
      );
    }
    if (data.containsKey('draws')) {
      context.handle(
        _drawsMeta,
        draws.isAcceptableOrUnknown(data['draws']!, _drawsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerOpponentStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerOpponentStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      opponentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_type'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      gamesPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_played'],
      )!,
      wins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wins'],
      )!,
      losses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}losses'],
      )!,
      draws: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draws'],
      )!,
    );
  }

  @override
  $PlayerOpponentStatsTable createAlias(String alias) {
    return $PlayerOpponentStatsTable(attachedDatabase, alias);
  }
}

class PlayerOpponentStat extends DataClass
    implements Insertable<PlayerOpponentStat> {
  final int id;
  final int userId;
  final String opponentType;
  final String? difficulty;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;
  const PlayerOpponentStat({
    required this.id,
    required this.userId,
    required this.opponentType,
    this.difficulty,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['opponent_type'] = Variable<String>(opponentType);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['games_played'] = Variable<int>(gamesPlayed);
    map['wins'] = Variable<int>(wins);
    map['losses'] = Variable<int>(losses);
    map['draws'] = Variable<int>(draws);
    return map;
  }

  PlayerOpponentStatsCompanion toCompanion(bool nullToAbsent) {
    return PlayerOpponentStatsCompanion(
      id: Value(id),
      userId: Value(userId),
      opponentType: Value(opponentType),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      gamesPlayed: Value(gamesPlayed),
      wins: Value(wins),
      losses: Value(losses),
      draws: Value(draws),
    );
  }

  factory PlayerOpponentStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerOpponentStat(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      opponentType: serializer.fromJson<String>(json['opponentType']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      gamesPlayed: serializer.fromJson<int>(json['gamesPlayed']),
      wins: serializer.fromJson<int>(json['wins']),
      losses: serializer.fromJson<int>(json['losses']),
      draws: serializer.fromJson<int>(json['draws']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'opponentType': serializer.toJson<String>(opponentType),
      'difficulty': serializer.toJson<String?>(difficulty),
      'gamesPlayed': serializer.toJson<int>(gamesPlayed),
      'wins': serializer.toJson<int>(wins),
      'losses': serializer.toJson<int>(losses),
      'draws': serializer.toJson<int>(draws),
    };
  }

  PlayerOpponentStat copyWith({
    int? id,
    int? userId,
    String? opponentType,
    Value<String?> difficulty = const Value.absent(),
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? draws,
  }) => PlayerOpponentStat(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    opponentType: opponentType ?? this.opponentType,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    wins: wins ?? this.wins,
    losses: losses ?? this.losses,
    draws: draws ?? this.draws,
  );
  PlayerOpponentStat copyWithCompanion(PlayerOpponentStatsCompanion data) {
    return PlayerOpponentStat(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      opponentType: data.opponentType.present
          ? data.opponentType.value
          : this.opponentType,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      gamesPlayed: data.gamesPlayed.present
          ? data.gamesPlayed.value
          : this.gamesPlayed,
      wins: data.wins.present ? data.wins.value : this.wins,
      losses: data.losses.present ? data.losses.value : this.losses,
      draws: data.draws.present ? data.draws.value : this.draws,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerOpponentStat(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('opponentType: $opponentType, ')
          ..write('difficulty: $difficulty, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    opponentType,
    difficulty,
    gamesPlayed,
    wins,
    losses,
    draws,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerOpponentStat &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.opponentType == this.opponentType &&
          other.difficulty == this.difficulty &&
          other.gamesPlayed == this.gamesPlayed &&
          other.wins == this.wins &&
          other.losses == this.losses &&
          other.draws == this.draws);
}

class PlayerOpponentStatsCompanion extends UpdateCompanion<PlayerOpponentStat> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> opponentType;
  final Value<String?> difficulty;
  final Value<int> gamesPlayed;
  final Value<int> wins;
  final Value<int> losses;
  final Value<int> draws;
  const PlayerOpponentStatsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.opponentType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
  });
  PlayerOpponentStatsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String opponentType,
    this.difficulty = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.wins = const Value.absent(),
    this.losses = const Value.absent(),
    this.draws = const Value.absent(),
  }) : userId = Value(userId),
       opponentType = Value(opponentType);
  static Insertable<PlayerOpponentStat> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? opponentType,
    Expression<String>? difficulty,
    Expression<int>? gamesPlayed,
    Expression<int>? wins,
    Expression<int>? losses,
    Expression<int>? draws,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (opponentType != null) 'opponent_type': opponentType,
      if (difficulty != null) 'difficulty': difficulty,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (wins != null) 'wins': wins,
      if (losses != null) 'losses': losses,
      if (draws != null) 'draws': draws,
    });
  }

  PlayerOpponentStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? opponentType,
    Value<String?>? difficulty,
    Value<int>? gamesPlayed,
    Value<int>? wins,
    Value<int>? losses,
    Value<int>? draws,
  }) {
    return PlayerOpponentStatsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      opponentType: opponentType ?? this.opponentType,
      difficulty: difficulty ?? this.difficulty,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (opponentType.present) {
      map['opponent_type'] = Variable<String>(opponentType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (gamesPlayed.present) {
      map['games_played'] = Variable<int>(gamesPlayed.value);
    }
    if (wins.present) {
      map['wins'] = Variable<int>(wins.value);
    }
    if (losses.present) {
      map['losses'] = Variable<int>(losses.value);
    }
    if (draws.present) {
      map['draws'] = Variable<int>(draws.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerOpponentStatsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('opponentType: $opponentType, ')
          ..write('difficulty: $difficulty, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('wins: $wins, ')
          ..write('losses: $losses, ')
          ..write('draws: $draws')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_users (id)',
    ),
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, bio, avatarPath, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int userId;
  final String? bio;
  final String? avatarPath;
  final DateTime updatedAt;
  const UserProfile({
    required this.userId,
    this.bio,
    this.avatarPath,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      userId: Value(userId),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      userId: serializer.fromJson<int>(json['userId']),
      bio: serializer.fromJson<String?>(json['bio']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'bio': serializer.toJson<String?>(bio),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({
    int? userId,
    Value<String?> bio = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    DateTime? updatedAt,
  }) => UserProfile(
    userId: userId ?? this.userId,
    bio: bio.present ? bio.value : this.bio,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      bio: data.bio.present ? data.bio.value : this.bio,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('userId: $userId, ')
          ..write('bio: $bio, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, bio, avatarPath, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.userId == this.userId &&
          other.bio == this.bio &&
          other.avatarPath == this.avatarPath &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> userId;
  final Value<String?> bio;
  final Value<String?> avatarPath;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.userId = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.userId = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserProfile> custom({
    Expression<int>? userId,
    Expression<String>? bio,
    Expression<String>? avatarPath,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (bio != null) 'bio': bio,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? userId,
    Value<String?>? bio,
    Value<String?>? avatarPath,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('bio: $bio, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $GameHistoryTable gameHistory = $GameHistoryTable(this);
  late final $PlayerOpponentStatsTable playerOpponentStats =
      $PlayerOpponentStatsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appUsers,
    gameHistory,
    playerOpponentStats,
    userProfiles,
  ];
}

typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      required String name,
      required String phone,
      required String passwordHash,
      required String salt,
      Value<DateTime> createdAt,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> phone,
      Value<String> passwordHash,
      Value<String> salt,
      Value<DateTime> createdAt,
    });

final class $$AppUsersTableReferences
    extends BaseReferences<_$AppDatabase, $AppUsersTable, AppUser> {
  $$AppUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $PlayerOpponentStatsTable,
    List<PlayerOpponentStat>
  >
  _playerOpponentStatsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.playerOpponentStats,
        aliasName: $_aliasNameGenerator(
          db.appUsers.id,
          db.playerOpponentStats.userId,
        ),
      );

  $$PlayerOpponentStatsTableProcessedTableManager get playerOpponentStatsRefs {
    final manager = $$PlayerOpponentStatsTableTableManager(
      $_db,
      $_db.playerOpponentStats,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerOpponentStatsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserProfilesTable, List<UserProfile>>
  _userProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProfiles,
    aliasName: $_aliasNameGenerator(db.appUsers.id, db.userProfiles.userId),
  );

  $$UserProfilesTableProcessedTableManager get userProfilesRefs {
    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProfilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playerOpponentStatsRefs(
    Expression<bool> Function($$PlayerOpponentStatsTableFilterComposer f) f,
  ) {
    final $$PlayerOpponentStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerOpponentStats,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerOpponentStatsTableFilterComposer(
            $db: $db,
            $table: $db.playerOpponentStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userProfilesRefs(
    Expression<bool> Function($$UserProfilesTableFilterComposer f) f,
  ) {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playerOpponentStatsRefs<T extends Object>(
    Expression<T> Function($$PlayerOpponentStatsTableAnnotationComposer a) f,
  ) {
    final $$PlayerOpponentStatsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.playerOpponentStats,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlayerOpponentStatsTableAnnotationComposer(
                $db: $db,
                $table: $db.playerOpponentStats,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userProfilesRefs<T extends Object>(
    Expression<T> Function($$UserProfilesTableAnnotationComposer a) f,
  ) {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, $$AppUsersTableReferences),
          AppUser,
          PrefetchHooks Function({
            bool playerOpponentStatsRefs,
            bool userProfilesRefs,
          })
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                name: name,
                phone: phone,
                passwordHash: passwordHash,
                salt: salt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String phone,
                required String passwordHash,
                required String salt,
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                passwordHash: passwordHash,
                salt: salt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playerOpponentStatsRefs = false, userProfilesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerOpponentStatsRefs) db.playerOpponentStats,
                    if (userProfilesRefs) db.userProfiles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playerOpponentStatsRefs)
                        await $_getPrefetchedData<
                          AppUser,
                          $AppUsersTable,
                          PlayerOpponentStat
                        >(
                          currentTable: table,
                          referencedTable: $$AppUsersTableReferences
                              ._playerOpponentStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AppUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).playerOpponentStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userProfilesRefs)
                        await $_getPrefetchedData<
                          AppUser,
                          $AppUsersTable,
                          UserProfile
                        >(
                          currentTable: table,
                          referencedTable: $$AppUsersTableReferences
                              ._userProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AppUsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, $$AppUsersTableReferences),
      AppUser,
      PrefetchHooks Function({
        bool playerOpponentStatsRefs,
        bool userProfilesRefs,
      })
    >;
typedef $$GameHistoryTableCreateCompanionBuilder =
    GameHistoryCompanion Function({
      Value<int> id,
      required int player1UserId,
      Value<int?> player2UserId,
      required String opponentType,
      required String opponentName,
      Value<String?> difficulty,
      required String resultForPlayer1,
      Value<int?> winnerUserId,
      Value<String?> movesJson,
      Value<DateTime> completedAt,
    });
typedef $$GameHistoryTableUpdateCompanionBuilder =
    GameHistoryCompanion Function({
      Value<int> id,
      Value<int> player1UserId,
      Value<int?> player2UserId,
      Value<String> opponentType,
      Value<String> opponentName,
      Value<String?> difficulty,
      Value<String> resultForPlayer1,
      Value<int?> winnerUserId,
      Value<String?> movesJson,
      Value<DateTime> completedAt,
    });

final class $$GameHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $GameHistoryTable, GameHistoryData> {
  $$GameHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUsersTable _player1UserIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias(
        $_aliasNameGenerator(db.gameHistory.player1UserId, db.appUsers.id),
      );

  $$AppUsersTableProcessedTableManager get player1UserId {
    final $_column = $_itemColumn<int>('player1_user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_player1UserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AppUsersTable _player2UserIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias(
        $_aliasNameGenerator(db.gameHistory.player2UserId, db.appUsers.id),
      );

  $$AppUsersTableProcessedTableManager? get player2UserId {
    final $_column = $_itemColumn<int>('player2_user_id');
    if ($_column == null) return null;
    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_player2UserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AppUsersTable _winnerUserIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias(
        $_aliasNameGenerator(db.gameHistory.winnerUserId, db.appUsers.id),
      );

  $$AppUsersTableProcessedTableManager? get winnerUserId {
    final $_column = $_itemColumn<int>('winner_user_id');
    if ($_column == null) return null;
    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_winnerUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GameHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultForPlayer1 => $composableBuilder(
    column: $table.resultForPlayer1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movesJson => $composableBuilder(
    column: $table.movesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get player1UserId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableFilterComposer get player2UserId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableFilterComposer get winnerUserId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerUserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultForPlayer1 => $composableBuilder(
    column: $table.resultForPlayer1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movesJson => $composableBuilder(
    column: $table.movesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get player1UserId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableOrderingComposer get player2UserId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableOrderingComposer get winnerUserId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerUserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameHistoryTable> {
  $$GameHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultForPlayer1 => $composableBuilder(
    column: $table.resultForPlayer1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movesJson =>
      $composableBuilder(column: $table.movesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$AppUsersTableAnnotationComposer get player1UserId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player1UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableAnnotationComposer get player2UserId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.player2UserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AppUsersTableAnnotationComposer get winnerUserId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.winnerUserId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GameHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameHistoryTable,
          GameHistoryData,
          $$GameHistoryTableFilterComposer,
          $$GameHistoryTableOrderingComposer,
          $$GameHistoryTableAnnotationComposer,
          $$GameHistoryTableCreateCompanionBuilder,
          $$GameHistoryTableUpdateCompanionBuilder,
          (GameHistoryData, $$GameHistoryTableReferences),
          GameHistoryData,
          PrefetchHooks Function({
            bool player1UserId,
            bool player2UserId,
            bool winnerUserId,
          })
        > {
  $$GameHistoryTableTableManager(_$AppDatabase db, $GameHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> player1UserId = const Value.absent(),
                Value<int?> player2UserId = const Value.absent(),
                Value<String> opponentType = const Value.absent(),
                Value<String> opponentName = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String> resultForPlayer1 = const Value.absent(),
                Value<int?> winnerUserId = const Value.absent(),
                Value<String?> movesJson = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => GameHistoryCompanion(
                id: id,
                player1UserId: player1UserId,
                player2UserId: player2UserId,
                opponentType: opponentType,
                opponentName: opponentName,
                difficulty: difficulty,
                resultForPlayer1: resultForPlayer1,
                winnerUserId: winnerUserId,
                movesJson: movesJson,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int player1UserId,
                Value<int?> player2UserId = const Value.absent(),
                required String opponentType,
                required String opponentName,
                Value<String?> difficulty = const Value.absent(),
                required String resultForPlayer1,
                Value<int?> winnerUserId = const Value.absent(),
                Value<String?> movesJson = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => GameHistoryCompanion.insert(
                id: id,
                player1UserId: player1UserId,
                player2UserId: player2UserId,
                opponentType: opponentType,
                opponentName: opponentName,
                difficulty: difficulty,
                resultForPlayer1: resultForPlayer1,
                winnerUserId: winnerUserId,
                movesJson: movesJson,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                player1UserId = false,
                player2UserId = false,
                winnerUserId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (player1UserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.player1UserId,
                                    referencedTable:
                                        $$GameHistoryTableReferences
                                            ._player1UserIdTable(db),
                                    referencedColumn:
                                        $$GameHistoryTableReferences
                                            ._player1UserIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (player2UserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.player2UserId,
                                    referencedTable:
                                        $$GameHistoryTableReferences
                                            ._player2UserIdTable(db),
                                    referencedColumn:
                                        $$GameHistoryTableReferences
                                            ._player2UserIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (winnerUserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.winnerUserId,
                                    referencedTable:
                                        $$GameHistoryTableReferences
                                            ._winnerUserIdTable(db),
                                    referencedColumn:
                                        $$GameHistoryTableReferences
                                            ._winnerUserIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$GameHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameHistoryTable,
      GameHistoryData,
      $$GameHistoryTableFilterComposer,
      $$GameHistoryTableOrderingComposer,
      $$GameHistoryTableAnnotationComposer,
      $$GameHistoryTableCreateCompanionBuilder,
      $$GameHistoryTableUpdateCompanionBuilder,
      (GameHistoryData, $$GameHistoryTableReferences),
      GameHistoryData,
      PrefetchHooks Function({
        bool player1UserId,
        bool player2UserId,
        bool winnerUserId,
      })
    >;
typedef $$PlayerOpponentStatsTableCreateCompanionBuilder =
    PlayerOpponentStatsCompanion Function({
      Value<int> id,
      required int userId,
      required String opponentType,
      Value<String?> difficulty,
      Value<int> gamesPlayed,
      Value<int> wins,
      Value<int> losses,
      Value<int> draws,
    });
typedef $$PlayerOpponentStatsTableUpdateCompanionBuilder =
    PlayerOpponentStatsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> opponentType,
      Value<String?> difficulty,
      Value<int> gamesPlayed,
      Value<int> wins,
      Value<int> losses,
      Value<int> draws,
    });

final class $$PlayerOpponentStatsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlayerOpponentStatsTable,
          PlayerOpponentStat
        > {
  $$PlayerOpponentStatsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AppUsersTable _userIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias(
        $_aliasNameGenerator(db.playerOpponentStats.userId, db.appUsers.id),
      );

  $$AppUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayerOpponentStatsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerOpponentStatsTable> {
  $$PlayerOpponentStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wins => $composableBuilder(
    column: $table.wins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get losses => $composableBuilder(
    column: $table.losses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get draws => $composableBuilder(
    column: $table.draws,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get userId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerOpponentStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerOpponentStatsTable> {
  $$PlayerOpponentStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wins => $composableBuilder(
    column: $table.wins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get losses => $composableBuilder(
    column: $table.losses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get draws => $composableBuilder(
    column: $table.draws,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get userId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerOpponentStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerOpponentStatsTable> {
  $$PlayerOpponentStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opponentType => $composableBuilder(
    column: $table.opponentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wins =>
      $composableBuilder(column: $table.wins, builder: (column) => column);

  GeneratedColumn<int> get losses =>
      $composableBuilder(column: $table.losses, builder: (column) => column);

  GeneratedColumn<int> get draws =>
      $composableBuilder(column: $table.draws, builder: (column) => column);

  $$AppUsersTableAnnotationComposer get userId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerOpponentStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerOpponentStatsTable,
          PlayerOpponentStat,
          $$PlayerOpponentStatsTableFilterComposer,
          $$PlayerOpponentStatsTableOrderingComposer,
          $$PlayerOpponentStatsTableAnnotationComposer,
          $$PlayerOpponentStatsTableCreateCompanionBuilder,
          $$PlayerOpponentStatsTableUpdateCompanionBuilder,
          (PlayerOpponentStat, $$PlayerOpponentStatsTableReferences),
          PlayerOpponentStat,
          PrefetchHooks Function({bool userId})
        > {
  $$PlayerOpponentStatsTableTableManager(
    _$AppDatabase db,
    $PlayerOpponentStatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerOpponentStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerOpponentStatsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlayerOpponentStatsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> opponentType = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> losses = const Value.absent(),
                Value<int> draws = const Value.absent(),
              }) => PlayerOpponentStatsCompanion(
                id: id,
                userId: userId,
                opponentType: opponentType,
                difficulty: difficulty,
                gamesPlayed: gamesPlayed,
                wins: wins,
                losses: losses,
                draws: draws,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String opponentType,
                Value<String?> difficulty = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> wins = const Value.absent(),
                Value<int> losses = const Value.absent(),
                Value<int> draws = const Value.absent(),
              }) => PlayerOpponentStatsCompanion.insert(
                id: id,
                userId: userId,
                opponentType: opponentType,
                difficulty: difficulty,
                gamesPlayed: gamesPlayed,
                wins: wins,
                losses: losses,
                draws: draws,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayerOpponentStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$PlayerOpponentStatsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$PlayerOpponentStatsTableReferences
                                        ._userIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayerOpponentStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerOpponentStatsTable,
      PlayerOpponentStat,
      $$PlayerOpponentStatsTableFilterComposer,
      $$PlayerOpponentStatsTableOrderingComposer,
      $$PlayerOpponentStatsTableAnnotationComposer,
      $$PlayerOpponentStatsTableCreateCompanionBuilder,
      $$PlayerOpponentStatsTableUpdateCompanionBuilder,
      (PlayerOpponentStat, $$PlayerOpponentStatsTableReferences),
      PlayerOpponentStat,
      PrefetchHooks Function({bool userId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> userId,
      Value<String?> bio,
      Value<String?> avatarPath,
      Value<DateTime> updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> userId,
      Value<String?> bio,
      Value<String?> avatarPath,
      Value<DateTime> updatedAt,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppUsersTable _userIdTable(_$AppDatabase db) =>
      db.appUsers.createAlias(
        $_aliasNameGenerator(db.userProfiles.userId, db.appUsers.id),
      );

  $$AppUsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$AppUsersTableTableManager(
      $_db,
      $_db.appUsers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AppUsersTableFilterComposer get userId {
    final $$AppUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableFilterComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppUsersTableOrderingComposer get userId {
    final $$AppUsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableOrderingComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AppUsersTableAnnotationComposer get userId {
    final $$AppUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.appUsers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.appUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfile, $$UserProfilesTableReferences),
          UserProfile,
          PrefetchHooks Function({bool userId})
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                userId: userId,
                bio: bio,
                avatarPath: avatarPath,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                userId: userId,
                bio: bio,
                avatarPath: avatarPath,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserProfilesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserProfilesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfile, $$UserProfilesTableReferences),
      UserProfile,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$GameHistoryTableTableManager get gameHistory =>
      $$GameHistoryTableTableManager(_db, _db.gameHistory);
  $$PlayerOpponentStatsTableTableManager get playerOpponentStats =>
      $$PlayerOpponentStatsTableTableManager(_db, _db.playerOpponentStats);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
