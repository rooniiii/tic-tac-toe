import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/screens/login_screen.dart';
import 'package:tic_tac_toe/screens/signup_screen.dart';
import 'package:tic_tac_toe/security/secure_prefs.dart';

void main() {
  setUp(() => SecurePrefs.setMockInitialValues({}));

  testWidgets('login screen has tooltips on every control', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    for (final message in [
      'Enter your registered email address',
      'Enter your registered password',
      'Show password',
      'Send a password reset link to your email',
      'Log in with your email and password',
      'Create a new NEON XO account',
    ]) {
      expect(find.byTooltip(message), findsOneWidget, reason: message);
    }

    // Let the screen's start-up timers finish before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('sign-up screen has tooltips on every control', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    for (final message in [
      'Back to login',
      'Only letters, 3 to 40 characters',
      'Enter a valid email address',
      'Choose your country, then enter your mobile number',
      'Must match the password above',
      'Create your NEON XO account',
      'Go back to the login screen',
    ]) {
      expect(find.byTooltip(message), findsOneWidget, reason: message);
    }
    expect(find.byTooltip('Show password'), findsNWidgets(2));
  });
}
