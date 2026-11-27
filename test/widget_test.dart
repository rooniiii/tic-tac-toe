import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tic_tac_toe/main.dart';
import 'package:tic_tac_toe/screens/login_screen.dart';
import 'package:tic_tac_toe/screens/splash_screen.dart';

/// Smoke test of the real app root without Firebase: the splash screen
/// shows, the session restore fails safely (no Firebase, no saved session)
/// and the player lands on the login screen.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // flutter_tts has no implementation in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
  });

  testWidgets('NEON XO app starts on the splash and moves to login',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
    // This is the game, not the admin panel.
    expect(find.text('ADMIN PANEL'), findsNothing);

    // Splash waits 3 s, then restores the session and fades to the next page.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
