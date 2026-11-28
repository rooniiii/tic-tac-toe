import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_toe/security/secure_prefs.dart';

void main() {
  test('moves old plain values into secure storage and wipes the plain file',
      () async {
    SecurePrefs.setMockInitialValues({
      'offline_phone_a@b.com': '+15550001',
      'login_fails_a@b.com': 2,
      'sound': false,
    });

    final prefs = await SecurePrefs.getInstance();

    expect(prefs.getString('offline_phone_a@b.com'), '+15550001');
    expect(prefs.getInt('login_fails_a@b.com'), 2);
    expect(prefs.getBool('sound'), false);

    final plain = await SharedPreferences.getInstance();
    expect(plain.getKeys(), isEmpty);

    final stored = await const FlutterSecureStorage().readAll();
    expect(stored.keys, ['neon_xo_prefs_v1']);
    expect(stored.values.single, contains('+15550001'));
  });

  test('set and remove are saved to secure storage', () async {
    SecurePrefs.setMockInitialValues({});
    final prefs = await SecurePrefs.getInstance();

    await prefs.setString('k', 'v');
    expect(
      await const FlutterSecureStorage().read(key: 'neon_xo_prefs_v1'),
      contains('"k":"v"'),
    );

    await prefs.remove('k');
    expect(prefs.getString('k'), isNull);
  });
}
