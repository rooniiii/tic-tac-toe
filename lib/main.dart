import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/account_status_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check - Android Debug Mode
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

// Lets services outside the widget tree show dialogs and change screens.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<String>? _blockedSub;
  bool _showingBlockedDialog = false;

  @override
  void initState() {
    super.initState();
    _blockedSub =
        AccountStatusService.instance.onBlocked.listen(_onAccountBlocked);
  }

  @override
  void dispose() {
    _blockedSub?.cancel();
    super.dispose();
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