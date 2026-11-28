import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'logic/auth/session_manager.dart';
import 'logic/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/account_status_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check: release builds prove they are the real app from
  // Google Play (Play Integrity). Debug builds use the debug provider so
  // developers can still run the app; register the debug token printed in
  // logcat in the Firebase Console.
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  );

  runApp(const MyApp());
}

// Lets services outside the widget tree show dialogs and change screens.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Tells the player why they are back on the login screen.
void showSessionExpiredMessage() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = appNavigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text(AuthService.sessionExpiredMessage),
        duration: Duration(seconds: 5),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<String>? _blockedSub;
  bool _showingBlockedDialog = false;
  bool _checkingSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _blockedSub =
        AccountStatusService.instance.onBlocked.listen(_onAccountBlocked);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blockedSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // Remember when the game was last used; the app may be killed now.
        unawaited(SessionManager.instance.touch());
      case AppLifecycleState.resumed:
        unawaited(_checkSessionOnResume());
      default:
        break;
    }
  }

  /// The game may have been in the background longer than the limits set
  /// by admins (Session Settings). Start-up is checked by the splash screen.
  Future<void> _checkSessionOnResume() async {
    if (_checkingSession) return;
    _checkingSession = true;
    try {
      await SessionManager.instance.refreshPolicy();
      final state = await SessionManager.instance.check();
      if (state == SessionState.missing) return; // not logged in

      if (state == SessionState.valid) {
        await SessionManager.instance.touch();
        return;
      }

      await AuthService().logout();
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      showSessionExpiredMessage();
    } catch (e) {
      debugPrint('Session check on resume failed: $e');
    } finally {
      _checkingSession = false;
    }
  }

  // The player was blocked by an admin while using the app: they are already
  // signed out, so show why and send them back to the login screen.
  Future<void> _onAccountBlocked(String message) async {
    final navigatorContext = appNavigatorKey.currentContext;
    if (navigatorContext == null || _showingBlockedDialog) return;

    _showingBlockedDialog = true;

    await showDialog<void>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account Unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _showingBlockedDialog = false;

    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
