import 'package:tic_tac_toe/security/secure_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/logic/auth/session_manager.dart';
import 'package:tic_tac_toe/logic/input_sanitizer.dart';
import 'package:tic_tac_toe/logic/level_progress_service.dart';
import 'package:tic_tac_toe/models/difficulty.dart';
import 'package:tic_tac_toe/services/house_ad_service.dart';

void main() {
  setUp(() => SecurePrefs.setMockInitialValues({}));

  group('LevelProgressService', () {
    final service = LevelProgressService();
    const phone = '+10000000000';

    test('new player starts at level 1', () async {
      expect(await service.currentLevel(phone, Difficulty.medium), 1);
    });

    test('winning advances one level, per difficulty', () async {
      await service.recordWin(phone, Difficulty.medium, 1);
      await service.recordWin(phone, Difficulty.medium, 2);
      expect(await service.currentLevel(phone, Difficulty.medium), 3);
      expect(await service.currentLevel(phone, Difficulty.hard), 1);
    });

    test('replaying an old level never moves progress back', () async {
      await service.recordWin(phone, Difficulty.easy, 10);
      await service.recordWin(phone, Difficulty.easy, 2);
      expect(await service.currentLevel(phone, Difficulty.easy), 11);
    });

    test('level 1000 completes the track and restarts at 1', () async {
      await service.recordWin(phone, Difficulty.hard, 999);
      expect(await service.currentLevel(phone, Difficulty.hard), 1000);

      final finished = await service.recordWin(phone, Difficulty.hard, 1000);
      expect(finished, isTrue);
      expect(await service.currentLevel(phone, Difficulty.hard), 1);
    });

    test('stored values are clamped to 1..1000', () async {
      SecurePrefs.setMockInitialValues({'level_${phone}_easy': 5000});
      expect(await service.currentLevel(phone, Difficulty.easy), 1000);
    });
  });

  group('SessionManager', () {
    final session = SessionManager.instance;

    test('missing, then valid after start, then gone after clear', () async {
      expect(await session.check(), SessionState.missing);
      await session.start();
      expect(await session.check(), SessionState.valid);
      await session.clear();
      expect(await session.check(), SessionState.missing);
    });

    test('expires after the idle timeout', () async {
      final now = DateTime.now();
      final old = now.subtract(SessionManager.idleTimeout + const Duration(hours: 1));
      SecurePrefs.setMockInitialValues({
        'session_token': 'abc',
        'session_issued_at': old.millisecondsSinceEpoch,
        'session_last_active': old.millisecondsSinceEpoch,
      });
      expect(await session.check(), SessionState.expired);
    });

    test('expires after the absolute lifetime even if active', () async {
      final now = DateTime.now();
      SecurePrefs.setMockInitialValues({
        'session_token': 'abc',
        'session_issued_at': now
            .subtract(SessionManager.maxSessionAge + const Duration(days: 1))
            .millisecondsSinceEpoch,
        'session_last_active': now.millisecondsSinceEpoch,
      });
      expect(await session.check(), SessionState.expired);
    });
  });

  group('InputSanitizer', () {
    test('removes control characters and limits length', () {
      expect(InputSanitizer.clean('  he\u0000llo\u0007 ', maxLength: 10), 'hello');
      expect(InputSanitizer.clean('a' * 600, maxLength: 500).length, 500);
    });

    test('accepts only https URLs', () {
      expect(InputSanitizer.isSafeHttpsUrl('https://example.com/a.png'), isTrue);
      expect(InputSanitizer.isSafeHttpsUrl('http://example.com/a.png'), isFalse);
      expect(InputSanitizer.isSafeHttpsUrl('javascript:alert(1)'), isFalse);
      expect(InputSanitizer.isSafeHttpsUrl('https://x.com/${'a' * 600}'), isFalse);
    });
  });

  group('HouseAd', () {
    test('defaults to a 15 second countdown and clamps bad values', () {
      expect(HouseAd.fromMap('1', {'title': 'A'}).countdownSeconds, 15);
      expect(
        HouseAd.fromMap('1', {'title': 'A', 'countdownSeconds': 999}).countdownSeconds,
        HouseAd.maxCountdown,
      );
      expect(
        HouseAd.fromMap('1', {'title': 'A', 'imageUrl': 'http://x.com'}).imageUrl,
        isNull,
      );
    });

    test('plays before every 3rd level', () {
      final ads = HouseAdService.instance;
      expect(ads.shouldShowBeforeLevel(2), isFalse);
      expect(ads.shouldShowBeforeLevel(4), isTrue);
      expect(ads.shouldShowBeforeLevel(7), isTrue);
      expect(ads.shouldShowBeforeLevel(8), isFalse);
    });
  });
}
