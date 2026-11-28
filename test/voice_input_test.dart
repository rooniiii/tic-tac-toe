import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/screens/ai_assistant_screen.dart';
import 'package:tic_tac_toe/security/secure_prefs.dart';

void main() {
  setUp(() {
    SecurePrefs.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // A phone with no speech recogniser (or microphone access denied):
    // initialize answers false.
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugin.csdcorp.com/speech_to_text'),
      (call) async => call.method == 'initialize' ? false : null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => 1,
    );
  });

  // One test only: the voice services are app-wide singletons, so a second
  // widget test would inherit unfinished calls from the first one.
  testWidgets('mic button in the input box; explains when unavailable',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantScreen()));

    expect(find.byTooltip('Speak your question'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);

    await tester.tap(find.byTooltip('Speak your question'));
    // Let the plugin calls (real futures) finish, then draw the result.
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 100),
        ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Voice input is not available'), findsOneWidget);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });
}
