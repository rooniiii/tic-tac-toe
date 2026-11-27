import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tic_tac_toe/logic/auth/login_attempt_limiter.dart';
import 'package:tic_tac_toe/logic/auth/password_hasher.dart';
import 'package:tic_tac_toe/logic/validators.dart';
import 'package:tic_tac_toe/models/user_stats.dart';

void main() {
  group('Validators', () {
    test('name', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('Al'), isNotNull);
      expect(Validators.name('Ali 2'), isNotNull);
      expect(Validators.name('a' * 41), isNotNull);
      expect(Validators.name('Ali Khan'), isNull);
    });

    test('email, including the 254 character limit', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b.co'), isNull);
      final tooLong = '${'a' * 250}@b.co';
      expect(Validators.email(tooLong), contains('254'));
    });

    test('password rules', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('short1!A'), isNull);
      expect(Validators.password('alllowercase1!'), isNotNull);
      expect(Validators.password('NoDigits!!'), isNotNull);
      expect(Validators.password('NoSpecial123'), isNotNull);
      expect(Validators.password('Aa1!${'x' * 40}'), isNotNull);
    });

    test('confirm password', () {
      expect(Validators.confirmPassword('', 'Abc123!x'), isNotNull);
      expect(Validators.confirmPassword('Abc123!y', 'Abc123!x'), isNotNull);
      expect(Validators.confirmPassword('Abc123!x', 'Abc123!x'), isNull);
    });
  });

  group('PasswordHasher', () {
    test('hash verifies with the right password only', () {
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash('Secret123!', salt);

      expect(hash, startsWith('pbkdf2-sha256\$'));
      expect(PasswordHasher.verify('Secret123!', salt, hash), isTrue);
      expect(PasswordHasher.verify('secret123!', salt, hash), isFalse);
      expect(PasswordHasher.verify('Secret123!', 'other', hash), isFalse);
      expect(PasswordHasher.verify('Secret123!', salt, ''), isFalse);
    });

    test('salts are random', () {
      expect(PasswordHasher.generateSalt(), isNot(PasswordHasher.generateSalt()));
    });

    test('new hashes do not need an upgrade', () {
      final hash = PasswordHasher.hash('x', PasswordHasher.generateSalt());
      expect(PasswordHasher.needsUpgrade(hash), isFalse);
      expect(PasswordHasher.needsUpgrade('abcdef0123'), isTrue);
    });
  });

  group('LoginAttemptLimiter', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('locks after 3 wrong passwords and clear unlocks', () async {
      final limiter = LoginAttemptLimiter();
      const email = 'Player@Example.com';

      expect(await limiter.checkLock(email), isNull);

      final first = await limiter.recordFailure(email, 'Wrong');
      expect(first, contains('2 attempt(s) remaining'));
      await limiter.recordFailure(email, 'Wrong');
      final third = await limiter.recordFailure(email, 'Wrong');
      expect(third, contains('locked'));

      // Same account regardless of case / spaces.
      expect(await limiter.checkLock(' player@example.com '), isNotNull);

      await limiter.clear(email);
      expect(await limiter.checkLock(email), isNull);
    });
  });

  group('UserStats', () {
    test('addResult counts results and keeps the best score', () {
      final stats = const UserStats()
          .addResult('win', 30)
          .addResult('loss', 10)
          .addResult('draw', 0);

      expect(stats.played, 3);
      expect(stats.wins, 1);
      expect(stats.losses, 1);
      expect(stats.draws, 1);
      expect(stats.bestScore, 30);
    });

    test('toMap / fromMap round trip', () {
      const stats = UserStats(played: 5, wins: 3, losses: 1, draws: 1, bestScore: 90);
      final copy = UserStats.fromMap(stats.toMap());
      expect(copy.toMap(), stats.toMap());
      expect(UserStats.fromMap({}).played, 0);
    });
  });
}
